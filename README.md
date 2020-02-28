# xWSL.CMD 

- A fast way to a simple desktop environent in WSL1
- No additional X Server download required.
- Works in Server Core.

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
- Included FreeRDP client is compiled to run with OpenH264 and media foundation disabled. 

There are some inelegant solutions used to address various WSL quirks; contributions are welcome to improve these and any other areas needing attention.

Enjoy!

Dan M.
