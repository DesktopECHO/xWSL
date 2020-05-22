# xWSL-20.04.cmd

- Simplicity - One command for a desktop environment in WSL1 with all the quirks taken care of
- Runs on Windows Server 2019 or Windows 10 Version 1803 (or newer)
- Ubuntu Linux 20.04 and custom themed XFCE 4.14 for a smooth user experience
- xRDP Display Server, no additional X Server downloads required
- RDP Audio playback enabled (YouTube playback in browser works)

xWSL is accessible from anywhere on your internal network and you connect using the standard Remote Desktop Client (mstsc.exe)

**From an elevated CMD.EXE prompt**, change to your desired install directory and type or paste the following command:

```
PowerShell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL-20.04/master/xWSL-20.04.cmd -UseBasicParsing -OutFile xWSL-20.04.cmd ; .\xWSL-20.04.cmd"
```

You will be asked a few questions:

```
xWSL for Ubuntu 20.04  
Enter a unique name for the distro or hit Enter to use default [xWSL]: 
Enter port number for xRDP traffic or hit Enter to use default [3399]: 
Enter port number for SSHd traffic or hit Enter to use default [3322]: 
```

Near the end of the script you will be prompted to create a non-root user.  This user will be added to sudo'ers automatically.

```
Enter name of xWSL user: danm
Enter password: ********

SUCCESS: Attempted to run the scheduled task "xWSL-Init".

  Start: Thu 05/21/2020 @ 18:04:20.86
    End: Thu 05/21/2020 @ 18:20:09.18

 Installation Complete, xRDP server listening on port 3399
 Connection Hint: MSTSC.EXE /F /V:MYPC:3399

C:\Users\danm>
```

Upon completion you'll have a nice looking and functional XFCE4 desktop that's accessible locally or remotely.

A scheduled task is created that runs at login to start xWSL.  **If you prefer to start xWSL at boot (like a service) do the following:**

- Right-click the task in Task Scheduler, click properties
- Click checkboxes for **Run whether user is logged on or not** and **Hidden** then click **OK**
- Enter your Windows credentials when prompted

Reboot your PC.  xWSL will automatically start at boot, no need to login to Windows.
