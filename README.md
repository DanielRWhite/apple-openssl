# Apple OpenSSL static/dynamic libraries & development source files
OpenSSL build script &amp; built library archives using different versions of OpenSSL for Mac/iOS development

# Releases
Pre-built libraries & development source files are tagged against the OpenSSL versions in [releases](https://github.com/DanielRWhite/apple-openssl/releases). They are bundled based on the platform & architecture they were built for. **Please note**, if you are needing iOS Simulator OpenSSL libraries and you are running on an Apple Silicon Mac, you need the `openssl-<version>-ios-arm64.tar.gz` release.

# How to run locally
## Prerequisites
 * A Mac device
 * Latest Xcode, command line tools, iOS & MacOS SDKs installed & updated
 * Atleast 1GB of disk space to be safe (Actual library files are ~20MB for MacOS & ~30MB for iOS when finished for each platform/architecture combination built)
 * ~30 minutes

## Instructions
It is best to add this repo as a submodule in a folder inside your own repo. To do that, create the parent directory where you want to put the submodule, for instance `deps` in your git project root, and run `git submodule add https://github.com/DanielRWhite/apple-openssl deps/apple` to add the submodule to your repo under `deps/apple`.

Once the submodule is installed, you will get all future updates & changes if anything breaks, or your can pin the submodule against a specific commit hash known to work with the MacOS/iOS version(s) you are developing for.

To build the libraries, `cd deps/apple` (or where you installed the submodule to) first, then `bash build.sh`. This will then build OpenSSL for all possible architectures on MacOS & iOS. If you don't need all of them, feel free to go into `build.sh` file, and comment out the platform/arch you don't need.

## Once build is finished
Once the build is finished, the `deps/apple/.cache` directory will be removed, cleaning up any space that was taken up during the build phase, and you will be left with a combination of `libs/<platform>/<arch>` folders.

### MacOS (Apple Silicon) OpenSSL libraries & development source files
```bash
export YOUR_ENV_VAR=deps/apple/libs/macos/arm64
```

### MacOS (Non Apple Silicon) OpenSSL libraries & development source files
```bash
export YOUR_ENV_VAR=deps/apple/libs/macos/x86_64
```

### iOS (armv7) OpenSSL libraries & development source files
```bash
export YOUR_ENV_VAR=deps/apple/libs/ios/armv7
```

### iOS (arm64)/iOS Simulator (Running on Apple Silicon Mac) OpenSSL libraries & development source files
```bash
export YOUR_ENV_VAR=deps/apple/libs/ios/arm64
```

### iOS Simulator (Running on Non Apple Silicon Mac) OpenSSL libraries & development source files
```bash
export YOUR_ENV_VAR=deps/apple/libs/ios/x86_64
```
