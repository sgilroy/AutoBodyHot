WinActivate, ahk_class ConsoleWindowClass
;WinActivate, ahk_class KiTTY
;Sleep, 200

WinWaitActive, ahk_class ConsoleWindowClass
SendRaw `%1POWR ?
WinWaitActive, ahk_class ConsoleWindowClass
Send {Enter}
;Send `%1POWR ?
