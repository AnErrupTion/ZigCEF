# ZigCEF

ZigCEF is a simple example on how to use CEF with Zig.

## CEF version

The latest known working version of CEF for ZigCEF is **116.0.21+g9c7dc32**.

## Build

1. Download a minimal CEF build for your platform [here](https://cef-builds.spotifycdn.com/index.html) and extract it.
2. Copy ``include`` to ``cef/include``.
3. Copy everything inside ``Release`` and ``Resources`` to ``cef/binaries``.
4. Build the project using ``zig build copy-bin``.
5. On Linux, go to the ``zig-out/bin`` directory, then run the sample using ``LD_LIBRARY_PATH=. ./ZigCEF``.