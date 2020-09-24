# xWSL.cmd (Version 1.1 / 20200923)

- Simplicity - A 'one-liner' completely configures XFCE 4.14 on Ubuntu 20.04 in WSL
- Much-improved desktop experience:  Updated xrdp to 0.9.13 and performance improvements in many areas (ie: Fullscreen TuxRacer and Minecraft, full-screen YouTube video, fluid desktop effects)
- Copy/Paste text and images work reliably between Windows and Linux in both directions
- RDP Audio playback enabled (YouTube playback in browser works well with no audio/video desync)
- Runs on Windows Server 2019 or Windows 10 Version 1809 (or newer, including Hyper-V Core)

The xWSL instance is accessible from anywhere on your network, connect to it via the MS Remote Desktop Client (mstsc.exe)

You will see best performance connecting from the local machine or over gigabit ethernet. 

<img width="1280" alt="xWSL1" src="https://user-images.githubusercontent.com/33142753/94092529-687a1b80-fdf1-11ea-9e3b-bfbb6228e893.png">

**INSTRUCTIONS:  From an elevated prompt, change to your desired install directory and type/paste the following command:**

```
PowerShell -executionpolicy bypass -command "wget https://github.com/DesktopECHO/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"
```

You will be asked a few questions.  The install script finds out the current DPI scaling from Windows; you can set your own value if preferred:

```
xWSL Installer

Enter a unique name for the distro or hit Enter to use default [xWSL]:
Set custom DPI scale or hit Enter to use Windows value [144]:
Port number for xRDP traffic or hit Enter to use default [3399]:
Port number for SSHd traffic or hit Enter to use default [3322]:
[Not recommended!] Type X to eXclude xWSL from Windows Defender:

xWSL to be installed in C:\Users\TestUser\xWSL
```

The installer will download the Windows Store Ubuntu image and the customizations located in this repository.
Near the end of the script you will be prompted to create a non-root user which will automatically be added to sudo'ers.

```
Enter name of xWSL user: zero
Enter password: ********
SUCCESS: The scheduled task "xWSL" has successfully been created.

      Start: Wed 09/23/2020 @ 15:37:23.97
        End: Wed 09/23/2020 @ 15:50:17.19
   Packages: 910

  - xRDP Server listening on port 3399 and SSHd on port 3322.

  - Links for GUI and Console sessions have been placed on your desktop.

  - (Re)launch init from the Task Scheduler or by running the following command:
    schtasks /run /tn xWSL

 xWSL Installation Complete!  RDP Client will start in a few seconds...
```

Currently you should see approximately 910 packages installed.  If the number reported is lower it means you had a download failure and should re-start the installation.

Upon completion the Remote Desktop client will launch a functional XFCE4 Desktop.  A scheduled task is created for starting/managing xWSL. 

   **If you want to start xWSL at boot (like a service) perform the following steps:**

   - Right-click the task in Task Scheduler, click properties
   - Click the checkboxes for **Run whether user is logged on or not** and click **OK**
   - Enter your Windows credentials when prompted

   **Convert to WSL2 Virtual Machine:**
-  xWSL can convert easily to a WSL2 VM if required.  First convert the instance:
    ```wsl --set-version [DistroName] 2```
- Change the hostname in the .RDP connection file to point at the WSL2 instance.  Assuming we're using the default distro name of ```xWSL``` (use whatever name you assigned to the distro)  Right click the .RDP file in Windows, click Edit.  Change the Computer name to your Windows hostname and add **```-xWSL.local```** to the end.  Your WSL2 instance resolves seamlessly with the Windows host using multicast DNS.
- For example, if the current value is ```LAPTOP:3399```, change it to ```LAPTOP-xWSL.local:3399``` and save the RDP connection file.  

**Make it your own:**

It's highly advisable to fork this project into your own repository so you have complete control over the packages and scripts in the repository, making further customization easy:

- Sign into GitHub and fork this project
- Edit ```xWSL.cmd```.  On line 2 you will see ```SET GITORG=DesktopECHO``` - Change ```DesktopECHO``` to the name of your repository.
- Personalize the script with dev toolkits or whatever it is you're working with
- Launch the script using your repository name:
 ```PowerShell -executionpolicy bypass -command "wget https://github.com/YOUR-REPO-NAME/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"```

**Quirks Addressed / Additional Info:**

- xWSL works fine with an X Server instead of xRDP but this has not been thoroughly tested.  The file ```/etc/profile.d/WinNT.sh``` contains WSL-centric environment variables that may need adjustment such as LIBGL_ALWAYS_INDIRECT.
- WSL1 Has issues with the latest libc library.  The package is being held so unmark and update libc after you get the updated WSL kernel. 
   [1809] **KB4571748**  *  [1903/1909] **KB4566116**  *  [2004] **KB4571756**
- WSL1 Doesn't work with PolicyKit.  Pulled-in GKSU and dependencies to accommodate GUI apps that need elevated rights.  
- Mozilla Seamonkey is bundled as a stable browser that's kept up to date via apt.  Current versions of Chrome / Firefox do not work in WSL1.
- Installed image consumes approximately 2.6 GB of disk space
- XFCE uses the Plata (light or dark) theme and Windows fonts (Segoe UI / Cascadia Code)
- This is a basic installation of XFCE to save bandwidth.  If you want the **complete** XFCE Desktop environment run ```sudo apt-get install xubuntu-desktop``` 
- Uninstall Instructions: https://github.com/DesktopECHO/xWSL/wiki/Uninstallation
