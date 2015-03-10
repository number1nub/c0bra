

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


	;{```` Add a Bookmarks Button ````}
	else if (menuCheck = "Bookmarks")
	{
		aText := "Bookmarks"
		CMD      := ""
		typeCMD  := ""
		Children := 0
	}
	;}


	;{```` Add a Main Menu Button ````}
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
	else if (A_ThisMenuItem = "Edit <" me ">")
	{
		GUI, 1:Destroy
		
		bIndex:="", pIndex:="", cIndex:="", curVal:=""
		
		InputBox, newText, c0bra Configuration, Button Text:,,,,,,,, %me%
		if (ErrorLevel || !newText)
		{
			msgbox, 4144, c0bra Configuration, Invalid entry.`n`nAborting
			return
		}

		for index, value in Buttons
		{
			if (value.Text = me && IsObject(value.Children))
			{
				Buttons[index].Text := newText
				JSON_Save(Buttons, files.user.Buttons)
				quickReload("Changes saved...", me " Bu")
			}
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
		
		JSON_Save(Buttons, files.user.Buttons)
		quickReload("Changes saved...", me " Button Updated")
	}
	;}


	;{```` Delete A Button ````}
	else if (InStr(A_ThisMenuItem, "Delete <" me ">"))
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
	;{````  Edit/Delete User Hotkey  ````}
	;~ else if (RegExMatch(A_ThisMenuItem, "i)^<(?P<Trigger>.+?)> - <(?P<Action>.+)>$", hk))
	;~ {
		;~ InputBox, newTrigger, Edit Hotkey, % "Hotkey trigger:`n`n(To DELETE hotkey, input blank value)",,400,175,,,,, % hkTrigger
		;~ If (ErrorLevel)
			;~ return		
		;~ if (!newTrigger)
		;~ {
			;~ Settings.userHotkeys.Remove(hkTrigger)
			;~ JSON_Save(Settings, files.user.Settings)
			;~ quickReload("Deleted Hotkey <" modReplace(hkTrigger) ">")
		;~ }
		;~ InputBox, newAction, Edit Hotkey, % "Hotkey action:",,600,160,,,,, % hkAction
		;~ If (ErrorLevel || !newAction)
			;~ return
		;~ Settings.userHotkeys.Remove(hkTrigger)
		;~ Settings.userHotkeys[newTrigger] := newAction
		;~ JSON_Save(Settings, files.user.Settings)
		;~ quickReload("New Hotkey: " modReplace(newTrigger) "`nAction:`n" newAction, "Updated Hotkey <" modReplace(hkTrigger) ">")
	;~ }
	;}
return

;}<<<==== Tray Menu Actions =====
