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

Then build it:

	cmake --build build -j8

To my utter amazement, it built without errors.
Then we copy all the files to the install directory: kwin-dev...

	cmake --install build

## Step 3: Find where effects are compiled

Next step is to figure out which files will be modified by the addition of a new built-in effects.
The obvious first file to find is the binary that will contain the executable code of our effect.
We can begin our search by looking for which binary the DimInactive effet is compiled into.

I edited src/plugins/diminactive/diminactive.cpp to contain an obvious error and ran:
	cmake --build build
to confirm that the build did involve this source file. It gave the approriate error, so I know
I'm editing the right file. So I undid the bad code and built again, which succeeded.

I then had a look at which output files were modified in the last 5 minutes to see what binaries
were candidates to contain the effects

	find . -type f -mmin -5 -executable

It appears that build/bin/kwin_wayland is the only executable to have been produced by the last build.

I was hoping to compare the symbols table from the binary I built against the one shipped with Arch,
but the Arch one does not contain any symbols.

	/usr/bin$ nm -C kwin_wayland 
	nm: kwin_wayland: no symbols

I will have to take it on faith that it contains the DimInactiveEffect class.

## Step 4: Launch KDE with the modified paths

My next baby step is to modify kwin-dev.desktop to include the kwin-dev directories that will contain
the modified kwin_wayland (and whatever other files I need to modify), but I will not have any files
in those directories. I just want to know that the modified path environment variables don't interfere
with launching the desktop.

I begin by wiping all the files from the kwin-dev tree, but leave the tree structure intact.

	find . -type f -delete

But before we do any changes, let's look at the content of the environment for the currently running
kwin_wayland process.

	ps aux | grep kwin_wayland
	cat /proc/18414/environ | tr '\0' '\n'

I will try to set a private environment variable in kwin-dev.desktop to see if it appears in the
environment of the running kwin_wayland process. In:

	sudo micro /usr/share/wayland-sessions/kwin-dev.desktop

I am changing the Exec line to:

	Exec=env FOCUSBORDER=foobar /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland

And it worked, the running kwin_wayland process contains FOCUSBORDER=foobar. So now I know that I can
control the environment variables if I need to.

But I just ran into a strange issue. Alt-Tab no longer rotates through windows. Going to plasma.desktop
to see if this is a problem I introduced. I logged out and back in a few times in both .desktop and the
problem did not reproduce. I will have to keep an eye out for this issue.

Next I will copy the Arch version of the startplasma-wayland and kwin_wayland binaries into 
kwin-dev/bin and see if it loads.

	cp /usr/bin/kwin_wayland .
	cp /usr/bin/startplasma-wayland .
	sudo chown root:root *
	
And then I changed the Exec line to:

	Exec=env FOCUSBORDER=foobar /usr/lib/plasma-dbus-run-session-if-needed /home/ptousig/Projects/kwin-dev/bin/startplasma-wayland

But kwin_wayland was still loaded from /usr/bin. I will now try to modify the PATH variable to control
where startplasma-wayland looks for kwin_wayland.

	Exec=env PATH=/home/ptousig/Projects/kwin-dev/bin:/usr/local/sbin:/usr/local/bin:/usr/bin /usr/lib/plasma-dbus-run-session-if-needed /home/ptousig/Projects/kwin-dev/bin/startplasma-wayland

That worked. The desktop loads (seemingly) correctly and the kwin_wayland process was loaded from
/home/ptousig/Projects/kwin-dev/bin

I believe I don't actually need startplasma-wayland in my kwin-dev/bin directory. The one from
/usr/bin should find my kwin_wayload just the same. But that doesn't work. Once I removed
kwin-dev/bin/startplasma-wayland the desktop fails to start and I get thrown back to the login
screen. I do not understand why.

Figured it out. I forgot to change the path to startplasma-wayland on the Exec line. It is now:

	Exec=env PATH=/home/ptousig/Projects/kwin-dev/bin:/usr/local/sbin:/usr/local/bin:/usr/bin /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland

## Step 5: Switching to the built binary

Now comes the big step. I will replace kwin-dev/bin/kwin_wayland with the one from the build.
Fingers crossed.

Success! My binary appears to get loaded and executed. But to make sure, and also to provide useful
debuggability in the future, I want to add some kind of tracing to DimInactiveEffect and see that
tracing in journalctl.

Added a debug line to the constructor:
	qDebug() << "DimInactiveEffect::DimInactiveEffect";

Had to switch back to plasma.desktop before I could replace kwin_wayland, but after that it worked.
I can look at tracing that occurred during boot with:

	journalctl --user -b | grep DimInactive

Or look at tracing live with:

	journalctl --user -f











# EOF
