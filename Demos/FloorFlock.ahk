SetWorkingDir, %A_ScriptDir%
RunWait, CloseAllDemos.ahk

RunWait, CCV.ahk

SetWorkingDir, C:\Program Files\FloorFlock\
Run, FloorFlock.exe