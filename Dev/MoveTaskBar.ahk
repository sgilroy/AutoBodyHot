;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Moves the taskbar to the bottom of the specified display.

MoveTaskBar(DeviceName)
{
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Get positions of the display and the taskbar.

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
  UnlockTaskbar()

  ; Change to absolute coordinate system.
  CoordMode, Mouse, Screen

  ; Save the current mouse position.
  MouseGetPos, currX, currY


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Move the taskbar.

  ; Get the taskbar window unlocked dimensions.
  WinGetPos tbrX, tbrY, tbrWidth, tbrHeight, ahk_class Shell_TrayWnd

  ; Determine target mouse coordinates.
  trgX := dspX + dspWidth // 2
  trgY := dspY + dspHeight - tbrHeight

  ; Initiate taskbar moving.
  Send, {LWin}!{Space}m{Right}
  Sleep, 500

  ; Move the mouse and the taskbar with it.
  MouseMove, %trgX%, %trgY%, 0
  Send, {Enter}
  Sleep, 1000


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Sometimes during the move the size of the bar gets reset.
  ; Here we make sure the size stays the same.

  ; Get the new size of the taskbar.
  WinGetPos newX, newY, newWidth, newHeight, ahk_class Shell_TrayWnd

  ; Compute the size delta.
  sizeDelta := newHeight - tbrHeight

  ; Adjust if required.
  if (sizeDelta)
  {
    ; Make the cursor go a bit more to make sure the size changes.
    if (sizeDelta < 0)
    {
      sizeDelta := sizeDelta - 1
    }
    else
    {
      sizeDelta := sizeDelta + 1
    }

    ; Initiate taskbar sizing.
    Send, {LWin}!{Space}s{Up}
    Sleep, 500

    ; Move the mouse and resize the taskbar.
    MouseMove, 0, %sizeDelta%, 0, R
    Send, {Enter}
    Sleep, 1000
  }

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Finalize the move.

  ; Move the mouse to the original position.
  MouseMove, %currX%, %currY%, 0

  ; Restore relative coordinate system.
  CoordMode, Mouse, Relative

  ; Lock the taskbar.
  UnlockTaskbar(False)
}
