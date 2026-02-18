#!/usr/bin/env bash
set -e

cmake --build build -j8
cp build/bin/kwin_wayland ../kwin-dev/bin
echo Build succeeded!
