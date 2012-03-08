#include Desktop\GatherWindows.ahk
#include Desktop\TaskbarMove.ahk

if (!DllCall("User32\OpenInputDesktop","int",0*0,"int",0*0,"int",0x0001L*1))
{
    MsgBox Desktop is locked. Demo will not be started.
    ExitApp
}

SetWorkingDir, %A_ScriptDir%\Projectors
RunWait, start_projectors.ahk
RunWait, enable_projectors_display.ahk
; TODO: move desktop icons over to the secondary display from the projector (primary) display
Sleep 200
GatherWindows(2)
TaskbarMove("Bottom", 2)

SetWorkingDir, %A_ScriptDir%\SoftDesktopLock
Run, UpdateDesktopCover.ahk

SetWorkingDir, C:\Program Files\Scalable Display2\release\
RunWait, WarpDesktop.bat

SetWorkingDir, %A_ScriptDir%\Demos
RunWait, Cronographer.ahk

SetWorkingDir, %A_ScriptDir%\Desktop
RunWait, MoveMouseOffProjector.ahk

; For some reason, the script is not exiting as expected
ExitApp
