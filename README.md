# focusborder
KWin plugin to highlight active window

I will attempt to document the journey of creating a KWin effects plugin.

My previous attempt failed miserably, so I am starting over with an approach centered around "baby steps".
Many of those steps will feel pointless to many experience Linux programmers, but I believe it will be
more educational this way.

## Step 1: Create an alternate KDE desktop

Since it appears that my KWin effects will need to be built into the kwin_wayload binary itself, I need
a way to launch KDE with modified binaries. And if anything goes wrong, I want to be able to log back
into a unmodified desktop environment.

The .desktop files live in /usr/share/wayland-sessions
It initially contained plasma.desktop.
I am adding kwin-dev.desktop with the following content:

	[Desktop Entry]
	Name=KWin Dev Session
	Comment=Run Plasma with custom KWin
	Exec=/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland
	TryExec=/usr/bin/startplasma-wayland
	DesktopNames=KDE
	X-KDE-PluginInfo-Version=6.5.5

The documentation for these .desktop files are at:
	xdg-open https://specifications.freedesktop.org/desktop-entry-spec/latest/

But some keys are not documented, like DeskTopNames.

## Step 2: Clone the KWin repo

I tried a git clone approach first, but couldn't find the exact branch to pull.
I then found out that I could get the build environment as a tar file, so I went to:
	xdg-open https://gitlab.archlinux.org/archlinux/packaging/packages/kwin
and opened PKGBUILD. The 'source' property gave the URLs for the main TAR file and one patch file.
After some variable substitutions, I had
	wget https://download.kde.org/stable/plasma/6.5.5/kwin-6.5.5.tar.xz
	wget https://invent.kde.org/plasma/kwin/-/commit/f79af348.patch

I extracted the tar.xz file and applied the patch
	tar xf kwin-6.5.5.tar.xz
	patch -p1 < ../f79af348.patch.txt

To build kwin, I had to make sure I had a bunch of dependencies:

	sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-wayland \
	  kf6-kconfig kf6-kcoreaddons kf6-kwindowsystem kf6-kglobalaccel \
	  kf6-kcrash kf6-kdbusaddons kf6-kidletime kf6-knotifications \
	  kf6-kservice kf6-kiconthemes kf6-kio kf6-kxmlgui \
	  plasma-wayland-protocols wayland-protocols \
	  libdrm libinput libxkbcommon libxcb \
	  pipewire libepoxy mesa

Then I had to "configure" the build:

	cmake -B build -S . \
	  -DCMAKE_INSTALL_PREFIX=/home/ptousig/Projects/kwin-dev \
	  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	  -DBUILD_TESTING=OFF

Then finally build it:

	cmake --build build -j8

To my utter amazement, it built without errors.
The next step will be to create the layout of binaries...

	cmake --install build

