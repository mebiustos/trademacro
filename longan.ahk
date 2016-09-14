; https://github.com/thirdy/longan
; based on https://github.com/trackpete/exiletools-price-macro/blob/master/poe_price_macro.ahk

#SingleInstance force

If (A_AhkVersion <= "1.1.22")
{
    msgbox, You need AutoHotkey v1.1.22 or later to run this script. `n`nPlease go to http://ahkscript.org/download and download a recent version.
    exit
}


; Control p
^p::
IfWinActive, Path of Exile ahk_class Direct3DWindowClass 
{
  FunctionReadItemFromClipboard()
}
return

FunctionReadItemFromClipboard() {
  ; Only does anything if POE is the window with focus
  IfWinActive, Path of Exile ahk_class Direct3DWindowClass
  {
    ; Send a ^C to copy the item information to the clipboard
	; Note: This will trigger any Item Info/etc. script that monitors the clipboard
    Send ^c
    ; Wait 250ms - without this the item information doesn't get to the clipboard in time
    Sleep 250
	; Get what's on the clipboard
    ClipBoardData = %clipboard%
    
    ; Split the clipboard data into strings to make sure it looks like a properly
	; formatted item, looking for the Rarity: tag in the first line. Just in case
	; something weird got copied to the clipboard.
	StringSplit, data, ClipBoardData, `n, `r
		
	; Strip out extra CR chars so my unix side server doesn't do weird things
	StringReplace RawItemData, ClipBoardData, `r, , A

	; If the first line on the clipboard has Rarity: it is probably some item
	; information from POE, so we'll send it to my server to process. Otherwise
	; we just don't do anything at all.
    IfInString, data1, Rarity:
    {
	  itemName := data2 . " " . data3
      IfInString, data3, ---
      {
        itemName := data2
      }
      
	  ; MsgBox % itemName
      
      payload := """league=Essence&type=&base=&name=" . itemName . "&dmg_min=&dmg_max=&aps_min=&aps_max=&crit_min=&crit_max=&dps_min=&dps_max=&edps_min=&edps_max=&pdps_min=&pdps_max=&armour_min=&armour_max=&evasion_min=&evasion_max=&shield_min=&shield_max=&block_min=&block_max=&sockets_min=&sockets_max=&link_min=&link_max=&sockets_r=&sockets_g=&sockets_b=&sockets_w=&linked_r=&linked_g=&linked_b=&linked_w=&rlevel_min=&rlevel_max=&rstr_min=&rstr_max=&rdex_min=&rdex_max=&rint_min=&rint_max=&mod_name=&mod_min=&mod_max=&group_type=And&group_min=&group_max=&group_count=1&q_min=&q_max=&level_min=&level_max=&ilvl_min=&ilvl_max=&rarity=&seller=&thread=&identified=&corrupted=&online=x&buyout=x&altart=&capquality=x&buyout_min=&buyout_max=&buyout_currency=&crafted=&enchanted="""
      ; java will do the proper url encoding
      
      RunWait, java -Dfile.encoding=UTF-8 -jar longan.jar -l 10 -p %payload%, , Hide ; after this line finishes, results.txt should appear
      FileRead, results, results.txt
      ShowToolTip(results)
      
	} 	
  }  
}

; Show tooltip, with fixed width font
ShowToolTip(String)
{
    Global X, Y, ToolTipTimeout, Opts
    
    ; Get position of mouse cursor
    MouseGetPos, X, Y

    
        CoordMode, ToolTip, Screen
        ;~ GetScreenInfo()
        ;~ TotalScreenWidth := Globals.Get("TotalScreenWidth", 0)
        ;~ HalfWidth := Round(TotalScreenWidth / 2)
        
        ;~ SecondMonitorTopLeftX := HalfWidth
        ;~ SecondMonitorTopLeftY := 0
        ScreenOffsetY := Opts.ScreenOffsetY
        ScreenOffsetX := Opts.ScreenOffsetX
        
        XCoord := 0 + ScreenOffsetX
        YCoord := 0 + ScreenOffsetY
        
        ToolTip, %String%, XCoord, YCoord
        ; Set up count variable and start timer for tooltip timeout
        ToolTipTimeout := 0
        SetTimer, ToolTipTimer, 100
}

; Tick every 100 ms
; Remove tooltip if mouse is moved or 5 seconds pass
ToolTipTimer:
    Global Opts, ToolTipTimeout
    ToolTipTimeout += 1
    MouseGetPos, CurrX, CurrY
    ; Pixels mouse must move to auto-dismiss tooltip
    MouseMoveThreshold := 200
    MouseMoved := (CurrX - X) ** 2 + (CurrY - Y) ** 2 > MouseMoveThreshold ** 2
    If (MouseMoved or (ToolTipTimeout >= 150))
    {
        SetTimer, ToolTipTimer, Off
        ToolTip
    }
    return