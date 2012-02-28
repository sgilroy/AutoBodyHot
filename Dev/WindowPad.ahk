; WindowPad:
;
;   Move and resize windows with Win+Numpad.
;     Win+Numpad1 = Fill bottom-left quarter of screen
;     Win+Numpad2 = Fill bottom half of screen
;     etc.
;
;   Move windows across monitors. For example:
;     Win+Numpad4 places the window on the left half of the screen.
;     Win+Numpad4 again moves it to the monitor to the right.
;
;   Quick monitor switch:
;     Win+Numpad5 places the window in the center of the screen.
;     Win+Numpad5 again moves the window to the next monitor.
;     (This works by monitor number, not necessarily left to right.)
;
;   QUICKER Monitor Switch:
;     Win+NumpadDot switches to the next monitor (1->2->3->1 etc.)
;     Win+NumpadDiv moves ALL windows to monitor 2.
;     Win+NumpadMult moves ALL windows to monitor 1.
;
;   Other shortcuts:
;     Win+Numpad0 toggles maximize.
;     Insert (or some other key) can be used in place of "Win".
;
; Credits:
;   Concept based on HiRes Screen Splitter by JOnGliko.
;   Written from scratch by Lexikos to support multiple monitors.
;   NumpadDot key functionality suggested by bobbo.
;
; Built with AutoHotkey v1.0.47.02
;
; HISTORY
;
; Version 1.14:
;   - Fixed modifier+EasyKey combos losing their native functions.
;
; Version 1.13:
;   - Applied bobbo's hack for moving maximized windows.
;
; Version 1.12:
;   - Added two methods to exclude windows from GatherWindows():
;       GatherExclude window group (exclude by title, class, etc.)
;       ProcessGatherExcludeList (exclude by process name)
;
; Version 1.11:
;   - Fixed compatiblity issue with screens that don't align at the top.
;
; Version 1.1:
;   - "Gather windows" hotkeys (NumpadDiv and NumpadMult)
;   - NumpadDot to move window to next monitor
;   - Added more EasyKey combos (for symmetry)
;   - Original functionality of EasyKey is retained (on key-release)
;   - SetWinDelay, -1 to reduce lag when making multiple moves (quickly)
;
; Version 1:
;   - intial release


WindowPadInit:
; Exclusion examples:
GroupAdd, GatherExclude, ahk_class SideBar_AppBarWindow
; These two come in pairs for the Vista sidebar gadgets:
GroupAdd, GatherExclude, ahk_class SideBar_HTMLHostWindow   ; gadget content
GroupAdd, GatherExclude, ahk_class BasicWindow              ; gadget shadow/outline

; Comma-delimited list of processes to exclude.
;ProcessGatherExcludeList = sidebar.exe

; (ProcessGatherExcludeList excludes ALL windows belonging to those processes,
;  including windows you may not want to exclude, like the sidebar config window.)

Prefix_Active = #   ; Win+Numpad      = Move active window
Prefix_Other  = #!  ; Alt+Win+Numpad  = Move previously active window

; Note: Shift (+) should not be used, as +Numpad is hooked by the OS
;   to do left/right/up/down/etc. (reverse Numlock) -- at least on Vista.

EasyKey = Insert    ; Insert is near Numpad on my keyboard...

; Note: Prefix_Other must not be a sub-string of Prefix_Active.
;       (If you want it to be, first edit the line "if (InStr(A_ThisHotkey, Prefix_Other))")

; Width and Height Factors for Win+Numpad5 (center key.)
CenterWidthFactor   = 1.0
CenterHeightFactor  = 1.0

Hotkey, IfWinActive ; in case this is included in another script...

Loop, 9
{   ; Register hotkeys.
    Hotkey, %Prefix_Active%Numpad%A_Index%, DoMoveWindowInDirection
    Hotkey, %Prefix_Other%Numpad%A_Index%, DoMoveWindowInDirection
    ; OPTIONAL
    if EasyKey
        Hotkey, %EasyKey% & Numpad%A_Index%, DoMoveWindowInDirection
}
Hotkey, %Prefix_Active%Numpad0, DoMaximizeToggle
Hotkey, %Prefix_Other%Numpad0, DoMaximizeToggle

Hotkey, %Prefix_Active%NumpadDot, MoveWindowToNextScreen
Hotkey, %Prefix_Other%NumpadDot, MoveWindowToNextScreen

Hotkey, %Prefix_Active%NumpadDiv, GatherWindowsLeft
Hotkey, %Prefix_Active%NumpadMult, GatherWindowsRight

if (EasyKey) {
    Hotkey, %EasyKey% & Numpad0, DoMaximizeToggle
    Hotkey, %EasyKey% & NumpadDot, MoveWindowToNextScreen
    Hotkey, %EasyKey% & NumpadDiv, GatherWindowsLeft
    Hotkey, %EasyKey% & NumpadMult, GatherWindowsRight
    Hotkey, *%EasyKey%, SendEasyKey ; let EasyKey's original function work (on release)
}
return

SendEasyKey:
    Send {Blind}{%EasyKey%}
    return

; This is actually based on monitor number, so if your secondary is on the
; right, you may want to switch these around.
GatherWindowsLeft:
    GatherWindows(2)
    return
GatherWindowsRight:
    GatherWindows(1)
    return



; Hotkey handler.
DoMoveWindowInDirection:
    DoMoveWindowInDirection()
    return

DoMoveWindowInDirection()
{
    local dir, dir0, dir1, dir2, widthFactor, heightFactor
    
    ; Define constants.
    if (!Directions1) {
        dir = -1:+1,0:+1,+1:+1,-1:0,0:0,+1:0,-1:-1,0:-1,+1:-1
        StringSplit, Directions, dir, `,
    }

    gosub WP_SetLastFoundWindowByHotkey
    
    ; Determine which direction we want to go.
    if (!RegExMatch(A_ThisHotkey, "\d+", dir) or !Directions%dir%)
    {
        MsgBox Error: "%A_ThisHotkey%" was registered and I can't figure out which number it is!
        return
    }
    dir := Directions%dir%
    StringSplit, dir, dir, :
    
    ; Determine width/height factors.
    if (dir1 or dir2) { ; to a side
        widthFactor  := dir1 ? 0.5 : 1.0
        heightFactor := dir2 ? 0.5 : 1.0
    } else {            ; to center
        widthFactor  := CenterWidthFactor
        heightFactor := CenterHeightFactor
    }
    
    ; Move the window!
    MoveWindowInDirection(dir1, dir2, widthFactor, heightFactor)
}
return

WP_SetLastFoundWindowByHotkey:
    ; Set Last Found Window.
    if (InStr(A_ThisHotkey, Prefix_Other))
        WinPreviouslyActive()
    else
        WinExist("A")
return

; "Maximize"
DoMaximizeToggle:
    MaximizeToggle()
return
    
MaximizeToggle()
{
    gosub WP_SetLastFoundWindowByHotkey
    WinGet, state, MinMax
    if state
        WinRestore
    else
        WinMaximize
}


; Does the grunt work of the script.
MoveWindowInDirection(sideX, sideY, widthFactor, heightFactor, screenMoveOnly=false)
{
    WinGetPos, x, y, w, h
    
    ; Determine which monitor contains the center of the window.
    m := GetMonitorAt(x+w/2, y+h/2)
    
    ; Get work area of active monitor.
    gosub CalcMonitorStats
    ; Calculate possible new position for window.
    gosub CalcNewPosition

    ; If the window is already there,
    if (newx "," newy "," neww "," newh) = (x "," y "," w "," h)
    {   ; ..move to the next monitor along instead.
    
        if (sideX or sideY)
        {   ; Move in the direction of sideX or sideY.
            SysGet, monB, Monitor, %m% ; get bounds of entire monitor (vs. work area)
            x := (sideX=0) ? (x+w/2) : (sideX>0 ? monBRight : monBLeft) + sideX
            y := (sideY=0) ? (y+h/2) : (sideY>0 ? monBBottom : monBTop) + sideY
            newm := GetMonitorAt(x, y, m)
        }
        else
        {   ; Move to center (Numpad5)
            newm := m+1
            SysGet, mon, MonitorCount
            if (newm > mon)
                newm := 1
        }
    
        if (newm != m)
        {   m := newm
            ; Move to opposite side of monitor (left of a monitor is another monitor's right edge)
            sideX *= -1
            sideY *= -1
            ; Get new monitor's work area.
            gosub CalcMonitorStats
        }
        ; Calculate new position for window.
        gosub CalcNewPosition
    }

    ; Restore before resizing...
    WinGet, state, MinMax
    if state
        WinRestore

    ; Finally, move the window!
    SetWinDelay, -1
    WinMove,,, newx, newy, neww, newh
    
    return

CalcNewPosition:
    ; Calculate new size.
    if (IsResizable()) {
        neww := Round(monWidth * widthFactor)
        newh := Round(monHeight * heightFactor)
    } else {
        neww := w
        newh := h
    }
    ; Calculate new position.
    newx := Round(monLeft + (sideX+1) * (monWidth  - neww)/2)
    newy := Round(monTop  + (sideY+1) * (monHeight - newh)/2)
    return

CalcMonitorStats:
    ; Get work area (excludes taskbar-reserved space.)
    SysGet, mon, MonitorWorkArea, %m%
    monWidth  := monRight - monLeft
    monHeight := monBottom - monTop
    return
}

; Get the index of the monitor containing the specified x and y co-ordinates.
GetMonitorAt(x, y, default=1)
{
    SysGet, m, MonitorCount
    ; Iterate through all monitors.
    Loop, %m%
    {   ; Check if the window is on this monitor.
        SysGet, Mon, Monitor, %A_Index%
        if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
            return A_Index
    }

    return default
}

IsResizable()
{
    WinGet, Style, Style
    return (Style & 0x40000) ; WS_SIZEBOX
}

; Note: This may not work properly with always-on-top windows. (Needs testing)
WinPreviouslyActive()
{
    active := WinActive("A")
    WinGet, win, List

    ; Find the active window.
    ; (Might not be win1 if there are always-on-top windows?)
    Loop, %win%
        if (win%A_Index% = active)
        {
            if (A_Index < win)
                N := A_Index+1
            
            ; hack for PSPad: +1 seems to get the document (child!) window, so do +2
            ifWinActive, ahk_class TfPSPad
                N += 1
            
            break
        }

    ; Use WinExist to set Last Found Window (for consistency with WinActive())
    return WinExist("ahk_id " . win%N%)
}


;
; Switch without moving/resizing (relative to screen)
;
MoveWindowToNextScreen:
    gosub WP_SetLastFoundWindowByHotkey
    WinGet, state, MinMax
    if state = 1
    {   ; Maximized windows don't move correctly on XP
        ; (and possibly other versions of Windows)
        WinRestore
        MoveWindowToNextScreen()
        WinMaximize
    }
    else
        MoveWindowToNextScreen()
return

MoveWindowToNextScreen()
{
    WinGetPos, x, y, w, h
    
    ; Determine which monitor contains the center of the window.
    ms := GetMonitorAt(x+w/2, y+h/2)
    
    ; Determine which monitor to move to.
    md := ms+1
    SysGet, mon, MonitorCount
    if (md > mon)
        md := 1
    
    ; This may happen if someone tries it with only one screen. :P
    if (md = ms)
        return

    ; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    SysGet, md, MonitorWorkArea, %md%
    msw := msRight - msLeft, msh := msBottom - msTop
    mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
    
    ; Calculate new size.
    if (IsResizable()) {
        w *= (mdw/msw)
        h *= (mdh/msh)
    }
    SetWinDelay, -1
    ; Move window, using resolution difference to scale co-ordinates.
    WinMove,,, mdLeft + (x-msLeft)*(mdw/msw), mdTop + (y-msTop)*(mdh/msh), w, h
}


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


Last edited by Lexikos on Fri Apr 02, 2010 7:23 am; edited 12 times in total
Back to top	
   	 	

bobbo



Joined: 19 Mar 2007
Posts: 15

Posted: Thu Aug 09, 2007 5:07 pm    Post subject:	
Absolutely love this tool, it is fast and effective at what it does. Instantly earned a place in my startup script. 

One suggestion: please add using the NumpadDot key to move the window to the next monitor without resizing the window. It's often nice to just throw a window to another screen without resizing first. Otherwise, great job!
Back to top	
 	 	

Lexikos



Joined: 17 Oct 2006
Posts: 7355
Location: Australia
Posted: Fri Aug 10, 2007 1:16 am    Post subject:	
Updated to v1.1: 
Added "Gather windows" hotkeys (NumpadDiv and NumpadMult) 
Added Win+NumpadDot to move window to next monitor 
Added more EasyKey combos (for symmetry) 
Original functionality of EasyKey is now retained (on key-release) 
Added SetWinDelay, -1 to reduce lag when making multiple moves (quickly)


Back to top	
   	 	

Charon the Hand



Joined: 07 Aug 2007
Posts: 8

Posted: Fri Aug 10, 2007 7:46 pm    Post subject:	
This is a splendid tool, thank you very much.
Back to top	
 	 	

lukemh
Guest





Posted: Sat Aug 11, 2007 4:27 am    Post subject: WOW	
This is AWESOME! Keep up the great work.
Back to top	
 	

bobbo



Joined: 19 Mar 2007
Posts: 15

Posted: Mon Aug 13, 2007 5:42 pm    Post subject:	
Again, great work, and thanks for the quick inclusion of my suggestion! I made a couple of minor edits for myself: 

This allows the NumpadDot to work for maximized windows: 
Code:
MoveWindowToNextScreen:
    gosub WP_SetLastFoundWindowByHotkey
    WinGet, state, MinMax
    if state
   {
        WinRestore
      MoveWindowToNextScreen()
        WinMaximize
   }
    else
      MoveWindowToNextScreen()
return


Similarly, this allows the "Gather Windows" to work with maximized windows (I only the changed last line of the original function, but I'm posting the whole function for completeness): 
Code (Expand):
GatherWindows(md=1)
{
    ;SetWinDelay, -1 ; Makes a BIG difference to perceived performance.
    
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
        ; Set Last Found Window.
        if (!WinExist("ahk_id " . win%A_Index%))
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
        
        ; Move window, using resolution difference to scale co-ordinates.
       WinGet, state, MinMax
       if state
      {
           WinRestore
         WinMove,,, mdx + (x-msx)*(mdw/msw), mdy + (y-msy)*(mdh/msh), w, h
           WinMaximize
      }
       else
         WinMove,,, mdx + (x-msx)*(mdw/msw), mdy + (y-msy)*(mdh/msh), w, h
    }
}


And finally, I removed the "SetWinDelay, -1" because of its AHK Command Reference entry: 
Quote:
Although a delay of -1 (no delay at all) is allowed, it is recommended that at least 0 be used, to increase confidence that the script will run correctly even when the CPU is under load.
Back to top	
 	 	

Lexikos



Joined: 17 Oct 2006
Posts: 7355
Location: Australia
Posted: Mon Aug 13, 2007 9:12 pm    Post subject:	
bobbo wrote:
This allows the NumpadDot to work for maximized windows:
It already worked for maximized windows (for me?; it resizes based on screen size difference.)  Restoring then maximizing again just adds a delay. The same applies to gather windows. 

[Edit] Heh, I just realised maximized windows go back to their original screen when you restore them. I guess using WinRestore before and WinMaximize after moving the window (like bobbo suggests) would fix this. For now, I'd rather omit it so the window moves "instantly." [/Edit] 

Quote:
And finally, I removed the "SetWinDelay, -1" because of its AHK Command Reference entry:
I ignored that because...
Quote:
This is done to improve the reliability of scripts because a window sometimes needs a period of "rest" after being created, activated, minimized, etc. so that it has a chance to update itself and respond to the next command that the script may attempt to send to it.
...if you're only sending one command to each window, there is no "next command." And it seemed to work reliably (and faster) with SetWinDelay,-1. 

Oh well, whatever works for you.
Back to top	
   	 	

silkcom
Guest





Posted: Tue Aug 14, 2007 5:03 pm    Post subject: Problem moving between monitors	
First, let me tell you, awesome script. This is exactly what I've been looking for. 

I found a small problem though: 

When I use the 6 to move to the right side, then to the next monitors left side, etc, it works, but when I use the 4 to try and do the same thing the opposite way it doesn't work. 

My setup: I have my secondary monitor on the right side of my main monitor. I did switch the variables in the GatherWindowsLeft and RIght, but I'm not sure if there is another place that I'm suppose to change it?
Back to top	
 	

Lexikos



Joined: 17 Oct 2006
Posts: 7355
Location: Australia
Posted: Wed Aug 15, 2007 12:37 am    Post subject:	
GatherWindows uses absolute monitor index, so it should be the only part you'd need to change. 

So you can move to the secondary, which is on the right, but not back to the primary? It seems to work fine for me (after moving my secondary to the right of my primary.) What's the exact setup of your monitors? (Easiest answer is to run this script and copy-paste the mon* variables.)
Code:
SysGet, m, MonitorCount
Loop, %m%
    SysGet, mon%A_Index%, Monitor, %A_Index%
ListVars
Pause
Back to top	
   	 	

silkcom
Guest





Posted: Wed Aug 15, 2007 2:38 pm    Post subject: mon vars	
Global Variables (alphabetical) 
-------------------------------------------------- 
0[1 of 3]: 0 
dir[0 of 0]: 
dir0[0 of 0]: 
dir1[0 of 0]: 
dir2[0 of 0]: 
Directions0[0 of 0]: 
Directions1[0 of 0]: 
EasyKey[0 of 0]: 
ErrorLevel[1 of 3]: 0 
heightFactor[0 of 0]: 
m[1 of 3]: 2 
mon1[0 of 0]: 
mon1Bottom[3 of 3]: 800 
mon1Left[1 of 3]: 0 
mon1Right[4 of 7]: 1280 
mon1Top[1 of 3]: 0 
mon2[0 of 0]: 
mon2Bottom[3 of 3]: 658 
mon2Left[4 of 7]: 1280 
mon2Right[4 of 7]: 2960 
mon2Top[4 of 7]: -392 
Prefix_Active[0 of 0]: 
Prefix_Other[0 of 0]: 
state[0 of 0]: 
widthFactor[0 of 0]: 


2nd question: 
I'm interested in changing the hotkeys. I know that I would have to change them in the Loop at the beginning but I'm not exactly sure how DoMoveWindowInDirection works, so I'm not sure if that would need to be changed too. The problem is that I'm on a laptop, so the numpad is a bit annoying to work with . I'd prefer to be able to do the move with one hand (I want to do Alt+Win+a to move left, and Alt+Win+d to move right, etc). 

Thanks again.
Back to top	
 	

silkcom
Guest





Posted: Wed Aug 15, 2007 2:42 pm    Post subject: I think I found it	
Ok, so I'm pretty sure that the problem is that my monitors are setup such that the tops don't line up (when I lined them up, in display properties, so that the tops were at the same level the script moved back and forth perfectly). 

Not sure how to fix it, but it's definately trying to get a monitor possition where the top is negative (which it is on my big monitor, but would return a bad number otherwise I would think).
Back to top	
 	

silkcom
Guest





Posted: Wed Aug 15, 2007 2:49 pm    Post subject: quick fix	
A quick fix that I put in is: 

In GetMonitorAt() as the first line I put: 
y := 100 

Not a bad answer, but if u positioned ur monitors such that 100 is below or above one of the monitors, then it would break again.
Back to top	
 	

Lexikos



Joined: 17 Oct 2006
Posts: 7355
Location: Australia
Posted: Wed Aug 15, 2007 9:05 pm    Post subject:	
I see the problem. It works by getting some point that is probably in the right monitor:
Code:
x := (sideX>0 ? monBRight : monBLeft) + sideX
y := (sideY>0 ? monBBottom : monBTop) + sideY
This needs to be fixed so that if sideX|Y = 0, the current window position on that axis is used. At the moment it would use the top/left of the monitor. 

Edit: done. (It now uses the center of the window when sideX|Y=0.)
Back to top	
   	 	

kmccoy



Joined: 17 Aug 2007
Posts: 1

Posted: Fri Aug 17, 2007 9:39 am    Post subject:	
This is really great. One thing I noticed is that when I gather windows, it gathers things that really shouldn't move, like the Vista Sidebar and desktop. It'd be great to be able to rule those things out, but I can't find anything in common to these items so that I can conveniently make it ignore them...
Back to top	
 	 	

Lexikos



Joined: 17 Oct 2006
Posts: 7355
Location: Australia
Posted: Fri Aug 17, 2007 1:11 pm    Post subject:	
My original need for gather windows was to move all windows to my secondary monitor when my primary isn't "hooked up"* to my PC - so I didn't have much need for an exclusion list. (Also, I find the Vista sidebar next to useless. ) 

* for lack of a better term; it has dual inputs, so I use it with my Xbox360 occasionally. 

I can see how it might be useful to exclude some windows, so I've added two methods of exclusion:
Exclude by title, class, etc. (GroupAdd, GatherExclude, ...) 
Exclude by process name (ProcessGatherExcludeList; comma-delimited.)
By default it excludes the sidebar and its gadgets. Simply uncomment ProcessGatherExcludeList and add process.exe to the list to exclude entire applications. (e.g. ...List = sidebar.exe,firefox.exe) 

silkcom wrote:
I'm interested in changing the hotkeys. I know that I would have to change them in the Loop at the beginning but I'm not exactly sure how DoMoveWindowInDirection works, so I'm not sure if that would need to be changed too.
I forgot to reply to this.   After using WindowPad for a while, I think I'd also like to change the keys. The main issue at the moment is the way DoMoveWindowInDirection maps keys (specifically, the numbers at the end of the key names) to directions - via the Directions array (which is initialized at the top of DoMoveWindowInDirection.) I realised when I wrote it that it wouldn't allow for proper customization, but I was in a hurry.   When I get time, I'll rewrite it to allow keys to be customized; probably similar to:
Code:
key_list =
( C
#Numpad4=-1,0  ; left
#Numpad5=0,0  ; middle
#Numpad6=1,0  ; right
...
!#Numpad1=2:-1,1  ; second window down-left
#NumpadMult=all:2  ; gather at monitor 2
#NumpadDot=+1 ; next monitor
)

One possible complication (with the "n:..." convention) is determining the true order for always-on-top windows. For instance, on Vista, windows 1 and 2 are the start button orb and taskbar (which are always-on-top.) 

I think the most accurate way would be to track window activation, and maintain a list of the last %n% active windows...
Back to top	
   	 	

Display posts from previous:   
	   AutoHotkey Community Forum Index -> Scripts & Functions	All times are GMT
Goto page 1, 2, 3 ... 20, 21, 22  Next
Page 1 of 22

 
Jump to:  
You can post new topics in this forum
You can reply to topics in this forum


Powered by phpBB © 2001, 2005 phpBB Group
