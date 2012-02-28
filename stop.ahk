if (!DllCall("User32\OpenInputDesktop","int",0*0,"int",0*0,"int",0x0001L*1))
{
    MsgBox Desktop is locked. Demo will not be stopped.
    ExitApp
}

SetWorkingDir, Demos
RunWait, CloseAllDemos.ahk

SetWorkingDir, C:\Program Files\Scalable Display2\release\
RunWait, UnwarpDesktop.bat
;Run, ScalableControlPanel.exe
;WinWait, ScalableDesktop
;WinActivate, ScalableDesktop
;; Playback
;Send {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}
;Send {Enter}
;Sleep 200
;; Disengage
;Send {Tab}{Tab}
;Send {Enter}
;
;; close the ScalableDesktop window
;;WinClose, ScalableDesktop
;Send !{F4}
;WinWaitClose, ScalableDesktop

SetWorkingDir, %A_ScriptDir%\Projectors
RunWait, stop_projectors.ahk
RunWait, disable_projectors_display.ahk
