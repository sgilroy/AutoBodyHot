#SingleInstance off
#include CoverDesktop.ahk

if (WinExist("LockUP_cover"))
{
	SysGet, numOfMonitors, MonitorCount
	CoverDesktop(numOfMonitors)
    ;WinWaitClose, LockUP_cover
}

;return
;GuiClose:
;GuiEscape:
ExitApp
