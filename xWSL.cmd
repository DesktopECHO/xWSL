@ECHO OFF & NET SESSION >NUL 2>&1 
IF %ERRORLEVEL% == 0 (ECHO Administrator check passed...) ELSE (ECHO You need to run this command with administrative rights.  Is User Account Control enabled? && pause && goto ENDSCRIPT)

COLOR 1F
SET WSLREV=20240403
SET DISTRO=xWSL
SET GITORG=DesktopECHO
SET GITPRJ=xWSL
SET BRANCH=master
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%

REM ## Enable WSL if required
POWERSHELL -Command "$WSL = Get-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Windows-Subsystem-Linux' ; if ($WSL.State -eq 'Disabled') {Enable-WindowsOptionalFeature -FeatureName $WSL.FeatureName -Online}"

REM ## Find system DPI setting and get installation parameters
IF NOT EXIST "%TEMP%\windpi.ps1" POWERSHELL.EXE -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/windpi.ps1' -UseBasicParsing -OutFile '%TEMP%\windpi.ps1'"
FOR /f "delims=" %%a in ('powershell -ExecutionPolicy bypass -command "%TEMP%\windpi.ps1" ') do set "WINDPI=%%a"
:DI
CLS && SET RUNSTART=%date% @ %time:~0,5%
REM ## Prevent installation to System32
IF EXIST .\CMD.EXE CD ..\..

ECHO [xWSL Installer %WSLREV%]
ECHO:
SET UBUVER=4& SET /p UBUVER=Enter '2' for Ubuntu 22.04 (Jammy) or '4' for Ubuntu 24.04 (Noble) [4]: 
ECHO: & ECHO Enter a unique name for your distro or hit Enter for default. 
SET /p DISTRO=Keep this name simple, no space or underscore characters [xWSL]: 
IF EXIST "%DISTRO%" (ECHO. & ECHO Folder exists with that name, choose a new folder name. & PAUSE & GOTO DI)
WSL.EXE -d %DISTRO% -e . > "%TEMP%\InstCheck.tmp"
FOR /f %%i in ("%TEMP%\InstCheck.tmp") do set CHKIN=%%~zi 
IF %CHKIN% == 0 (ECHO. & ECHO There is a WSL distribution registered with that name; uninstall it or choose a new name. & PAUSE & GOTO DI)
ECHO: & SET RDPPRT=3399& SET /p RDPPRT=    Port number for xRDP traffic or hit Enter to use default [3399]: 
SET SSHPRT=3322& SET /p SSHPRT=Port number for SSHd traffic or hit Enter to use default [3322]: 
                 SET /p WINDPI=Set a custom display scale or hit Enter for Windows default [%WINDPI%]: 
FOR /f "delims=" %%a in ('PowerShell -Command 96 * "%WINDPI%" ') do set "LINDPI=%%a"
FOR /f "delims=" %%a in ('PowerShell -Command 32 * "%WINDPI%" ') do set "PANEL=%%a"
SET DEFEXL=NONO& SET /p DEFEXL=Not recommended!  Hit X to eXclude distro from Windows Defender: 
SET DISTROFULL=%CD%\%DISTRO%
SET _rlt=%DISTROFULL:~2,2%
IF "%_rlt%"=="\\" SET DISTROFULL=%CD%%DISTRO%
SET GO="%DISTROFULL%\LxRunOffline.exe" r -n "%DISTRO%" -c
REM ## Download Ubuntu and install packages
:GETIMG
IF NOT EXIST "%TEMP%\Ubuntu2%UBUVER%04.tar.gz" POWERSHELL.EXE -Command "Start-BitsTransfer -source https://github.com/DesktopECHO/wsl-images/releases/latest/download/ubuntu-2%UBUVER%.04-amd64.tar.gz -destination '%TEMP%\Ubuntu2%UBUVER%04.tar.gz'" 
REM /F %%A in ("%TEMP%\Ubuntu2%UBUVER%04.tar.gz") do If %%~zA NEQ 367282707 DEL "%TEMP%\Ubuntu2%UBUVER%04.tar.gz" && GOTO GETIMG
%DISTROFULL:~0,1%: & MKDIR "%DISTROFULL%" & CD "%DISTROFULL%" & MKDIR logs > NUL
(ECHO [xWSL Inputs] && ECHO. && ECHO.   Distro: %DISTRO% && ECHO.     Path: %DISTROFULL% && ECHO. RDP Port: %RDPPRT% && ECHO. SSH Port: %SSHPRT% && ECHO.DPI Scale: %WINDPI% && ECHO.) > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% xWSL Inputs.log"
IF NOT EXIST "%TEMP%\LxRunOffline.exe" POWERSHELL.EXE -Command "Invoke-WebRequest %BASE%/LxRunOffline.exe -UseBasicParsing -OutFile '%TEMP%\LxRunOffline.exe'"
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
ECHO @WSLCONFIG.EXE /t %DISTRO% ^&^& WSL.EXE --unregister %DISTRO%                                            >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @"%APPDATA%\LxRunOffline.exe" ur -n %DISTRO%                                                             >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% xRDP"                                                >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"   
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Secure Shell"                                        >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @NETSH AdvFirewall Firewall del rule name="%DISTRO% Avahi Multicast DNS"                                 >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO @RD /S /Q "%DISTROFULL%"                                                                                 >> "%DISTROFULL%\Uninstall %DISTRO%.cmd"
ECHO Installing xWSL Distro [%DISTRO%] to "%DISTROFULL%" & ECHO This will take a few minutes, please wait... 
IF %DEFEXL%==X (POWERSHELL.EXE -Command "Invoke-WebRequest %BASE%/excludeWSL.ps1 -UseBasicParsing -OutFile '%DISTROFULL%\excludeWSL.ps1'" & START /WAIT /MIN "Add exclusions in Windows Defender" "POWERSHELL.EXE" "-ExecutionPolicy" "Bypass" "-Command" ".\excludeWSL.ps1" "%DISTROFULL%" &  DEL ".\excludeWSL.ps1")
ECHO:& ECHO [%TIME:~0,8%] Installing Ubuntu             (~0m45s)
START /WAIT /MIN "Creating WSL userspace..." "%TEMP%\LxRunOffline.exe" "i" "-n" "%DISTRO%" "-f" "%TEMP%\Ubuntu2%UBUVER%04.tar.gz" "-d" "%DISTROFULL%" 
(FOR /F "usebackq delims=" %%v IN (`PowerShell -Command "whoami"`) DO set "WAI=%%v") & ICACLS "%DISTROFULL%" /grant "%WAI%":(CI)(OI)F > NUL
(COPY /Y "%TEMP%\LxRunOffline.exe" "%DISTROFULL%" > NUL ) & "%DISTROFULL%\LxRunOffline.exe" sd -n "%DISTRO%" 

START /MIN /WAIT "Remove un-needed packages..." %GO% "echo 'exit 0' > /etc/init.d/udev ; SUDO_FORCE_REMOVE=yes DEBIAN_FRONTEND=noninteractive apt-get -qqy purge --autoremove needrestart apparmor* bc* bcache-tools* bolt* btrfs-progs* busybox-initramfs* cloud-guest-utils* cloud-init* cloud-initramfs-copymods* cloud-initramfs-dyn-netconf* cryptsetup* cryptsetup-initramfs* dmeventd* eject* ethtool* fdisk* finalrd* fonts-ubuntu-console* fwupd* fwupd-signed* gdisk* initramfs-tools* initramfs-tools-bin* initramfs-tools-core* iputils-ping* irqbalance* isc-dhcp-client* isc-dhcp-common* klibc-utils* kpartx* landscape-common* libaio1* libarchive13* libatasmart4* libblockdev-crypto2* libblockdev-fs2* libblockdev-loop2*  libblockdev-part2* libblockdev-swap2* libblockdev-utils2* libblockdev2* libdevmapper-event1.02.1* libdrm-common* libdrm2* libefiboot1* libefivar1* libflashrom1* libfreetype6* libftdi1-2* libfwupd2* libgpgme11* libgusb2* libinih1* libisns0* libjcat1* libjson-glib-1.0-0* libjson-glib-1.0-common* libklibc* liblvm2cmd2.03* liblzo2-2* libmbim-glib4* libmbim-proxy* libmm-glib0* libmspack0* libnetplan0* libnspr4* libnss3* libnuma1* libopeniscsiusr* libparted-fs-resize0* libplymouth5* libpng16-16* libqmi-glib5* libqmi-proxy* libsgutils2-2* libtcl8.6* libtss2-esys-3.0.2-0* libtss2-mu0* libtss2-sys1* libtss2-tcti-cmd0* libtss2-tcti-device0* libtss2-tcti-mssim0* libtss2-tcti-swtpm0* libudisks2-0* liburcu8* libvolume-key1* libxmlsec1* libxmlsec1-openssl* libxslt1.1* linux-base* lvm2* lxd-agent-loader* mdadm* modemmanager* multipath-tools* netcat-openbsd* netplan.io* open-iscsi* open-vm-tools* overlayroot* plymouth* plymouth-theme-ubuntu-text* sbsigntool* secureboot-db* sg3-utils* snapd* sosreport* squashfs-tools* tcl* tcl8.6* thin-provisioning-tools* tpm-udev* ubuntu-minimal* ubuntu-server* udisks2* usb-modeswitch* usb-modeswitch-data* xfsprogs* zerofree*"

ECHO [%TIME:~0,8%] Setup apt-fast and clone repo (~1m00s)
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/systemd/system/snap* /var/cache/snapd /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh ; echo 'echo 1' > /usr/sbin/runlevel ; cd /tmp ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git ; dpkg -i /tmp/xWSL/deb/aria2_*.deb /tmp/xWSL/deb/libaria2-0_*.deb /tmp/xWSL/deb/libc-ares2_*.deb /tmp/xWSL/deb/libssh2-1_*.deb ; chmod +x /tmp/xWSL/dist/usr/local/bin/apt-fast ; cp -p /tmp/xWSL/dist/usr/local/bin/apt-fast /usr/local/bin ; mv /tmp/xWSL/dist/etc/dpkg/dpkg.cfg.d/01_nodoc /etc/dpkg/dpkg.cfg.d ; apt-get update ; apt-get -qqy install systemd > /dev/null 2>&1  ; cd /bin && mv -f systemd-sysusers{,.org} && ln -s echo systemd-sysusers ; apt-get -fy install > /dev/null 2>&1 ; # DEBIAN_FRONTEND=noninteractive apt-fast -qqy dist-upgrade" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Setup apt-fast and clone repo.log" 2>&1

IF /I %UBUVER% == 2 (START /MIN /WAIT "Jammy Packages..." %GO% "add-apt-repository -y ppa:xubuntu-dev/staging ; apt-fast -qqy install xfdesktop4 thunar thunar-archive-plugin --no-install-recommends") ELSE (START /MIN /WAIT "Noble Packages..." %GO% "echo DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/noble/*.deb --no-install-recommends")

ECHO [%TIME:~0,8%] Prerequisite components       (~1m45s)
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/*gconf*.deb /tmp/xWSL/deb/*gksu*.deb /tmp/xWSL/deb/*keyring*.deb /tmp/xWSL/deb/libldap-2.5-0_*.deb /tmp/xWSL/deb/multiarch-support_*.deb acl apt-config-icons apt-config-icons-hidpi apt-config-icons-large apt-config-icons-large-hidpi arc-theme arj avahi-daemon base-files binutils cairo-5c dbus-x11 dconf-gsettings-backend dconf-service dialog distro-info-data dumb-init fonts-cascadia-code gstreamer1.0-tools inetutils-syslogd lhasa libcairo-5c0 libdbus-glib-1-2 libde265-0 libdrm-intel1 libegl-mesa0 libegl1 libfdk-aac2 libfs6 libgbm1 libgif7 libgl1 libglu1-mesa libglx-mesa0 libglx0 libgstreamer1.0-0 libgtk-3-bin libgtk-3-common libgtkd-3-0 libheif1 libice6 libid3tag0 libimlib2 libisl23 liblhasa0 libmpc3 libnspr4 libnss-mdns libnss3 libopengl0 libpackagekit-glib2-18 libpolkit-agent-1-0 libpolkit-gobject-1-0 libsecret-1-0 libsm6 libvte-2.91-0 libvte-2.91-common libvted-3-0 libwayland-server0 libx11-xcb1 libxatracker2 libxaw7 libxcb-randr0 libxcb-shape0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont2 libxft2 libxi6 libxinerama1 libxkbfile1 libxmu6 libxmuu1 libxpm4 libxrandr2 libxss1  libxtst6 libxv1 libxvmc1 libxxf86dga1 libxxf86vm1 mesa-vulkan-drivers moreutils nickle packagekit packagekit-tools pkexec policykit-1 putty putty-tools python3-distupgrade python3-packaging python3-psutil python3-xdg openssh-client openssh-server openssh-sftp-server ssh-import-id ssl-cert ubuntu-release-upgrader-core unace unzip x11-apps x11-common x11-session-utils x11-utils x11-xfs-utils x11-xkb-utils x11-xserver-utils x264 xauth xbase-clients xcvt xdg-utils xfonts-100dpi xfonts-base xfonts-encodings xfonts-scalable xfonts-utils xinit xinput xorg xserver-common xserver-xorg xserver-xorg-core xserver-xorg-input-all xserver-xorg-input-libinput xserver-xorg-legacy xserver-xorg-video-dummy xvfb zip  --no-install-recommends ; echo 'exit 0' > /bin/setfacl" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Prerequisite components.log" 2>&1
START /MIN "Kora Icon Thene..." %GO% "cd /tmp ; unzip /tmp/xWSL/kora-1.6.0.zip ; mv kora-1.6.0/kora* /usr/share/icons/ ; rm -rf kora-*"

ECHO [%TIME:~0,8%] Xfce desktop environment      (~2m00s)
%GO% "DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/seamonkey*.deb dmz-cursor-theme evince gigolo gvfs-fuse libaacs0 libconfig9 libosmesa6 librsvg2-common libwebrtc-audio-processing1 libxfce4ui-utils lrzip lzip lzop mesa-utils mesa-va-drivers mesa-vdpau-drivers mousepad ncompress pavucontrol pulseaudio synaptic wslu xarchiver xfce4 xfce4-appfinder xfce4-clipman xfce4-clipman-plugin xfce4-cpugraph-plugin xfce4-datetime-plugin xfce4-notifyd xfce4-panel xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-session xfce4-settings xfce4-taskmanager xfce4-terminal xfce4-whiskermenu-plugin xfwm4 xserver-xorg-input-all libnotify-bin --no-install-recommends ; wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb ; apt-fast -qqy install ./chrome-remote-desktop_current_amd64.deb ; rm ./chrome-remote-desktop_current_amd64.deb ; echo 'exit 0' > /usr/bin/lspci ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install /tmp/xWSL/deb/xrdp*.deb /tmp/xWSL/deb/xorgxrdp*.deb /tmp/xWSL/deb/pulseaudio-module-xrdp_0.6-1prebuild0~0xwsl%UBUVER%_amd64.deb /tmp/xWSL/deb/libx264*.deb --no-install-recommends ; DEBIAN_FRONTEND=noninteractive apt-fast -qqy install falkon qt5-gtk2-platformtheme ; sed -i 's/ExecStartPre=.*/ExecStartPre=/g' /usr/lib/systemd/system/xrdp.service ; rm /etc/X11/Xsession.d/10enforce-single-graphical-session" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Xfce desktop environment.log" 2>&1
START /MIN "Get Mozilla keys..."  %GO% "echo 'deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main' > /etc/apt/sources.list.d/seamonkey.list ; apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C ; apt-key export 2667CA5C | gpg --dearmour -o /etc/apt/trusted.gpg.d/seamonkey.gpg --batch --yes"

REM ## Additional items to install can go here...
REM ## %GO% "cd /tmp ; wget https://dl2.tlauncher.org/f.php?f=files%2FTLauncher-2.86.zip -O tl.zip ; unzip tl.zip"
REM ## %GO% "apt-get -y install openjdk-17-jdk"

%GO% "apt-get -qqy purge --autoremove ; apt-get clean" > ".\logs\%TIME:~0,2%%TIME:~3,2%%TIME:~6,2% Post-install clean-up.log"
%GO% "which schtasks.exe" > "%TEMP%\SCHT.tmp" & set /p SCHT=<"%TEMP%\SCHT.tmp"
%GO% "sed -i 's#SCHT#%SCHT%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl ; sed -i 's#DISTRO#%DISTRO%#g' /tmp/xWSL/dist/usr/local/bin/restartwsl"
IF %LINDPI% GEQ 288 ( %GO% "sed -i 's/HISCALE/3/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/HISCALE/2/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/HISCALE/1/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/QQQ/96/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/QQQ/%LINDPI%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/PANEL/32/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/PANEL/%PANEL%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" )
IF %LINDPI% LSS 144 ( %GO% "sed -i 's/Default-hdpi/Default/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
%GO% "sed -i 's/ xWSL/ %DISTRO%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/panel/whiskermenu-1.rc"
%GO% "sed -i 's/port=3389/port=%RDPPRT%/g' /tmp/xWSL/dist/etc/xrdp/xrdp.ini
%GO% "sed -i 's/\\h/%DISTRO%/g' /tmp/xWSL/dist/etc/skel/.bashrc ; sed -i 's/\\h/%DISTRO%/g' /root/.bashrc"
%GO% "sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/WSLINSTANCENAME/%DISTRO%/g' /tmp/xWSL/dist/usr/local/bin/initwsl"
%GO% "sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/#host-name=foo/host-name=%DISTRO%/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/use-ipv4=yes/use-ipv4=no/g' /etc/avahi/avahi-daemon.conf"
%GO% "cp /mnt/c/Windows/Fonts/*.ttf /usr/share/fonts/truetype ; ssh-keygen -A ; adduser xrdp ssl-cert" > NUL
%GO% "chmod 644 /tmp/xWSL/dist/etc/wsl.conf"
%GO% "chmod 755 /tmp/xWSL/dist/etc/profile.d/xWSL.sh /tmp/xWSL/dist/usr/local/bin/restartwsl /tmp/xWSL/dist/usr/local/bin/initwsl /tmp/xWSL/dist/etc/init.d/xrdp ; chmod -R 700 /tmp/xWSL/dist/etc/skel/.config ; chmod -R 7700 /tmp/xWSL/dist/etc/skel/.local ; chmod 700 /tmp/xWSL/dist/etc/skel/.mozilla"
%GO% "cp -Rp /tmp/xWSL/dist/* / ; cp -Rp /tmp/xWSL/dist/etc/skel/.config /root ; cp -Rp /tmp/xWSL/dist/etc/skel/.local /root ; chown -R xrdp:root /etc/xrdp ; update-rc.d xrdp defaults"

SET RUNEND=%date% @ %time:~0,5%
CD %DISTROFULL% 
ECHO:
SET /p XU=Enter name of primary user for %DISTRO%: 
POWERSHELL -Command $prd = read-host "Enter password for %XU%" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($prd) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp & set /p PWO=<.tmp
%GO% "useradd -m -p nulltemp -s /bin/bash %XU%"
%GO% "(echo '%XU%:%PWO%') | chpasswd"
%GO% "echo '%XU% ALL=(ALL:ALL) ALL' >> /etc/sudoers"
%GO% "sed -i 's/PLACEHOLDER/%XU%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/COMPY/localhost/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/RDPPRT/%RDPPRT%/g' /tmp/xWSL/xWSL.rdp"
%GO% "cp /tmp/xWSL/xWSL.rdp ./xWSL._"
ECHO $prd = Get-Content .tmp > .tmp.ps1
ECHO ($prd ^| ConvertTo-SecureString -AsPlainText -Force) ^| ConvertFrom-SecureString ^| Out-File .tmp >> .tmp.ps1
POWERSHELL -ExecutionPolicy Bypass -Command ./.tmp.ps1
TYPE .tmp>.tmpsec.txt
COPY /y /b xWSL._+.tmpsec.txt "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp" > NUL
DEL /Q xWSL._ .tmp*.* > NUL
%GO% "sudo -u %XU% bash -c 'gconftool-2 --set "/apps/gksu/disable-grab" --type bool "true" ; gconftool-2 --set "/apps/gksu/sudo-mode" --type bool "true"'"
ECHO:
ECHO Open Windows Firewall Ports for xRDP, SSH, mDNS...
NETSH AdvFirewall Firewall add rule name="%DISTRO% xRDP" dir=in action=allow protocol=TCP localport=%RDPPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Secure Shell" dir=in action=allow protocol=TCP localport=%SSHPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Avahi Multicast DNS" dir=in action=allow program="%DISTROFULL%\rootfs\usr\sbin\avahi-daemon" enable=yes > NUL
START /MIN "%DISTRO% Init" WSL ~ -u root -d %DISTRO% -e initwsl 2
ECHO Building RDP Connection file, Console link, Init system...
ECHO @IF EXIST "%PROGRAMFILES%\WSL\WSL.EXE" (@"%PROGRAMFILES%\WSL\WSL.EXE" -t %DISTRO% ^&^& PING 127.0.0.1 ^>NUL ^&^& START /MIN "%DISTRO%" "%PROGRAMFILES%\WSL\WSL.EXE" ~ -u root -d %DISTRO% -e initwsl 2 ^&^& EXIT) ELSE (@WSLCONFIG.EXE /t %DISTRO% ^&^& PING 127.0.0.1 ^> NUL ^&^& START /MIN "%DISTRO%" "WSL.EXE" ~ -u root -d %DISTRO% -e initwsl 2 ^&^& EXIT) > "%DISTROFULL%\Init.cmd"
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
