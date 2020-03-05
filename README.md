# xWSL.CMD 

- One-step method to a simple desktop environment in WSL1.
- No additional X Server download required, uses xRDP.
- Works in Server Core edition.

**From an elevated CMD.EXE prompt**, change to your desired install directory and type or paste the following command:

```
powershell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSL.CMD -UseBasicParsing -OutFile xwsl.cmd ; .\xwsl.cmd"
```

When the script completes you'll have a lightweight and useable desktop with the following attributes:

- Ubuntu Linux 18.04 App Store Image downloaded directly from Microsoft.  
- XFCE 4.14 backport for Ubuntu 18.04, with PPA's from other sources included for customization. 
- XRDP Display Server - Access your WSL Linux desktop from the standard Windows Remote Desktop Client (mstsc.exe)
- Remmina remote desktop viewer from developer PPA
- PulseAudio for Windows bundled for audio support.
- Simple init system started through Task Scheduler.
- Mozilla SeaMonkey is the default (stable) Web renderer; YouTube works if at times a little jumpy.     
- Included FreeRDP client is compiled to run using OpenH264 and media foundation disabled (Server Core). 

**Setup Notes:**

In your WSL distro's install folder (For example using the default of C:\Users\Administrator\xWSL) you will see a file called **xWSL.CMD**.  Run this to get the RDP Server, InitScripts and PulseAudio going after a reboot:
```
START XWSL.CMD
```
Optionally, adjust the scheduled tasks that were pre-configured to increase the level of startup automation.

There are some inelegant solutions used to address various WSL quirks; contributions are welcome to improve these and any other areas needing attention.

Enjoy!

Dan M.

Reddit thread: https://www.reddit.com/r/bashonubuntuonwindows/comments/fbvbb1/wslxrdp_fully_automated_installation/
YouTube walkthru: https://www.youtube.com/watch?v=iJc1Su8l9Lo
