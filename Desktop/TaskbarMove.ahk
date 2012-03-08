;TaskbarMove("Bottom", 2)

TaskbarMove(p_pos, monitor=-1) {
	label:="TaskbarMove_" p_pos

	WinExist("ahk_class Shell_TrayWnd")
    if (monitor = -1)
    {
        SysGet, s, Monitor
    }
    else
    {
        SysGet, s, Monitor, %monitor%
    }

    WinGetPos, X, Y, Width, Height
    if (Width < Height)
    {
        barThickness := Width
    }
    else
    {
        barThickness := Height
    }
    
	if (IsLabel(label)) {
		Goto, %label%
	}
	return

	TaskbarMove_Top:
	WinMove(sLeft, sTop, sRight - sLeft, barThickness)
	return

	TaskbarMove_Bottom:
	WinMove(sLeft, sBottom - barThickness, sRight - sLeft, barThickness)
	return

	TaskbarMove_Left:
	WinMove(sLeft, sTop, barThickness, sBottom - sTop)
	return

	TaskbarMove_Right:
	WinMove(sRight - barThickness, sTop, barThickness, sBottom - sTop)
	return
}

WinMove(p_x, p_y, p_w="", p_h="", p_hwnd="") {
	WM_ENTERSIZEMOVE:=0x0231
	WM_EXITSIZEMOVE :=0x0232

	if (p_hwnd!="") {
		WinExist("ahk_id " p_hwnd)
	}

	SendMessage, WM_ENTERSIZEMOVE
	Tooltip WinMove(%p_x%`, %p_y%`, %p_w%`, %p_h%)
	WinMove, , , p_x, p_y, p_w, p_h
	SendMessage, WM_EXITSIZEMOVE
}