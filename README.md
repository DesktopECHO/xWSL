# xWSL

The fastest way to a Linux desktop in WSL.  From an elevated command prompt:

> powershell -command "wget https://raw.githubusercontent.com/DesktopECHO/xWSL/master/xWSL.CMD -UseBasicParsing -OutFile xwsl.cmd ; .\xwsl.cmd"

- Ubuntu 18.04/XFCE 4.14 desktop builds itself from the official Windows App Store image.
- XRDP Display Server, use with Remote Desktop Client (mstsc.exe)
- PulseAudio Windows binaries included for audio support.
- Simple init system started in Task Scheduler.
- Youtube video in browser is a bit choppy, but sound works well. 
- FreeRDP Client included (wfreerdp.exe) for desktop sessions on Server Core. This part is a little janky and there's no audio support, but it works.

Run xWSL.CMD, sit back and watch the show.
There are some pretty ugly solutions in place to address WSL quirks, contributors welcome!

Enjoy,
D.
