@ECHO OFF
SET GITORG=DesktopECHO
SET GITPRJ=xWSL
SET BRANCH=master
SET BASE=https://github.com/%GITORG%/%GITPRJ%/raw/%BRANCH%

REM ## UAC Check 
NET SESSION >NUL 2>&1
 if %errorLevel% == 0 (
      echo Administrative permissions confirmed...
  ) else (
      echo You need to run this command with administrative rights.  User Account Control enabled?
      pause
      goto ENDSCRIPT
  )

REM ## Enable WSL
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
CLS && SET RUNSTART=%date% @ %time%

REM ## Determine ideal DPI
IF NOT EXIST %TEMP%\dpi.ps1 POWERSHELL.EXE -ExecutionPolicy Bypass -Command "wget %BASE%/dpi.ps1 -UseBasicParsing -OutFile %TEMP%\dpi.ps1"
FOR /f "delims=" %%a in ('powershell -ExecutionPolicy bypass -command "%TEMP%\dpi.ps1" ') do set "LINDPI=%%a"

REM ## Get installation parameters
ECHO xWSL Installer
ECHO:

:DI
SET DISTRO=xWSL& SET /p DISTRO=Enter a unique name for the distro or hit Enter to use default [xWSL]: 
IF EXIST %DISTRO% GOTO DI
                 SET /p LINDPI=Set custom DPI scale or hit Enter to use Windows value [%LINDPI%]: 
SET RDPPRT=3399& SET /p RDPPRT=Port number for xRDP traffic or hit Enter to use default [3399]: 
SET SSHPRT=3322& SET /p SSHPRT=Port number for SSHd traffic or hit Enter to use default [3322]: 
SET DEFEXL=NONO& SET /p DEFEXL=[Not recommended!] Type X to eXclude %DISTRO% from Windows Defender: 

REM ## Download distro base
IF /I %CD%==C:\Windows\System32 CD %HOMEPATH%
SET DISTROFULL=%CD%\%DISTRO%
SET _rlt=%DISTROFULL:~2,2%
IF "%_rlt%"=="\\" SET DISTROFULL=%CD%%DISTRO%
SET GO=%DISTROFULL%\LxRunOffline.exe r -n %DISTRO% -c 
ECHO: && ECHO %DISTRO% to be installed in %DISTROFULL% && ECHO Downloading... (or using local copy if available)
IF NOT EXIST %TEMP%\Ubuntu2004.zip POWERSHELL.EXE -Command "Start-BitsTransfer -source https://aka.ms/wslubuntu2004 -destination %TEMP%\Ubuntu2004.zip"
POWERSHELL.EXE -command "Expand-Archive -Path %TEMP%\Ubuntu2004.zip -DestinationPath %TEMP% -force

REM ## Install Distro with LxRunOffline / https://github.com/DDoSolitary/LxRunOffline
IF NOT EXIST %TEMP%\LxRunOffline.exe POWERSHELL.EXE -Command "wget %BASE%/LxRunOffline.exe -UseBasicParsing -OutFile %TEMP%\LxRunOffline.exe"
%TEMP%\LxRunOffline.exe  i -n %DISTRO% -d .\%DISTRO% -f %TEMP%\install.tar.gz
%TEMP%\LxRunOffline.exe sd -n %DISTRO%
COPY %TEMP%\LxRunOffline.* %DISTROFULL% > NUL

REM ## Add exclusions in Windows Defender if requested
IF NOT EXIST %TEMP%\excludeWSL.ps1 POWERSHELL.EXE -Command "wget %BASE%/excludeWSL.ps1 -UseBasicParsing -OutFile %TEMP%\excludeWSL.ps1"
IF %DEFEXL%==X POWERSHELL.EXE -ExecutionPolicy bypass -command "%TEMP%\excludeWSL.ps1 '%DISTROFULL%'"

REM ## The following line will be removed when the 2020-08 WSL update shows up in WU for non-seekers 
%GO% "add-apt-repository -y ppa:rafaeldtinoco/lp1871129 ; apt install libc6=2.31-0ubuntu8+lp1871129~1 libc6-dev=2.31-0ubuntu8+lp1871129~1 libc-bin=2.31-0ubuntu8+lp1871129~1 libc-dev-bin=2.31-0ubuntu8+lp1871129~1 -y --allow-downgrades ; apt-mark hold libc6"

REM ## Download xWSL overlay
CD %DISTROFULL%
%GO% "cd /tmp ; git clone -b %BRANCH% --depth=1 https://github.com/%GITORG%/%GITPRJ%.git"
%GO% "ssh-keygen -A ; mkdir -p /root/.local/share ; apt-get update"

REM ## Install local packages
%GO% "DEBIAN_FRONTEND=noninteractive apt-get -y install /tmp/xWSL/deb/gksu_2.1.0_amd64.deb /tmp/xWSL/deb/libgksu2-0_2.1.0_amd64.deb /tmp/xWSL/deb/libgnome-keyring0_3.12.0-1+b2_amd64.deb /tmp/xWSL/deb/libgnome-keyring-common_3.12.0-1_all.deb /tmp/xWSL/deb/multiarch-support_2.27-3ubuntu1_amd64.deb /tmp/xWSL/deb/xrdp_0.9.13.1-2_amd64.deb /tmp/xWSL/deb/xorgxrdp_0.2.12-1_amd64.deb /tmp/xWSL/deb/plata-theme_0.9.8-0ubuntu1~focal1_all.deb /tmp/xWSL/deb/papirus-icon-theme_20200901-4672+pkg21~ubuntu20.04.1_all.deb /tmp/xWSL/deb/fonts-cascadia-code_2005.15-1_all.deb --no-install-recommends"

REM ## Install Seamonkey Browser
%GO% "echo deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main >> /etc/apt/sources.list"
%GO% "apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C ; apt-get update ; apt-get -y install seamonkey-mozilla-build"
%GO% "update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/seamonkey 100 ; update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/seamonkey 100 ; update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/seamonkey 100"

REM ## Install dependencies for desktop environments
%GO% "DEBIAN_FRONTEND=noninteractive apt-get -y install x11-apps x11-session-utils x11-xserver-utils pulseaudio dialog distro-info-data lsb-release dumb-init inetutils-syslogd xdg-utils avahi-daemon libnss-mdns binutils putty synaptic pulseaudio-utils pulseaudio mesa-utils bzip2 p7zip-full unar unzip zip libatkmm-1.6-1v5 libcairomm-1.0-1v5 libcanberra-gtk3-0 libcanberra-gtk3-module libglibmm-2.4-1v5 libgtkmm-3.0-1v5 libpangomm-1.4-1v5 libsigc++-2.0-0v5 dbus-x11 libdbus-glib-1-2 libqt5core5a --no-install-recommends"

REM ## Install XFCE4
%GO% "DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4-terminal xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin pavucontrol xfwm4 xfce4-panel xfce4-session xfce4-settings thunar thunar-volman thunar-archive-plugin xfdesktop4 xfce4-screenshooter libsmbclient gigolo gvfs-fuse gvfs-backends gvfs-bin mousepad evince xarchiver lhasa lrzip lzip lzop ncompress zip unzip dmz-cursor-theme adapta-gtk-theme gconf-defaults-service xfce4-taskmanager hardinfo --no-install-recommends" 

REM ## Install Media Player and Image Editor
%GO% "DEBIAN_FRONTEND=noninteractive apt-get -y install mtpaint parole"

REM ## Additional items to install can go here...
REM ## %GO% "cd /tmp ; wget https://files.multimc.org/downloads/multimc_1.4-1.deb"
REM ## %GO% "apt-get -y install extremetuxracer tilix /tmp/multimc_1.4-1.deb"

REM ## Remove un-needed packages
%GO% "apt-get -qq purge cryptsetup cryptsetup-bin cryptsetup-initramfs cryptsetup-run irqbalance multipath-tools apparmor snapd squashfs-tools libplymouth5 plymouth plymouth-theme-ubuntu-text open-vm-tools cloud-init isc-dhcp-* gnustep* lvm2* mdadm apport open-iscsi powermgmt-base popularity-contest fwupd libfwupd2 ; apt-get -qq autoremove ; apt-get -qq clean" > NUL

REM ## Customize
IF %LINDPI% GEQ 288 ( %GO% "sed -i 's/HISCALE/3/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/HISCALE/2/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/Default-hdpi/Default-xhdpi/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/Segoe UI Semi-Bold 11/Segoe UI Semi-Bold 22/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
IF %LINDPI% GEQ 192 ( %GO% "sed -i 's/QQQ/96/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/QQQ/%LINDPI%/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 192 ( %GO% "sed -i 's/HISCALE/1/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" )
IF %LINDPI% LSS 120 ( %GO% "sed -i 's/Default-hdpi/Default/g' /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" )
SET /A SESMAN = %RDPPRT% - 50
%GO% "sed -i 's/ListenPort=3350/ListenPort=%SESMAN%/g' /etc/xrdp/sesman.ini"
%GO% "sed -i 's/thinclient_drives/.xWSL/g' /etc/xrdp/sesman.ini"
%GO% "sed -i 's/port=3389/port=%RDPPRT%/g' /tmp/xWSL/dist/etc/xrdp/xrdp.ini ; cp /tmp/xWSL/dist/etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini"
%GO% "sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"
%GO% "sed -i 's/XWSLINSTANCENAME/%DISTRO%/g' /tmp/xWSL/dist/usr/local/bin/initWSL"
%GO% "sed -i 's/#enable-dbus=yes/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf ; sed -i 's/#host-name=foo/host-name=%COMPUTERNAME%-%DISTRO%/g' /etc/avahi/avahi-daemon.conf"
%GO% "cp /mnt/c/Windows/Fonts/*.ttf /usr/share/fonts/truetype ; rm -rf /etc/pam.d/systemd-user ; rm -rf /etc/systemd ; rm -rf /usr/share/icons/breeze_cursors ; rm -rf /usr/share/icons/Breeze_Snow/cursors ; ssh-keygen -A ; adduser xrdp ssl-cert"
%GO% "mv /usr/bin/pkexec /usr/bin/pkexec.orig ; echo gksudo -k -S -g \$1 > /usr/bin/pkexec ; chmod 755 /usr/bin/pkexec"
%GO% "chmod 644 /tmp/xWSL/dist/etc/wsl.conf"
%GO% "chmod 644 /tmp/xWSL/dist/var/lib/xrdp-pulseaudio-installer/*.so"
%GO% "chmod 700 /tmp/xWSL/dist/usr/local/bin/initWSL ; chmod 700 /tmp/xWSL/dist/etc/skel/.config ; chmod 700 /tmp/xWSL/dist/etc/skel/.local ; chmod 700 /tmp/xWSL/dist/etc/skel/.gconf ; chmod 700 /tmp/xWSL/dist/etc/skel/.mozilla"
%GO% "chmod 644 /tmp/xWSL/dist/etc/profile.d/WinNT.sh"
%GO% "chmod 644 /tmp/xWSL/dist/etc/xrdp/xrdp.ini"
%GO% "cp -r /tmp/xWSL/dist/* /"
%GO% "rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh"
%GO% "strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5"

REM ## Setup user access 
SET RUNEND=%date% @ %time%
CD %DISTROFULL% 
ECHO:
ECHO:
SET /p XU=Enter name of %DISTRO% user: 
BASH -c "useradd -m -p nulltemp -s /bin/bash %XU%"
POWERSHELL -Command $prd = read-host "Enter password" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($prd) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp & set /p PWO=<.tmp
BASH -c "echo %XU%:%PWO% | chpasswd"
%GO% "sed -i 's/PLACEHOLDER/%XU%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/COMPY/%COMPUTERNAME%/g' /tmp/xWSL/xWSL.rdp"
%GO% "sed -i 's/RDPPRT/%RDPPRT%/g' /tmp/xWSL/xWSL.rdp"
%GO% "cp /tmp/xWSL/xWSL.rdp ./xWSL._"
ECHO $prd = Get-Content .tmp > .tmp.ps1
ECHO ($prd ^| ConvertTo-SecureString -AsPlainText -Force) ^| ConvertFrom-SecureString ^| Out-File .tmp  >> .tmp.ps1
POWERSHELL -ExecutionPolicy Bypass -Command .tmp.ps1 
TYPE .tmp>.tmpsec.txt
COPY /y /b %DISTROFULL%\xWSL._+.tmpsec.txt "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp" > NUL
DEL /Q  xWSL._ .tmp*.* > NUL
BASH -c "echo '%XU% ALL=(ALL:ALL) ALL' >> /etc/sudoers"

REM ## Open Firewall Ports
NETSH AdvFirewall Firewall add rule name="%DISTRO% xRDP" dir=in action=allow protocol=TCP localport=%RDPPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Secure Shell" dir=in action=allow protocol=TCP localport=%SSHPRT% > NUL
NETSH AdvFirewall Firewall add rule name="%DISTRO% Avahi Multicast DNS" dir=in action=allow program="%DISTROFULL%\rootfs\usr\sbin\avahi-daemon" enable=yes > NUL

REM ## Build RDP, Console, Init Links, Scheduled Task...
ECHO @WSLCONFIG /t %DISTRO% > "%DISTROFULL%\Init.cmd"
ECHO @WSL ~ -u root -d %DISTRO% -e initWSL 2 >> "%DISTROFULL%\Init.cmd"
ECHO @WSL ~ -u %XU% -d %DISTRO% >  "%DISTROFULL%\%DISTRO% (%XU%) Console.cmd"
COPY /Y "%DISTROFULL%\%DISTRO% (%XU%) Console.cmd" "%USERPROFILE%\Desktop\%DISTRO% (%XU%) Console.cmd" > NUL
COPY /Y "%DISTROFULL%\%DISTRO% (%XU%) Desktop.rdp" "%USERPROFILE%\Desktop\%DISTRO% (%XU%) Desktop.rdp" > NUL
START /MIN "%DISTRO% Init" WSL ~ -u root -d %DISTRO% -e initWSL 2
POWERSHELL -C "$WAI = (whoami) ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('AAAA', $WAI) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
POWERSHELL -C "$WAC = (pwd)    ; (Get-Content .\rootfs\tmp\xWSL\xWSL.xml).replace('QQQQ', $WAC) | Set-Content .\rootfs\tmp\xWSL\xWSL.xml"
SCHTASKS /Create /TN:%distro% /XML .\rootfs\tmp\xWSL\xWSL.xml /F
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
ECHO: 
:ENDSCRIPT
