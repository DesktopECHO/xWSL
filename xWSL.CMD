@ECHO OFF
POWERSHELL.EXE -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux"
CLS
ECHO xWSL Installer // Daniel Milisic // dmilisic@desktopecho.com
ECHO Downloading Ubuntu 18.04 for WSL from Microsoft...
IF NOT EXIST Ubuntu1804.exe POWERSHELL.EXE -command "wget https://aka.ms/wsl-ubuntu-1804 -UseBasicParsing -OutFile xWSL.ZIP"
set "DISTRO=xWSL" 
set "RDPPRT=3388"
set "SSHPRT=3322"
set /p DISTRO=Enter a unique name for the distro or hit Enter to use default [xWSL]:
set /p RDPPRT=Enter port number for xRDP traffic or hit Enter to use default [3388]:
set /p SSHPRT=Enter port number for SSHd traffic or hit Enter to use default [3322]:
POWERSHELL.EXE -command "Expand-Archive xWSL.ZIP %DISTRO%"
CD %DISTRO%
REM -UseBasicParsing is to prevent IE from doing the download, needed for Server Core or Hyper-V Server 2019
POWERSHELL.EXE -command "wget https://441.surf/xWSLres.zip -UseBasicParsing -OutFile xWSLres.zip"
POWERSHELL.EXE -command "Expand-Archive xWSLres.ZIP"
DEL xWSLres.zip
MOVE .\xWSLres\lxr.exe .\
LXR install -n %DISTRO% -d . -f install.tar.gz
LXR sd -n %DISTRO%

WSL rm -f /etc/resolv.conf ; cp ./xWSLres/resolv.conf /etc/resolv.conf ; chmod 444 /etc/resolv.conf
WSL cp ./xWSLres/mozilla.list /etc/apt/sources.list.d/mozilla.list ; apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2667CA5C 
WSL add-apt-repository -y ppa:xubuntu-dev/staging ; add-apt-repository -y ppa:mark-pcnetspec/gksu ; apt-add-repository -y ppa:remmina-ppa-team/remmina-next ; add-apt-repository -y ppa:system76/pop ; add-apt-repository -y ppa:xubuntu-dev/ppa ; apt update

WSL < ./xWSLres/packagelist xargs sudo DEBIAN_FRONTEND=noninteractive apt-get -y install -o APT::Install-Suggests=0 -o APT::Install-Recommends=0
WSL apt -y install ./xWSLres/libxapian22v5_1.2.22-2-xWSL_amd64.deb ./xWSLres/synaptic_0.83-xWSL_amd64.deb xrdp xorgxrdp -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 ; apt-mark hold synaptic
WSL apt -y --allow-remove-essential remove bind9-host dnsutils initramfs-tools initramfs-tools-core libbind9-160 libdns1100 libirs160 libisc169 libisccc160 libisccfg160 parted cloud-guest-utils cloud-init cloud-initramfs-copymods cloud-initramfs-dyn-netconf friendly-recovery init liblxc-common liblxc1 libnss-systemd libpam-systemd lxd netplan.io networkd-dispatcher nplan plymouth plymouth-theme-ubuntu-text policykit-1 snapd systemd systemd-sysv ubuntu-minimal ubuntu-server ubuntu-standard apparmor apport busybox-initramfs busybox-static dirmngr gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv irqbalance isc-dhcp-client isc-dhcp-common libntfs-3g88 libnuma1 lxcfs lxd-client mdadm ntfs-3g open-iscsi open-vm-tools python3-distupgrade python3-software-properties python3-update-manager software-properties-common ubuntu-release-upgrader-core ufw unattended-upgrades update-manager-core update-notifier-common vim vim-common vim-runtime vim-tiny 
WSL rm -rf /etc/skel ; cp ./xWSLres/skel.tar /etc ; mv /usr/bin/pkexec /usr/bin/pkexec.xWSL ; ln -s /usr/bin/gksu /usr/bin/pkexec ; ln -s /mnt/c/Windows/Fonts /usr/share/fonts/truetype/microsoft ; rm /etc/xrdp/xrdp.ini ; rm /etc/xrdp/sesman.ini ; cp ./xWSLres/*.ini /etc/xrdp ; cp ./xWSLres/xWSL*.png /usr/share/pixmaps ; cd /etc ; tar xvf skel.tar ; rm -rf /usr/share/themes/Xfce* ; rm -rf /usr/share/themes/ZOMG* ; rm -rf /usr/share/themes/R* ; rm -rf /usr/share/icons/Humanity*
WSL sed -i 's/3388/%RDPPRT%/g' /etc/xrdp/xrdp.ini
WSL sed -i 's/#Port 22/Port %SSHPRT%/g' /etc/ssh/sshd_config
WSL sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

NETSH AdvFirewall Firewall add rule name="XRDP Port %RDPPRT% for WSL" dir=in action=allow protocol=TCP localport=%RDPPRT%
NETSH AdvFirewall Firewall add rule name="SSHd Port %SSHPRT% for WSL" dir=in action=allow protocol=TCP localport=%SSHPRT%
CLS
set /p xu=Enter name of xWSL user: 
bash -c "useradd -m -p nulltemp -s /bin/bash %xu%"
powershell -Command $pword = read-host "Enter password" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt & set /p password=<.tmp.txt & del .tmp.txt
bash -c "echo %xu%:%password% | chpasswd"
bash -c "echo '%xu% ALL=(ALL:ALL) ALL' >> /etc/sudoers"
