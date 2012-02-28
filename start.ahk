#include GatherWindows.ahk
#include MultiMonitor.ahk

if (!DllCall("User32\OpenInputDesktop","int",0*0,"int",0*0,"int",0x0001L*1))
{
    MsgBox Desktop is locked. Demo will not be started.
    ExitApp
}

SetWorkingDir, %A_ScriptDir%\Projectors
RunWait, start_projectors.ahk
RunWait, enable_projectors_display.ahk
; TODO: move any widows, the task bar, and desktop icons over to the
Sleep 200
GatherWindows(2)
;MoveTaskBar("\\.\DISPLAY1")

SetWorkingDir, C:\Program Files\Scalable Display2\release\
Run, ScalableControlPanel.exe
;WinWait, ScalableDesktop™
WinWait, ScalableDesktop
WinActivate, ScalableDesktop
; Playback
Send {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}
Send {Enter}
Sleep 200
; Engage
Send {Tab}{Tab}
Send {Enter}

; close the ScalableDesktop window
;WinClose, ScalableDesktop
Send !{F4}
WinWaitClose, ScalableDesktop

SetWorkingDir, %A_ScriptDir%\Demos
RunWait, FloorFlock_start.ahk

; For some reason, the script is not exiting as expected
ExitApp
