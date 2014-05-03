
return

;{ Main Trigger for c0bra
;_______________________

	mainTrigger:		
		HKHoldTime := 475	;Min. time to hold HK to trigger hold event
		
		sTime := A_TickCount
		loop
		{
			Sleep, 20
			if ((A_TickCount - sTime) > HKHoldTime)
				goto, MainTrigger_Held
			getkeystate, keyVar, %mainHotkey%, P
			IfEqual, keyVar, U, break
		}
		goto, MainTrigger_Pressed
	return
	
	
	MainTrigger_Held:		
		Execute(Settings.mainHotkey.holdAction, "Held Main Hotkey")
	return


	MainTrigger_Pressed:
		If (WinExist("c0bra Main GUI"))
		{
			if WinActive("c0bra Main GUI")
				SLR_GUI()
			else
			{
				Gui, Destroy
				goto, Gui
			}
		}
		else
		{
			IfWinExist SLR
			{
				IfWinActive SLR
					goto Gui
				else
					WinActivate SLR
			}
			else
				goto Gui
		}
		
	return
	
;}
	
	
;{ GUI Code 
;__________


; MAIN GUI CALL
;______________

	Gui:

	Gui, 1:Destroy
	Gui, 2:Destroy
	
	MouseGetPos, XPOS, YPOS
	
	guiOldPos:
	
	; Set variables from json file
	;_____________________________

		currGui := 1
		
		ButtonList := []
		mainButtons := ""
		
		Guis 	:= JSON_Load(guiSettings)
		Buttons := JSON_Load(buttonSettings)
		
		buttonSpacing 		:= Guis.mainGui.buttonSpacing
		buttonWidth 		:= Guis.mainGui.buttonWidth
		buttonHeight 		:= Guis.mainGui.buttonHeight
		search 				:= Guis.mainGui.search
		textSize 			:= Guis.mainGui.textSize
		textBold 			:= Guis.mainGui.textBold
		lastButWidth 		:= (buttonWidth * 2) + (buttonSpacing * 2)
		sideLastButWidth 	:= lastButWidth - (4 * buttonSpacing)
		footerColor			:= Guis.mainGui.footerColor
		
		For key, value in Buttons
		{
			tempButton := value.text
			ButtonList.Insert(value.text, value)
			if (ButtonList[tempButton].Level = "")
				mainButtons .= (mainButtons ? "," : "") value.text
			
			allButtons .= (allButtons ? "," : "") value.text
		}
		
	; Start Gui Call
	;_______________
	
		Gui, Color, % Guis.mainGui.guiBackColor

		gui, -caption +ToolWindow +AlwaysOnTop
		gui, margin, %buttonSpacing%, %buttonSpacing%
		
		; Google Search and Go Button - if enabled
		;_________________________________________
			
			if (search)
			{
				searchTextSize := Guis.search.searchTextSize
				searchHeight := Guis.search.searchHeight
				searchBackText := Guis.search.searchBackText
				goWidth := Guis.search.goWidth
				xGo := (buttonWidth * 2) + (buttonSpacing * 2) - goWidth
				searchWidth := (buttonWidth * 2) - goWidth
				searchTextWidth := searchWidth - 8
				searchTextColor := Guis.search.searchTextColor
								
				Gui, font, s%searchTextSize% w400
				Gui, Add, Edit, x%buttonSpacing% y%buttonSpacing% w%searchWidth% h%searchHeight% 0x200 vGSEARCH,
				Gui, Add, Text, xp yp-1 w%searchTextWidth% h%searchHeight%-2 0x200 Center +backgroundtrans hwndBackSearch, %searchBackText%
				
				gui, font, s%textSize% w%textBold% c%searchTextColor%
				
				Gui, Add, text, x%xGo% y%buttonSpacing% w%goWidth% h%searchHeight% 0x200 Center gButtonPress hwndGO, GO
					CTLCOLORS.Attach(GO, ButtonList.GO.BackColor, ButtonList.GO.TextColor)
			}
			
		; Don't add the following buttons to the main gui
		;________________________________________________

			StringReplace, mainButtons, mainButtons, GO`,
			StringReplace, mainButtons, mainButtons, Default`,
			
			
		; Add Main Gui Buttons
		;_____________________
		
			gui, font, s%textSize% w%textBold%
			
			loop, Parse, mainButtons, `,
				KEY_COUNT := A_Index

			loop, Parse, mainButtons, `,
			{
				A_HWND := "back" A_Index
				
				
				if (A_Index = 1) ; first key
				{
					Gui, Add, text, x%buttonSpacing% y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
						CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
					continue
				}
				
				else if (mod(A_Index, 2)) ; odd key
				{
					if (A_Index = KEY_COUNT) ; odd last key
					{
						lastButton := A_LoopField
						Gui, Add, text, x%buttonSpacing% y+%buttonSpacing% w%LastButWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
							CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
						continue
					}
					
					Gui, Add, text, x%buttonSpacing% y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
						CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
					continue
				}
				
				else ; even key
				{
					Gui, Add, text, x+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
						CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
					continue
				}
			}
			
		; Footer call
		;____________
			
			if (guis.mainGui.footer)
			{
				footerWidth := (buttonWidth * 2) + buttonSpacing
				
				Gui, font, s7 c%footerColor%
				Gui, Add, Text, x%buttonSpacing% y+5 w%footerWidth% h10 0x200 Center hwndFOOTER, % "c0bra v" Settings.version
			}
			
		gui, show, x%XPOS% y%YPOS%, c0bra Main GUI
		
		; Insert SLR buttons back into mainButtons variable
		;__________________________________________________
		
			mainButtons .= ",GO"

	return

;}


;{ Side Gui Call
;______________
		
	SIDE_GUI()
	{
		global

		currGui := A_Gui
		nextGui := currGui = 1 ? currGui + 2 : currGui + 1
		
		if (!currGui)	; Band-Aid for method being called when using The Closer
			return
		
		SetTitleMatchMode, 3
		IfWinExist, %A_GuiControl%
		{
			gui, %nextGui%:Destroy
			return
		}
		SetTitleMatchMode, 1
		
		PREV_GUI := A_Gui
		;~ PREV_GUI := currGui
		currGui := nextGui
		
		Gui, Submit, nohide
		Gui, +LastFound
		WinGetPos,x,y,w,h

		GuiControlGet, CONTROL_POS, Pos, %A_GuiControl%
		
		if (PREV_GUI = 1)
			ON_LEFT := ON_LEFT(CONTROL_POSX)
		
		if (A_GuiControl = lastButton)
		{
			XPOS := x + (2 * buttonSpacing)
			YPOS := y + CONTROL_POSY + buttonSpacing + buttonHeight
		}
		else if ON_LEFT
		{
			XPOS := x - (2 * buttonSpacing) - buttonWidth
			YPOS := y + CONTROL_POSY - buttonSpacing
		}
		else
		{
			XPOS := x + CONTROL_POSX + buttonWidth + buttonSpacing
			YPOS := y + CONTROL_POSY - buttonSpacing
		}
		
		ChildrenList := []
		childrenButtons := ""
		
		For key, value in ButtonList[A_GuiControl].Children
		{
			;~ ChildrenButtons .= (ChildrenButtons ? "`n" : "") value
			ChildrenList.Insert(value, ButtonList[value])
			childrenButtons .= (childrenButtons ? "," : "") value
		}
		
		Gui, %currGui%:Color, % guis.mainGui.guiBackColor
		Gui, %currGui%:-caption +ToolWindow +Owner%PREV_GUI%
		gui, %currGui%:margin, %buttonSpacing%, %buttonSpacing%
		gui, %currGui%:Font, s%textSize% w%textBold%
		
		;Bookmarks
		;_________
		
			if (A_GuiControl = "Bookmarks")
			{
				MyFavs := A_MyDocuments "\..\Favorites\Links"
				
				;LOOP THROUGH FAVORITES FOLDER FOR KEY, VALUE, AND COUNT
				;_______________________________________________________
				
					loop, %MyFavs%\*.url
					{
						if (A_LoopFileExt = "URL")
						{
							THE_BOOKMARK := RegExReplace(A_LoopFileName, "i)\.[^.]*$")
							THE_BOOKMARK_PATH := A_LoopFileLongPath
							
							A_HWND := "book" A_Index
							
							if (lastButton = "Bookmarks")
							{
								Gui, %currGui%:Add, text, x%buttonSpacing% y+%buttonSpacing% w%sideLastButWidth% h%buttonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % THE_BOOKMARK
									CTLCOLORS.Attach(%A_HWND%, ButtonList.Bookmarks.BackColor, ButtonList.Bookmarks.TextColor)
							}
							else
							{
								Gui, %currGui%:Add, text, y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % THE_BOOKMARK
									CTLCOLORS.Attach(%A_HWND%, ButtonList.Bookmarks.BackColor, ButtonList.Bookmarks.TextColor)
							}
						}
					}
			}
		
		;not bookmarks
		;_____________
		
			else
			{
				Loop, Parse, childrenButtons, `,
				{
					A_HWND := "side" A_Index
					
					if (lastButton = A_GuiControl)
					{
						Gui, %currGui%:Add, text, x%buttonSpacing% y+%buttonSpacing% w%sideLastButWidth% h%buttonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % A_LoopField
							CTLCOLORS.Attach(%A_HWND%, ChildrenList[A_LoopField].BackColor, ChildrenList[A_LoopField].TextColor)
					}
					else
					{
						Gui, %currGui%:Add, text, y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % A_LoopField
							CTLCOLORS.Attach(%A_HWND%, ChildrenList[A_LoopField].BackColor, ChildrenList[A_LoopField].TextColor)
					}
				}
			}
		
		Gui, %currGui%:Show, x%XPOS% y%YPOS%, %A_GuiControl%
	}
	
	
;}
	
	
;{ Shutdown Logoff Restart (SLR) Gui
;__________________________________

	SLR_GUI()
	{
		global
		
		Gui, 1:Destroy
		
		slrSettings := JSON_Load(slrButtonSettings)
		slrList := []
		slrButtons := ""
		
		For key, value in slrSettings
		{
			slrButtons .= (slrButtons ? "`n" : "") value.text
			slrList.Insert(value.text, value)
		}
		
		MouseGetPos, MouseX1, MouseY1
		
		gui, 2:font, s%textSize% w%textBold%
		Gui, 2:+toolwindow -caption
		Gui, 2:Color, Guis.mainGui.slrGuiColor
		Gui, 2:Margin, %buttonSpacing%, %buttonSpacing%
		
		Loop, Parse, slrButtons, `n
		{
			if (A_Index = 1)
				Gui, 2:Add, text, x%buttonSpacing% y%buttonSpacing% w%buttonWidth% h%buttonHeight% hwnd%A_LoopField% 0x200 Center gSLR, %A_LoopField%
			else
				Gui, 2:Add, text, y+%buttonSpacing% w%buttonWidth% h%buttonHeight% hwnd%A_LoopField% 0x200 Center gSLR, %A_LoopField%
			
			CTLCOLORS.Attach(%A_LoopField%, slrList[A_LoopField].BackColor, slrList[A_LoopField].TextColor)
		}
		
		Gui, 2:Show, x%MouseX1% y%MouseY1%, c0bra SLR
	}
	
;}
	
	
;{ Shutdown Logoff Restart (SLR) Submit
;_____________________________________

	SLR:
	
		Gui, Submit
		if !(A_GuiControl = "Cancel")
		{
			MsgBox,4,, SAVE ALL YOUR WORK BEFORE HITTING YES!!`n`nAre you sure you want to %A_GuiControl%?
			IfMsgBox yes
			{
				Gui, 1:Destroy
				Shutdown, % A_GuiControl = "Shutdown" ? "13" : A_GuiControl = "Restart" ? "6" : "0"
			}
			Else
				return
		}
	
	return
	
;}


;{ Gui Sizing
;____________

	GuiSize:
	2GuiSize:
	3GuiSize:
	4GuiSize:
	5GuiSize:
	6GuiSize:
	7GuiSize:
	8GuiSize:
	9GuiSize:
	10GuiSize:
	
	   If (A_EventInfo != 1)
	   {
		  Gui, %A_Gui%:+LastFound
		  WinSet, ReDraw
	   }
	   
	Return

;}


;{ Gui Closes and Escapes
;________________________

	99GuiClose:
	99GuiEscape:
	10GuiClose:
	10GuiEscape:
	9GuiClose:
	9GuiEscape:
	8GuiClose:
	8GuiEscape:
	7GuiClose:
	7GuiEscape:
	6GuiClose:
	6GuiEscape:
	5GuiClose:
	5GuiEscape:
	4GuiClose:
	4GuiEscape:
	3GuiClose:
	3GuiEscape:
	2GuiClose:
	2GuiEscape:
	GuiClose:
	GuiEscape:
		
		CTLCOLORS.free()
		Loop 10
			Gui, %A_index%:Destroy
		Gui, 99:Destroy
	return

;}


;{ RIGHT-CLICK MENU
;_________________

	GuiContextMenu:
	2GuiContextMenu:
	3GuiContextMenu:
	4GuiContextMenu:
	5GuiContextMenu:
	6GuiContextMenu:
	7GuiContextMenu:
	8GuiContextMenu:
	9GuiContextMenu:
	10GuiContextMenu:
	
		MouseGetPos, XPOS, YPOS
		me := A_GuiControl	
		meDisp := RegExReplace(me, "i)(.+)s$", "$1(s)")
		meAdd  := RegExReplace(me, "i)(.+)s$", "$1")
		
		for key, value in Settings.buttonTypes
			buttonTypes .= (buttonTypes ? "|" : "") value
	
	
		;{ ___ A button in Bookmarks Gui is right clicked, no right click
		;________________________________________________________________
		
			if !(buttonList[me])
				return
			
		;}
				
				
		;{ ___ Common top of menu	
		;________________________
		
			Menu, Title, Add
			Menu, Title, DeleteAll		
			menu, title, add, Cancel, cancelMenuItem
			menu, title, default, cancel
			Menu, Title, Add
			
		;}
		
		
		;{ ___ Add Main Button sub menu
		;______________________________
		
			If !(buttonList[me].Level)
			{
				Menu, SubAdd, Add
				Menu, SubAdd, DeleteAll
				loop, parse, buttonTypes, |
				{
					Menu, SubAdd, Add, main %A_LoopField%, QuickEditMenu
					;TODO: check to make sure the same button type doesn't exist already
					if A_LoopField in %allButtons%
						Menu, SubAdd, Disable, main %A_LoopField%
				}
				
				Menu, Title, Add, Add Main Button, :SubAdd
				Menu, Title, Add
			}
			
		;}
		
		
		;{ ___ Add button menus
		;______________________
		
			if (buttonList[me].Children && me != "GO" && me != "Bookmarks")
			{
				Menu, SubAdd1, Add
				Menu, SubAdd1, DeleteAll
				loop, parse, buttonTypes, |
				{
					Menu, SubAdd1, Add, %A_LoopField%, QuickEditMenu
					;TODO: check to make sure the same button type doesn't exist already
					;~ if A_LoopField in %allButtons%
						;~ Menu, SubAdd, Disable, %A_LoopField%
				}
				
				Menu, Title, Add, Add to %me%, :SubAdd1
			}
			
		;}
		
		
		;{ ___ Color button menus
		;________________________
			
			Menu, colorAdd, Add
			Menu, colorAdd, DeleteAll
			Menu, colorAdd, Add, % "BackColor", QuickEditMenu
			Menu, colorAdd, Add, % "TextColor", QuickEditMenu
			Menu, colorAdd, Add, % "HlBackColor", QuickEditMenu
			Menu, colorAdd, Add, % "HlTextColor", QuickEditMenu
			Menu, Title, Add, Change %me% Colors, :colorAdd
			
		;}
	
	
		;{ ___ Edit and Delete button menus
		;__________________________________
		
			if (me != "GO")
			{
				Menu, Title, Add, Delete %me% button, QuickEditMenu
				;TODO: make sure user knows that buttons inside will be lost as well
				
				if (!buttonList[me].Children && me != "Bookmarks")
					Menu, Title, Add, Edit %me%, QuickEditMenu
			}
			
		;}
			
		
		;{ ___ If main button, add bar
		
			;~ if me in %mainButtons%
				;~ Menu, Title, Add
			
		;}	
		
		Menu, Title, Show, x%XPOS% y%YPOS%
		
	return
		
;}
		
		
;{ Cancel right click menu item
;______________________________

	CancelMenuItem:
		;~ Gui, 99:Destroy
	return

;}


;{ Right click menu functions
;____________________________

	QuickEditMenu:
	
		temp_MenuItem := RegExReplace(A_ThisMenuItem, "\s")
		
		for key in guis.mainGui
			GuiKeys := (guiKeys != "" ? guiKeys "," : "") key
		for key in guis.search
			GuiKeys := (guiKeys != "" ? guiKeys "," : "") key

	
		;{ ___ Outlook, main outlook, programs, main programs
		;____________________________________________________
		
			If (A_ThisMenuItem = "Outlook" || A_ThisMenuItem = "Program" 
				|| A_ThisMenuItem = "main Outlook" || A_ThisMenuItem = "main Program")
			{
				Gui, 1:Destroy
				
				CMD := 1			
				typeCMD := "P"
				
				if (A_ThisMenuItem = "Outlook")
				{
					argsCMD := "Outlook"
				}

				redoProgram:
				
				Gui +LastFound +OwnDialogs +AlwaysOnTop
				InputBox, aText, Button Title, What is the name of the program?
				if ErrorLevel
					return
				
				if (aText = "")
				{
					MsgBox, 4113, c0bra Button Namer, No button name was entered.`n`nEnter the new button name.
					IfMsgBox OK
						goto, redoProgram
					else
						return
				}

				if (buttonCheck(buttons, aText))
					goto, redoProgram
				;~ else
					;~ return
				
				Gui +LastFound +OwnDialogs +AlwaysOnTop
				FileSelectFile, argsCMD,1,, Select the program that the %aText% button will open
				if ErrorLevel
					return

				Children := 0				
			}
			
		;}
		
		
		;{ ___ Folder or main folder
		;___________________________
		
			else if (A_ThisMenuItem = "Folder" || A_ThisMenuItem = "main Folder")
			{
				Gui, 1:Destroy
				
				CMD := 1
				typeCMD := "R"
				
				redoFolder:
				
				Gui +LastFound +OwnDialogs +AlwaysOnTop
				InputBox, aText, Button Title, What is the button Title?
				if ErrorLevel
					return
				
				if (aText = "")
				{
					MsgBox, 4113, c0bra Button Namer, No button name was entered.`n`nEnter the new button name.
					IfMsgBox OK
						goto, redoFolder
					else
						return
				}
				
				if (buttonCheck(buttons, aText))
					goto, redoFolder
				;~ else
					;~ return
				
				Gui +LastFound +OwnDialogs +AlwaysOnTop
				FileSelectFolder, argsCMD,,, Select the folder that the %aText% button will open
				if ErrorLevel
					return
				
				Children := 0
			}
			
		;}
		
		
		;{ ___ Edit button name
		;______________________
		
			else if (A_ThisMenuItem = "Edit " me)
			{
				Gui, 1:Destroy
				
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
				goto, guiOldPos
			}
			
		;}
		
		
		;{ ___ No-run List Add / Remove
		;______________________________
		
			else if (A_ThisMenuItem = "Add to no-run list")
			{
				Gui, Destroy
				
				InputBox, addNorun, Add to No-run List, Enter one of the following that when open`, c0bra won't run`n`n- Part of Window Title`n- All of Window Title`n- Window ahk Class (use winspy)`n`n<< Example shown in box >>,,, 225,,,,, Excel <or> ahk_class #31463
				if ErrorLevel
					return
				
				for key, value in Settings.mainHotkey.disableIfActive
				{
					if (value = addNorun)
					{
						MsgBox, 4096, c0bra No-run, The No-run window %addNorun% already exists.
						return
					}
				}
						
				Settings.mainHotkey.disableIfActive.Insert(addNorun)
				JSON_Save(Settings, c0braSettings)
				Reload
				return
			}
			
			else if A_ThisMenuItem in %disableMainHKList%
			{
				Gui, Destroy
				
				MsgBox, 4113, c0bra No-run, Are you sure you want to remove %A_ThisMenuItem% from the No-run list?
				IfMsgBox OK
				{
					for key, value in Settings.mainhotkey.disableIfActive
					{
						if (value = A_ThisMenuItem)
						{
							Settings.mainHotkey.disableIfActive.Remove(key)
							JSON_Save(Settings, c0braSettings)
							Reload
							return
						}
					}
				}
				
				else
					return
			}
			
		;}
		
		
		;{ ___ Search bar
		;________________
		
			else if (A_ThisMenuItem = "Search Bar")
			{
				guis.mainGui.search := guis.mainGui.search ? 0 : 1
				JSON_save(guis, guiSettings)
				
				IfWinExist, c0bra Main GUI
				{
					Gui, Destroy
					goto, guiOldPos
				}
				
				return
			}
			
		;}
		
		
		;{ ___ Change search text
		;________________________
			
			else if (A_ThisMenuItem = "Change Text: " guis.search.searchBackText)
			{
				InputBox, backText, Search Text, Enter text to be shown in search box.,,,,,,,, % guis.search.searchBackText
				guis.search.searchBackText := backText
				JSON_save(guis, guiSettings)
				
				IfWinExist, c0bra Main GUI
				{
					Gui, Destroy
					goto, guiOldPos
				}
				
				return
			}

		;}
	
		
		;{ ___ Footer
		;____________
			
			else if (A_ThisMenuItem = "Footer")
			{
				guis.mainGui.footer := guis.mainGui.footer ? 0 : 1
				JSON_save(guis, guiSettings)

				IfWinExist, c0bra Main GUI
				{
					Gui, Destroy
					goto, guiOldPos
				}
				
				return
			}
		
		;}
		
		
		else if temp_MenuItem in %GuiKeys%
		{
			InputBox, newOption, c0bra Gui Options, Enter the new value for A_ThisMenuitem.,,,,,,,, % guis.mainGui[temp_MenuItem] != "" ? guis.mainGui[temp_MenuItem] : guis.search[temp_MenuItem]
			if !(ErrorLevel)
			{
				if (guis.mainGui[temp_MenuItem] != "")
				{
					guis.mainGui[temp_MenuItem] := newOption
					JSON_save(guis, guiSettings)
				}
				else if (guis.search[temp_MenuItem] != "")
				{
					guis.search[temp_MenuItem] := newOption
					JSON_save(guis, guiSettings)
				}
			}
				
			return
		}
		
		
		;{ ___ Delete
		;____________
			
			else if (InStr(A_ThisMenuItem, "Delete"))
			{
				MsgBox, 262196, c0bra Delete, Delete %me% button? 
				ifmsgbox, Yes
				{	
					deleteButton(me)
					
					Gui, Destroy
					goto, guiOldPos
				}
			}
		
		;}
		
		
		;{ ___ Back, text, backhl, texthl color
		;___________________________________
		
			else if (A_ThisMenuItem = "BackColor" || A_ThisMenuItem = "TextColor" 
					|| A_ThisMenuItem = "HlBackColor" || A_ThisMenuItem = "HlTextColor")
			{
				htmlColors := "Black|Silver|Gray|White|Maroon|Red|Purple|Fuchsia|Green|Lime|Olive|Yellow|Navy|Blue|Teal|Aqua"
				StringReplace, htmlColors, htmlColors, % buttonList[me][A_ThisMenuItem], % buttonList[me][A_ThisMenuItem] = "Aqua" ? buttonList[me][A_ThisMenuItem] "||" : buttonList[me][A_ThisMenuItem] "|"

				Gui, 1:Destroy
				Gui, 99:Add, Button, x5 y40 w100 h30 gCustom, Custom
				Gui, 99:Add, Text, x25 y13 w40 h20 +Right, Color:
				Gui, 99:Add, DropDownList, x75 y10 w120 h20 r16 vdaColor gcolorDrop, % htmlColors
				Gui, 99:Add, Text, x+10 w40 h20 hwndColorHwnd, 
					CTLCOLORS.Attach(ColorHwnd, buttonList[me][A_ThisMenuItem], buttonList[me][A_ThisMenuItem])
				Gui, 99:Add, Button, x105 y40 w60 h30 gCancelMenuItem, Cancel
				Gui, 99:Add, Button, x165 y40 w100 h30 gokButton Default, OK
				Gui, 99:Show, w270 h80, c0bra Colors
				return
			}
			
		;}
		
		
		;{ ___ Menu item doesn't exist or under construction
		;_______________________________________________
		
			else
			{
				msgbox, 4144,, Sorry!`n`nThis feature is still under construction...
				gui, Destroy
				return
			}
			
		;}
		
		
		;{ ___ Parent
		;____________
		
			Parent := InStr(A_ThisMenuItem, "main") ? "0" : me
		
		;}
		
		
		;{ ___ Default or parent colors or color picker
		;______________________________________________
		
			aColor := {}
			
			MsgBox, 4100, c0bra Colors, Use default colors?
			IfMsgBox Yes
			{
				if !(Parent)
				{
					MsgBox, 4100, c0bra Colors, Use default colors?
					IfMsgBox Yes
					{
						aColor[1] := buttonList.Default.BackColor
						aColor[2] := buttonList.Default.TextColor
						aColor[3] := buttonList.Default.HlBackColor
						aColor[4] := buttonList.Default.HlTextColor
					}
				}
				else
				{
					MsgBox, 4100, c0bra Colors, Use %Parent% colors?
					IfMsgBox Yes
					{
						aColor[1] := buttonList[Parent].BackColor
						aColor[2] := buttonList[Parent].TextColor
						aColor[3] := buttonList[Parent].HlBackColor
						aColor[4] := buttonList[Parent].HlTextColor
					}
				}
			}
			else
			{
				aColor[1] := ColorPicker("BackColor")
					if !(aColor[1])
						return
				aColor[2] := ColorPicker("TextColor")
					if !(aColor[2])
						return
				aColor[3] := ColorPicker("HlBackColor")
					if !(aColor[3])
						return
				aColor[4] := ColorPicker("HlTextColor")
					if !(aColor[4])
						return
			}
			
		;}
		
		
		;{ ___ Add button
		;________________
		
			addButton(aText, CMD, typeCmd, argsCmd, aColor, Children, Parent)
			
		;}
		
		
		goto, guiOldPos
		
	return

;}


;{ Color Drop
;____________

	colorDrop:
		
		Gui, 99:Submit, nohide
		CTLCOLORS.Change(ColorHwnd, daColor, "White")

	return
	
;}


;{ Color Gui OK button
;_____________________

	okButton:
	
		Gui, 99:Submit
		Gui, 99:Destroy

		newColor := daColor
		
		for key, value in buttons
		{
			if (value.text = me)
			{
				buttons[key][A_ThisMenuItem] := newColor
				JSON_Save(buttons, buttonSettings)
				gui, 1:destroy
				;~ goto, guiOldPos
				Run %A_ScriptFullPath% \restart
			}
		}

	return
	
;}


;{ Color Gui custom button
;_________________________

	Custom:

		Gui, 99:submit
		Gui, 99:destroy

		newColor := ColorPicker(A_ThisMenuItem)
		if !(newColor)
			return
		
		for key, value in buttons
		{
			if (value.text = me)
			{
				buttons[key][A_ThisMenuItem] := newColor
				JSON_Save(buttons, buttonSettings)
				gui, 1:destroy
				;~ goto, guiOldPos
				Run %A_ScriptFullPath% \restart
			}
		}
		
	return
	
;}


;{ Main gui button press label
;____________________
	
	ButtonPress:
	
		mainBut := A_GuiControl
	
		if !(WinExist(A_GuiControl))
			Gui, 3:Destroy ; kill gui 3 before in case another gui is selected
		
		GuiControlGet, controlhwnd, Hwnd, %A_GuiControl% ; hwnd of control pressed
		
		
		; GOOGLE SEARCH
		;______________
			
			IfWinActive, c0bra Main GUI
			{
				if (controlhwnd = go || !A_GuiControl)
				{
					if SEARCH
					{
						Gui, Submit
						
						if instr(A_ThisHotkey, "^") ; if control is held for a website
						{
							Run % "chrome.exe " instr(GSEARCH, ".com") ? "www." GSEARCH : "www." GSEARCH ".com"
							Gui, Destroy
							return
						}
						
						Google(GSEARCH) ; regular google search
						Gui, Destroy
						return
					}
				}
			}
			
		Gui, Submit, NoHide
			
		; Get command from JSON file
		;___________________________
		
			Execute("[" buttonList[A_GuiControl].Cmd.Type "] " buttonlist[A_GuiControl].Cmd.Arg, buttonlist[A_GuiControl].Text)
		
	return
	
;}


;{ Side Gui Button Press label
;_______________________
	
	3ButtonPress:

		Next_Kill := A_GUI + 1
		
		SetTitleMatchMode, 3
		if !(WinExist(A_GuiControl))
			Gui, %NEXT_KILL%:Destroy ; kill gui 2 before in case another gui is selected

		SetTitleMatchMode, 1
		WinGetActiveTitle, A_TITLE
		
		if (A_TITLE = "Bookmarks")
		{
			MyFavs := A_MyDocuments "\..\Favorites\Links"
			Run, % MyFavs "\" A_GuiControl ".url"
			Gui, 1:Destroy
			return
		}

		Execute("[" ChildrenList[A_GuiControl].Cmd.Type "] " childrenList[A_GuiControl].Cmd.Arg, ChildrenList[A_GuiControl].Text)
	
	return
	
;}
		

;{ Exit App for tray icon
;_______________________

	closer:
		ExitApp
	return
	
;}
	

	
	
	
	
	
	