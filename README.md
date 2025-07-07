
# CRIU Static

This repository is born out of the necessity of having a statically linked
[CRIU](https://github.com/checkpoint-restore/criu) binary and a statically linked [libcriu](https://criu.org/C_API).

You can find pre-built binaries in the [Releases](https://github.com/seqeralabs/criu-static/releases) page.

## Limitations

This static build does not ship (yet, if you want to help, raise an hand 🙋):

- `plugins/amdgpu`;
- `plugins/cuda`;


In addition, shipping `lib/pycriu` is probably pointless for this repository but
having it will make the final artifact more complete.


## Build

We only tested this in Alpine Linux, building on other Linux distributions should work
but the instructions below should work on most major linux distros.

We didn't put any code against building with other libc implementations and building works fine with glibc, however
this repository will include the musl license in case the main compiler used to build this project uses musl as toolchain.

### Build Dependencies

**Alpine Linux**

```bash
apk update
apk add cmake make clang llvm git autoconf automake libtool m4 flex bison pkgconfig bash linux-headers patch coreutils gettext gettext-dev
```

### Configure

```bash
cmake --preset static-release
```

### Build

```bash
cmake --build --preset static-release
```

### Install or Package

You can install directly

```bash
sudo cmake --install build
```

OR we can build a package to install on another system.

```bash
cpack --config build/CPackConfig.cmake --verbose -B dist -G STGZ
```


## License

As it is derived from CRIU, this work is released  GNU General Public License version 2. See `COPYING`.

All the dependencies, along with their own licenses and their source code are bundled in the final artifact that gets built from this repository.
See the `Build` section of this README.
