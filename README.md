# xWSL.CMD 

The fast and simple way to a Linux desktop in WSL.  

**From an elevated CMD.EXE prompt**, change to your desired install directory and type or paste the following command:

> powershell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSL.CMD -UseBasicParsing -OutFile xwsl.cmd ; .\xwsl.cmd"

- Ubuntu 18.04 + XFCE 4.14 builds itself from the official Windows App Store, a set of predefined PPA's and required packages. 
- XRDP Display Server, use with Remote Desktop Client (mstsc.exe)
- PulseAudio Windows binaries included for audio support, works for me? Needs testing.
- Simple init system started in Task Scheduler.
- Youtube video in browser is a bit choppy, but sound works well. 
- FreeRDP Client included (wfreerdp.exe) for desktop sessions on Server Core. This part is a little janky and there's no audio support, but it's there if you need it.
 
There are some inelegant solutions used to address WSL quirks, contributions welcome to improve this and other things!

Enjoy,
D.
