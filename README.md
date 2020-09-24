# xWSL.cmd

- Simplicity - A 'one-liner' completely sets up XFCE in WSL
- Runs on Windows Server 2019 or Windows 10 Version 1803 (or newer, including Server Core)
- XFCE 4.14 on Ubuntu 20.04 
- xRDP Display Server, no additional X Server downloads required
- RDP Audio playback enabled (YouTube playback in browser works)

**INSTRUCTIONS:  From an elevated CMD.EXE prompt change to your desired install directory and type/paste the following command:**

```
PowerShell -executionpolicy bypass -command "wget https://github.com/DesktopECHO/xWSL/raw/Testing/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"
```

You will be asked a few questions.  The install script finds out the current DPI scaling from Windows; you can set your own value if needed:

```
xWSL for Devuan Linux
Enter a unique name for the distro or hit Enter to use default [xWSL]:
Enter port number for xRDP traffic or hit Enter to use default [3399]:
Enter port number for SSHd traffic or hit Enter to use default [3322]:
Enter X to eXclude WSL1 instances from Windows Defender: 
Enter DPI Scaling or hit Enter to use default [96]:
xWSL to be installed in C:\xWSL
```

Exclusions will be automatically added to Windows Defender if you requested:

```
Added exclusion for C:\xWSL
Added exclusion for C:\xWSL\rootfs\bin\*
Added exclusion for C:\xWSL\rootfs\sbin\*
Added exclusion for C:\xWSL\rootfs\usr\bin\*
Added exclusion for C:\xWSL\rootfs\usr\sbin\*
Added exclusion for C:\xWSL\rootfs\usr\local\bin\*
Added exclusion for C:\xWSL\rootfs\usr\local\go\bin\*
```

The installer will download all the necessary packages to convert the Windows Store Debian image into Devuan Linux with XFCE.
Near the end of the script you will be prompted to create a non-root user.  This user will be automatically added to sudo'ers.

```
Enter name of xWSL user: zero
Enter password: ********

      Start: Sat 07/25/2020 @ 14:05:11.49
        End: Sat 07/25/2020 @ 14:15:49.42
   Packages: 962

  - xRDP Server listening on port 3399 and SSHd on port 3322.

  - Links for GUI and Console sessions have been placed on your desktop.

  - (Re)launch init from the Task Scheduler or by running the following command:
    schtasks /run /tn xWSL

 xWSL Installation Complete!  GUI will start in a few seconds...
```

Currently you should see approximately 962 packages installed.  If the number reported is much lower it means you had a download failure and need to re-start the install.

Upon completion you'll be logged into an attractive and fully functional XFCE Plasma.  A scheduled task is created for starting/managing xWSL. 

   **If you want to start xWSL at boot (like a service with no console window) do the following:**

   - Right-click the task in Task Scheduler, click properties
   - Click the checkboxes for **Run whether user is logged on or not** and **Hidden** then click **OK**
   - Enter your Windows credentials when prompted

   Reboot your PC.  xWSL will automatically start at boot, no need to login to Windows.

**Convert to WSL2 Virtual Machine:**
-  xWSL will convert easily to WSL2.  Only one additional adjustment is necessary; change the hostname in the .RDP connection file to point at the WSL2 instance.  First convert the instance:
    ```wsl --set-version [DistroName] 2```
- Assuming we're using the default distro name of ```xWSL``` (use whatever name you assigned to the distro)  Right click the .RDP file in Windows, click Edit.  Change the Computer name to your Windows hostname plus **```-xWSL.local```**  Your WSL2 instance resolves seamlessly using multicast DNS  
- For example, if the current value is ```LAPTOP:3399```, change it to ```LAPTOP-xWSL.local:3399``` and save the RDP connection file.  

**Make it your own:**

From a security standpoint, it would be best to fork this project so you (and only you) control the packages and files in the repository.

- Sign into GitHub and fork this project
- Edit ```xWSL.cmd```.  On line 2 you will see ```SET GITORG=DesktopECHO``` - Change ```DesktopECHO``` to the name of your own repository.
- Customize the script any way you like.
- Launch the script using your repository name:
 ```PowerShell -executionpolicy bypass -command "wget https://github.com/YOUR-REPO-NAME/xWSL/raw/Devuan/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"```

**Quirks Addressed / Additional Info:**
- xWSL should work fine with an X Server instead of xRDP but this has not been thoroughly tested.  The file ```/etc/profile.d/WinNT.sh``` contains WSL-centric environment variables that may need adjustment such as LIBGL_ALWAYS_INDIRECT.
- WSL1 Has issues with the latest libc6 library.  The package is being held until fixes from MS are released over Windows Update.  Unmark and update libc6 after MS releases the update.
- WSL1 Doesn't work with PolicyKit.  Pulled-in GKSU and dependencies to accommodate GUI apps that need elevated rights.  
- Rolled back and held xRDP until the current update is better-behaved (xrdp-chansrv high CPU %)
- Current versions of Chrome / Firefox do not work in WSL1; Mozilla Seamonkey is included as the 'official' stable/maintained browser
- Installed image consumes approximately 2.6 GB of disk space
- XFCE uses the Adwaita-Dark theme and Windows fonts (Segoe UI / Consolas)
- Copy/Paste of text and images work reliably between Windows and Linux
- This is a basic installation of XFCE to save bandwidth.  If you want the **complete** XFCE Desktop environment run ```sudo apt-get install xfce4-desktop-environment``` 
