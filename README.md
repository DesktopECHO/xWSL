# xWSL.CMD 

The fast way to a simple desktop environent in WSL1, no X Server download required.

**From an elevated CMD.EXE prompt**, change to your desired install directory and type or paste the following command:

> powershell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSL.CMD -UseBasicParsing -OutFile xwsl.cmd ; .\xwsl.cmd"

When the script completes you'll have a lightweight and useable desktop with the following attributes:

- Ubuntu Linux 18.04 App Store Image downloaded directly from Microsoft.  
- XFCE 4.14 backport for Ubuntu 18.04, with PPA's from other sources included for customization. 
- XRDP Display Server - Access your WSL Linux desktop from the standard Windows Remote Desktop Client (mstsc.exe)
- Remmina remote desktop viewer from developer PPA
- PulseAudio for Windows bundled for audio support.
- Simple init system started through Task Scheduler.
- Mozilla SeaMonkey is the default Web renderer; YouTube works if at times a little jumpy.  Firefox/Chrome is not currently stable enough to use with this build.   
- Included FreeRDP client (wfreerdp.exe) is built to run in Server Core. 

There are some inelegant solutions used to address various WSL quirks; contributions are welcome to improve these and any other areas in need of attention.

Enjoy!

Dan M.
