
CoverDesktop(monitor=-1)
{
    if (monitor = -1)
    {
        ; DETERMINE size of desktop area to cover
        SysGet, numOfMonitors, MonitorCount
        screenX=0
        screenY=0
        Loop, %numOfMonitors%
        {
           SysGet, currentMon, Monitor, %A_Index%
           if (currentMonLeft < screenX)
                    screenX = %currentMonLeft%
           if (currentMonTop < screenY)
                    screenY = %currentMonTop%
        }
        SysGet, mX, 78
        SysGet, mY, 79
    }
    else
    {
        SysGet, currentMon, Monitor, %monitor%
        screenX = %currentMonLeft%
        screenY = %currentMonTop%
        mX := currentMonRight - currentMonLeft
        mY := currentMonBottom - currentMonTop
    }

    ; HIDE cursor
    MouseMove, %mX%,%mX%,0

    if (WinExist("LockUP_cover"))
    {
        ;WinClose
		WinMove, ,, %screenX%, %screenY%, %mX%, %mY%
		WinSet, AlwaysOnTop, on
    }
	else
	{
		; SHOW Blank Window
		Gui, 2:Color, 000000
		Gui, 2: +AlwaysOnTop -Caption
		Gui, 2:Show, NoActivate w%mX% h%mY% x%screenX% y%screenY%,LockUP_cover
	}

	return
	2GuiClose:
	ExitApp
}
