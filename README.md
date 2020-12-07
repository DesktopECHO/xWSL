# [xWSL.cmd (Version 1.3 / 20201207)](https://github.com/DesktopECHO/xWSL)

Beauty and Simplicity - A 'one-liner' command completely configures XFCE 4.16 on Ubuntu 20.04 in WSL

* Much-improved desktop experience:  Updated xrdp to 0.9.13 and performance improvements in many areas (ie: Fullscreen TuxRacer and Minecraft, full-screen YouTube video, fluid desktop effects)
* Copy/Paste text and images work reliably between Windows and Linux in both directions
* RDP Audio playback enabled (YouTube playback in browser works well with no audio/video desync)
* Runs on Windows Server 2019 or Windows 10 Version 1809 (or newer, including Hyper-V Core)

The xWSL instance is accessible from anywhere on your network, connect to it via the MS Remote Desktop Client (mstsc.exe)

You will see best performance connecting from the local machine or over gigabit ethernet.

![xWSL Desktop](https://user-images.githubusercontent.com/33142753/94092529-687a1b80-fdf1-11ea-9e3b-bfbb6228e893.png)

**IMPORTANT!  Requires August/Sept 2020 WSL update for Windows 10, included in 20H2:**

* 1809 - KB4571748
* 1909 - KB4566116
* 2004 - KB4571756
* 20H2 - FIXED

**INSTRUCTIONS:  From an elevated prompt, change to your desired install directory and type/paste the following command:**

    PowerShell -executionpolicy bypass -command "wget https://github.com/DesktopECHO/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"

You will be asked a few questions.  The install script finds out the current DPI scaling from Windows; you can set your own value if preferred:

    [xWSL Installer 20201207]

    Enter a unique name for your xWSL distro or hit Enter to use default.
    Keep this name simple, no space or underscore characters [xWSL]:
    Port number for xRDP traffic or hit Enter to use default [3399]:
    Port number for SSHd traffic or hit Enter to use default [3322]:
    Set a custom DPI scale, or hit Enter to use Windows value [120]:
    [Not recommended!] Type X to eXclude from Windows Defender: X

    Installing xWSL Distro [xWSL] to "C:\Users\Zero\xWSL"
    This will take a few minutes, please wait...    

The installer will download the Windows Store Ubuntu image and the customizations located in this repository. 

    [20:35:21] Installing Ubuntu 20.04 LTS
    [20:36:51] Git clone xWSL from GitHub
    [20:38:00] Install base packages
    [20:44:59] Install dependencies for desktop environment
    [20:46:46] Install XFCE4 desktop environment
    [20:49:41] Install media playback components
    [20:51:46] Cleaning up unneeded packages
    [20:52:44] Install Mozilla Seamonkey web browser
   
At the end of the script you will be prompted to create a non-root user which will automatically be added to sudo'ers.

    Enter name of primary user for xWSL: zero
    Enter password for zero: ********

    Open Windows Firewall Ports for xRDP, SSH, mDNS...
    Building RDP Connection file, Console link, Init system...
    Building Uninstaller... [C:\Users\Zero\xWSL\Uninstall xWSL.cmd]
    Building Scheduled Task...
    SUCCESS: The scheduled task "xWSL" has successfully been created.

          Start: Mon 11/09/2020 @ 20:29
            End: Mon 11/09/2020 @ 20:54
       Packages: 911

      - xRDP Server listening on port 3399 and SSHd on port 3322.

      - Links for GUI and Console sessions have been placed on your desktop.

      - (Re)launch init from the Task Scheduler or by running the following command:
        schtasks /run /tn xWSL

     xWSL Installation Complete!  GUI will start in a few seconds...


A successful xWSL install will report 911 packages installed.  If the count shown is lower, it means you had a download failure and it is advisable to uninstall and re-start the installation.

Upon completion the Remote Desktop client will launch a functional XFCE4 Desktop.  A scheduled task is created for starting/managing xWSL.

**If you want to start xWSL at boot (like a service) perform the following steps:**

* Right-click the task in Task Scheduler, click properties
* Click the checkboxes for **Run whether user is logged on or not** and click **OK**
* Enter your Windows credentials when prompted

**To  restart the instance:  (In this example using the default distro name of  'xWSL')**

* `schtasks /run /tn xWSL`

**To terminate the instance:**

* `wslconfig /t xWSL`

**Convert to WSL2 Virtual Machine:**

* xWSL can convert easily to a WSL2 VM if required.  First convert the instance: `wsl --set-version [DistroName] 2`
* Change the hostname in the .RDP connection file to point at the WSL2 instance.  Assuming we're using the default distribution name of `xWSL` (use whatever name you assigned to the distro)  Right click the .RDP file in Windows, click Edit.  Change the Computer name to your Windows hostname and add `-xWSL.local` to the end.
* For example, if the current value is `LAPTOP:3399`, change it to `LAPTOP-xWSL.local:3399` and save the RDP connection file.  Your WSL2 instance resolves seamlessly with the Windows host using multicast DNS.

**Make it your own:**

It's highly advisable to fork this project into your own repository so you have complete control over the packages and scripts in the repository, making further customization easy:

* Sign into GitHub and fork this project
* Edit `xWSL.cmd`.  On line 2 you will see `SET GITORG=DesktopECHO` \- Change `DesktopECHO` to the name of your repository.
* Personalize the script with dev toolkits or whatever it is you're working on.
* Launch the script using your repository name: `PowerShell -executionpolicy bypass -command "wget https://github.com/YOUR-REPO-NAME/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"`

**Quirks Addressed / Additional Info:**

* When you log out out of an XFCE session the WSL instance is restarted. This is the equivilent to having a freshly-booted desktop environment at every login, but the 'reboot' process only takes about 5 seconds.
* xWSL should work fine with an X Server instead of xRDP but this has not been thoroughly tested. The file /etc/profile.d/xWSL.sh contains WSL-centric environment variables that may need adjustment such as LIBGL_ALWAYS_INDIRECT.
* WSL1 Doesn't work with PolicyKit. Enabled kdesu for apps needing elevated rights (plasma-discover, ksystemlog, muon, root console.)
* Rebuilt xrdp 0.9.13 thanks to Sergey Dryabzhinsky @ http://packages.rusoft.ru/ppa/rusoft/xrdp/
* Apt-fast was added to improve download speed and reliability.
* Mozilla Seamonkey is bundled as a stable browser that's kept up to date via apt.  Current versions of Chrome / Firefox do not work in WSL1.
* Installed image consumes approximately 2.6 GB of disk space
* XFCE uses the Plata (light or dark) theme and Windows fonts (Segoe UI / Cascadia Code)
* This is a basic installation of XFCE to save bandwidth.  If you want the **complete** XFCE Desktop environment run `sudo apt-get install xubuntu-desktop`
* Uninstaller is located in root of xWSL folder, **Uninstall xWSL.cmd**

**Screenshots:**

xWSL Install Complete![xWSL Install Complete](https://user-images.githubusercontent.com/33142753/98679083-dcd33480-2335-11eb-98f2-d03114d7b2fd.png)

xWSL Install Folder![xWSL Install Folder](https://user-images.githubusercontent.com/33142753/98679263-215ed000-2336-11eb-8d06-5463f0614e87.png)
