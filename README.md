# [xWSL.cmd (Version 1.3 / 20201211)](https://github.com/DesktopECHO/xWSL)

One command to NetInstall Ubuntu 20.04, xRDP, and XFCE 4.16-beta on WSL.

* Improved desktop experience, performance improvements in many areas
* [Ubuntu Graphics](https://launchpad.net/~oibaf/+archive/ubuntu/graphics-drivers) update with Mesa 21 on LLVM 11 
* [XFCE 4.16-beta](https://launchpad.net/~bluesabre/+archive/ubuntu/xfce-4.16)
* RDP Audio playback enabled (YouTube playback in browser works well with no audio/video desync)
* Runs on Windows Server 2019 or Windows 10 Version 1809 (or newer, including Hyper-V Core)
* Chrome Remote Desktop pre-installed, see wiki for steps to enable

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

You will be asked a few questions.  The installer script finds the current DPI scaling in Windows, you can set your own value if preferred:

    [xWSL Installer 20201207]

    Enter a unique name for your xWSL distro or hit Enter to use default.
    Keep this name simple, no space or underscore characters [xWSL]:
    Port number for xRDP traffic or hit Enter to use default [3399]:
    Port number for SSHd traffic or hit Enter to use default [3322]:
    Set a custom DPI scale, or hit Enter to use Windows value [120]:
    [Not recommended!] Type X to eXclude from Windows Defender: X

    Installing xWSL Distro [xWSL] to "C:\Users\Zero\xWSL"
    This will take a few minutes, please wait...    

The installer will download and install the [**LxRunOffline**](https://github.com/DDoSolitary/LxRunOffline) distro manager and [Windows Store Ubuntu image](https://www.microsoft.com/en-bm/p/ubuntu/9nblggh4msv6?).  Reference times will vary depending on system performance and the presence of antivrirus software.  A fast system amd network can complete the install in less than 10 minutes. 

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


A successful xWSL install will show 956 packages installed.  When install completes the XFCE desktop session is launched using saved credentials. 

**Configure xWSL to start at boot (like a service, no console window)**

 - Right-click the task in Task Scheduler, click properties
 - Click the checkbox for **Run whether user is logged on or not** and click **OK**
 - Enter your Windows credentials when prompted
 
 Reboot your PC when complete and xWSL will startup automatically.

**Start/Stop Operation**

* Reboot the instance (example with default distro name of 'xWSL'): ````schtasks /run /tn xWSL```` 
* Terminate the instance: ````wslconfig /t xWSL````

**xWSL leverages Multicast DNS to lookup WSL2 instances**

If your computer has virtualization support you can convert it to WSL2.  xWSL is faster on WSL1, but WSL2 has additional capabilities. 

Example of conversion to WSL2 on machine name "ENVY":
 - Stop WSL on ENVY:
    ````wsl --shutdown````
 - Convert the instance to WSL2:
    ````wsl --set-version xWSL 2````
 - Restart kWSL Instance:
    ````schtasks /run /tn xWSL````
 - Edit the RDP file on your desktop to point at the WSL2 instance by adding ````-xWSL.local```` to the hostname:
    ````ENVY-xWSL.local:3399````

**Make it your own:**

From a security standpoint, it would be best to fork this project so you (and only you) control the packages and files in the repository.

- Sign into GitHub and fork this project
- Edit ```xWSL.cmd```.  On line 2 you will see ```SET GITORG=DesktopECHO``` - Change ```DesktopECHO``` to the name of your own repository.
- Customize the script any way you like.
- Launch the script using your repository name:
 ```PowerShell -executionpolicy bypass -command "wget https://github.com/YOUR-REPO-NAME/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"```

**Quirks / Limitations / Additional Info:**

* When you log out out of a desktop session the entire xWSL instance is restarted, the equivilent of a clean-boot at every login.  
* xWSL should work fine with an X Server instead of xRDP but this has not been thoroughly tested. The file /etc/profile.d/xWSL.sh contains WSL-centric environment variables that may need adjustment such as LIBGL_ALWAYS_INDIRECT.
* WSL1 Doesn't work with PolicyKit. Enabled gksu for apps needing elevated rights (Synaptic, root console)
* Rebuilt xrdp 0.9.13 thanks to Sergey Dryabzhinsky @ http://packages.rusoft.ru/ppa/rusoft/xrdp/
* [Apt-fast](https://github.com/ilikenwf/apt-fast) added to improve download speed and reliability.
* Mozilla Seamonkey included as a stable browser that's kept up to date via apt.  Current versions of Chrome / Firefox do not work in WSL1.
* Installed image consumes approximately 2.6 GB of disk space
* XFCE uses the Plata (light or dark) theme and Windows fonts (Segoe UI / Cascadia Code)
* This is a basic installation of XFCE to save bandwidth.  If you want the complete XFCE Desktop environment run `sudo apt-get install xubuntu-desktop`
* Uninstaller is located in root of xWSL folder, **Uninstall xWSL.cmd** - Make sure you 'Run As Administrator' to ensure removal of the scheduled task and firewall rules

**Screenshots:**

xWSL Install Complete![xWSL Install Complete](https://user-images.githubusercontent.com/33142753/98679083-dcd33480-2335-11eb-98f2-d03114d7b2fd.png)

xWSL Install Folder![xWSL Install Folder](https://user-images.githubusercontent.com/33142753/98679263-215ed000-2336-11eb-8d06-5463f0614e87.png)
