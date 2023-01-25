# Cross Dockerfiles

Custom Dockerfiles compatible with [cross](https://github.com/cross-rs/cross).

## Usage

You can use it in cross dockerfiles for example one where you want to compile a Rust egui app.

```dockerfile
FROM ghcr.io/stevenliebregt/cross-raspberry-pi:main

RUN dpkg --add-architecture armhf
RUN apt-get update && apt-get -y install libfontconfig1-dev:armhf

ENV PKG_CONFIG_PATH="/usr/lib/arm-linux-gnueabihf/pkgconfig/:${PKG_CONFIG_PATH}"
```

## Credits

Uses build scripts and dockerfiles from cross.