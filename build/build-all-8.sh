#!/bin/bash
# ------------------------------------------------------------------
# busybox 1.38.0 -> 8 个全静态单文件（Linux musl 4 个 + Android NDK 4 个）
#
# 用法:
#   ./build-all-8.sh                     # 全部 8 个
#   ONLY=android_arm64 ./build-all-8.sh  # 只编一个（调试用）
#
# 需要的环境变量（都有默认值，按需覆盖）:
#   SRC         已打补丁的源码目录（默认 ./busybox-1.38.0；不存在则从 PATCHED_TGZ 解压）
#   PATCHED_TGZ 已打补丁源码包（默认 ./busybox-1.38.0-full-compat-src.tar.gz）
#   CFG         你的 .config（默认 ./user.config）
#   NB          NDK 的 bin 目录
#   ZIG         zig 可执行文件（Linux 组用）
#   OUT         产物目录（默认 ./bins）
#   W           构建工作区（默认 /tmp/bb-build）
# ------------------------------------------------------------------
set -u

SRC=${SRC:-./busybox-1.38.0}
PATCHED_TGZ=${PATCHED_TGZ:-./busybox-1.38.0-full-compat-src.tar.gz}
CFG=${CFG:-./user.config}
NB=${NB:-$HOME/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin}
ZIG=${ZIG:-zig}
OUT=${OUT:-./bins}
W=${W:-/tmp/bb-build}
ONLY=${ONLY:-}

die() { echo "错误: $*" >&2; exit 1; }

[ -x "$NB/aarch64-linux-android24-clang" ] || die "找不到 NDK 编译器，请设置 NB（当前: $NB）"
[ -x "$NB/llvm-strip" ] || die "找不到 $NB/llvm-strip"
[ -f "$CFG" ] || die "找不到 config: $CFG"

# ---- 0) 准备源码 ----
mkdir -p "$W"
if [ ! -d "$SRC" ]; then
	echo "==> 解压已打补丁的源码包：$PATCHED_TGZ"
	[ -f "$PATCHED_TGZ" ] || die "既没有 $SRC，也没有 $PATCHED_TGZ"
	mkdir -p "$W/src"
	tar xf "$PATCHED_TGZ" -C "$W/src" || die "解压失败"
	SRC="$W/src/busybox-1.38.0"
fi
SRC=$(cd "$SRC" && pwd)

# Linux 组要用的树：去掉 Android 专用垫片头（避免和 musl 自己的头冲突）
LINUX_SRC="$W/src-linux"
rm -rf "$LINUX_SRC"
cp -a "$SRC" "$LINUX_SRC"
rm -f "$LINUX_SRC/include/sys/kd.h"  "$LINUX_SRC/include/netinet/ether.h" \
      "$LINUX_SRC/include/sys/shm.h" "$LINUX_SRC/include/sys/sem.h" \
      "$LINUX_SRC/include/sys/msg.h"

# ---- 1) 每个目标一份独立构建目录（绝不共用，否则互相删文件） ----
prep() { # $1=名字 $2=源码树
	rm -rf "$W/build-$1"
	cp -a "$2" "$W/build-$1" || die "复制构建目录失败: $1"
	cp "$CFG" "$W/build-$1/.config"
	# 仅两处让步：bionic 与 musl 都没有 Sun RPC（libtirpc）
	sed -i -e 's/^CONFIG_FEATURE_INETD_RPC=y/# CONFIG_FEATURE_INETD_RPC is not set/' \
	       -e 's/^CONFIG_FEATURE_MOUNT_NFS=y/# CONFIG_FEATURE_MOUNT_NFS is not set/' \
	       "$W/build-$1/.config"
}

build() { # $1=名字 $2=ARCH $3=CC $4=输出名
	if [ -n "$ONLY" ] && [ "$ONLY" != "$1" ]; then return 0; fi
	echo "==> $4"
	( cd "$W/build-$1" && make -j"$(nproc)" ARCH=$2 CC="$3" STRIP="$NB/llvm-strip" ) \
		> "$W/$1.log" 2>&1
	if [ $? -ne 0 ] || [ ! -f "$W/build-$1/busybox" ]; then
		echo "   × 失败，日志: $W/$1.log"
		grep -m3 -iE "error:|undefined reference|duplicate symbol|No such file" "$W/$1.log" | sed 's/^/     /'
		return 1
	fi
	cp "$W/build-$1/busybox" "$OUT/$4"
	printf "   ✓ %s  %s 字节  align=%s\n" "$4" "$(stat -c%s "$OUT/$4")" \
		"$(readelf -lW "$OUT/$4" | awk '/LOAD/{print $NF}' | sort -u | tr '\n' ',')"
}

mkdir -p "$OUT"
prep android_arm64  "$SRC"
prep android_arm    "$SRC"
prep android_x86    "$SRC"
prep android_x86_64 "$SRC"
prep linux_arm64    "$LINUX_SRC"
prep linux_armhf    "$LINUX_SRC"
prep linux_x86      "$LINUX_SRC"
prep linux_x86_64   "$LINUX_SRC"

FAIL=0
build android_arm64  arm64  "$NB/aarch64-linux-android24-clang"    busybox-android-arm64 || FAIL=1
build android_arm    arm    "$NB/armv7a-linux-androideabi24-clang" busybox-android-arm   || FAIL=1
build android_x86    i386   "$NB/i686-linux-android24-clang"      busybox-android-x86   || FAIL=1
build android_x86_64 x86_64 "$NB/x86_64-linux-android24-clang"    busybox-android-x64   || FAIL=1
build linux_arm64    arm64  "$ZIG cc -target aarch64-linux-musl"  busybox-linux-arm64   || FAIL=1
build linux_armhf    arm    "$ZIG cc -target arm-linux-musleabihf" busybox-linux-armhf  || FAIL=1
build linux_x86      i386   "$ZIG cc -target x86-linux-musl"      busybox-linux-x86     || FAIL=1
build linux_x86_64   x86_64 "$ZIG cc -target x86_64-linux-musl"   busybox-linux-x64     || FAIL=1

echo
echo "产物目录: $OUT"
ls -l "$OUT" 2>/dev/null
[ -n "$ONLY" ] && exit $FAIL

# ---- 2) 总校验：静态 / 无解释器 / 16K 对齐 ----
echo
echo "==> 校验（静态链接 / 无 INTERP / 16K 对齐）"
for f in "$OUT"/busybox-*; do
	[ -f "$f" ] || continue
	name=$(basename "$f")
	ok=1
	readelf -d "$f" 2>/dev/null | grep -q "no dynamic section" || ok=0
	[ "$(readelf -lW "$f" 2>/dev/null | grep -c INTERP)" -eq 0 ] || ok=0
	align=$(readelf -lW "$f" 2>/dev/null | awk '/LOAD/{print $NF}' | sort -u | tr '\n' ',')
	[ "$align" = "0x4000," ] || ok=0
	[ $ok -eq 1 ] && echo "  ✓ $name  align=$align" || echo "  × $name  align=$align"
done

if [ $FAIL -ne 0 ]; then
	echo; echo "有目标失败，日志在 $W/*.log"; exit 1
fi
echo
echo "全部完成。把 busybox-* 拷到目标机后，改名或软链成 busybox 再执行。"
