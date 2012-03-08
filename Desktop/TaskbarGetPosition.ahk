WinExist("ahk_class Shell_TrayWnd")
WinGetPos, X, Y, Width, Height
MsgBox, %X%`, %Y%`, %Width%`, %Height%