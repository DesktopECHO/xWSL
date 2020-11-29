# kWSL.cmd - KDE Neon 5.20 for WSL1

  - NetInstall of KDE Neon 5.20 on WSL1
  - Easy to deploy
  - Runs on Windows Server 2019 or Windows 10 Version 1809 (or newer, including Server Core)
  - xRDP Display Server, no additional X Server downloads required
  - RDP Audio playback enabled (YouTube playback in browser works with audio in sync)
  - Chrome Remote Desktop pre-installed, see wiki for simple steps to enable

![image](https://user-images.githubusercontent.com/33142753/100149597-d3d57d80-2e74-11eb-899a-a7476b016e27.png)

**IMPORTANT! Requires August/Sept 2020 WSL update for Windows 10, included in 20H2:**
  - 1809 - KB4571748
  - 1909 - KB4566116
  - 2004 - KB4571756
  - 20H2 - FIXED

**INSTRUCTIONS:  From an elevated CMD.EXE prompt change to your desired install directory and type/paste the following command:**

```
PowerShell -executionpolicy bypass -command "wget https://github.com/DesktopECHO/kWSL/raw/master/kWSL.cmd -UseBasicParsing -OutFile kWSL.cmd ; .\kWSL.cmd"
```

You will be asked a few questions.  The install script finds the current DPI scaling, you can set your own value if needed:

```
[kWSL Installer 20201124]

Enter a unique name for your kWSL distro or hit Enter to use default.
Keep this name simple, no space or underscore characters [kWSL]: Neon
Port number for xRDP traffic or hit Enter to use default [3399]: 13399
Port number for SSHd traffic or hit Enter to use default [3322]: 13322
Set a custom DPI scale, or hit Enter for Windows default [1.5]: 1.25
[Not recommended!] Type X to eXclude from Windows Defender:

Installing kWSL Distro [Neon] to "C:\WSL Distros\Neon"
This will take a few minutes, please wait...
```

The installer will download all the necessary packages to convert the Windows Store Ubuntu 20.04 image into KDE Neon 5.20.  Reference times will vary depending on system performance and the presence of antivrirus software.  A fast system/network can complete the install in about 10 minutes.

```
[16:07:04] Installing Ubuntu 20.04 LTS (~1m30s)
[16:07:56] Git clone and update repositories (~1m15s)
[16:08:51] Remove un-needed packages (~1m30s)
[16:09:22] Configure apt-fast Downloader (~0m45s)
[16:09:34] Remote Desktop Components (~2m45s)
[16:11:07] KDE Neon 5.20 User Edition (~11m30s)
[16:16:39] Install Mozilla Seamonkey and media playback (~1m30s)
[16:17:02] Final clean-up (~0m45s)
```

Near the end of the script you will be prompted to create a non-root user.  This user will be automatically added to sudo'ers.

```
Open Windows Firewall Ports for xRDP, SSH, mDNS...
Building RDP Connection file, Console link, Init system...
Building Scheduled Task...
SUCCESS: The scheduled task "Neon" has successfully been created.

      Start: Tue 11/24/2020 @ 16:06
        End: Tue 11/24/2020 @ 16:17
   Packages: 1327

  - xRDP Server listening on port 13399 and SSHd on port 13322.

  - Links for GUI and Console sessions have been placed on your desktop.

  - (Re)launch init from the Task Scheduler or by running the following command:
    schtasks /run /tn Neon

 Neon Installation Complete!  GUI will start in a few seconds...
```
The install summary should indicate 1327 or 1328 packages installed, depending on Windows version.   

**Upon completion you'll be logged into your KDE Desktop.** 

**Configure kWSL to start at boot (like a service, no console window)**

 - Right-click the task in Task Scheduler, click properties
 - Click the checkbox for **Run whether user is logged on or not** and click **OK**
 - Enter your Windows credentials when prompted
 
 Reboot your PC when complete and kWSL will startup automatically.

**xWSL is configured to use Bonjour (Multicast DNS) for easy access in WSL2**

If your computer has virtualization support you can convert it to WSL2.  kWSL is faster on WSL1, but WSL2 has additional capabilities. 

Example of conversion to WSL2 on machine name "ENVY":
 - Stop WSL on ENVY:
 ````wsl --shutdown````
 - Convert the instance to WSL2:
 ````wsl --set-version kWSL 2````
 - Restart kWSL Instance:
 ````schtasks /run /tn kWSL````
 - Adjust the RDP file saved on the desktop to now point at the new WSL2 instance:
 ````ENVY-kWSL.local:3399````

**Make it your own:**

From a security standpoint, it would be best to fork this project so you (and only you) control the packages and files in the repository.

- Sign into GitHub and fork this project
- Edit ```kWSL.cmd```.  On line 2 you will see ```SET GITORG=DesktopECHO``` - Change ```DesktopECHO``` to the name of your own repository.
- Customize the script any way you like.
- Launch the script using your repository name:
 ```PowerShell -executionpolicy bypass -command "wget https://github.com/YOUR-REPO-NAME/kWSL/raw/master/kWSL.cmd -UseBasicParsing -OutFile kWSL.cmd ; .\kWSL.cmd"```

**Quirks / Limitations / Additional Info:**
- kWSL should work fine with an X Server instead of xRDP but this has not been thoroughly tested.  The file ```/etc/profile.d/kWSL.sh``` contains WSL-centric environment variables that may need adjustment such as LIBGL_ALWAYS_INDIRECT.
- Plasma-discover doesn't work in Server 2019 / Win 10 v.1809 -- The installer will remove it if you're running an affected OS. 
- WSL1 Doesn't work with PolicyKit.  Enabled kdesu for apps needing elevated rights (plasma-discover, ksystemlog, muon, root console.)    
- KDE Lockscreen is disabled (due to policykit)  
- Patched KDE Activity Manager to disable WAL in sqlite3. 
- Rebuilt xrdp 0.9.13 thanks to Sergey Dryabzhinsky @ http://packages.rusoft.ru/ppa/rusoft/xrdp/
- Current versions of Chrome / Firefox / Konqueror do not work in WSL1; Mozilla Seamonkey is included as a stable/maintained browser.  TODO: Get Konqueror working with an older version of the Chromium engine. 
- Installed image consumes approximately 3 GB of disk space.
- Apt-fast was added to improve download speed and reliability.
- KDE uses the Breeze-Dark theme and Windows fonts (Segoe UI / Consolas)
- This is a basic installation of KDE to save bandwidth.  If you want the **complete** KDE Desktop environment (+3GB Disk) run ```sudo pkcon -y install neon-all``` 

![image](https://user-images.githubusercontent.com/33142753/100148485-33cb2480-2e73-11eb-932b-54e34b445575.png)

![image](https://user-images.githubusercontent.com/33142753/100385367-c21ce300-2ff8-11eb-9276-6f51b366839f.png)
