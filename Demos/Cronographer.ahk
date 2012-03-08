SetWorkingDir, %A_ScriptDir%
RunWait, CloseAllDemos.ahk

SetWorkingDir, C:\of_preRelease_v007_win_cb\apps\workspace\alphaShaders12_textTUIO\bin\
Run, geometryShaderExample_DEBUG.exe

WinWaitActive, ahk_class GLUT

WinActivate, ahk_class Progman