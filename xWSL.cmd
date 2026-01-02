@ECHO OFF & NET SESSION >NUL 2>&1 
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)

REM ============================================================================
REM CONFIGURATION SECTION
REM ============================================================================
COLOR 1F
SET WSLREV=20260102
SET DISTRO=xWSL
SET GITORG=DesktopECHO
SET GITPRJ=xWSL
SET BRANCH=master
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%
SET RDPPRT_DEFAULT=3399
SET SSHPRT_DEFAULT=3322

REM ============================================================================
REM INITIALIZATION
REM ============================================================================
REM Enable WSL if required
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"

REM Find system DPI setting
IF NOT EXIST "%TEMP%\windpi.ps1" POWERSHELL.EXE -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/windpi.ps1' -UseBasicParsing -OutFile '%TEMP%\windpi.ps1'"
FOR /f "delims=" %%a in ('powershell -ExecutionPolicy bypass -command "%TEMP%\windpi.ps1" ') do set "WINDPI=%%a"

REM ============================================================================
REM USER INPUT SECTION
REM ============================================================================
:DI
CLS && SET RUNSTART=%date% @ %time:~0,5%

REM Prevent installation to System32
IF EXIST .\CMD.EXE CD ..\..

ECHO [xWSL Installer %WSLREV%]
ECHO:

REM Get Ubuntu version choice
SET UBUVER=4
SET /p UBUVER=Enter '2' for Ubuntu 22.04 (Jammy) or '4' for Ubuntu 24.04 (Noble) [4]: 

REM Get custom distro name
ECHO: & ECHO Enter a unique name for your distro or hit Enter for default.
SET /p DISTRO=Keep this name simple, no space or underscore characters [xWSL]: 

REM Validate distro name doesn't already exist
IF EXIST "%DISTRO%" (
  ECHO. & ECHO Folder exists with that name, choose a new folder name. & PAUSE & GOTO DI
)

REM Check if distro is already registered with WSL
WSL.EXE -d %DISTRO% -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (
  ECHO. & ECHO There is a WSL distribution registered with that name; uninstall it or choose a new name.
  PAUSE & GOTO DI
)

REM Get DNS settings from system
FOR /f "tokens=2" %%a in ('nslookup . 2^>nul ^| findstr /C:"Address:"') do (set "DNS=nameserver %%a")

REM Get port numbers for services
ECHO:
SET RDPPRT=%RDPPRT_DEFAULT%
SET /p RDPPRT=    Port number for xRDP traffic or hit Enter to use default [%RDPPRT_DEFAULT%]: 

SET SSHPRT=%SSHPRT_DEFAULT%
SET /p SSHPRT=Port number for SSHd traffic or hit Enter to use default [%SSHPRT_DEFAULT%]: 

REM Get DPI scale setting
SET /p WINDPI=Set a custom display scale or hit Enter for Windows default [%WINDPI%]: 

REM Calculate Linux DPI values (96 DPI base for X11, 32 for panel height)
FOR /f "delims=" %%a in ('PowerShell -Command 96 * "%WINDPI%" ') do set "LINDPI=%%a"
FOR /f "delims=" %%a in ('PowerShell -Command 32 * "%WINDPI%" ') do set "PANEL=%%a"

REM Windows Defender exclusion option
SET DEFEXL=NONO
SET /p DEFEXL=Not recommended!  Hit X to eXclude distro from Windows Defender: 

REM ============================================================================
REM SETUP DISTRO PATH
REM ============================================================================
SET DISTROFULL=%CD%\%DISTRO%
SET _rlt=%DISTROFULL:~2,2%
IF "%_rlt%"=="\\" SET DISTROFULL=%CD%%DISTRO%
SET GO="%DISTROFULL%\LxRunOffline.exe" r -n "%DISTRO%" -c

REM ============================================================================
REM DOWNLOAD AND PREPARE UBUNTU IMAGE
REM ============================================================================
:GETIMG
IF NOT EXIST "%TEMP%\Ubuntu2%UBUVER%04.tar.gz" (
  POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/wsl-images/releases/latest/download/ubuntu-2%UBUVER%.04-amd64.tar.gz -destination '%TEMP%\Ubuntu2%UBUVER%04.tar.gz'"
)

REM Create distro directory structure
%DISTROFULL:~0,1%: 
MKDIR "%DISTROFULL%"
CD "%DISTROFULL%"
MKDIR logs > NUL

REM Log installation inputs
(
  ECHO [xWSL Inputs]
  ECHO.
  ECHO.   Distro: %DISTRO%
  ECHO.     Path: %DISTROFULL%
  ECHO. RDP Port: %RDPPRT%
  ECHO. SSH Port: %SSHPRT%
  ECHO.DPI Scale: %WINDPI%
  ECHO.
) > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% xWSL Inputs.log"

REM Download LxRunOffline tool if needed
IF NOT EXIST "%TEMP%\LxRunOffline.exe" (
  POWERSHELL.EXE -Command "Invoke-WebRequest %BASE%/LxRunOffline.exe -UseBasicParsing -OutFile '%TEMP%\LxRunOffline.exe'"
)

REM ============================================================================
REM CREATE UNINSTALL SCRIPT
REM ============================================================================
SETLOCAL ENABLEDELAYEDEXPANSION
(
  ECHO @COLOR 1F
  ECHO @ECHO Ensure you are running this command with elevated rights.  Uninstall %DISTRO%?
  ECHO @PAUSE
  ECHO @COPY /Y "%DISTROFULL%\LxRunOffline.exe" "%APPDATA%"
  ECHO @POWERSHELL -Command "Remove-Item ([Environment]::GetFolderPath('Desktop')+'\%DISTRO% (*) Console.cmd')"
  ECHO @POWERSHELL -Command "Remove-Item ([Environment]::GetFolderPath('Desktop')+'\%DISTRO% (*) Desktop.rdp')"
  ECHO @SCHTASKS /Delete /TN:%DISTRO% /F
  ECHO @CLS
  ECHO @ECHO Uninstalling %DISTRO%, please wait...
  ECHO @CD ..
  ECHO @WSLCONFIG.EXE /t %DISTRO% ^&^& WSL.EXE --unregister %DISTRO%
  ECHO @"%APPDATA%\LxRunOffline.exe" ur -n %DISTRO%
  ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% xRDP"
  ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Secure Shell"
  ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Avahi Multicast DNS"
  ECHO @RD /S /Q "%DISTROFULL%"
) > "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ENDLOCAL
ECHO:

REM ============================================================================
REM INSTALL WSL DISTRIBUTION
REM ============================================================================
ECHO Installing xWSL Distro [%DISTRO%] to "%DISTROFULL%"
ECHO This will take a few minutes, please wait...

REM Add Windows Defender exclusions if requested
IF %DEFEXL%==X (
  POWERSHELL.EXE -Command "Invoke-WebRequest %BASE%/excludeWSL.ps1 -UseBasicParsing -OutFile '%DISTROFULL%\excludeWSL.ps1'"
  START /WAIT /MIN "Add exclusions in Windows Defender" "POWERSHELL.EXE" "-ExecutionPolicy" "Bypass" "-Command" ".\excludeWSL.ps1" "%DISTROFULL%"
  DEL ".\excludeWSL.ps1"
)

ECHO: & ECHO [%TIME:~0,8%] Installing Ubuntu             (~0m45s)
START /WAIT /MIN "Creating WSL userspace..." "%TEMP%\LxRunOffline.exe" "i" "-n" "%DISTRO%" "-f" "%TEMP%\Ubuntu2%UBUVER%04.tar.gz" "-d" "%DISTROFULL%" 

REM Set permissions and finalize installation
(FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v")
ICACLS "%DISTROFULL%" /grant "%WAI%":(CI)(OI)F > NUL
COPY /Y "%TEMP%\LxRunOffline.exe" "%DISTROFULL%" > NUL
"%DISTROFULL%\LxRunOffline.exe" sd -n "%DISTRO%" 

REM ============================================================================
REM PACKAGE INSTALLATION SECTION
REM ============================================================================

REM Remove unnecessary packages
START /MIN /WAIT "Remove un-needed packages..." %GO% "echo 'exit 0' > /etc/init.d/udev ; SUDO_FORCE_REMOVE=yes DEBIAN_FRONTEND=noninteractive apt-get -qqy purge --autoremove needrestart apparmor* bc* bcache-tools* bolt* btrfs-progs* busybox-initramfs* cloud-guest-utils* cloud-init* cloud-initramfs-copymods* cloud-initramfs-dyn-netconf* lvm2* lxd-agent-loader* mdadm* modemmanager* multipath-tools* netplan.io* open-iscsi* open-vm-tools* overlayroot* plymouth* plymouth-theme-ubuntu-text* sbsigntool* secureboot-db* sg3-utils* snapd* sosreport* squashfs-tools* thin-provisioning-tools* tpm-udev* ubuntu-minimal* ubuntu-server* usb-modeswitch* usb-modeswitch-data* zerofree*"

REM Setup apt-fast package manager and clone xWSL repository
ECHO [%TIME:~0,8%] Setup apt-fast and clone repo (~1m00s)
%GO% "echo %DNS% > /etc/resolv.conf ; rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/systemd/system/snap* /var/cache/snapd /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh ; echo 'echo 1' > /usr/sbin/runlevel ; cd /tmp ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git ; dpkg -i /tmp/xWSL/deb/aria2_*.deb /tmp/xWSL/deb/libaria2-0_*.deb /tmp/xWSL/deb/libc-ares2_*.deb /tmp/xWSL/deb/libssh2-1_*.deb ; chmod +x /tmp/xWSL/dist/usr/local/bin/apt-fast ; cp -p /tmp/xWSL/dist/usr/local/bin/apt-fast /usr/local/bin ; mv /tmp/xWSL/dist/etc/dpkg/dpkg.cfg.d/01_nodoc /etc/dpkg/dpkg.cfg.d ; echo %DNS% > /etc/resolv.conf ; apt-get update ; apt-get -qqy install systemd > /dev/null 2>&1 ; cd /bin && mv -f systemd-sysusers{,.org} && ln -s echo systemd-sysusers ; apt-get -fy install > /dev/null 2>&1 ; # DEBIAN_FRONTEND=noninteractive apt-fast -qqy dist-upgrade" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Setup apt-fast and clone repo.log" 2>&1

REM Install prerequisite components
ECHO [%TIME:~0,8%] Prerequisite components       (~1m45s)
%GO% "echo %DNS% > /etc/resolv.conf ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/*gconf*.deb /tmp/xWSL/deb/*gksu*.deb /tmp/xWSL/deb/*keyring*.deb /tmp/xWSL/deb/libldap-2.5-0_*.deb /tmp/xWSL/deb/multiarch-support_*.deb software-properties-common acl apt-config-icons apt-config-icons-hidpi apt-config-icons-large apt-config-icons-large-hidpi arc-theme arj avahi-daemon base-files binutils cairo-5c dbus-x11 dconf-gsettings-backend dconf-service dialog distro-info-data dumb-init fonts-cascadia-code gstreamer1.0-tools inetutils-syslogd lhasa libcairo-5c0 libdbus-glib-1-2 libde265-0 libdrm-intel1 libegl-mesa0 libegl1 libfdk-aac2 libfs6 libgbm1 libgif7 libgl1 libglu1-mesa libglx-mesa0 libglx0 libgstreamer1.0-0 libgtk-3-bin libgtk-3-common libgtkd-3-0 libheif1 libice6 libid3tag0 libimlib2 libisl23 liblhasa0 libmpc3 libnspr4 libnss-mdns libnss3 libopengl0 libpackagekit-glib2-18 libpolkit-agent-1-0 libpolkit-gobject-1-0 libsecret-1-0 libsm6 libvte-2.91-0 libvte-2.91-common libvted-3-0 libwayland-server0 libx11-xcb1 libxatracker2 libxaw7 libxcb-randr0 libxcb-shape0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont2 libxft2 libxi6 libxinerama1 libxkbfile1 libxmu6 libxmuu1 libxpm4 libxrandr2 libxss1 libxtst6 libxv1 libxvmc1 libxxf86dga1 libxxf86vm1 mesa-vulkan-drivers moreutils nickle packagekit packagekit-tools pkexec policykit-1 putty putty-tools python3-distupgrade python3-packaging python3-psutil python3-xdg ssh ssl-cert ubuntu-release-upgrader-core unace unzip x11-apps x11-common x11-session-utils x11-utils x11-xfs-utils x11-xkb-utils x11-xserver-utils x264 xauth xbase-clients xcvt xdg-utils xfonts-100dpi xfonts-base xfonts-encodings xfonts-scalable xfonts-utils xinit xinput xorg xserver-common xserver-xorg xserver-xorg-core xserver-xorg-input-all xserver-xorg-input-libinput xserver-xorg-legacy xserver-xorg-video-dummy xvfb zip --no-install-recommends ; echo 'exit 0' > /bin/setfacl" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Prerequisite components.log" 2>&1

START /MIN /WAIT "XFCE PPA Packages..." %GO% "echo %DNS% > /etc/resolv.conf ; add-apt-repository -y ppa:xubuntu-dev/staging ; apt-get update"

REM Install Kora icon theme
START /MIN "Kora Icon Thene..." %GO% "cd /tmp ; unzip /tmp/xWSL/kora-1.6.0.zip ; mv kora-1.6.0/kora* /usr/share/icons/ ; rm -rf kora-*"

REM Install Xfce desktop environment
ECHO [%TIME:~0,8%] Xfce desktop environment      (~2m00s)
%GO% "echo %DNS% > /etc/resolv.conf ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/seamonkey*.deb dmz-cursor-theme evince gigolo gvfs-fuse libaacs0 libconfig9 libosmesa6 librsvg2-common libwebrtc-audio-processing1 libxfce4ui-utils lrzip lzip lzop mesa-utils mesa-va-drivers mesa-vdpau-drivers mousepad ncompress pavucontrol pulseaudio synaptic wslu xarchiver xfce4 xfce4-appfinder xfce4-clipman xfce4-clipman-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-notifyd xfce4-panel xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-session xfce4-settings xfce4-taskmanager xfce4-terminal xfce4-whiskermenu-plugin xfwm4 xserver-xorg-input-all libnotify-bin libglapi-mesa libxcb-dri2-0 --no-install-recommends ; wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb ; apt-fast -qqy install ./chrome-remote-desktop_current_amd64.deb ; rm ./chrome-remote-desktop_current_amd64.deb ; echo 'exit 0' > /usr/bin/lspci ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/xrdp*.deb /tmp/xWSL/deb/xorgxrdp*.deb /tmp/xWSL/deb/pulseaudio-module-xrdp_0.6-1prebuild0~0xwsl%UBUVER%_amd64.deb /tmp/xWSL/deb/libx264*.deb --no-install-recommends ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install falkon qt5-gtk-platformtheme qt5-gtk2-platformtheme ; sed -i 's/ExecStartPre=.*/ExecStartPre=/g' /usr/lib/systemd/system/xrdp.service ; rm /etc/X11/Xsession.d/10enforce-single-graphical-session" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Xfce desktop environment.log" 2>&1

REM Retrieve Mozilla keys for Seamonkey repository
START /MIN "Get Mozilla keys..." %GO% "echo %DNS% > /etc/resolv.conf ; echo 'deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main' > /etc/apt/sources.list.d/seamonkey.list ; apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C ; apt-key export 2667CA5C | gpg --dearmour -o /etc/apt/trusted.gpg.d/seamonkey.gpg --batch --yes"

REM Final cleanup and configuration
%GO% "apt-get -qqy purge --autoremove ; apt-get clean" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Post-install clean-up.log"

REM Get scheduler path for restart script
%GO% "which schtasks.exe" > "%TEMP%\SCHT.tmp" & set /p SCHT=<"%TEMP%\SCHT.tmp"

REM Configure distro-specific settings
%GO% "sed -i 's#SCHT#%SCHT%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl ; sed -i 's#DISTRO#%DISTRO%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl"

REM Apply DPI scaling to Xfce configuration
IF %LINDPI% GEQ 288 ( %GO% "sed -i 's/HISCALE/3/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/HISCALE/2/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/HISCALE/1/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )

REM Apply font DPI settings
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/QQQ/96/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/QQQ/%LINDPI%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )

REM Apply panel height settings
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/PANEL/32/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/PANEL/%PANEL%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" )

REM Apply window manager theme scaling
IF %LINDPI% LSS 144 ( %GO% "sed -i 's/Default-hdpi/Default/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )

%GO% "sed -i 's/ xWSL/ %DISTRO%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/panel/whiskermenu-1.rc"
%GO% "sed -i 's/port=3389/port=%RDPPRT%/g' /tmp/xWSL/dist/etc/xrdp/xrdp.ini"
%GO% "sed -i 's/\\h/%DISTRO%/g' /tmp/xWSL/dist/etc/skel/.bashrc ; sed -i 's/\\h/%DISTRO%/g' /root/.bashrc"
%GO% "sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/WSLINSTANCENAME/%DISTRO%/g' /tmp/xWSL/dist/usr/local/bin/initwsl"
%GO% "sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/#host-name=foo/host-name=%DISTRO%/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/use-ipv4=yes/use-ipv4=no/g' /etc/avahi/avahi-daemon.conf"
%GO% "cp /mnt/c/Windows/Fonts/*.ttf /usr/share/fonts/truetype ; ssh-keygen -A ; adduser xrdp ssl-cert" > NUL
%GO% "chmod 644 /tmp/xWSL/dist/etc/wsl.conf"
%GO% "chmod 755 /tmp/xWSL/dist/etc/profile.d/xWSL.sh /tmp/xWSL/dist/usr/local/bin/restartwsl /tmp/xWSL/dist/usr/local/bin/initwsl /tmp/xWSL/dist/etc/init.d/xrdp ; chmod -R 700 /tmp/xWSL/dist/etc/skel/.config ; chmod -R 7700 /tmp/xWSL/dist/etc/skel/.local ; chmod 700 /tmp/xWSL/dist/etc/skel/.mozilla"
%GO% "cp -Rp /tmp/xWSL/dist/* / ; cp -Rp /tmp/xWSL/dist/etc/skel/.config /root ; cp -Rp /tmp/xWSL/dist/etc/skel/.local /root ; chown -R xrdp:root /etc/xrdp ; update-rc.d xrdp defaults"

REM ============================================================================
REM POST-INSTALLATION CONFIGURATION
REM ============================================================================
SET RUNEND=%date% @ %time:~0,5%
CD %DISTROFULL% 
ECHO:
REM Create user account and set password
SET /p XU=Enter name of primary user for %DISTRO%: 
POWERSHELL -Command $prd = read-host "Enter password for %XU%" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($prd) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp & set /p PWO=<.tmp

REM Add user and configure sudo privileges
%GO% "useradd -m -p nulltemp -s /bin/bash %XU%"
%GO% "(echo '%XU%:%PWO%') | chpasswd"
%GO% "echo '%XU% ALL=(ALL:ALL) ALL' >> /etc/sudoers"

REM Create RDP connection file with user credentials
%GO% "sed -i 's/PLACEHOLDER/%XU%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/COMPY/localhost/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/RDPPRT/%RDPPRT%/g' /tmp/xWSL/xWSL.rdp"
%GO% "cp /tmp/xWSL/xWSL.rdp ./xWSL._"

REM Encrypt and embed password in RDP file
ECHO $prd = Get-Content .tmp > .tmp.ps1
ECHO ($prd ^| ConvertTo-SecureString -AsPlainText -Force) ^| ConvertFrom-SecureString ^| Out-File .tmp >> .tmp.ps1
POWERSHELL -ExecutionPolicy Bypass -Command ./.tmp.ps1
TYPE .tmp>.tmpsec.txt
COPY /y /b xWSL._+.tmpsec.txt "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp" > NUL
DEL /Q xWSL._ .tmp*.* > NUL

REM Configure gksu for GUI password prompts
%GO% "sudo -u %XU% bash -c 'gconftool-2 --set "/apps/gksu/disable-grab" --type bool "true" ; gconftool-2 --set "/apps/gksu/sudo-mode" --type bool "true"'"

REM Configure Windows Firewall for services
ECHO:
ECHO Open Windows Firewall Ports for xRDP, SSH, mDNS...
NETSH AdvFirewall Firewall add rule name="%DISTRO% xRDP" dir=in action=allow protocol=TCP localport=%RDPPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Secure Shell" dir=in action=allow protocol=TCP localport=%SSHPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Avahi Multicast DNS" dir=in action=allow program="%DISTROFULL%\rootfs\usr\sbin\avahi-daemon" enable=yes > NUL

REM Initialize services
START /MIN "%DISTRO% Init" WSL ~ -u root -d %DISTRO% -e initwsl 2
ECHO Building RDP Connection file, Console link, Init system...

REM Create init script to restart services on system boot
ECHO @ECHO OFF > "%DISTROFULL%\Init.cmd"
ECHO IF EXIST "%PROGRAMFILES%\WSL\WSL.EXE" ( >> "%DISTROFULL%\Init.cmd"
ECHO   @"%PROGRAMFILES%\WSL\WSL.EXE" -t %DISTRO% >> "%DISTROFULL%\Init.cmd"
ECHO   @PING 127.0.0.1 ^> NUL >> "%DISTROFULL%\Init.cmd"
ECHO   @START /MIN "%DISTRO%" "%PROGRAMFILES%\WSL\WSL.EXE" ~ -u root -d %DISTRO% -e initwsl 2 >> "%DISTROFULL%\Init.cmd"
ECHO   @EXIT >> "%DISTROFULL%\Init.cmd"
ECHO ) ELSE ( >> "%DISTROFULL%\Init.cmd"
ECHO   @WSLCONFIG.EXE /t %DISTRO% >> "%DISTROFULL%\Init.cmd"
ECHO   @PING 127.0.0.1 ^> NUL >> "%DISTROFULL%\Init.cmd"
ECHO   @START /MIN "%DISTRO%" "WSL.EXE" ~ -u root -d %DISTRO% -e initwsl 2 >> "%DISTROFULL%\Init.cmd"
ECHO   @EXIT >> "%DISTROFULL%\Init.cmd"
ECHO ) >> "%DISTROFULL%\Init.cmd"

REM Create console shortcut
ECHO @WSL ~ -u %XU% -d %DISTRO% > "%DISTROFULL%\%DISTRO% (%XU%) Console.cmd"

REM Set default user UID
"%DISTROFULL%\LxRunOffline.exe" su -n %DISTRO% -v 1000

REM Copy shortcuts to desktop
POWERSHELL -Command "Copy-Item '%DISTROFULL%\%DISTRO% (%XU%) Console.cmd' ([Environment]::GetFolderPath('Desktop'))"
POWERSHELL -Command "Copy-Item '%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp' ([Environment]::GetFolderPath('Desktop'))"

REM Create scheduled task for auto-start
ECHO Building Scheduled Task...
POWERSHELL -C "$WAI = (whoami) ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('AAAA', $WAI) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
POWERSHELL -C "$WAC = (pwd)    ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('QQQQ', $WAC) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
SCHTASKS /Create /TN:%DISTRO% /XML .\rootfs\tmp\xWSL\xWSL.xml /F

REM Display installation summary
ECHO:
ECHO:      Start: %RUNSTART%
ECHO:        End: %RUNEND%
%GO%  "echo -ne '   Packages:'\   ; dpkg-query -l | grep "^ii" | wc -l "
ECHO: 
ECHO:  - xRDP Server listening on port %RDPPRT% and SSHd on port %SSHPRT%.
ECHO: 
ECHO:  - Links for GUI and Console sessions have been placed on your desktop.
ECHO: 
ECHO:  - (Re)launch init from the Task Scheduler or by running the following command: 
ECHO:    schtasks /run /tn %DISTRO%
ECHO: 
ECHO: %DISTRO% Installation Complete!  GUI will start in a few seconds...  
PING -n 6 LOCALHOST > NUL 
START "Remote Desktop Connection" "MSTSC.EXE" "/V" "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp"
CD ..
ECHO: 
:ENDSCRIPT
