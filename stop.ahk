if (!DllCall("User32\OpenInputDesktop","int",0*0,"int",0*0,"int",0x0001L*1))
{
    MsgBox Desktop is locked. Demo will not be stopped.
    ExitApp
}

SetWorkingDir, Demos
RunWait, CloseAllDemos.ahk

SetWorkingDir, C:\Program Files\Scalable Display2\release\
RunWait, UnwarpDesktop.bat

SetWorkingDir, %A_ScriptDir%\Projectors
RunWait, stop_projectors.ahk
RunWait, disable_projectors_display.ahk

; Sleep a bit before we try to change the cover
Sleep, 3000
SetWorkingDir, %A_ScriptDir%\SoftDesktopLock
Run, UpdateDesktopCover.ahk
