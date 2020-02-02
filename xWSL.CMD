@ECHO OFF
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
CLS
ECHO xWSL Installer // Daniel Milisic // dmilisic@desktopecho.com
set "DISTRO=xWSL" 
set "RDPPRT=3388"
set "SSHPRT=3322"
set /p DISTRO=Entfer a unique name for the distro or hit Enter to use default [xWSL]:
set /p RDPPRT=Enter port number for xRDP traffic or hit Enter to use default [3388]:
set /p SSHPRT=Enter port number for SSHd traffic or hit Enter to use default [3322]:
REM Quit on Name Collision
IF EXIST %DISTRO% ECHO FOLDER EXISTS! & EXIT
ECHO Downloading Ubuntu 18.04 for WSL from Microsoft...
REM If We already have the distro don't waste time grabbing it again
IF NOT EXIST %TEMP%\Ubuntu1804.zip POWERSHELL.EXE -Command "wget https://aka.ms/wsl-ubuntu-1804 -UseBasicParsing -OutFile %TEMP%\Ubuntu1804.zip"
REM But always refresh xWSLres from GitHub
IF EXIST %TEMP%\xWSLres.zip DEL %TEMP%\xWSLres.zip
POWERSHELL.EXE -Command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSLres.zip -UseBasicParsing -OutFile %TEMP%\xWSLres.zip"
POWERSHELL.EXE -command "Expand-Archive %TEMP%\Ubuntu1804.zip -DestinationPath .\%DISTRO%"
POWERSHELL.EXE -command "Expand-Archive %TEMP%\xWSLres.zip       -DestinationPath .\%DISTRO%\xWSLres"
NETSH AdvFirewall Firewall add rule name="XRDP Port %RDPPRT% for WSL" dir=in action=allow protocol=TCP localport=%RDPPRT%
NETSH AdvFirewall Firewall add rule name="SSHd Port %SSHPRT% for WSL" dir=in action=allow protocol=TCP localport=%SSHPRT%
CD \%DISTRO%\xWSL
REM Install Distro with LxRunOfflineunOffline -- https://github.com/DDoSolitary/LxRunOfflineunOffline
LxRunOffline install -n %DISTRO% -d . -f install.tar.gz
REM Register Distro
LxRunOffline sd -n %DISTRO%
REM Workaround WSL DNS Isssue
WSL rm -f /etc/resolv.conf ; cp resolv.conf /etc/resolv.conf ; chmod 444 /etc/resolv.conf
REM Pull in Seamonkey as default browser
WSL cp .mozilla.list /etc/apt/sources.list.d/mozilla.list ; apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C 
REM Pull in PPA's
WSL add-apt-repository -y ppa:xubuntu-dev/staging ; add-apt-repository -y ppa:mark-pcnetspec/gksu ; apt-add-repository -y ppa:remmina-ppa-team/remmina-next ; add-apt-repository -y ppa:system76/pop ; add-apt-repository -y ppa:xubuntu-dev/ppa ; apt update
<<<<<<< HEAD
WSL dpkg --clear-selections ; dpkg --set-selections < packagelist ; DEBIAN_FRONTEND=noninteractive apt -y upgrade -o APT::Install-Suggests=0 -o APT::Install-Recommends=0
=======
WSL apt -y install gksu imagemagick cgroup-lite zip libnotify-bin at-spi2-core wslu xfce4 xfce4-panel xfce4-terminal thunar dbus-x11 libgtk-3-bin mousepad thunar-volman xfce4-notifyd thunar-archive-plugin remmina-common remmina-plugin-exec remmina-plugin-rdp remmina-plugin-secret remmina-plugin-vnc remmina-plugin-www filezilla xorg libgtk-3-bin xfce4 xfce4-terminal seamonkey -o APT::Install-Suggests=0 -o APT::Install-Recommends=0
>>>>>>> fdc4504a76a7cf601b5b71d60ab7f6d4ee726556
REM This older version of Synaptic works fine and prevents a crap-ton of dependancies from getting pulled in:
WSL apt -y install ./xWSLres/libxapian22v5_1.2.22-2-xWSL_amd64.deb ./xWSLres/synaptic_0.83-xWSL_amd64.deb xrdp xorgxrdp -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 
WSL apt-mark hold synaptic
WSL rm -rf /etc/skel ; cp -rp ./xWSLres/skel/ /etc/ ; chown -R root:root /etc/skel ; chmod -R 755 /etc/skel
REM Ugly but effective replacement of pkexec with gksu, hey at least Synaptic elevates properly now  
WSL mv /usr/bin/pkexec /usr/bin/pkexec.xWSL ; ln -s /usr/bin/gksu /usr/bin/pkexec 
REM It's a Microsoft OS we might as well pull in the nice fonts...
WSL ln -s /mnt/c/Windows/Fonts /usr/share/fonts/truetype/microsoft
REM Custom xrdp config
WSL rm /etc/xrdp/xrdp.ini ; rm /etc/xrdp/sesman.ini ; cp ./xWSLres/*.ini /etc/xrdp ; cp ./xWSLres/xWSL*.png /usr/share/pixmaps
REM Get rid of a bunch of useless bits taking up space
WSL rm -rf /usr/share/themes/Xfce* ; rm -rf /usr/share/themes/ZOMG* ; rm -rf /usr/share/themes/R* ; rm -rf /usr/share/icons/Humanity*
WSL sed -i 's/3388/%RDPPRT%/g' /etc/xrdp/xrdp.ini
WSL sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config
WSL sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
WSL cp ./xWSLres/wslinit /usr/local/bin/wslinit ; chown root:root /usr/local/bin/wslinit ; chmod 755 /usr/local/bin/wslinit
WSL md /var/lib/xrdp-pulseaudio-installer ; /cp ./xWSLres/module-xrdp-* /var/lib/xrdp-pulseaudio-installer
CLS
set /p xu=Enter name of xWSL user: 
bash -c "useradd -m -p nulltemp -s /bin/bash %xu%"
powershell -Command $pword = read-host "Enter password" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt & set /p password=<.tmp.txt & del .tmp.txt
bash -c "echo %xu%:%password% | chpasswd"
bash -c "echo '%xu% ALL=(ALL:ALL) ALL' >> /etc/sudoers"
./xWSLres
./xWSLres/FreeRDP/WfreeRDP /f /v:localhost:%RDPPRT% /u:%xu% /p:%password%
