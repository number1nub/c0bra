

;{===== Context Menu Actions ====>>>

QuickEditMenu:
	temp_MenuItem := RegExReplace(A_ThisMenuItem, "\s")
	
	for key in Settings.mainGui
		GuiKeys := (guiKeys != "" ? guiKeys "," : "") key
	for key in Settings.search
		GuiKeys := (guiKeys != "" ? guiKeys "," : "") key

	StringReplace, menuCheck, A_ThisMenuItem, main%A_Space%
	menuCheck := Trim(menuCheck)
	
	
	;{```` Add Program Button ````}
	If (menuCheck = "Program")
	{
		GUI, Destroy
		GUI, 1:Destroy
		
		CMD := 1			
		typeCMD := "P"
		
		if (A_ThisMenuItem = "Outlook")
			argsCMD := "Outlook"

		redoProgram:
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		InputBox, aText, Button Title, What is the name of the program?
		if (ErrorLevel || !aText)
			return
		if (buttonCheck(buttons, aText))
			goto, redoProgram
		
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		FileSelectFile, argsCMD,1,, Select the program that the %aText% button will open
		if (ErrorLevel || !argsCMD)
			return

		Children := 0				
	}
	;}


	;{```` Add a Folder Button ````}
	else if (menuCheck = "Folder")
	{
		Gui, Destroy
		GUI, 1:Destroy
		
		CMD := 1
		typeCMD := "R"
		
		redoFolder:
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		InputBox, aText, Button Title, What is the button Title?
		if (ErrorLevel || !aText)
				return
				
		if (buttonCheck(buttons, aText))
			goto, redoFolder
		;~ else
			;~ return
		
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		FileSelectFolder, argsCMD,,, Select the folder that the %aText% button will open
		if (ErrorLevel || !argsCMD)
			return
		
		Children := 0
	}
	;}
	

	;{```` Add a Send Keys Button ````}
	else if (menuCheck = "Send Keys")
	{
		Gui, Destroy
		GUI, 1:Destroy
		
		CMD := 1
		typeCMD := "S"
		
		redoSendKeys:
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		InputBox, aText, Button Title, What is the button Title?
		if (ErrorLevel || !aText)
			return
				
		if (buttonCheck(buttons, aText))
			goto, redoSendKeys
		
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		InputBox, argsCMD,Create c0bra Button,Enter the keys to be sent,,375,145
		If (ErrorLevel || !argsCmd)
			return
		
		Children := 0
	}
	;}


	;{````  Add a Bookmarks Button  ````}
	else if (menuCheck = "Bookmarks")
	{
		aText := "Bookmarks"
		CMD      := ""
		typeCMD  := ""
		Children := 0
	}
	;}


	;{````  Add a Main Menu Button  ````}
	else if (menuCheck = "Sub-Menu Button")
	{
		GUI, Destroy
		GUI, 1:Destroy
		
		redoSubMenu:
		GUI +LastFound +OwnDialogs +AlwaysOnTop
		InputBox, aText, Sub-Menu Name, Enter the name for the sub-menu button:
		if (ErrorLevel || !aText)
			return					
		if (buttonCheck(buttons, aText))
			goto, redoSubMenu
			
		CMD      := ""
		typeCMD  := ""
		Children := []
	}
	;}


	;{```` Edit A Button ````}
	else if (A_ThisMenuItem = "Edit " me)
	{
		GUI, 1:Destroy
		
		bIndex := ""
		pIndex := ""
		cIndex := ""
		curVal := ""
		
		InputBox, newText, c0bra Configuration, Button Text:,,,,,,,, %me%
		if (ErrorLevel || !newText)
		{
			msgbox, 4144, c0bra Configuration, Invalid entry.`n`nAborting
			return
		}
		
		
		for index, value in Buttons
		{
			if (value.Children && !pIndex)
			{
				for childIndex, child in value.Children
					if (child = me)
					{
						pIndex := index
						cIndex := childIndex
					}
			}
			else if (value.Text = me)
			{
				bIndex := index
				curVal := value.Cmd.Arg
			}
		}
		
		InputBox, newCommand, c0bra Configuration, Button Command:,,,,,,,, %curVal%
		If (ErrorLevel || !newCommand)
		{
			msgbox, 4144, c0bra Configuration, Invalid entry.`n`nAborting
			return
		}
		
		Buttons[pIndex].Children[cIndex] := newText
		Buttons[bIndex].Text := newText
		Buttons[bIndex].Cmd.Arg := newCommand
		
		JSON_Save(Buttons, buttonSettings)
		quickReload("Changes saved...", me " Button Updated")
	}
	;}


	;~ ;{```` Add to No-run List ````}
	;~ else if (A_ThisMenuItem = "Add to no-run list")
	;~ {
		;~ GUI, Destroy
		;~ GUI, 1:Destroy
		
		;~ InputBox, addNoRun, Add to NoRun List, Enter a window title or class name in which to disable the c0bra hotkey,,375,175		
		;~ if ErrorLevel
			;~ return
		
		;~ for key, value in Settings.mainHotkey.disableIfActive
			;~ if (value = addNorun)
			;~ {
				;~ MsgBox, 4096, c0bra No-run, The No-run window %addNorun% already exists.
				;~ return
			;~ }
				
		;~ Settings.mainHotkey.disableIfActive.Insert(addNorun)
		;~ JSON_Save(Settings, c0braSettings)
		;~ Reload	
	;~ }
	;~ ;}
	
	
	;~ ;{```` Remove From No-Run ````}
	;~ else if A_ThisMenuItem in %disableMainHKList%
	;~ {
		;~ GUI, Destroy
		;~ GUI, 1:Destroy
		
		;~ MsgBox, 4113, c0bra No-run, Are you sure you want to remove %A_ThisMenuItem% from the No-run list?
		;~ IfMsgBox OK
		;~ {
			;~ for key, value in Settings.mainhotkey.disableIfActive			
				;~ if (value = A_ThisMenuItem)
				;~ {
					;~ Settings.mainHotkey.disableIfActive.Remove(key)
					;~ JSON_Save(Settings, c0braSettings)
					;~ Reload
					;~ return
				;~ }
		;~ }
		;~ else
			;~ return
	;~ }
	;~ ;}
	
	
	;~ ;{```` Add to Close Tab List ````}
	;~ else if (A_ThisMenuItem = "Add to close tab list")
	;~ {
		;~ GUI, Destroy
		;~ GUI, 1:Destroy
		
		;~ InputBox, addCloseTab, Add to close tab List, Enter a window title or class name in which to close tab,,375,175		
		;~ if (ErrorLevel || !addCloseTab)
			;~ return
		
		;~ for key, value in Settings.theCloser.closeTabIfActive
			;~ if (value = addCloseTab)
			;~ {
				;~ MsgBox, 4096, c0bra Closer, The %addNorun% already exists in close tab list.
				;~ return
			;~ }
				
		;~ Settings.theCloser.closeTabIfActive.Insert(addCloseTab)
		;~ JSON_Save(Settings, c0braSettings)
		;~ Reload	
	;~ }
	;~ ;}
	
	
	;~ ;{```` Toggle Search Bar ````}
	;~ else if (A_ThisMenuItem = "Search Bar")
	;~ {
		;~ guis.search.search := !guis.search.search
		;~ JSON_save(guis, guiSettings)
		;~ quickReload("Search bar " (guis.search.search ? "Enabled" : "Disabled"))
	
		;~ IfWinExist, c0bra Main GUI
		;~ {
			;~ GUI, Destroy
			;~ GUI, 1:Destroy
			;~ goto, guiOldPos
		;~ }
		
		;~ return
	;~ }
	;}
	
	
	;{```` Main Gui Settings ````}
	;~ else if (A_ThisMenuItem = "Main Gui Settings")
	;~ {
		;~ Gui_Settings("Main")
		;~ theGui := "Main"
		;~ return
	;~ }
	;}
	
	
	;{```` Side Gui Settings ````}
	;~ else if (A_ThisMenuItem = "Side Gui Settings")
	;~ {
		;~ Gui_Settings("Side")
		;~ return
	;~ }
	;}
	
	
	;{```` SLR Gui Settings ````}
	;~ else if (A_ThisMenuItem = "SLR Gui Settings")
	;~ {
		;~ Gui_Settings("SLR")
		;~ return
	;~ }
	;}


	;{```` Change search text ````}
	;~ else if (A_ThisMenuItem = "Change Search Text")
	;~ {
		;~ InputBox, backText, Search Text, Enter text to be shown in search box.,,,,,,,, % guis.search.BackText
		;~ if (errorlevel)
			;~ return
		
		;~ guis.search.BackText := backText
		;~ JSON_save(guis, guiSettings)
		;~ quickReload("Search text updated...")		
	;~ }
	;~ ;}


	;~ ;{```` Toggle Footer ````}
	;~ else if (A_ThisMenuItem = "Footer")
	;~ {
		;~ guis.footer.footer := !guis.footer.footer
		;~ JSON_save(guis, guiSettings)
		;~ quickReload("Footer " (guis.footer.footer ? "Enabled" : "Disabled"))		
	;~ }
	;}


	;{```` Main GUI Options ````}
	;~ else if temp_MenuItem in %GuiKeys%
	;~ {
		;~ InputBox, newOption, c0bra GUI Options, Enter the new value for A_ThisMenuitem.,,,,,,,, % guis.mainGui[temp_MenuItem] != "" ? guis.mainGui[temp_MenuItem] : guis.search[temp_MenuItem]
		;~ if !(ErrorLevel)
		;~ {
			;~ if (guis.mainGui[temp_MenuItem] != "")
			;~ {
				;~ guis.mainGui[temp_MenuItem] := newOption
				;~ JSON_save(guis, guiSettings)
			;~ }
			;~ else if (guis.search[temp_MenuItem] != "")
			;~ {
				;~ guis.search[temp_MenuItem] := newOption
				;~ JSON_save(guis, guiSettings)
			;~ }
		;~ }
			
		;~ return
	;~ }
	;}


	;{```` Delete A Button ````}
	else if (InStr(A_ThisMenuItem, "Delete"))
	{
		MsgBox, 262196, c0bra Delete, Are you sure you want to delete the %me% button? 
		ifmsgbox, Yes
		{
			GUI, Destroy
			deleteButton(me)
			goto, guiOldPos
		}
		return
	}
	;}


	;{```` Change Button Colors ````}
	else if (RegExMatch(Trim(A_ThisMenuItem), "i)Color\s*$"))
	{	
		ColorGui()
		return
	}
	;}


	;{```` Unhandled Menu Item ````}
	else
	{
		msgbox, 4144,, Sorry!`n`nThis feature is still under construction...
		GUI, Destroy
		return
	}
	;}
	
	
	
	;********************************************************
	;{___  Create The Button  _______________________________
	
	Parent := InStr(A_ThisMenuItem, "main") ? "0" : me
		
	; Default or parent colors or color picker
	aColor := {}
	
	;CHANGED: Removed the option to fully customize the button on creation (too annoying)

	dBack   := buttonList.Default.BackColor
	dText   := buttonList.Default.TextColor
	dHLBack := buttonList.Default.HlBackColor
	dHLText := buttonList.Default.HlTextColor
	
	aColor[1] := dBack
	aColor[2] := dText
	aColor[3] := dHLBack
	aColor[4] := dHLText

	if (Parent)
	{
		pBack   := buttonList[Parent].BackColor
		pText   := buttonList[Parent].TextColor
		pHLBack := buttonList[Parent].HlBackColor
		pHLText := buttonList[Parent].HlTextColor
		
		;CHANGED: Only prompt if parent button isn't using default colors
		if (pBack != dBack || pText != dText || pHLBack != dHLBack || pHLText != dHLText)
		{
			MsgBox, 4132, c0bra Colors, Use same color settings as parent button (%Parent%)?`n`nIf NO, current default colors will be used.
			IfMsgBox Yes
			{
				aColor[1] := buttonList[Parent].BackColor
				aColor[2] := buttonList[Parent].TextColor
				aColor[3] := buttonList[Parent].HlBackColor
				aColor[4] := buttonList[Parent].HlTextColor
			}
		}
	}
		
	addButton(aText, CMD, typeCmd, argsCmd, aColor, Children, Parent)
	goto, gui
	goto, guiOldPos
	;}
return

;}<<<==== Context Menu Actions =====



;{===== Tray Menu Actions ====>>>

TrayText:

	;{```` Change Main Hotkey ````}
	;~ if (A_ThisMenuItem = "Trigger: " Settings.mainHotkey.mainHotkey)
	;~ {
		;~ mainHotkey := settings.mainHotkey.mainHotkey
		;~ InputBox, newTrigger, c0bra Trigger, Enter new c0bra trigger hotkey(s)`nCurrent Hotkey - %mainHotkey%`n`nExample 1 - MButton`nExample 2 - ^#1`n,,,,,,,, % mainHotkey
		;~ if (ErrorLevel || !newTrigger)
			;~ return		
		;~ Settings.mainHotkey.mainHotkey := newTrigger
		;~ JSON_Save(Settings, c0braSettings)
		;~ quickReload("New Trigger: " newTrigger, "Main Hotkey Changed")
	;~ }
	;}

	;{```` Add new user hotkey ````}
	;~ else if (A_ThisMenuItem = "Add New Hotkey")
	;~ {
		;~ InputBox, newTrigger, New Hotkey, Hotkey trigger:
		;~ If (ErrorLevel || !newTrigger)
			;~ return
		;~ InputBox, newAction, New Hotkey, % "Hotkey action:`n(use either [F], [L], [R] or [P])"
		;~ If (ErrorLevel || !newAction)
			;~ return
		
		;~ Settings.userHotkeys[newTrigger] := newAction
		;~ JSON_Save(Settings, c0braSettings)
		;~ quickReload("ACTION:`n" newAction, "Added Hotkey <" modReplace(newTrigger) ">")
	;~ }
	;}
	
	;{````  Edit/Delete User Hotkey  ````}
	;~ else if (RegExMatch(A_ThisMenuItem, "i)^<(?P<Trigger>.+?)> - <(?P<Action>.+)>$", hk))
	;~ {
		;~ InputBox, newTrigger, Edit Hotkey, % "Hotkey trigger:`n`n(To DELETE hotkey, input blank value)",,400,175,,,,, % hkTrigger
		;~ If (ErrorLevel)
			;~ return		
		;~ if (!newTrigger)
		;~ {
			;~ Settings.userHotkeys.Remove(hkTrigger)
			;~ JSON_Save(Settings, c0braSettings)
			;~ quickReload("Deleted Hotkey <" modReplace(hkTrigger) ">")
		;~ }
		;~ InputBox, newAction, Edit Hotkey, % "Hotkey action:",,600,160,,,,, % hkAction
		;~ If (ErrorLevel || !newAction)
			;~ return
		;~ Settings.userHotkeys.Remove(hkTrigger)
		;~ Settings.userHotkeys[newTrigger] := newAction
		;~ JSON_Save(Settings, c0braSettings)
		;~ quickReload("New Hotkey: " modReplace(newTrigger) "`nAction:`n" newAction, "Updated Hotkey <" modReplace(hkTrigger) ">")
	;~ }
	;}
			return

;}<<<==== Tray Menu Actions =====



