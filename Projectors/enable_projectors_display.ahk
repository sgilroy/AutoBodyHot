#include EnableDisplayDevice.ahk
    
	; Loop {
        ; if ! EnumDisplayDevices(A_Index, DeviceName, StateFlags)
            ; break
        ; if (StateFlags & 4)
            ; text .= DeviceName " is the primary display device.`n"
        ; else if (StateFlags & 1)
            ; text .= "The desktop extends onto " DeviceName ".`n"
        ; if (StateFlags & 8)
            ; text .= DeviceName " is a pseudo-device.`n"
    ; }
    ; MsgBox %text%
	
;EnableDisplayDevice("\\.\DISPLAY2", 1) ; turn on secondary display (the projectors) 

Run, displayswitch /extend 
