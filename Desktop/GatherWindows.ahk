;
; "Gather" windows on a specific screen.
;

GatherWindows(md=1)
{
    global ProcessGatherExcludeList
    
    SetWinDelay, -1 ; Makes a BIG difference to perceived performance.
    
    ; List all visible windows.
    WinGet, win, List
    
    ; Copy bounds of all monitors to an array.
    SysGet, mc, MonitorCount
    Loop, %mc%
        SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
    
    ; Destination monitor
    mdx := mon%md%Left
    mdy := mon%md%Top
    mdw := mon%md%Right - mdx
    mdh := mon%md%Bottom - mdy
    
    Loop, %win%
    {
        ; If this window matches the GatherExclude group, don't touch it.
        if (WinExist("ahk_group GatherExclude ahk_id " . win%A_Index%))
            continue
        
        ; Set Last Found Window.
        if (!WinExist("ahk_id " . win%A_Index%))
            continue

        WinGet, procname, ProcessName
        ; Check process (program) exclusion list.
        if procname in %ProcessGatherExcludeList%
            continue
        
        WinGetPos, x, y, w, h
        
        ; Determine which monitor this window is on.
        xc := x+w/2, yc := y+h/2
        ms := 1
        Loop, %mc%
            if (xc >= mon%A_Index%Left && xc <= mon%A_Index%Right
                && yc >= mon%A_Index%Top && yc <= mon%A_Index%Bottom)
            {
                ms := A_Index
                break
            }
        ; If already on destination monitor, skip this window.
        if (ms = md)
            continue
        
        ; Source monitor
        msx := mon%ms%Left
        msy := mon%ms%Top
        msw := mon%ms%Right - msx
        msh := mon%ms%Bottom - msy
        
        ; If the window is resizable, scale it by the monitors' resolution difference.
        if (IsResizable()) {
            w *= (mdw/msw)
            h *= (mdh/msh)
        }
    
        WinGet, state, MinMax
        if state = 1
            WinRestore
        
        ; Move window, using resolution difference to scale co-ordinates.
        WinMove,,, mdx + (x-msx)*(mdw/msw), mdy + (y-msy)*(mdh/msh), w, h

        if state = 1
            WinMaximize
    }
}

IsResizable()
{
    WinGet, Style, Style
    return (Style & 0x40000) ; WS_SIZEBOX
}
