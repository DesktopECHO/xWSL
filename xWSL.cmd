@ECHO OFF
SET RUNSTART=%date% @ %time%
REM ## Enable WSL
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

REM ## Get install names and port numbers
ECHO xWSL for Ubuntu 20.04  
SET DISTRO=xWSL& SET /p DISTRO=Enter a unique name for the distro or hit Enter to use default [xWSL]: 
SET RDPPRT=3399& SET /p RDPPRT=Enter port number for xRDP traffic or hit Enter to use default [3399]: 
SET SSHPRT=3322& SET /p SSHPRT=Enter port number for SSHd traffic or hit Enter to use default [3322]: 

REM ## Download distro
SET DISTROFULL=%CD%\%DISTRO%
ECHO xWSL (%DISTRO%) To be installed in: %DISTROFULL%
ECHO Downloading Ubuntu 20.04 for WSL (or using local copy if available)
IF NOT EXIST %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz POWERSHELL.EXE -Command "wget https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -UseBasicParsing -OutFile %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz"

REM ## Install Distro with LxRunOffline / https://github.com/DDoSolitary/LxRunOffline
POWERSHELL.EXE -Command "wget https://github.com/DesktopECHO/xWSL/raw/master/LxRunOffline.exe -UseBasicParsing -OutFile %TEMP%\LxRunOffline.exe"
IF EXIST %DISTRO% EXIT
%TEMP%\LxRunOffline.exe i -d .\%DISTRO% -f %TEMP%\ubuntu-20.04-server-cloudimg-amd64-wsl.rootfs.tar.gz -n %DISTRO%
%TEMP%\LxRunOffline.exe sd -n %DISTRO%
MOVE %TEMP%\LxRunOffline.* %DISTROFULL%

REM ## Open Firewall Ports
NETSH AdvFirewall Firewall add rule name="XRDP Port %RDPPRT% for WSL" dir=in action=allow protocol=TCP localport=%RDPPRT%
NETSH AdvFirewall Firewall add rule name="SSHd Port %SSHPRT% for WSL" dir=in action=allow protocol=TCP localport=%SSHPRT%

REM ## Configure Ubuntu 20.04 on WSL
CD %DISTROFULL%
WSL cd /tmp ; git clone --depth=1 https://github.com/DesktopECHO/xWSL.git
WSL ssh-keygen -A
WSL rm -rf /etc/apt/apt.conf.d/20snapd.conf /etc/rc2.d/S01whoopsie /etc/init.d/console-setup.sh
WSL apt-get -y purge irqbalance multipath-tools apparmor snapd squashfs-tools libplymouth5 plymouth plymouth-theme-ubuntu-text open-vm-tools cloud-init isc-dhcp-* mdadm apport open-iscsi powermgmt-base popularity-contest fwupd libfwupd2 --autoremove
WSL add-apt-repository -y ppa:rafaeldtinoco/lp1871129 ; apt-get update ; apt install libc6=2.31-0ubuntu8+lp1871129~1 -y --allow-downgrades ; apt-mark hold libc6
WSL apt-get -y dist-upgrade
WSL apt-get -y install xrdp xorgxrdp xfce4-terminal xfce4-whiskermenu-plugin pulseaudio xfce4-pulseaudio-plugin libatkmm-1.6-1v5 libcairomm-1.0-1v5 libcanberra-gtk3-0 libcanberra-gtk3-module libglibmm-2.4-1v5 libgtkmm-3.0-1v5 libpangomm-1.4-1v5 libsigc++-2.0-0v5 pavucontrol xfwm4 xfce4-panel xfce4-session xfce4-settings dmz-cursor-theme thunar thunar-volman thunar-archive-plugin x11-apps x11-session-utils x11-xserver-utils xfdesktop4 xfce4-screenshooter libdbus-glib-1-2 libsmbclient gigolo gvfs-fuse gvfs-backends gvfs-bin at-spi2-core mtpaint mousepad evince xarchiver binutils lhasa lrzip lzip lzop ncompress zip unzip adapta-gtk-theme papirus-icon-theme synaptic gconf-defaults-service --no-install-recommends
WSL apt-get -y install /tmp/xWSL/deb/gksu_2.0.2-9ubuntu1+peppermint0.0.0.1_amd64.deb /tmp/xWSL/deb/libgnome-keyring0_3.12.0-1build1_amd64.deb /tmp/xWSL/deb/libgksu2-0_2.0.13~pre1-9ubuntu2+peppermint0.0.0.1_amd64.deb /tmp/xWSL/deb/multiarch-support_2.27-3ubuntu1_amd64.deb /tmp/xWSL/deb/libgnome-keyring-common_3.12.0-1build1_all.deb /tmp/xWSL/deb/xrdp_0.9.9-1_amd64.deb --allow-downgrades --force-yes ; apt-mark hold xrdp
WSL sed -i 's/port=3389/port=%RDPPRT%/g' /tmp/xWSL/dist/etc/xrdp/xrdp.ini
WSL sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config
WSL sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
WSL ln -s /mnt/c/Windows/Fonts /usr/share/fonts/truetype/microsoft
WSL systemd-machine-id-setup
WSL mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
WSL mv /bin/pkexec /bin/pkexec.ubuntu ; ln -s /bin/gksudo /bin/pkexec
WSL chmod 644 /tmp/xWSL/dist/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/*.xml
WSL chmod 644 /tmp/xWSL/dist/etc/wsl.conf
WSL chmod 644 /tmp/xWSL/dist/var/lib/xrdp-pulseaudio-installer/*.so
WSL chmod 700 /tmp/xWSL/dist/usr/local/bin/initWSL
WSL chmod 644 /tmp/xWSL/dist/etc/profile.d/xwsl.sh
WSL chmod 644 /tmp/xWSL/dist/etc/xrdp/xrdp.ini
WSL chmod 644 /tmp/xWSL/dist/etc/skel/.moonchild\ productions/pale\ moon/xWSL.default/*
WSL adduser xrdp ssl-cert
WSL cp -r /tmp/xWSL/dist/* /

REM ## Install Mozilla or Pale Moon Browser
WSL sed -i -e "\$adeb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" /etc/apt/sources.list
WSL apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C
WSL apt-get update ; apt-get -y install xdg-utils seamonkey-mozilla-build
WSL update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/seamonkey 100 ; update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/seamonkey 100 ; update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/seamonkey 100
REM ## WSL sh -c "echo 'deb http://download.opensuse.org/repositories/home:/stevenpusser/xUbuntu_20.04/ /' > /etc/apt/sources.list.d/home:stevenpusser.list"
REM ## WSL wget -nv https://download.opensuse.org/repositories/home:stevenpusser/xUbuntu_20.04/Release.key -O ~/Release.key ; apt-key add ~/Release.key ; apt-get update ; apt-get -y install palemoon --no-install-recommends
WSL apt clean

REM ## Setup user access 
CD %DISTROFULL%
SET /p xu=Enter name of xWSL user: 
BASH -c "useradd -m -p nulltemp -s /bin/bash %xu%"
POWERSHELL -Command $prd = read-host "Enter password" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($prd) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt & set /p password=<.tmp.txt
BASH -c "echo %xu%:%password% | chpasswd"
WSL sed -i 's/PLACEHOLDER/%xu%/g' /tmp/xWSL/xWSL.rdp
WSL sed -i 's/COMPY/%COMPUTERNAME%/g' /tmp/xWSL/xWSL.rdp
WSL sed -i 's/RDPPRT/%RDPPRT%/g' /tmp/xWSL/xWSL.rdp
WSL cp /tmp/xWSL/xWSL.rdp ./xWSL._
ECHO $prd = Get-Content .tmp.txt > .tmp.ps1
ECHO ($prd ^| ConvertTo-SecureString -AsPlainText -Force) ^| ConvertFrom-SecureString ^| Out-File .tmp.txt  >> .tmp.ps1
POWERSHELL -Command .tmp.ps1 
TYPE .tmp.txt>.tmpsec.txt
COPY /y /b %DISTROFULL%\xWSL._+.tmpsec.txt %DISTROFULL%\%DISTRO%.rdp > NUL
DEL /Q  xWSL._ .tmp*.* > NUL
BASH -c "echo '%xu% ALL=(ALL:ALL) ALL' >> /etc/sudoers"
ECHO WSL -u %xu% -d %DISTRO%  > "%DISTROFULL%\%DISTRO%-%xu%.cmd"
ECHO WSLCONFIG /t %DISTRO%    > "%DISTROFULL%\%DISTRO%-Init.cmd"
ECHO WSL -u root -d %DISTRO% -e initWSL 2  >> "%DISTROFULL%\%DISTRO%-Init.cmd"
SCHTASKS /CREATE /RU %USERNAME% /RL HIGHEST /SC ONSTART /TN "%DISTRO%-Init" /TR "%DISTROFULL%\%DISTRO%-Init.cmd" /F
ECHO $task = Get-ScheduledTask "%DISTRO%-Init" ; $task.Settings.ExecutionTimeLimit = "PT0S" ; Set-ScheduledTask $task > %TEMP%\ExecTimeLimit.ps1
POWERSHELL -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -COMMAND %TEMP%\ExecTimeLimit.ps1
START /MIN "xWSL Runlevel" "%DISTROFULL%\%DISTRO%-Init.cmd""
IF EXIST "%USERPROFILE%\Desktop\%DISTRO% Console (%xu%)" DEL "%USERPROFILE%\Desktop\%DISTRO% Console (%xu%)" > NUL
MKLINK "%USERPROFILE%\Desktop\%DISTRO% Console (%xu%)" "%DISTROFULL%\%DISTRO%-%xu%.cmd" > NUL
COPY /Y "%DISTROFULL%\%DISTRO%.rdp" "%USERPROFILE%\Desktop\%DISTRO% Desktop (%xu%).rdp" > NUL
SET RUNEND=%date% @ %time%
ECHO.
ECHO.  Start: %RUNSTART%
ECHO.    End: %RUNEND%
ECHO. 
ECHO. Installation Complete.  xRDP server listening on port %RDPPRT% and SSH on port %SSHPRT%
ECHO. Links for GUI and Console sessions have been placed on your desktop.
ECHO. Autolaunching RDP Desktop Session in 5 seconds...
PING -n 6 LOCALHOST > NUL 
MSTSC.EXE "%DISTROFULL%\%DISTRO%.rdp"
