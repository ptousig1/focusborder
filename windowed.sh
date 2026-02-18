#!/usr/bin/env bash

export QT_LOGGING_RULES="kwin*.debug=true;kwin*.warning=true"
export KWIN_COMPOSE=O2
export KWIN_FORCE_OWN_LOGGING=1
export KWIN_BIN=/home/ptousig/Projects/kwin-dev/bin/kwin_wayland
# export KWIN_WRAPPER_BIN=/home/ptousig/Projects/kwin-dev/bin/kwin_wayland_wrapper
export PATH=/home/ptousig/Projects/kwin-dev/bin:/usr/local/sbin:/usr/local/bin:/usr/bin
# ~/Projects/kwin-dev/bin/kwin_wayland --xwayland --width 1600 --height 900 --exit-with-session=/usr/bin/konsole
export WAYLAND_DISPLAY=kwin-nested-1

systemd-run --user --scope --quiet \
	env -i \
	XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
	HOME="$HOME" \
	PATH="$PATH" \
	KWIN_BIN="$KWIN_BIN" \
	KWIN_WRAPPER_BIN="$KWIN_WRAPPER_BIN" \
	WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
	startplasma-wayland --nested
	
# /usr/bin/startplasma-wayland --xwayland --nested
