;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize multi-monitor states.

;InitMultiMonitor()


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set next configuration.

;#F12:: SetNextDisplayConfiguration()


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization.

InitMultiMonitor()
{
  ; Declare global variables.
  global MMTest1
  global MMTest2

  ; Reset counts.
  global MultiMonitorDisplayCount := 0
  global MultiMonitorModeCount    := 0
  global MultiMonitorConfigCount  := 0
  global MultiMonitorConfigIndex  := -1

  ; Add devices.
  FlatPanel := AddDisplay("\\.\DISPLAY1", "Iiyama Flat Panel", 14)
  TVMonitor := AddDisplay("\\.\DISPLAY2", "Sony XBR 40",        1)

  ; Add modes.
  MonitorOff       := AddDisplayMode(   0,    0,  0,  0)
  Mode720x480x32   := AddDisplayMode( 720,  480, 32, 60)
  Mode800x600x32   := AddDisplayMode( 800,  600, 32, 60)
  Mode1024x768x32  := AddDisplayMode(1024,  768, 32, 60)
  Mode1280x1024x32 := AddDisplayMode(1280, 1024, 32, 60)

  ; Add configurations.
  AddDisplayConfig(FlatPanel, Mode1280x1024x32, TVMonitor, Mode1280x1024x32)
  AddDisplayConfig(TVMonitor, Mode720x480x32,   FlatPanel, Mode1024x768x32)
  AddDisplayConfig(FlatPanel, Mode1024x768x32,  TVMonitor, Mode720x480x32)

  ; Define status window.
  Gui, 5:Font, s16, Arial
  Gui, 5:Add, Text,, The following configuration is being set:
  Gui, 5:Add, Text, vMMTest1 w540,
  Gui, 5:Add, Text, vMMTest2 w540,
  Gui, 5:Show, w550 Hide, Please Wait...

  ; Set configuration.
  SetNextDisplayConfiguration()
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create new configuration entry.

AddDisplayConfig(PrimaryDisplay, PrimaryMode, SecondaryDisplay, SecondaryMode)
{                     
  ; All variables in this function are global.
  global

  ; New item index.
  Result := MultiMonitorConfigCount

  ; Store new item
  Config%MultiMonitorConfigCount%PrimaryDisplay   := PrimaryDisplay
  Config%MultiMonitorConfigCount%PrimaryMode      := PrimaryMode
  Config%MultiMonitorConfigCount%SecondaryDisplay := SecondaryDisplay
  Config%MultiMonitorConfigCount%SecondaryMode    := SecondaryMode

  ; Advance the count.
  MultiMonitorConfigCount := MultiMonitorConfigCount + 1

  ; Return item's index.
  return Result
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create new display entry.

AddDisplay(Name, Description, MouseSpeed)
{                     
  ; All variables in this function are global.
  global

  ; New item index.
  Result := MultiMonitorDisplayCount

  ; Store new item
  Monitor%MultiMonitorDisplayCount%Name        := Name
  Monitor%MultiMonitorDisplayCount%Description := Description
  Monitor%MultiMonitorDisplayCount%MouseSpeed  := MouseSpeed

  ; Advance the count.
  MultiMonitorDisplayCount := MultiMonitorDisplayCount + 1

  ; Return item's index.
  return Result
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create new mode entry.

AddDisplayMode(Width, Height, Depth, Refresh)
{                     
  ; All variables in this function are global.
  global

  ; New item index.
  Result := MultiMonitorModeCount

  ; Store new item
  Mode%MultiMonitorModeCount%Width   := Width
  Mode%MultiMonitorModeCount%Height  := Height
  Mode%MultiMonitorModeCount%Depth   := Depth
  Mode%MultiMonitorModeCount%Refresh := Refresh

  ; Advance the count.
  MultiMonitorModeCount := MultiMonitorModeCount + 1

  ; Return item's index.
  return Result
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns formatted mode description.

GetModeDescription(DisplayDescription, Width, Height, Depth, Refresh)
{
  if ((Width == 0) or (Height == 0))
  {
    Result := "Off"
  }
  else
  {
    Result := DisplayDescription
            . " at "
            . Width . "x" . Height
            . "x" . Depth
            . "@" . Refresh . "Hz"
  }

  return Result
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns display info by its index.

GetDisplayInfo(Index, ByRef Name, ByRef Description, ByRef MouseSpeed = 0)
{                     
  ; All variables in this function are global.
  global

  Name        := Monitor%Index%Name
  Description := Monitor%Index%Description
  MouseSpeed  := Monitor%Index%MouseSpeed
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns display info by its index.

GetModeInfo(Index, ByRef Width, ByRef Height, ByRef Depth, ByRef Refresh)
{                     
  ; All variables in this function are global.
  global

  Width   := Mode%Index%Width
  Height  := Mode%Index%Height
  Depth   := Mode%Index%Depth
  Refresh := Mode%Index%Refresh
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns display info by its index.

GetConfigInfo( Index
             , ByRef PrimaryDisplay, ByRef PrimaryMode
             , ByRef SecondaryDisplay, ByRef SecondaryMode)
{                     
  ; All variables in this function are global.
  global

  PrimaryDisplay   := Config%Index%PrimaryDisplay
  PrimaryMode      := Config%Index%PrimaryMode
  SecondaryDisplay := Config%Index%SecondaryDisplay
  SecondaryMode    := Config%Index%SecondaryMode
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns the position and size of the specified display.

GetDisplayPosition(DeviceName, ByRef X, ByRef Y, ByRef Width, ByRef Height)
{
  ; DEVMODE size.
  DevModeSize := 156

  ; Reserve the space for the structure and clear with zeros.
  VarSetCapacity(DevMode, DevModeSize, 0)

  ; DEVMODE.dmSize = sizeof(DEVMODE).
  NumPut(DevModeSize, DevMode, 36, UShort)

  ; Query current settings.
  status := DllCall( "EnumDisplaySettings"
                   , "str",  DeviceName
                   , "uint", -1         ; ENUM_CURRENT_SETTINGS
                   , "uint", &DevMode)

  ; Verify the status.
  if (!status)
  {
    return False
  }

  ; Fetch the values.
  X := NumGet(DevMode, 44)
  Y := NumGet(DevMode, 48)

  Width  := NumGet(DevMode, 108)
  Height := NumGet(DevMode, 112)

  ; Success.
  return True
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Schedule but do not perform a display mode change.

ScheduleModeChange( DeviceName
                  , Primary
                  , X, Y
                  , Width, Height
                  , Depth = 0
                  , Refresh = 0)
{
  ; Set default flags.
  ModeFlags := 0x00000001  ; CDS_UPDATEREGISTRY
             | 0x10000000  ; CDS_NORESET

  ; Set primary.
  if (Primary)
  {
    ModeFlags := ModeFlags
               | 0x00000010
  }

  ; DEVMODE size.
  DevModeSize := 156

  ; Reserve the space for the structure and clear with zeros.
  VarSetCapacity(DevMode, DevModeSize, 0)

  ; DEVMODE.dmSize = sizeof(DEVMODE).
  NumPut(DevModeSize, DevMode, 36, UShort)

  ; Set additional default mode flags.
  DevModeFlags := 0x00000020  ; DM_POSITION
                | 0x00080000  ; DM_PELSWIDTH
                | 0x00100000  ; DM_PELSHEIGHT

  ; Is color depth specified?
  if (Depth)
  {
    DevModeFlags := DevModeFlags
                  | 0x00040000  ; DM_BITSPERPEL

    ; DEVMODE.dmBitsPerPel = Depth.
    NumPut(Depth, DevMode, 104)
  }

  ; Is refresh rate specified?
  if (Refresh)
  {
    DevModeFlags := DevModeFlags
                  | 0x00400000  ; DM_DISPLAYFREQUENCY

    ; DEVMODE.dmDisplayFrequency = Refresh.
    NumPut(Refresh, DevMode, 120)
  }

  ; DEVMODE.dmFields = DevModeFlags.
  NumPut(DevModeFlags, DevMode, 40)

  ; DEVMODE.dmPosition.(x, y) = (X, Y).
  NumPut(X, DevMode, 44)
  NumPut(Y, DevMode, 48)

  ; DEVMODE.(dmPelsWidth, dmPelsHeight) = (Width, Height).
  NumPut(Width,  DevMode, 108)
  NumPut(Height, DevMode, 112)

  ; Change mode.
  status := DllCall( "ChangeDisplaySettingsEx"
                   , "str",  DeviceName  ; Name of display device.
                   , "uint", &DevMode    ; Graphics mode.
                   , "uint", 0           ; Not used; must be NULL.
                   , "uint", ModeFlags   ; Mode flags.
                   , "uint", 0)          ; No video parameters.

  ; Check the status.
  if (status)
  {
    MsgBox,
    (
      Failed to schedule a mode change:
      Code returned: %status%
      Device name: %DeviceName%
      Primary: %Primary%
      Position: (%X%, %Y%)
      Mode size: (%Width%x%Height%)
      Color depth: %Depth%
      Refresh Rate: %Refresh%
    )
  }

  ; Return result.
  return status
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set specified mode for two monitors at the same time.
;
; Possible return values:
;   DISP_CHANGE_SUCCESSFUL  =  0
;   DISP_CHANGE_RESTART     =  1
;   DISP_CHANGE_FAILED      = -1
;   DISP_CHANGE_BADMODE     = -2
;   DISP_CHANGE_NOTUPDATED  = -3
;   DISP_CHANGE_BADFLAGS    = -4
;   DISP_CHANGE_BADPARAM    = -5
;   DISP_CHANGE_BADDUALVIEW = -6

SetMultiMonitorConfiguration(ConfigIndex)
{
  ; Show the status window.
  Gui, 5:Show

  ; Get the configuration details.
  GetConfigInfo( ConfigIndex
               , PrimaryDeviceIndex, PrimaryModeIndex
               , SecondaryDeviceIndex, SecondaryModeIndex)

  ; Fetch display info.
  GetDisplayInfo( PrimaryDeviceIndex
                , PrimaryName, PrimaryDescription, MouseSpeed)
  GetDisplayInfo( SecondaryDeviceIndex
                , SecondaryName, SecondaryDescription)

  ; Fetch mode info.
  GetModeInfo( PrimaryModeIndex
             , PrimaryWidth, PrimaryHeight
             , PrimaryDepth, PrimaryRefresh)
  GetModeInfo( SecondaryModeIndex
             , SecondaryWidth, SecondaryHeight
             , SecondaryDepth, SecondaryRefresh)

  ; Get descriptions of the modes for the user.
  PrimaryModeDescription := GetModeDescription( PrimaryDescription
                                              , PrimaryWidth, PrimaryHeight
                                              , PrimaryDepth, PrimaryRefresh)

  SecondaryModeDescription := GetModeDescription( SecondaryDescription
                                                , SecondaryWidth, SecondaryHeight
                                                , SecondaryDepth, SecondaryRefresh)

  ; Update the dialog.
  GuiControl, 5:Text, MMTest1, Primary: %PrimaryModeDescription%
  GuiControl, 5:Text, MMTest2, Secondary: %SecondaryModeDescription%

  ; Assume a failure.
  status := -1

  ; Use a loop for easy error handling.
  Loop
  {
    ; Primary has to be valid.
    if ((PrimaryWidth == 0) or (PrimaryHeight == 0))
    {
      Break
    }

    ; Determine the requested mode validity.
    SecondaryValid := ((SecondaryWidth == 0) or (SecondaryHeight == 0))
      ? False
      : True

    ; Schedule primary mode change.
    status := ScheduleModeChange( PrimaryName, True
                                , 0, 0
                                , PrimaryWidth, PrimaryHeight
                                , PrimaryDepth, PrimaryRefresh)
    if (status)
    {
      break
    }

    ; Schedule secondary mode change.
    status := ScheduleModeChange( SecondaryName, False
                                , PrimaryWidth, 0
                                , SecondaryWidth, SecondaryHeight
                                , SecondaryDepth, SecondaryRefresh)
    if (status)
    {
      break
    }

    ; Apply the changes.
    status := DllCall( "ChangeDisplaySettingsEx"
                     , "uint", 0
                     , "uint", 0
                     , "uint", 0
                     , "uint", 0
                     , "uint", 0)
    if (status)
    {
      MsgBox, Failed to apply mode changes: %status%
      Break
    }

    ; Wait for everything to settle.
    Sleep, 5000

    ; Move the taskbar to the primary display.
    MoveTaskBar(PrimaryName)

    ; Set mouse pointer speed.
    DllCall( "SystemParametersInfo"
           , "uint", 0x0071    ; SPI_SETMOUSESPEED
           , "uint", 0
           , "uint", MouseSpeed
           , "uint", 0)

    ; Terminate the loop.
    break
  }

  ; Hide the status window.
  Gui, 5:Hide
  SoundPlay, *-1

  return status
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unlocks the taskbar.

UnlockTaskbar(Unlock = True, Wait = True)
{
  ; Get the taskbar window dimensions.
  WinGetPos x, y, width, height, ahk_class Shell_TrayWnd

  ; Determine the taskbar status.
  ; (the height of a locked task bar should be a multiple of 30)
  locked := Mod(height, 30) == 0

  ; Should we still toggle?
  if ((Unlock ^ locked) == 0)
  {
    ; All mouse coordinates are now relative to the screen.
    CoordMode, Mouse, Screen

    ; Save current mouse position.
    MouseGetPos, currX, currY

    ; Calculate the click point.
    clkX := x + width  - 1
    clkY := y + height - 1

    ; Invoke the menu and select 'Lock the Taskbar'
    Click Right %clkX%, %clkY%
    Send, l

    ; Move the mouse to the original position.
    MouseMove, %currX%, %currY%, 0

    ; Restore default.
    CoordMode, Mouse, Relative

    ; Wait until everything is settled.
    if (Wait)
    {
      Sleep, 2000
    }
  }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the taskbar to the bottom of the specified display.

MoveTaskBar(DeviceName)
{
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Get positions of the display and the taskbar.

  ListVars
  Pause

  ; Get the display position.
  if (!GetDisplayPosition(DeviceName, dspX, dspY, dspWidth, dspHeight))
  {
    return
  }


  ; Get the taskbar window dimensions.
  WinGetPos tbrX, tbrY, tbrWidth, tbrHeight, ahk_class Shell_TrayWnd


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Verify whether the taskbar is already within the display.

  if (    (tbrX >= dspX) and (tbrX + tbrWidth  <= dspX + dspWidth)
      and (tbrY >= dspY) and (tbrY + tbrHeight <= dspY + dspHeight))
  {
    return
  }


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Prepare for the move.

  ; Unlock the taskbar.
  ;UnlockTaskbar()

  ; Change to absolute coordinate system.
  CoordMode, Mouse, Screen

  ; Save the current mouse position.
  MouseGetPos, currX, currY

  ListVars
  Pause

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Move the taskbar.

  ; Get the taskbar window unlocked dimensions.
  WinGetPos tbrX, tbrY, tbrWidth, tbrHeight, ahk_class Shell_TrayWnd

  ; if (tbrWidth > tbrHeight)
  ; {
    ; tbrX := tbrX + tbrWidth // 2
	; tbrY := tbrY - 1
  ; }
  ; else
  ; {
	; tbrY := tbrY + tbrHeight // 2
	; tbrX := tbrX + 1
  ; }
  ListVars
  Pause
  
  ; Determine target mouse coordinates.
  trgX := dspX + dspWidth // 2
  trgY := dspY + dspHeight - tbrHeight

  ; Initiate taskbar moving.
  ;Send, {LWin}!{Space}m{Right}
  ;Sleep, 500
  MouseClickDrag, Left, %tbrX%, %tbrY%, %trgX%, %trgY%

  ; Move the mouse and the taskbar with it.
;  MouseMove, %trgX%, %trgY%, 0
;  Send, {Enter}
;  Sleep, 1000

  ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; ; Sometimes during the move the size of the bar gets reset.
  ; ; Here we make sure the size stays the same.

  ; ; Get the new size of the taskbar.
  ; WinGetPos newX, newY, newWidth, newHeight, ahk_class Shell_TrayWnd

  ; ; Compute the size delta.
  ; sizeDelta := newHeight - tbrHeight

  ; ; Adjust if required.
   ; if (sizeDelta)
  ; {
    ; ; Make the cursor go a bit more to make sure the size changes.
    ; if (sizeDelta < 0)
    ; {
      ; sizeDelta := sizeDelta - 1
    ; }
    ; else
    ; {
      ; sizeDelta := sizeDelta + 1
    ; }

    ; ; Initiate taskbar sizing.
    ; Send, {LWin}!{Space}s{Up}
    ; Sleep, 500

    ; ; Move the mouse and resize the taskbar.
    ; MouseMove, 0, %sizeDelta%, 0, R
    ; Send, {Enter}
    ; Sleep, 1000
  ; }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Finalize the move.

  ; Move the mouse to the original position.
  MouseMove, %currX%, %currY%, 0

  ; Restore relative coordinate system.
  CoordMode, Mouse, Relative

  ; Lock the taskbar.
  ;UnlockTaskbar(False)
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set next display configuration.

SetNextDisplayConfiguration()
{
  ; Access global variables.
  global MultiMonitorConfigIndex
  global MultiMonitorConfigCount

  ; Advance to the next configuration.
  MultiMonitorConfigIndex := MultiMonitorConfigIndex + 1

  ; Rewind.
  if (MultiMonitorConfigIndex == MultiMonitorConfigCount)
  {
    MultiMonitorConfigIndex := 0
  }

  ; Set configuration.
  SetMultiMonitorConfiguration(MultiMonitorConfigIndex)
}