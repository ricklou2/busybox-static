# busybox — Fully Static Build (8 targets)

**Languages:** [English](#english) | [简体中文](#简体中文) | [繁體中文](#繁體中文)

---

## English

A standalone, fully static build of **busybox**, a single-binary Swiss-army knife of Unix utilities. Eight executables are provided — four for Linux (musl) and four for Android (NDK, API 24) — together with the upstream source and build scripts. The binaries have no dynamic interpreter and no shared-library dependencies, and are aligned to 16 KB pages, so they run on Android phones (Android 7–16), embedded devices, and minimal Linux systems.

**Upstream version:** 1.38.0

### Executables

| File | Size | MD5 |
|---|---:|---|
| busybox-android-arm | 1,580,196 B | `ed733ec6d479e97f2f1b7923d97c3d65` |
| busybox-android-arm64 | 1,666,944 B | `a4662993d63707e0f5a6f208b06d9d70` |
| busybox-android-x64 | 1,670,968 B | `d7017f56859fb28428bb446dc1a38e29` |
| busybox-android-x86 | 1,759,852 B | `d558d36c51d63556c792ed9774246206` |
| busybox-linux-arm64 | 1,356,368 B | `0740446379846304d2c75968807a3aa7` |
| busybox-linux-armhf | 1,430,840 B | `641049eef01279bdfca82a4c02b83c3f` |
| busybox-linux-x64 | 1,339,016 B | `fe70b50c68de15faebde56da47029fdc` |
| busybox-linux-x86 | 1,283,364 B | `74f649fc17795e98f46612428892c635` |

### Static verification

```bash
readelf -l <binary> | grep -c INTERP   # 0
readelf -l <binary> | grep LOAD        # align 0x4000 (16 KB)
file <binary>                         # statically linked
```

### Install and run

```bash
# Linux
install -m755 bins/busybox-linux-x64 /usr/local/bin/busybox
busybox

# Android (via adb)
adb push bins/busybox-android-arm64 /data/local/tmp/busybox
adb shell "chmod 755 /data/local/tmp/busybox"
adb shell "/data/local/tmp/busybox"
```

### Repository layout

```
bins/     Eight executables (linux & android, x64/x86/arm64/arm)
build/    Build scripts
patches/  Patches
src/      Upstream source
```

### Offline build

The source and build scripts are included for fully offline reproduction. The Linux targets use zig (musl cross-compilation) and the Android targets use the NDK (API 24):

```bash
# Run the bundled build script (see build/)
sh build/build-all-8.sh
```

| Target | Linux triple | Android triple |
|---|---|---|
| x64 | x86_64-linux-musl | x86_64-linux-android24 |
| x86 | x86-linux-musl | i686-linux-android24 |
| arm64 | aarch64-linux-musl | aarch64-linux-android24 |
| arm | arm-linux-musleabihf | armv7a-linux-androideabi24 |

---

## 简体中文

**busybox** 的独立全静态构建包，集众多 Unix 工具于一身的单文件工具箱。共提供 8 个可执行文件——Linux（musl）4 个、Android（NDK，API 24）4 个，并附上游源码与构建脚本。可执行文件无动态解释器、无共享库依赖，按 16 KB 页对齐，可在安卓手机（Android 7–16）、嵌入式设备和精简 Linux 系统上运行。

**上游版本：**1.38.0

### 可执行文件

| 文件 | Size | MD5 |
|---|---:|---|
| busybox-android-arm | 1,580,196 B | `ed733ec6d479e97f2f1b7923d97c3d65` |
| busybox-android-arm64 | 1,666,944 B | `a4662993d63707e0f5a6f208b06d9d70` |
| busybox-android-x64 | 1,670,968 B | `d7017f56859fb28428bb446dc1a38e29` |
| busybox-android-x86 | 1,759,852 B | `d558d36c51d63556c792ed9774246206` |
| busybox-linux-arm64 | 1,356,368 B | `0740446379846304d2c75968807a3aa7` |
| busybox-linux-armhf | 1,430,840 B | `641049eef01279bdfca82a4c02b83c3f` |
| busybox-linux-x64 | 1,339,016 B | `fe70b50c68de15faebde56da47029fdc` |
| busybox-linux-x86 | 1,283,364 B | `74f649fc17795e98f46612428892c635` |

### 静态性核验

```bash
readelf -l <二进制> | grep -c INTERP   # 0
readelf -l <二进制> | grep LOAD        # align 0x4000（16 KB）
file <二进制>                         # statically linked
```

### 安装与运行

```bash
# Linux
install -m755 bins/busybox-linux-x64 /usr/local/bin/busybox
busybox

# Android（通过 adb）
adb push bins/busybox-android-arm64 /data/local/tmp/busybox
adb shell "chmod 755 /data/local/tmp/busybox"
adb shell "/data/local/tmp/busybox"
```

### 仓库结构

```
bins/     八个可执行文件（linux 与 android，x64/x86/arm64/arm）
build/    构建脚本
patches/  补丁
src/      上游源码
```

### 离线编译

源码与构建脚本已包含，可完全离线复现。Linux 目标使用 zig（musl 交叉编译），Android 目标使用 NDK（API 24）：

```bash
# 运行附带的构建脚本（见 build/）
sh build/build-all-8.sh
```

| 目标 | Linux triple | Android triple |
|---|---|---|
| x64 | x86_64-linux-musl | x86_64-linux-android24 |
| x86 | x86-linux-musl | i686-linux-android24 |
| arm64 | aarch64-linux-musl | aarch64-linux-android24 |
| arm | arm-linux-musleabihf | armv7a-linux-androideabi24 |

---

## 繁體中文

**busybox** 的獨立全靜態建構包，集眾多 Unix 工具於一身的單檔案工具箱。共提供 8 個可執行檔——Linux（musl）4 個、Android（NDK，API 24）4 個，並附上游原始碼與建構腳本。可執行檔無動態直譯器、無共用程式庫相依性，按 16 KB 頁對齊，可在安卓手機（Android 7–16）、嵌入式裝置和精簡 Linux 系統上執行。

**上游版本：**1.38.0

### 可執行檔

| 檔案 | Size | MD5 |
|---|---:|---|
| busybox-android-arm | 1,580,196 B | `ed733ec6d479e97f2f1b7923d97c3d65` |
| busybox-android-arm64 | 1,666,944 B | `a4662993d63707e0f5a6f208b06d9d70` |
| busybox-android-x64 | 1,670,968 B | `d7017f56859fb28428bb446dc1a38e29` |
| busybox-android-x86 | 1,759,852 B | `d558d36c51d63556c792ed9774246206` |
| busybox-linux-arm64 | 1,356,368 B | `0740446379846304d2c75968807a3aa7` |
| busybox-linux-armhf | 1,430,840 B | `641049eef01279bdfca82a4c02b83c3f` |
| busybox-linux-x64 | 1,339,016 B | `fe70b50c68de15faebde56da47029fdc` |
| busybox-linux-x86 | 1,283,364 B | `74f649fc17795e98f46612428892c635` |

### 靜態性核驗

```bash
readelf -l <可執行檔> | grep -c INTERP   # 0
readelf -l <可執行檔> | grep LOAD        # align 0x4000（16 KB）
file <可執行檔>                         # statically linked
```

### 安裝與執行

```bash
# Linux
install -m755 bins/busybox-linux-x64 /usr/local/bin/busybox
busybox

# Android（透過 adb）
adb push bins/busybox-android-arm64 /data/local/tmp/busybox
adb shell "chmod 755 /data/local/tmp/busybox"
adb shell "/data/local/tmp/busybox"
```

### 倉庫結構

```
bins/     八個可執行檔（linux 與 android，x64/x86/arm64/arm）
build/    建構腳本
patches/  修補程式
src/      上游原始碼
```

### 離線建構

原始碼與建構腳本已包含，可完全離線重現。Linux 目標使用 zig（musl 交叉編譯），Android 目標使用 NDK（API 24）：

```bash
# 執行附帶的建構腳本（見 build/）
sh build/build-all-8.sh
```

| 目標 | Linux triple | Android triple |
|---|---|---|
| x64 | x86_64-linux-musl | x86_64-linux-android24 |
| x86 | x86-linux-musl | i686-linux-android24 |
| arm64 | aarch64-linux-musl | aarch64-linux-android24 |
| arm | arm-linux-musleabihf | armv7a-linux-androideabi24 |
