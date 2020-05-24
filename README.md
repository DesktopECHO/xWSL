# xWSL.cmd

- Simplicity - One command for a desktop environment in WSL1 with all the quirks taken care of
- Runs on Windows Server 2019 or Windows 10 Version 1803 (or newer)
- Ubuntu Linux 20.04 and custom themed XFCE 4.14 for a smooth user experience
- xRDP Display Server, no additional X Server downloads required
- RDP Audio playback enabled (YouTube playback in browser works)

xWSL is accessible from anywhere on your network, you connect to it via Microsoft's Remote Desktop Client (mstsc.exe)

**From an elevated CMD.EXE prompt** change to your desired install directory and type/paste the following command:

```
PowerShell -command "wget https://github.com/DesktopECHO/xWSL/raw/master/xWSL.cmd -UseBasicParsing -OutFile xWSL.cmd ; .\xWSL.cmd"
```

You will be asked a few questions:

```
xWSL for Ubuntu 20.04
Enter a unique name for the distro or hit Enter to use default [xWSL]: 
Enter port number for xRDP traffic or hit Enter to use default [3399]: 
Enter port number for SSHd traffic or hit Enter to use default [3322]: 
xWSL (xWSL) To be installed in: C:\Users\danm\xWSL
```

Near the end of the script you will be prompted to create a non-root user.  This user will be automatically added to sudo'ers.

```
Enter name of xWSL user: danm
Enter password: ********
SUCCESS: The scheduled task "xWSL-Init" has successfully been created.

TaskPath                                       TaskName                          State
--------                                       --------                          -----
\                                              xWSL-Init                         Ready

  Start: Sun 05/24/2020 @ 20:08:00.84
    End: Sun 05/24/2020 @ 20:16:48.87

 Installation Complete.  xRDP server listening on port 3399 and SSH on port 3322
 Links for GUI and Console sessions have been placed on your desktop.
 Autolaunching RDP Desktop Session in 5 seconds...

C:\Users\danm>
```

Upon completion you'll be logged into an attractive and fully functional XFCE4 desktop.  A scheduled task is created that runs at login to start xWSL. 

**If you prefer to start xWSL at boot (like a service) do the following:**

- Right-click the task in Task Scheduler, click properties
- Click the checkboxes for **Run whether user is logged on or not** and **Hidden** then click **OK**
- Enter your Windows credentials when prompted

Reboot your PC.  xWSL will automatically start at boot, no need to login to Windows.
