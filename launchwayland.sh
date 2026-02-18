#!/usr/bin/env bash
PATH=/home/ptousig/Projects/kwin-dev/bin:/usr/local/sbin:/usr/local/bin:/usr/bin
exec systemd-run --user --scope --unit=plasma-session /usr/bin/startplasma-wayland
