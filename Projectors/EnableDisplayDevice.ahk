; Enables, disables or toggles a display device.
;
; DeviceName:   The name of the device, e.g. \\.\DISPLAY1
;               Alternatively, it can be the index of the device, which might
;               not be the same as the number shown in Display Settings.
; Action:       The action to take.
;                    0   Disable (false is synonymous with 0)
;                    1   Enable (true is synonymous with 1)
;                   -1   Toggle
; NoReset:      If true, settings will be saved to the registry, but not applied.
;
; The following can be used to apply settings saved in the registry:
;   DllCall("ChangeDisplaySettings", "uint", 0, "uint", 1)
;
; Return values:
;    DISP_CHANGE_SUCCESSFUL       0
;    DISP_CHANGE_RESTART          1
;    DISP_CHANGE_FAILED          -1
;    DISP_CHANGE_BADMODE         -2
;    DISP_CHANGE_NOTUPDATED      -3
;    DISP_CHANGE_BADFLAGS        -4
;    DISP_CHANGE_BADPARAM        -5
;
EnableDisplayDevice(DeviceName, Action=1, NoReset=false)
{
    if (Action = -1) || (DeviceName+0 != "")
    {
        VarSetCapacity(DisplayDevice, 424), NumPut(424, DisplayDevice, 0)
        VarSetCapacity(ThisDeviceName, 32, 0)
        Index = 0
        Loop {
            if !DllCall("EnumDisplayDevices", "UInt", 0, "UInt", A_Index-1, "UInt", &DisplayDevice, "UInt", 0)
                return -5
            ThisDeviceState := NumGet(DisplayDevice, 164)
            Index += 1
            DllCall("lstrcpynA", "Str", ThisDeviceName, "UInt", &DisplayDevice+4, "int", 32)
            if (DeviceName = Index || DeviceName = ThisDeviceName)
            {
                if Action = -1
                    Action := !(ThisDeviceState & 1)
                DeviceName := ThisDeviceName
                break
            }
        }
    }
    VarSetCapacity(devmode, 156, 0), NumPut(156, devmode, 36, "UShort")
    if Action
        NumPut(0x000020, devmode, 40) ; Enable by setting position = {0,0}
    else
        NumPut(0x180020, devmode, 40) ; Disable by setting size = {0,0}
    err := DllCall("ChangeDisplaySettingsEx", "str", DeviceName, "uint", &devmode, "uint", 0, "uint", 0x10000001, "uint", 0)
    if !err && !NoReset
        err := DllCall("ChangeDisplaySettings", "uint", 0, "uint", 1)
    return err, ErrorLevel:=Action
}

; EnumDisplayDevices(Index [, ByRef Name, ByRef StateFlags ] )
;
; Index:        One-based index of device to get info for.
; DeviceName:   [out] The name of the device.
; StateFlags:   [out] Any reasonable combination of the following flags:
;   0x00000001      DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
;   0x00000004      DISPLAY_DEVICE_PRIMARY_DEVICE
;   0x00000008      DISPLAY_DEVICE_MIRRORING_DRIVER
; DeviceKey:    [out] Path to the device's registry key relative to HKEY_LOCAL_MACHINE.
;
; Returns true if the display device exists, otherwise false.
;
/* Example 1 (requires EnableDisplayDevice()):
    SecondaryDevice =
    count = 0
    Loop {
        if ! EnumDisplayDevices(A_Index, DeviceName, StateFlags)
            break
        if !(StateFlags & 8) ; not a pseudo-device
            if (++count = 2) ; second device
                break
    }
    if DeviceName
        EnableDisplayDevice(DeviceName, -1) ; toggle
*/
/* Example 2:
    Loop {
        if ! EnumDisplayDevices(A_Index, DeviceName, StateFlags)
            break
        if (StateFlags & 4)
            text .= DeviceName " is the primary display device.`n"
        else if (StateFlags & 1)
            text .= "The desktop extends onto " DeviceName ".`n"
        if (StateFlags & 8)
            text .= DeviceName " is a pseudo-device.`n"
    }
    MsgBox %text%
*/
EnumDisplayDevices(Index, ByRef DeviceName, ByRef StateFlags="", ByRef DeviceKey="")
{
    ; DISPLAY_DEVICE DisplayDevice
    VarSetCapacity(DisplayDevice, 424)
    ; lpDisplayDevice.cb := sizeof(DISPLAY_DEVICE)
    NumPut(424, DisplayDevice, 0)
    
    VarSetCapacity(DeviceName, 32, 0)
    VarSetCapacity(DeviceKey, 128, 0)
    ; For consistency, clear StateFlags in case of failure.
    StateFlags = 0
    
    if ! DllCall("EnumDisplayDevices"
        , "UInt", 0
        , "UInt", Index-1
        , "UInt", &DisplayDevice
        , "UInt", 0)
        return false
    
    StateFlags := NumGet(DisplayDevice, 164)
    DllCall("lstrcpynA", "Str", DeviceName, "UInt", &DisplayDevice+4,   "int", 32)
    DllCall("lstrcpynA", "Str", DeviceKey,  "UInt", &DisplayDevice+296, "int", 128)
    if (SubStr(DeviceKey,1,18)="\Registry\Machine\")
        DeviceKey := SubStr(DeviceKey,19)
    return true
}