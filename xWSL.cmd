@ECHO OFF & NET SESSION >NUL 2>&1 
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)

COLOR 1F
SET DISTRO=UbuntuWSL
SET GITORG=DesktopECHO
SET GITPRJ=xWSL
SET BRANCH=master
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%

REM ## Enable WSL if required
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"

REM ## Find system DPI setting and get installation parameters
IF NOT EXIST "%TEMP%\windpi.ps1" POWERSHELL.EXE -ExecutionPolicy Bypass -Command "wget '%BASE%/windpi.ps1' -UseBasicParsing -OutFile '%TEMP%\windpi.ps1'"
FOR /f "delims=" %%a in ('powershell -ExecutionPolicy bypass -command "%TEMP%\windpi.ps1" ') do set "WINDPI=%%a"
:DI
CLS && SET RUNSTART=%date% @ %time:~0,5%
IF EXIST .\CMD.EXE CD ..\..

ECHO [xWSL Installer 20220802]
ECHO:
ECHO Enter a unique name for your xWSL distro or hit Enter to use default. 
SET /p DISTRO=Keep this name simple, no space or underscore characters [UbuntuWSL]: 
IF EXIST "%DISTRO%" (ECHO. & ECHO Folder exists with that name, choose a new folder name. & PAUSE & GOTO DI)
WSL.EXE -d %DISTRO% -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO There is a WSL distribution registered with that name; uninstall it or choose a new name. & PAUSE & GOTO DI)
SET RDPPRT=3399& SET /p RDPPRT=Port number for xRDP traffic or hit Enter to use default [3399]: 
SET SSHPRT=3322& SET /p SSHPRT=Port number for SSHd traffic or hit Enter to use default [3322]: 
                 SET /p WINDPI=Set a custom DPI scale, or hit Enter for Windows default [%WINDPI%]: 
FOR /f "delims=" %%a in ('PowerShell -Command "%WINDPI% * 96" ') do set "LINDPI=%%a"
FOR /f "delims=" %%a in ('PowerShell -Command 36 * "%WINDPI%" ') do set "PANEL=%%a"
SET DEFEXL=NONO& SET /p DEFEXL=[Not recommended!] Type X to eXclude from Windows Defender: 
SET DISTROFULL=%CD%\%DISTRO%
SET _rlt=%DISTROFULL:~2,2%
IF "%_rlt%"=="\\" SET DISTROFULL=%CD%%DISTRO%
SET GO="%DISTROFULL%\LxRunOffline.exe" r -n "%DISTRO%" -c
REM ## Download Ubuntu and install packages
IF NOT EXIST "%TEMP%\Ubuntu2204.tar.gz" POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/wsl-images/releases/latest/download/ubuntu-22.04-amd64.tar.gz -destination '%TEMP%\Ubuntu2204.tar.gz'"
%DISTROFULL:~0,1%: & MKDIR "%DISTROFULL%" & CD "%DISTROFULL%" & MKDIR logs > NUL
(ECHO [xWSL Inputs] && ECHO. && ECHO.   Distro: %DISTRO% && ECHO.     Path: %DISTROFULL% && ECHO. RDP Port: %RDPPRT% && ECHO. SSH Port: %SSHPRT% && ECHO.DPI Scale: %WINDPI% && ECHO.) > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% xWSL Inputs.log"
IF NOT EXIST "%TEMP%\LxRunOffline.exe" POWERSHELL.EXE -Command "wget %BASE%/LxRunOffline.exe -UseBasicParsing -OutFile '%TEMP%\LxRunOffline.exe'"
ECHO:
ECHO @COLOR 1F                                                                                                >  "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @ECHO Ensure you are running this command with elevated rights.  Uninstall %DISTRO%?                     >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @PAUSE                                                                                                   >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @COPY /Y "%DISTROFULL%\LxRunOffline.exe" "%APPDATA%"                                                     >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @POWERSHELL -Command "Remove-Item ([Environment]::GetFolderPath('Desktop')+'\%DISTRO% (*) Console.cmd')" >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @POWERSHELL -Command "Remove-Item ([Environment]::GetFolderPath('Desktop')+'\%DISTRO% (*) Desktop.rdp')" >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @SCHTASKS /Delete /TN:%DISTRO% /F                                                                        >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @CLS                                                                                                     >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @ECHO Uninstalling %DISTRO%, please wait...                                                              >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @CD ..                                                                                                   >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @WSLCONFIG /T %DISTRO%                                                                                   >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @"%APPDATA%\LxRunOffline.exe" ur -n %DISTRO%                                                             >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% xRDP"                                                >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"   
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Secure Shell"                                        >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Avahi Multicast DNS"                                 >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @RD /S /Q "%DISTROFULL%"                                                                                 >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO Installing xWSL Distro [%DISTRO%] to "%DISTROFULL%" & ECHO This will take a few minutes, please wait... 
IF %DEFEXL%==X (POWERSHELL.EXE -Command "wget %BASE%/excludeWSL.ps1 -UseBasicParsing -OutFile '%DISTROFULL%\excludeWSL.ps1'" & START /WAIT /MIN "Add exclusions in Windows Defender" "POWERSHELL.EXE" "-ExecutionPolicy" "Bypass" "-Command" ".\excludeWSL.ps1" "%DISTROFULL%" &  DEL ".\excludeWSL.ps1")
ECHO:& ECHO [%TIME:~0,8%] Installing Ubuntu 22.04   (~0m30s)
START /WAIT /MIN "Installing Ubuntu userspace..." "%TEMP%\LxRunOffline.exe" "i" "-n" "%DISTRO%" "-f" "%TEMP%\Ubuntu2204.tar.gz" "-d" "%DISTROFULL%" 
(FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v") & ICACLS "%DISTROFULL%" /grant "%WAI%":(CI)(OI)F > NUL
(COPY /Y "%TEMP%\LxRunOffline.exe" "%DISTROFULL%" > NUL ) & "%DISTROFULL%\LxRunOffline.exe" sd -n "%DISTRO%" 
ECHO [%TIME:~0,8%] APT update and clone repo (~3m00s)
%GO% "echo 'deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe' > /etc/apt/sources.list"
%GO% "echo 'deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe' >> /etc/apt/sources.list"
%GO% "echo 'deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe' >> /etc/apt/sources.list"
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/systemd/system/snap* /var/cache/snapd /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh ; echo 'echo 1' > /usr/sbin/runlevel"
START /MIN "Move Icons..." %GO% "mv /usr/share/icons $PWD ; rm -rf /usr/share/icons ; ln -s $PWD/icons /usr/share/icons"
START /MIN /WAIT "Git clone..." %GO% "cd /tmp ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git"
%GO% "mv /tmp/xWSL/dist/etc/dpkg/dpkg.cfg.d/01_nodoc /etc/dpkg/dpkg.cfg.d ; dpkg -i /tmp/xWSL/deb/python*.deb /tmp/xWSL/deb/gzip_1.10-4ubuntu1_amd64.deb /tmp/xWSL/deb/aria2_1.36.0-1_amd64.deb /tmp/xWSL/deb/libaria2-0_1.36.0-1_amd64.deb /tmp/xWSL/deb/libc-ares2_1.18.1-1build1_amd64.deb /tmp/xWSL/deb/libssh2-1_1.10.0-3_amd64.deb ; apt-mark hold gzip ; pip3 install apt-select ; chmod +x /tmp/xWSL/dist/usr/local/bin/apt-fast ; cp -p /tmp/xWSL/dist/usr/local/bin/apt-fast /usr/local/bin" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Configure apt-fast Downloader.log" 2>&1
START /MIN /WAIT "Remove un-needed packages..." %GO% "apt-mark hold sudo ; DEBIAN_FRONTEND=noninteractive apt-get -y purge needrestart apparmor* bc* bcache-tools* bolt* btrfs-progs* busybox-initramfs* cloud-guest-utils* cloud-init* cloud-initramfs-copymods* cloud-initramfs-dyn-netconf* cryptsetup* cryptsetup-initramfs* dmeventd* eject* ethtool* fdisk* finalrd* fonts-ubuntu-console* fwupd* fwupd-signed* gdisk* initramfs-tools* initramfs-tools-bin* initramfs-tools-core* iputils-ping* irqbalance* isc-dhcp-client* isc-dhcp-common* klibc-utils* kpartx* landscape-common* libaio1* libarchive13* libatasmart4* libblockdev-crypto2* libblockdev-fs2* libblockdev-loop2* libblockdev-part-err2* libblockdev-part2* libblockdev-swap2* libblockdev-utils2* libblockdev2* libdevmapper-event1.02.1* libdns-export1110* libdrm-common* libdrm2* libefiboot1* libefivar1* libfdisk1* libflashrom1* libfreetype6* libftdi1-2* libfwupd2* libfwupdplugin5* libgcab-1.0-0* libgpgme11* libgusb2* libinih1* libisc-export1105* libisns0* libjcat1* libjson-glib-1.0-0* libjson-glib-1.0-common* libklibc* liblvm2cmd2.03* liblzo2-2* libmbim-glib4* libmbim-proxy* libmm-glib0* libmspack0* libnetplan0* libnspr4* libnss3* libnuma1* libopeniscsiusr* libparted-fs-resize0* libplymouth5* libpng16-16* libqmi-glib5* libqmi-proxy* libsgutils2-2* libsmbios-c2* libtcl8.6* libtss2-esys-3.0.2-0* libtss2-mu0* libtss2-sys1* libtss2-tcti-cmd0* libtss2-tcti-device0* libtss2-tcti-mssim0* libtss2-tcti-swtpm0* libudisks2-0* liburcu8* libvolume-key1* libxmlsec1* libxmlsec1-openssl* libxslt1.1* linux-base* lvm2* lxd-agent-loader* mdadm* modemmanager* multipath-tools* netcat-openbsd* netplan.io* open-iscsi* open-vm-tools* overlayroot* plymouth* plymouth-theme-ubuntu-text* sbsigntool* secureboot-db* sg3-utils* snapd* sosreport* squashfs-tools* tcl* tcl8.6* thin-provisioning-tools* tpm-udev* ubuntu-minimal* ubuntu-server* udisks2* usb-modeswitch* usb-modeswitch-data* xfsprogs* zerofree* ; apt-mark unhold sudo"

:APTRELY
START /MIN /WAIT "Find best mirror..." %GO% "MyIP=$(curl -s ifconfig.me) ; MyCountry=$(curl -s ipinfo.io/$MyIP/country) ; echo Region: $MyCountry ; apt-select -C $MyCountry ; mv sources.list /etc/apt/ ; apt-get update 2> /tmp/apterr"
FOR /F %%A in ("%DISTROFULL%\rootfs\tmp\apterr") do If %%~zA NEQ 0 GOTO APTRELY 

ECHO [%TIME:~0,8%] Remote Desktop Components (~1m45s)
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -y install /tmp/xWSL/deb/xorgxrdp*.deb /tmp/xWSL/deb/xrdp*.deb /tmp/xWSL/deb/gksu_2.1.0_amd64.deb /tmp/xWSL/deb/libgksu2-0_2.1.0_amd64.deb /tmp/xWSL/deb/libgnome-keyring0_3.12.0-1+b2_amd64.deb /tmp/xWSL/deb/libgnome-keyring-common_3.12.0-1_all.deb /tmp/xWSL/deb/multiarch-support_2.27-3ubuntu1_amd64.deb /tmp/xWSL/deb/plata-theme_0.9.9-0ubuntu1~focal1_all.deb /tmp/xWSL/deb/libfdk-aac1_0.1.6-1_amd64.deb apt-config-icons apt-config-icons-hidpi apt-config-icons-large apt-config-icons-large-hidpi arj avahi-daemon base-files binutils cairo-5c cpp cpp-11 dbus-x11 dconf-gsettings-backend dconf-service dialog distro-info-data dumb-init fonts-cascadia-code gcc-11-base gstreamer1.0-tools inetutils-syslogd lhasa libatk-bridge2.0-0 libatspi2.0-0 libcairo-5c0 libdbus-glib-1-2 libdrm-intel1 libdw1 libegl1 libegl-mesa0 libfs6 libgbm1 libgl1 libglu1-mesa libglx0 libglx-mesa0 libgstreamer1.0-0 libgtk-3-0 libgtk-3-bin libgtk-3-common libgtkd-3-0 libice6 libisl23 liblhasa0 libllvm11 libmpc3 libnss-mdns libopengl0 libpackagekit-glib2-18 libphobos2-ldc-shared98 libpolkit-agent-1-0 libpolkit-gobject-1-0 libsecret-1-0 libsm6 libvte-2.91-0 libvte-2.91-common libvted-3-0 libwayland-server0 libx11-xcb1 libxatracker2 libxaw7 libxcb-randr0 libxcb-shape0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont2 libxft2 libxi6 libxinerama1 libxkbfile1 libxmu6 libxmuu1 libxpm4 libxrandr2 libxss1 libxt6 libxtst6 libxv1 libxvmc1 libxxf86dga1 libxxf86vm1 mesa-vulkan-drivers moreutils nickle packagekit packagekit-tools putty putty-tools python3-packaging python3-xdg python3-distupgrade python3-psutil samba-common-bin tilix tilix-common ubuntu-release-upgrader-core unace unar unzip x11-apps x11-common x11-session-utils x11-utils x11-xfs-utils x11-xkb-utils x11-xserver-utils xauth xbase-clients xcvt xdg-utils xfonts-100dpi xfonts-base xfonts-encodings xfonts-scalable xfonts-utils xinit xinput xorg xserver-common xserver-xorg xserver-xorg-core xserver-xorg-legacy orphan-sysvinit-scripts xvfb zip humanity-icon-theme adwaita-icon-theme hicolor-icon-theme --no-install-recommends" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Remote Desktop Components.log" 2>&1

ECHO [%TIME:~0,8%] Xfce4 Desktop Environment (~2m30s)
START /MIN "Copying Icons..." %GO% "rm -rf /usr/share/icons/* ; mv /tmp/xWSL/dist/usr/local/share/icons.tgz ./temp ; cd ./temp ; tar xf icons.tgz ; mv ./icons/* /usr/share/icons/ ; mkdir /usr/share/icons/default ; touch /usr/share/icons/default/index.theme"
START /MIN /WAIT "Mozilla Keys..." %GO% "echo 'deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main' > /etc/apt/sources.list.d/seamonkey.list ; apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C ; apt-key export 2667CA5C | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/seamonkey.gpg --batch --yes"
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -y install /tmp/xWSL/deb/seamonkey*.deb falkon libaacs0 libvdpau1 libosmesa6 mesa-va-drivers mesa-vdpau-drivers dmz-cursor-theme evince gconf-defaults-service gigolo gvfs-backends gvfs-fuse hardinfo lhasa libconfig9 libsmbclient libtumbler-1-0 libwebrtc-audio-processing1 libxfce4ui-utils lrzip lzip lzop mousepad ncompress libgdk-pixbuf-2.0-0 librsvg2-common pavucontrol pulseaudio qt5-gtk2-platformtheme synaptic thunar thunar-archive-plugin thunar-volman tumbler tumbler-common unzip xarchiver xfce4 xfce4-appfinder xfce4-notifyd xfce4-panel xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-session xfce4-settings xfce4-taskmanager xfce4-terminal xfce4-whiskermenu-plugin xfdesktop4 xfwm4 zip wslu mesa-utils xfce4-datetime-plugin xfce4-clipman xfce4-clipman-plugin xfce4-cpugraph-plugin xserver-xorg-video-dummy --no-install-recommends ; wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb ; dpkg -i ./chrome-remote-desktop_current_amd64.deb ; rm ./chrome-remote-desktop_current_amd64.deb" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Xfce Desktop Environment.log" 2>&1

REM ## Additional items to install can go here...
REM ## %GO% "cd /tmp ; wget https://dl2.tlauncher.org/f.php?f=files%2FTLauncher-2.86.zip -O tl.zip ; unzip tl.zip"
REM ## %GO% "apt-get -y install openjdk-17-jdk"

ECHO [%TIME:~0,8%] Post-install clean-up     (~0m45s)
%GO% "apt-get -y purge --autoremove apparmor needrestart gnustep-base-runtime gnustep-base-common gnustep-common libobjc4 powermgmt-base unar ; apt-get clean" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Post-install clean-up.log"

SET /A SESMAN = %RDPPRT% - 50
%GO% "which schtasks.exe" > "%TEMP%\SCHT.tmp" & set /p SCHT=<"%TEMP%\SCHT.tmp"
%GO% "sed -i 's#SCHT#%SCHT%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl ; sed -i 's#DISTRO#%DISTRO%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl"
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/HISCALE/2/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 288 ( %GO% "sed -i 's/HISCALE/3/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/Default-hdpi/Default-xhdpi/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/16/32/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/QQQ/96/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/QQQ/%LINDPI%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/HISCALE/1/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 120 ( %GO% "sed -i 's/Default-hdpi/Default/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )

%GO% "mkdir -p /dev/dri ; mknod -m 666 /dev/dri/card0 c 226 0 ; mknod -m 666 /dev/dri/renderD128 c 226 128 ; mknod -m 666 /dev/fb0 c 29 0"
%GO% "sed -i 's/ xWSL/ %DISTRO%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/panel/whiskermenu-1.rc"
%GO% "sed -i 's/ListenPort=3350/ListenPort=%SESMAN%/g' /etc/xrdp/sesman.ini"
%GO% "sed -i 's/thinclient_drives/.xWSL/g' /etc/xrdp/sesman.ini"
%GO% "sed -i 's/port=3389/port=%RDPPRT%/g' /tmp/xWSL/dist/etc/xrdp/xrdp.ini ; sed -i 's/\\h/%DISTRO%/g' /tmp/xWSL/dist/etc/skel/.bashrc"
%GO% "sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/WSLINSTANCENAME/%DISTRO%/g' /tmp/xWSL/dist/usr/local/bin/initwsl"
%GO% "sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/#host-name=foo/host-name=%COMPUTERNAME%-%DISTRO%/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/use-ipv4=yes/use-ipv4=no/g' /etc/avahi/avahi-daemon.conf"
%GO% "cp /mnt/c/Windows/Fonts/*.ttf /usr/share/fonts/truetype ; ssh-keygen -A ; adduser xrdp ssl-cert" > NUL
%GO% "chmod 644 /tmp/xWSL/dist/etc/wsl.conf ; chmod 644 /tmp/xWSL/dist/var/lib/xrdp-pulseaudio-installer/*.so"
%GO% "chmod 755 /tmp/xWSL/dist/etc/profile.d/xWSL.sh ; chmod 755 /tmp/xWSL/dist/usr/local/bin/restartwsl ; chmod 755 /tmp/xWSL/dist/usr/local/bin/initwsl ; chmod -R 700 /tmp/xWSL/dist/etc/skel/.config ; chmod -R 7700 /tmp/xWSL/dist/etc/skel/.local ; chmod 700 /tmp/xWSL/dist/etc/skel/.mozilla ; chmod +x /tmp/xWSL/dist/etc/skel/Desktop/Falkon.desktop ; chmod +x /tmp/xWSL/dist/etc/skel/Desktop/Seamonkey.desktop"
%GO% "rm /usr/lib/systemd/system/dbus-org.freedesktop.login1.service /usr/share/dbus-1/system-services/org.freedesktop.login1.service /usr/share/polkit-1/actions/org.freedesktop.login1.policy"
%GO% "rm /usr/share/dbus-1/services/org.freedesktop.systemd1.service /usr/share/dbus-1/system-services/org.freedesktop.systemd1.service /usr/share/dbus-1/system.d/org.freedesktop.systemd1.conf /usr/share/polkit-1/actions/org.freedesktop.systemd1.policy /usr/share/applications/gksu.desktop"
%GO% "cp -Rp /tmp/xWSL/dist/* / ; cp -Rp /tmp/xWSL/dist/etc/skel/.config /root ; cp -Rp /tmp/xWSL/dist/etc/skel/.local /root ; chown -R xrdp:root /etc/xrdp"

SET RUNEND=%date% @ %time:~0,5%
CD %DISTROFULL% 
ECHO:
SET /p XU=Enter name of primary user for %DISTRO%: 
POWERSHELL -Command $prd = read-host "Enter password for %XU%" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($prd) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp & set /p PWO=<.tmp
%GO% "useradd -m -p nulltemp -s /bin/bash %XU%"
%GO% "(echo '%XU%:%PWO%') | chpasswd"
%GO% "echo '%XU% ALL=(ALL:ALL) ALL' >> /etc/sudoers"
%GO% "sed -i 's/PLACEHOLDER/%XU%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/COMPY/%COMPUTERNAME%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/RDPPRT/%RDPPRT%/g' /tmp/xWSL/xWSL.rdp"
%GO% "cp /tmp/xWSL/xWSL.rdp ./xWSL._"
ECHO $prd = Get-Content .tmp > .tmp.ps1
ECHO ($prd ^| ConvertTo-SecureString -AsPlainText -Force) ^| ConvertFrom-SecureString ^| Out-File .tmp >> .tmp.ps1
POWERSHELL -ExecutionPolicy Bypass -Command ./.tmp.ps1
TYPE .tmp>.tmpsec.txt
COPY /y /b xWSL._+.tmpsec.txt "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp" > NUL
DEL /Q xWSL._ .tmp*.* > NUL
ECHO:
ECHO Open Windows Firewall Ports for xRDP, SSH, mDNS...
NETSH AdvFirewall Firewall add rule name="%DISTRO% xRDP" dir=in action=allow protocol=TCP localport=%RDPPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Secure Shell" dir=in action=allow protocol=TCP localport=%SSHPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Avahi Multicast DNS" dir=in action=allow program="%DISTROFULL%\rootfs\usr\sbin\avahi-daemon" enable=yes > NUL
START /MIN "%DISTRO% Init" WSL ~ -u root -d %DISTRO% -e initwsl 2
ECHO Building RDP Connection file, Console link, Init system...
ECHO @START /MIN "%DISTRO%" WSLCONFIG.EXE /t %DISTRO%                  >  "%DISTROFULL%\Init.cmd"
ECHO @Powershell.exe -Command "Start-Sleep 3"                          >> "%DISTROFULL%\Init.cmd"
ECHO @START /MIN "%DISTRO%" WSL.EXE ~ -u root -d %DISTRO% -e initwsl 2 >> "%DISTROFULL%\Init.cmd"
ECHO @WSL ~ -u %XU% -d %DISTRO% > "%DISTROFULL%\%DISTRO% (%XU%) Console.cmd"
"%DISTROFULL%\LxRunOffline.exe" su -n %DISTRO% -v 1000
POWERSHELL -Command "Copy-Item '%DISTROFULL%\%DISTRO% (%XU%) Console.cmd' ([Environment]::GetFolderPath('Desktop'))"
POWERSHELL -Command "Copy-Item '%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp' ([Environment]::GetFolderPath('Desktop'))"
ECHO Building Scheduled Task...
POWERSHELL -C "$WAI = (whoami) ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('AAAA', $WAI) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
POWERSHELL -C "$WAC = (pwd)    ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('QQQQ', $WAC) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
SCHTASKS /Create /TN:%DISTRO% /XML .\rootfs\tmp\xWSL\xWSL.xml /F
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
