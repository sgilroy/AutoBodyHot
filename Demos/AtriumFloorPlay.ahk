SetWorkingDir, %A_ScriptDir%
RunWait, CloseAllDemos.ahk

SetWorkingDir, C:\src\ccv\apps\addonsExamples\VS2008\bin
Run, Community Core Vision.exe
;WinWait, Community Core Vision
Sleep, 1000

SetWorkingDir, C:\Program Files\AtriumFloorPlay\
Run, AtriumFloorPlay.exe