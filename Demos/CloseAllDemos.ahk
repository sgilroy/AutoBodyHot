; Stops all running demos

; Exclusion examples:
GroupAdd, DemoWindowsExclude, ahk_class SideBar_AppBarWindow
; These two come in pairs for the Vista sidebar gadgets:
GroupAdd, DemoWindowsExclude, ahk_class SideBar_HTMLHostWindow   ; gadget content
GroupAdd, DemoWindowsExclude, ahk_class BasicWindow              ; gadget shadow/outline

; Comma-delimited list of processes to exclude.
; We exclude ALL windows belonging to these processes
DemoProcessesExcludeList = chrome.exe,explorer.exe,Dwm.exe,WerFault.exe,notepad++.exe,taskmgr.exe

; List all visible windows.
WinGet, win, List

FileAppend,
(
Closing demos...

), CloseAllDemos.log

Loop, %win%
{
    ; If this window matches the DemoWindowsExclude group, don't touch it.
    if (WinExist("ahk_group DemoWindowsExclude ahk_id " . win%A_Index%))
        continue

    ; Set Last Found Window.
    if (!WinExist("ahk_id " . win%A_Index%))
        continue

    WinGet, procname, ProcessName
    ; Check process (program) exclusion list.
    if procname in %DemoProcessesExcludeList%
        continue
    
    windowName := win%A_Index%
    FileAppend,
    (
        Closing window from process %procname% %windowName%

    ), CloseAllDemos.log
    
	if (procname == "Community Core Vision.exe")
	{
		WinActivate, ahk_id %windowName%
		Send {Esc}
	}
	else
	{
		WinClose, ahk_id %windowName%
	}
}        