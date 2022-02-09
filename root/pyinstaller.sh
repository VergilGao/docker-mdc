#!/bin/sh
# Simple wrapper around pyinstaller

set -e

# Use the hacked ldd to fix libc.musl-x86_64.so.1 location
PATH="/pyinstaller:$PATH"

# Exclude pycrypto and PyInstaller from built packages
exec pyinstaller "$@"