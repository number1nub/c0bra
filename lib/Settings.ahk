#NoEnv
#SingleInstance, Force
#Escapechar ``
#CommentFlag ;

;~ Interface for Gui Settings

;~ Gui Settings Call (call Main, Side, or SLR)

Gui_Settings()
{
	global
	
	Gui, 1:Destroy
	Gui, 2:Destroy
	
	;{```` Create CSV button lists ````}
	Buttons    := JSON_Load(buttonSettings)
	ButtonList := []
	
	For key, value in Buttons
	{
		tempButton := value.text
		ButtonList.Insert(value.text, value)
	}
	;}
	
	Gui, Settings:Margin, 2, 10
	Gui, Settings:Font, s11 cBlack w700, Times New Roman	
	Gui, Settings:Add, Tab2, x2 y2 w675 h315 Wrap, Hotkeys|Gui Appearance|Colors / Add-ons|The Closer
	
	
	;{````  Hotkeys Tab Controls  ````}
	Gui, Settings:Tab, Hotkeys
	
	Gui, Settings:Add, GroupBox, x5 y35 w330 h280 Center, TRIGGER HOTKEYS
	Gui, Settings:Add, Text, xp+5 yp+30 w140 h30 Section, Main Trigger
	Gui, Settings:Add, Text, xp y+5 wp hp, Hold Trigger Action
	Gui, Settings:Add, Edit, x+5 ys-5 w175 hp vmainTrigger, % Settings.mainHotkey.mainHotkey
	Gui, Settings:Add, Edit, xp y+5 wp hp vmainHoldTrigger, % Settings.mainHotkey.holdAction
	Gui, Settings:Add, Text, xs y+10 w320 hp Center, Main trigger is disabled for the below items:
	
	aList :=
	for key, value in Settings.mainHotkey.disableIfActive
		aList := (aList = "" ? "" : aList "|") value
	Gui, Settings:Add, ListBox, xp y+5 w320 h110 vdisableIfActive hwndHdisableIfActive, %aList%
	Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddTriggerDisable, Add
	Gui, Settings:Add, Button, x+25 yp wp hp gremTriggerDisable, Remove
	
	Gui, Settings:Add, GroupBox, x340 y35 w330 h280 Center, USER HOTKEYS
	Gui, Settings:Add, Text, xp+5 yp+30 w320 h30 Center Section, Manage any personal hotkeys below:
	
	bList :=
	for key, value in Settings.userHotkeys
		bList := (bList = "" ? "" : bList "|") key "`t" value
	Gui, Settings:Add, ListBox, xp y+7 wp h190 vuserHotkeys hwndHuserHotkeys, %bList%
	Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddUserHotkey, Add
	Gui, Settings:Add, Button, x+25 yp w100 hp gremUserHotkey, Remove
	
	
	;{````  Appearance Tab Controls  ````}
	Gui, Settings:Tab, Gui Appearance
	
	Gui, Settings:Add, Text, x+5 y+40 w160 h30 Section, Button Height (pixels)
	Gui, Settings:Add, Text, xp y+5 wp hp, Button Width (pixels)
	Gui, Settings:Add, Text, xp y+5 wp hp, Button Spacing (pixels)
	Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Font
	Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Boldness
	Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Size
	Gui, Settings:Add, Text, xp y+5 wp hp, Background Color
	
	Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, MAIN GUI
	Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vbHeight, % Settings.mainGui.buttonHeight
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vbWidth, % Settings.mainGui.buttonWidth
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vbSpacing, % Settings.mainGui.buttonSpacing
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r6 0x100 Center vtFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
		GuiControl, Settings:ChooseString, tFont, % Settings.mainGui.textFont
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r2 0x100 Center vtBold, 400|700
		GuiControl, Settings:ChooseString, tBold, % Settings.mainGui.textBold
	Gui, Settings:Add, Edit, xp y+10 wp hp Center vtSize, % Settings.mainGui.textSize
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vguiColor gGuiColor, % Settings.mainGui.guiBackColor
	
	Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, SIDE GUI
	Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vsbHeight, % Settings.sideGui.buttonHeight
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vsbWidth, % Settings.sideGui.buttonWidth
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vsbSpacing, % Settings.sideGui.buttonSpacing
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r6 0x100 Center vstFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
		GuiControl, Settings:ChooseString, stFont, % Settings.sideGui.textFont
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r2 0x100 Center vstBold, 400|700
		GuiControl, Settings:ChooseString, stBold, % Settings.sideGui.textBold
	Gui, Settings:Add, Edit, xp y+10 wp hp Center vstSize, % Settings.sideGui.textSize
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vsguiColor gGuiColor, % Settings.sideGui.guiBackColor
	
	Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, SLR GUI
	Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vslrbHeight, % Settings.SLRGui.buttonHeight
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vslrbWidth, % Settings.SLRGui.buttonWidth
	Gui, Settings:Add, Edit, xp y+5 wp hp Center vslrbSpacing, % Settings.SLRGui.buttonSpacing
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r6 0x100 Center vslrtFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
		GuiControl, Settings:ChooseString, slrtFont, % Settings.SLRGui.textFont
	Gui, Settings:Add, ComboBox, xp y+10 wp hp r2 0x100 Center vslrtBold, 400|700
		GuiControl, Settings:ChooseString, slrtBold, % Settings.SLRGui.textBold
	Gui, Settings:Add, Edit, xp y+10 wp hp Center vslrtSize, % Settings.SLRGui.textSize
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vslrguiColor gGuiColor, % Settings.SLRGui.guiBackColor
	
	
	;{```` Colors / Add-ons Tab Controls  ````}
	Gui, Settings:Tab, Colors / Add-ons
	Gui, Settings:Add, GroupBox, x5 y35 w335 h200 Center, DEFAULT BUTTON COLORS
	Gui, Settings:Add, Text, xp+5 yp+30 w160 h30 Section, Back Color
	Gui, Settings:Add, Text, xp y+5 wp hp, Text Color
	Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Back Color
	Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Text Color
	Gui, Settings:Add, Button, x+15 ys-5 w150 h30 Center vBackColor gGuiColor, % ButtonList.Default.BackColor
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vTextColor gGuiColor,  % ButtonList.Default.TextColor
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLBackColor gGuiColor,  % ButtonList.Default.HLBackColor
	Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLTextColor gGuiColor,  % ButtonList.Default.HLTextColor
	Gui, Settings:Add, CheckBox, xs+5 y+5 w310 hp vChangeDefaults, Update all buttons to default colors now?
	
	Gui, Settings:Add, GroupBox, x+20 y35 w325 h130 Center, MAIN GUI ADD-ONS
	Gui, Settings:Add, CheckBox, xp+5 yp+25 w310 h30 Section vmainSearch, Show Search Bar on Main Gui?
		GuiControl, Settings:, mainSearch, % Settings.search.search ? 1 : 0
	Gui, Settings:Add, Text, xp y+10 w125 h30, Search Bar Text
	Gui, Settings:Add, Edit, x+5 yp-5 w185 h30 Center vmainSearchText, % Settings.search.backText
	Gui, Settings:Add, CheckBox, xs y+5 w310 hp vmainFooter, Show Footer on Main Gui?
		GuiControl, Settings:, mainFooter, % Settings.footer.footer ? 1 : 0
	
	
	;{````  The Closer Tab Controls  ````}
	Gui, Settings:Tab, The Closer
	
	Gui, Settings:Add, Text, x10 y45 w100 h30 Section, Closer Hotkey
	Gui, Settings:Add, Edit, x+5 ys-5 w215 hp vcloserHotkey, % Settings.theCloser.hotkey
	Gui, Settings:Add, GroupBox, x5 y+6 w330 h240 Center, DISABLE THE CLOSER
	Gui, Settings:Add, Text, xp+5 yp+25 w320 h30 Center, The Closer is disabled for the following items:
	
	cList :=
	for key, value in Settings.theCloser.disableIfActive
		cList := (cList = "" ? "" : cList "|") value
	Gui, Settings:Add, ListBox, xp y+5 w320 h150 vcloserDisable hwndHcloserDisable, %cList%
	Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddCloserDisable, Add
	Gui, Settings:Add, Button, x+25 yp wp hp gremCloserDisable, Remove
	
	Gui, Settings:Add, GroupBox, x340 y35 w330 h280 Center, TAB CLOSER
	Gui, Settings:Add, Text, xp+5 yp+25 w320 h35 Wrap Center Section, The Closer will close a tab instead of the window for the following items:
	
	dList :=
	for key, value in Settings.theCloser.closeTabIfActive
		dList := (dList = "" ? "" : dList "|") value
	Gui, Settings:Add, ListBox, xp y+7 wp h190 vCloserTabs hwndHcloserTabs, %dList%
	Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddCloserTabs, Add
	Gui, Settings:Add, Button, x+25 yp w100 hp gremCloserTabs, Remove
	
	
	;{````  End Tab Control  ````}
	Gui, Settings:Tab
	
	Gui, Settings:Add, Button, x210 y325 w100 h30 gallSet Default, ALL SET
	Gui, Settings:Add, Button, x+50 yp wp hp gsettingsCancel, CANCEL
	
	Gui, Settings:Show, Center, c0bra Settings
	Return
}
		
		

allSet:
	Gui, Settings:Submit
	
	Settings.mainHotkey.mainHotkey := mainTrigger
	Settings.mainHotkey.holdAction := mainHoldTrigger
	
	ControlGet, disableTriggerList, List,,, ahk_id %HdisableIfActive%
	Settings.mainHotkey.disableIfActive := [] 
	Loop, Parse, disableTriggerList, `n
		Settings.mainHotkey.disableIfActive[A_Index] := A_LoopField
	
	ControlGet, userHotkeysList, List,,, ahk_id %HuserHotkeys%
	Settings.userHotkeys := []
	Loop, Parse, userHotkeysList, `n
	{
		Loop, Parse, A_LoopField, `t
		{
			if (A_Index = 1)
				aKey := A_LoopField
			else
				aValue := A_LoopField
		}
		Settings.userHotkeys[aKey] := aValue
	}
	
	Settings.mainGui.buttonHeight := bHeight
	Settings.mainGui.buttonSpacing := bSpacing
	Settings.mainGui.buttonWidth := bWidth
	GuiControlGet, aGuiColor, Settings:, guiColor
	Settings.mainGui.guiBackColor := aGuiColor
	Settings.mainGui.textBold := tBold
	Settings.mainGui.textFont := tFont
	Settings.mainGui.textSize := tSize
	
	Settings.search.Height := bHeight
	Settings.search.textBold := tBold
	Settings.search.textFont := tFont
	;;~ Settings.search.textSize := tSize
	
	Settings.sideGui.buttonHeight := sbHeight
	Settings.sideGui.buttonSpacing := sbSpacing
	Settings.sideGui.buttonWidth := sbWidth
	GuiControlGet, aSGuiColor, Settings:, sguiColor
		Settings.sideGui.guiBackColor := aSGuiColor
	Settings.sideGui.textBold := stBold
	Settings.sideGui.textFont := stFont
	Settings.sideGui.textSize := stSize
	
	Settings.SLRGui.buttonHeight := slrbHeight
	Settings.SLRGui.buttonSpacing := slrbSpacing
	Settings.SLRGui.buttonWidth := slrbWidth
	GuiControlGet, aSLRGuiColor, Settings:, slrguiColor
	Settings.SLRGui.guiBackColor := aSLRGuiColor
	Settings.SLRGui.textBold := slrtBold
	Settings.SLRGui.textFont := slrtFont
	Settings.SLRGui.textSize := slrtSize
	
	GuiControlGet, BackColorText, Settings:, BackColor
		Buttons.Defaults.BackColor := BackColorText
	GuiControlGet, TextColorText, Settings:, TextColor
		Buttons.Defaults.TextColor := TextColorText
	GuiControlGet, HLBackColorText, Settings:, HLBackColor
		Buttons.Defaults.HLBackColor := HLBackColorText
	GuiControlGet, HLTextColorText, Settings:, HLTextColor
		Buttons.Defaults.HLTextColor := HLTextColorText
	
	if (ChangeDefaults)
	{				
		for key, value in buttons
		{
			tempButton := value.text
			ButtonList.Insert(value.text, value)
			
			GuiControlGet, BackColorText, Settings:, BackColor
				buttons[key].BackColor := BackColorText
			GuiControlGet, TextColorText, Settings:, TextColor
				buttons[key].TextColor := TextColorText
			GuiControlGet, HLBackColorText, Settings:, HLBackColor
				buttons[key].HLBackColor := HLBackColorText
			GuiControlGet, HLTextColorText, Settings:, HLTextColor
				buttons[key].HLTextColor := HLTextColorText
		}
	}
	
	Settings.search.search := mainSearch ? 1 : 0
	Settings.search.backText := mainSearchText
	Settings.footer.footer := mainFooter ? 1 : 0
	
	Settings.theCloser.hotkey := closerHotkey
	
	ControlGet, disableCloserList, List,,, ahk_id %HcloserDisable%
	Settings.theCloser.disableIfActive := []
	Loop, Parse, disableCloserList, `n
		Settings.theCloser.disableIfActive[A_Index] := A_LoopField
	
	ControlGet, closerTabList, List,,, ahk_id %HcloserTabs%
	Settings.theCloser.closeTabIfActive := []
	Loop, Parse, closerTabList, `n
		Settings.theCloser.closeTabIfActive[A_Index] := A_LoopField
	
	ButtonList := []
	JSON_Save(buttons, buttonSettings)
	JSON_save(Settings, c0braSettings)
	Buttons := []
	
	Gui, Settings:Destroy
	quickReload("GUI Settings Updated...")
return



SettingsGuiClose:
SettingsGuiEscape:
settingsCancel:
	Gui, Settings:Destroy
	Buttons := []
return



addTriggerDisable:
	Gui Settings: +OwnDialogs
	
	InputBox, aTriggerDisable, c0bra Disable Trigger, Type or paste the window title or program that will disable c0bra from opening.`n`nExample: ahk_exe chrome.exe`n- If Chrome was active`, the main trigger would be disabled.
	if (ErrorLevel)
		return
	if (aTriggerDisable = "")
	{
		MsgBox, 4112, c0bra Disable Trigger, No window or class input was found.  Please try again.
		return
	}
	;TODO - figure out if this disable if active already exists
	 
	 GuiControl, Settings:, disableIfActive, % aTriggerDisable
return



remTriggerDisable:
	Gui Settings: +OwnDialogs
	
	GuiControl, Settings:+AltSubmit, disableIfActive
	GuiControlGet, aDisableRemovePos, Settings:, disableIfActive
	if (Errorlevel)
		return
	if (aDisableRemovePos = "")
	{
		MsgBox, 4144, c0bra Disable Trigger, No window or class was selected.`n`nPlease select an item to remove from the Disable If Active list and try again.
		return
	}
	
	GuiControl, Settings:-AltSubmit, disableIfActive
	GuiControlGet, aDisableRemove, Settings:, disableIfActive
	
	MsgBox, 4129, c0bra Disable Trigger, Are you sure you want to remove `"%aDisableRemove%`" from the Disable If Active List?
	IfMsgBox Cancel
		return
	
	Control, Delete, %aDisableRemovePos%,, ahk_id %HdisableIfActive%
return



addUserHotkey:
	Gui Settings: +OwnDialogs
	
	InputBox, anewHotkey, c0bra User Hotkeys, What is the new Hotkey?`n`nExample: ^+1`n-This hotkey would be ctrl + shift + 1
	if (ErrorLevel)
		return
	if (anewHotkey = "")
	{
		MsgBox, 4112, c0bra User Hotkeys, No hotkey was entered.  Please try again.
		return
	}
	;TODO - figure out if this user hotkey already exists
	
	InputBox, anewHotkeyAction, c0bra User Hotkeys, What will the %anewHotkey% hotkey do?`n`nExample: [F] quickReload`n-This would find the function `"quickReload`" and run it.
	if (ErrorLevel)
		return
	if (anewHotkeyAction = "")
	{
		MsgBox, 4112, c0bra User Hotkeys, No hotkey action was entered.  Please try again.
		return
	}
	
	GuiControl, Settings:, userHotkeys, % anewHotkey "`t" anewHotkeyAction
return



remUserHotkey:
	Gui Settings: +OwnDialogs
	
	GuiControl, Settings:+AltSubmit, userHotkeys
	GuiControlGet, aHotkeyRemovePos, Settings:, userHotkeys
	if (Errorlevel)
		return
	if (aHotkeyRemovePos = "")
	{
		MsgBox, 4144, c0bra User Hotkeys, No user hotkey was selected.`n`nPlease select an item to remove from the User Hotkeys list and try again.
		return
	}
	
	GuiControl, Settings:-AltSubmit, userHotkeys
	GuiControlGet, aHotkeyRemove, Settings:, userHotkeys
	
	MsgBox, 4129, c0bra User Hotkeys, Are you sure you want to remove `"%aHotkeyRemove%`" from the User Hotkeys List?
	IfMsgBox Cancel
		return
	
	Control, Delete, %aHotkeyRemovePos%,, ahk_id %HuserHotkeys%
return



addCloserDisable:
	Gui Settings: +OwnDialogs
	
	InputBox, aCloserDisable, c0bra Disable Closer, Type or paste the window title or program that will disable c0bra's closer from running.`n`nExample: ahk_exe chrome.exe`n- If Chrome was active`, the closer would be disabled.
	if (ErrorLevel)
		return
	if (aCloserDisable = "")
	{
		MsgBox, 4112, c0bra Disable Closer, No window or class input was found.  Please try again.
		return
	}
	;TODO - figure out if this disable if active already exists
	 
	 GuiControl, Settings:, closerDisable, % aCloserDisable
return



remCloserDisable:
	Gui Settings: +OwnDialogs
	
	GuiControl, Settings:+AltSubmit, closerDisable
	GuiControlGet, aCloserRemPos, Settings:, closerDisable
	if (Errorlevel)
		return
	if (aCloserRemPos = "")
	{
		MsgBox, 4144, c0bra Disable Closer, No window or class was selected.`n`nPlease select an item to remove from the Disable Closer list and try again.
		return
	}
	
	GuiControl, Settings:-AltSubmit, closerDisable
	GuiControlGet, aCloserRem, Settings:, closerDisable
	
	MsgBox, 4129, c0bra Disable Closer, Are you sure you want to remove `"%aCloserRem%`" from the Disable Closer List?
	IfMsgBox Cancel
		return
	
	Control, Delete, %aCloserRemPos%,, ahk_id %HcloserDisable%
return



addCloserTabs:
	Gui Settings: +OwnDialogs
	
	InputBox, aCloserTabs, c0bra Closer Tabs, Type or paste the window title or program that c0bra's closer will close tabs instead of windows.`n`nExample: ahk_exe chrome.exe`n- If Chrome was active`, the closer would close the active tab.
	if (ErrorLevel)
		return
	if (aCloserTabs = "")
	{
		MsgBox, 4112, c0bra Closer Tabs, No window or class input was found.  Please try again.
		return
	}
	;TODO - figure out if this disable if active already exists
	 
	 GuiControl, Settings:, closerTabs, % aCloserTabs
return



remCloserTabs:
	Gui Settings: +OwnDialogs
	
	GuiControl, Settings:+AltSubmit, closerTabs
	GuiControlGet, aCloserTabRemPos, Settings:, closerTabs
	if (Errorlevel)
		return
	if (aCloserTabRemPos = "")
	{
		MsgBox, 4144, c0bra Closer Tabs, No window or class was selected.`n`nPlease select an item to remove from the Closer Tabs list and try again.
		return
	}
	
	GuiControl, Settings:-AltSubmit, closerTabs
	GuiControlGet, aCloserTabs, Settings:, closerTabs
	
	MsgBox, 4129, c0bra Closer Tabs, Are you sure you want to remove `"%aCloserTabs%`" from the Closer Tabs List?
	IfMsgBox Cancel
		return
	
	Control, Delete, %aCloserTabRemPos%,, ahk_id %HcloserTabs%
return



guiColor:
	aGuiSettings := 1
	ColorButton := A_GuiControl

	ColorGui()
	
	;~ theColor := RegExReplace(ColorChooser(), "i)0x")
	
	;~ if (theColor <> "")
		;~ GuiControl, Settings:, guiColor, %theColor%
return


		
;~ DefaultColor:
	;~ ColorButton := A_GuiControl
	;~ ColorGui()
;~ return
		
