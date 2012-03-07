#include CoverDesktop.ahk

InputBox, monitor, Select Monitor, Specify the number of the monitor to cover
if (monitor != null)
{
    CoverDesktop(monitor)
    WinWaitClose, LockUP_cover
}

;return
;GuiClose:
;GuiEscape:
ExitApp
