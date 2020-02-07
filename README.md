# xWSL.CMD 

The fast and simple way to a Linux desktop in WSL.  

**From an elevated CMD.EXE prompt**, change to your desired install directory and type or paste the following command:

> powershell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSL.CMD -UseBasicParsing -OutFile xwsl.cmd ; .\xwsl.cmd"

When the script completes you'll have a lightweight and useable desktop with the following attributes:

- Ubuntu 18.04 App Store Image will download directly from Microsoft.  
- XFCE 4.14 backport for Ubuntu 18.04, with PPA's from other sources included for customization. 
- XRDP Display Server - Access your WSL Linux desktop from the standard Windows Remote Desktop Client (mstsc.exe)
- PulseAudio for Windows included for audio support.
- Simple init system started through Task Scheduler.
- Mozilla SeaMonkey is the default Web renderer.  Firefox/Chrome have issues in WSL.   
- FreeRDP client (wfreerdp.exe) included for console sessions on Server Core. This part is a little janky at present and there's no audio support.  This could effectively turn a Hyper-V Server 2019 installation into a general-purpose Linux desktop. 

There are some inelegant solutions used to address various WSL quirks; contributions are welcome to improve these and any other areas needing improvement.

Enjoy!
Dan M.
