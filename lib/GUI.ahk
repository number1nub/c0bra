
;{===== Main Hotkey Handler ====>>>

	mainTrigger:
		;Min. time to hold HK to trigger hold event
		HKHoldTime := 475
		
		sTime := A_TickCount
		loop
		{
			Sleep, 20
			if ((A_TickCount - sTime) > HKHoldTime)
				goto, MainTrigger_Held
			getkeystate, keyVar, % Settings.mainHotkey.mainHotkey, P
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
				GUI, Destroy
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

;}<<<==== Main Hotkey Handler =====


;{===== Create Main GUI ====>>>

GUI:
	GUI, Destroy
	GUI, 1:Destroy
	GUI, 2:Destroy

	if !(_reloaded)
		MouseGetPos, XPOS, YPOS
	else
		_reloaded := false

guiOldPos:
	currGui 	:= 1	
	ButtonList 	:= []
	mainButtons	:= ""
	
	Guis 	:= JSON_Load(guiSettings)
	Buttons := JSON_Load(buttonSettings)
	
	buttonSpacing 		:= Guis.mainGui.buttonSpacing
	buttonWidth 		:= Guis.mainGui.buttonWidth
	buttonHeight 		:= Guis.mainGui.buttonHeight
	search 				:= Guis.search.search
	textSize 			:= Guis.mainGui.textSize
	textBold 			:= Guis.mainGui.textBold
	textFont			:= Guis.mainGui.textFont
	lastButWidth 		:= (buttonWidth * 2) + buttonSpacing
	sideLastButWidth	:= lastButWidth - (4 * buttonSpacing)
	footerColor			:= Guis.mainGui.footerColor
	
	;{````  Create CSV button lists  ````}
	For key, value in Buttons
	{
		tempButton := value.text
		ButtonList.Insert(value.text, value)
		if (ButtonList[tempButton].Level = "")
			mainButtons .= (value.text != "GO" && value.text != "Default") ? ((mainButtons ? "," : "") value.text) : ""
		allButtons .= (allButtons ? "," : "") value.text
	}
	;}
	
	GUI, Color, % Guis.mainGui.guiBackColor
	GUI, -caption +ToolWindow +AlwaysOnTop
	GUI, margin, %buttonSpacing%, %buttonSpacing%
	

	;{````  Create Search Bar  ````}
	if (search)
	{
		searchTextSize 	:= Guis.search.textSize
		searchHeight    := Guis.search.Height
		searchBackText  := Guis.search.backText
		goWidth         := Guis.mainGui.goWidth
		xGo 			:= (buttonWidth * 2) + (buttonSpacing * 2) - goWidth
		searchWidth 	:= (buttonWidth * 2) - goWidth
		searchTextWidth := searchWidth - 8
		searchTextColor := Guis.search.textColor
		searchTextFont	:= Guis.search.textFont
		searchTextBold  := Guis.search.textBold

		GUI, font, s%searchTextSize% w%searchtextBold% c%searchTextColor%, %searchTextFont%
		GUI, Add, Edit, x%buttonSpacing% y%buttonSpacing% w%searchWidth% h%searchHeight% 0x200 vGSEARCH,
		GUI, Add, Text, xp yp-1 w%searchTextWidth% h%searchHeight%-2 0x200 Center +backgroundtrans hwndBackSearch, %searchBackText%		
		GUI, font, s%textSize% w%textBold% c%searchTextColor%, %textFont%	
		GUI, Add, text, x%xGo% y%buttonSpacing% w%goWidth% h%searchHeight% 0x200 Center gButtonPress hwndGO, GO
		CTLCOLORS.Attach(GO, ButtonList.GO.BackColor, ButtonList.GO.TextColor)
	}
	;}
	
			
	; Add Main GUI Buttons
	GUI, font, s%textSize% w%textBold%
	
	loop, Parse, mainButtons, `,
		KEY_COUNT := A_Index

	loop, Parse, mainButtons, `,
	{
		A_HWND := "back" A_Index
		
		; first key
		if (A_Index = 1)
		{	
			GUI, Add, text, x%buttonSpacing% y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
				CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
			continue
		}
		
		; odd key
		else if (mod(A_Index, 2))
		{
			; last key
			if (A_Index = KEY_COUNT)
			{
				lastButton := A_LoopField
				GUI, Add, text, x%buttonSpacing% y+%buttonSpacing% w%LastButWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
					CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
				continue
			}			
			GUI, Add, text, x%buttonSpacing% y+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
				CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
			continue
		}
		
		; even key
		else 
		{
			GUI, Add, text, x+%buttonSpacing% w%buttonWidth% h%buttonHeight% 0x200 Center gButtonPress hwnd%A_HWND%, % A_LoopField
				CTLCOLORS.Attach(%A_HWND%, ButtonList[A_LoopField].BackColor, ButtonList[A_LoopField].TextColor)
			continue
		}
	}
		
	; Footer call		
	if (guis.footer.footer)
	{
		footerWidth := (buttonWidth * 2) + buttonSpacing
		footerTextSize 	:= Guis.footer.textSize
		footerHeight    := Guis.footer.Height
		footerTextColor := Guis.footer.textColor
		footerTextFont	:= Guis.footer.textFont
		footerTextBold  := Guis.footer.textBold
		footerColor		:= Guis.footer.footerColor
		
		GUI, font, s%footerTextSize% w%footerTextBold% c%footerTextColor%, %footerTextFont%
		GUI, Add, Text, x%buttonSpacing% y+5 w%footerWidth% h%footerHeight% 0x200 Center hwndFOOTER, % "c0bra v" Settings.version
			CTLCOLORS.Attach(FOOTER, footerColor, footerTextColor)
	}
		
	GUI, show, x%XPOS% y%YPOS%, c0bra Main GUI
	
	; Insert SLR buttons back into mainButtons variable	
	mainButtons .= ",GO"
return

;}<<<==== Main GUI Creation =====



;{===== Side GUI Call ====>>>

	SIDE_GUI()
	{
		global

		sideButtonSpacing 		:= Guis.sideGui.buttonSpacing
		sideButtonWidth 		:= Guis.sideGui.buttonWidth
		sideButtonHeight 		:= Guis.sideGui.buttonHeight
		sideSearch 				:= Guis.sideGui.search
		sideTextSize 			:= Guis.sideGui.textSize
		sideTextBold 			:= Guis.sideGui.textBold
		sideTextFont			:= Guis.sideGui.textFont

		currGui := A_Gui
		nextGui := currGui = 1 ? currGui + 2 : currGui + 1
		
		if (!currGui)	; Band-Aid for method being called when using The Closer
			return
		
		SetTitleMatchMode, 3
		IfWinExist, %A_GuiControl%
		{
			GUI, %nextGui%:Destroy
			return
		}
		SetTitleMatchMode, 1
		
		PREV_GUI := A_Gui
		;~ PREV_GUI := currGui
		currGui := nextGui
		
		GUI, Submit, nohide
		GUI, +LastFound
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
			XPOS := x - (2 * sideButtonSpacing) - sideButtonWidth
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
		
		GUI, %currGui%:Color, % guis.sideGui.guiBackColor
		GUI, %currGui%:-caption +ToolWindow +Owner%PREV_GUI%
		GUI, %currGui%:margin, %sideButtonSpacing%, %sideButtonSpacing%
		GUI, %currGui%:Font, s%sideTextSize% w%sideTextBold%, %sideTextFont%
		
		;Bookmarks

		
			if (A_GuiControl = "Bookmarks")
			{
				MyFavs := A_MyDocuments "\..\Favorites\Links"
				
				;LOOP THROUGH FAVORITES FOLDER FOR KEY, VALUE, AND COUNT

				
					loop, %MyFavs%\*.url
					{
						if (A_LoopFileExt = "URL")
						{
							THE_BOOKMARK := RegExReplace(A_LoopFileName, "i)\.[^.]*$")
							THE_BOOKMARK_PATH := A_LoopFileLongPath
							
							A_HWND := "book" A_Index
							
							if (lastButton = "Bookmarks")
							{
								GUI, %currGui%:Add, text, x%sideButtonSpacing% y+%sideButtonSpacing% w%sideLastButWidth% h%sideButtonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % THE_BOOKMARK
									CTLCOLORS.Attach(%A_HWND%, ButtonList.Bookmarks.BackColor, ButtonList.Bookmarks.TextColor)
							}
							else
							{
								GUI, %currGui%:Add, text, y+%sideButtonSpacing% w%sideButtonWidth% h%sideButtonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % THE_BOOKMARK
									CTLCOLORS.Attach(%A_HWND%, ButtonList.Bookmarks.BackColor, ButtonList.Bookmarks.TextColor)
							}
						}
					}
			}
		
		;not bookmarks

		
			else
			{
				Loop, Parse, childrenButtons, `,
				{
					A_HWND := "side" A_Index
					
					if (lastButton = A_GuiControl)
					{
						GUI, %currGui%:Add, text, x%sideButtonSpacing% y+%sideButtonSpacing% w%sideLastButWidth% h%sideButtonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % A_LoopField
							CTLCOLORS.Attach(%A_HWND%, ChildrenList[A_LoopField].BackColor, ChildrenList[A_LoopField].TextColor)
					}
					else
					{
						GUI, %currGui%:Add, text, y+%sideButtonSpacing% w%sideButtonWidth% h%sideButtonHeight% 0x200 Center g3ButtonPress hwnd%A_HWND%, % A_LoopField
							CTLCOLORS.Attach(%A_HWND%, ChildrenList[A_LoopField].BackColor, ChildrenList[A_LoopField].TextColor)
					}
				}
			}
		
		GUI, %currGui%:Show, x%XPOS% y%YPOS%, %A_GuiControl%
	}
	
;}<<<==== Side GUI Call =====
	
	
;{===== Shutdown Logoff Restart (SLR) GUI ====>>>

SLR_GUI()
{
	global
	
	GUI, 1:Destroy
	
	slrSettings := JSON_Load(slrButtonSettings)
	slrList := []
	slrButtons := ""
	
	For key, value in slrSettings
	{
		slrButtons .= (slrButtons ? "`n" : "") value.text
		slrList.Insert(value.text, value)
	}
	
	MouseGetPos, MouseX1, MouseY1
	
	SLRbuttonSpacing 		:= Guis.SLRGui.buttonSpacing
	SLRbuttonWidth 			:= Guis.SLRGui.buttonWidth
	SLRbuttonHeight 		:= Guis.SLRGui.buttonHeight
	SLRguiBackColor			:= Guis.SLRGui.guiBackColor
	SLRtextSize 			:= Guis.SLRGui.textSize
	SLRtextBold 			:= Guis.SLRGui.textBold
	SLRtextFont				:= Guis.SLRGui.textFont
	
	GUI, 2:font, s%SLRtextSize% w%SLRtextBold%, %SLRtextFont%
	GUI, 2:+toolwindow -caption
	GUI, 2:Color, % Guis.SLRGui.guiBackColor
	GUI, 2:Margin, %SLRbuttonSpacing%, %SLRbuttonSpacing%
	
	Loop, Parse, slrButtons, `n
	{
		if (A_Index = 1)
			GUI, 2:Add, text, x%SLRbuttonSpacing% y%SLRbuttonSpacing% w%SLRbuttonWidth% h%SLRbuttonHeight% hwnd%A_LoopField% 0x200 Center gSLR, %A_LoopField%
		else
			GUI, 2:Add, text, y+%SLRbuttonSpacing% w%SLRbuttonWidth% h%SLRbuttonHeight% hwnd%A_LoopField% 0x200 Center gSLR, %A_LoopField%
		
		CTLCOLORS.Attach(%A_LoopField%, slrList[A_LoopField].BackColor, slrList[A_LoopField].TextColor)
	}
	
	GUI, 2:Show, x%MouseX1% y%MouseY1%, c0bra SLR
}
	
SLR:
	GUI, Submit
	if !(A_GuiControl = "Cancel")
	{
		MsgBox,4,, SAVE ALL YOUR WORK BEFORE HITTING YES!!`n`nAre you sure you want to %A_GuiControl%?
		IfMsgBox yes
		{
			GUI, 1:Destroy
			Shutdown, % A_GuiControl = "Shutdown" ? "13" : A_GuiControl = "Restart" ? "6" : "0"
		}
		Else
			return
	}

return

;}<<<==== Shutdown Logoff Restart (SLR) GUI =====



ColorGui()
{
	global
	
	if (ColorButton <> "")
	{
		daButton := ColorButton
		me 		 := "Default"
	}
	else
		daButton := A_ThisMenuItem
	
	htmlColors := "Black|Silver|Gray|White|Maroon|Red|Purple|Fuchsia|Green|Lime|Olive|Yellow|Navy|Blue|Teal|Aqua"
	StringReplace, htmlColors, htmlColors, % buttonList[me][daButton], % buttonList[me][daButton] = "Aqua" ? buttonList[me][daButton] "||" : buttonList[me][daButton] "|"
	
	GUI, 1:Destroy	
	GUI, CLR:Margin, 5, 5
	GUI, CLR:Add, Button, x5 y40 w100 h30 gCustom, Custom
	GUI, CLR:Add, Text, x25 y13 w40 h20 +Right, Color:
	GUI, CLR:Add, DropDownList, x75 y10 w120 h20 r16 vdaColor gcolorDrop, % htmlColors
	GUI, CLR:Add, Text, x+10 w40 h20 hwndColorHwnd, 		
	GUI, CLR:Add, Button, x105 y40 w60 h30 gbtnDefault, Default
	GUI, CLR:Add, Button, x165 y40 w100 h30 gokButton Default, OK
	GUI, CLR:Show, h80, c0bra Colors
	
	CTLCOLORS.Attach(ColorHwnd, buttonList[me][daButton], buttonList[me][daButton])
}



;{===== GUI Sizing ====>>>

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
CLRGuiSize:
   If (A_EventInfo != 1)
   {
	  GUI, %A_Gui%:+LastFound
	  WinSet, ReDraw
   }   
return

;}<<<==== GUI Sizing =====


;{===== GUI Closes and Escapes ====>>>

CLRGuiClose:
CLRGuiEscape:
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
		GUI, %A_index%:Destroy
	ColorButton :=
	GUI, CLR:Destroy
return

;}



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
	
	; Get button name 
	me := A_GuiControl	
	meDisp := RegExReplace(me, "i)(.+)s$", "$1(s)")
	meAdd  := RegExReplace(me, "i)(.+)s$", "$1")
	
	; No context menu for a button in Bookmarks GUI
	if !(buttonList[me])
		return

	for key, value in Settings.buttonTypes
		buttonTypes .= (buttonTypes ? "|" : "") value


	; Common top of menu
	Menu, Title, Add
	Menu, Title, DeleteAll		
	menu, title, add, Cancel, cancelMenuItem
	menu, title, default, cancel
	Menu, Title, Add
	

	; Add Main Button sub menu
	If !(buttonList[me].Level)
	{
		Menu, SubAdd, Add
		Menu, SubAdd, DeleteAll
		Menu, SubAdd, Add, main Sub-Menu Button, QuickEditMenu
		Menu, SubAdd, Add
		
		loop, parse, buttonTypes, |
		{
			Menu, SubAdd, Add, main %A_LoopField%, QuickEditMenu
			if (instr(allButtons,"Bookmarks") && A_LoopField = "Bookmarks")
				Menu, SubAdd, Disable, main %A_LoopField%
		}
		
		Menu, Title, Add, Add Main Button, :SubAdd
	}
	
	
	; Add button menus
	if (buttonList[me].Children && me != "GO" && me != "Bookmarks")
	{
		Menu, SubAdd1, Add
		Menu, SubAdd1, DeleteAll
		loop, parse, buttonTypes, |
		{
			if (A_LoopField <> "Bookmarks")
			Menu, SubAdd1, Add, %A_LoopField%, QuickEditMenu
			;TODO: check to make sure the same button type doesn't exist already
			;~ if A_LoopField in %allButtons%
				;~ Menu, SubAdd, Disable, %A_LoopField%
		}
		
		Menu, Title, Add, Add to <%me%>, :SubAdd1
	}

	; Color button menus
	Menu, colorAdd, Add
	Menu, colorAdd, DeleteAll
	Menu, colorAdd, Add, % "BackColor", QuickEditMenu
	Menu, colorAdd, Add, % "TextColor", QuickEditMenu
	Menu, colorAdd, Add, % "HlBackColor", QuickEditMenu
	Menu, colorAdd, Add, % "HlTextColor", QuickEditMenu
	Menu, Title, Add, <%me%> Colors, :colorAdd

	; Edit and Delete button menus
	if (me != "GO")
	{
		if (buttonList[me].Level && me != "Bookmarks")
			Menu, Title, Add, Edit <%me%>, QuickEditMenu
		
		Menu, Title, Add, Delete <%me%>, QuickEditMenu		
	}
		
	Menu, Title, Add
	Menu, Title, Add, Main Gui Settings, QuickEditMenu
	Menu, Title, Add, Side Gui Settings, QuickEditMenu
	Menu, Title, Add, SLR Gui Settings, QuickEditMenu
	
	Menu, Title, Show, x%XPOS% y%YPOS%
return


cancelMenuItem:
	; Do nothing...
return








;{===== Edit Color GUI Event Handlers ====>>>

	colorDrop:
		GUI, CLR:Submit, nohide
		CTLCOLORS.Change(ColorHwnd, daColor, "White")
	return


	btnDefault:
		GUI, 1:Destroy
		GUI, 2:Destroy
		GUI, CLR:Submit
		GUI, CLR:Destroy
		
		newColor := buttonList.Default.BackColor
		
		for key, value in buttons
		{
			if (value.text = me)
			{
				buttons[key][A_ThisMenuItem] := newColor
				JSON_Save(buttons, buttonSettings)
				
				GUI, 1:destroy
				GUI, Destroy
				
				quickReload(me " button set to default colors", "Button Color Updated")
			}
		}
	return


	okButton:
		GUI, CLR:Submit
		GUI, CLR:Destroy

		newColor := daColor
			
		IfWinExist, GUI Window Settings
		{
			if (newColor <> "")
				GuiControl, Settings:, %ColorButton%, %newColor%
			
			for key, value in buttons
			{
				if (value.text = "Default")
					buttons[key][ColorButton] := newColor
			}
			ColorButton :=
			return
		}
			
		for key, value in buttons
		{
			if (value.text = me)
			{
				buttons[key][A_ThisMenuItem] := newColor
				JSON_Save(buttons, buttonSettings)
				
				GUI, 1:destroy
				GUI, Destroy
				quickReload(me " button " A_ThisMenuItem " updated", "Button Color Updated")
			}
		}
	return



	Custom:
		GUI, CLR:submit
		GUI, CLR:destroy

		newColor := ColorPicker(A_ThisMenuItem)
		if !(newColor)
			return
		
		for key, value in buttons
		{
			if (value.text = me)
			{
				buttons[key][A_ThisMenuItem] := newColor
				JSON_Save(buttons, buttonSettings)
				GUI, 1:destroy
				
				quickReload(me " button " A_ThisMenuItem " updated", "Button Color Updated")
			}
		}
	return

;}<<<==== Color GUI Event Handlers =====



;{===== Main GUI Button Click ====>>>

ButtonPress:
	mainBut := A_GuiControl

	; kill GUI 3 before in case another GUI is selected
	if !(WinExist(A_GuiControl))
		GUI, 3:Destroy
	
	; hwnd of control pressed
	GuiControlGet, controlhwnd, Hwnd, %A_GuiControl%
		
	; GOOGLE SEARCH
	IfWinActive, c0bra Main GUI
	{
		if (controlhwnd = go || !A_GuiControl)
		{
			if SEARCH
			{
				GUI, Submit
				; if control is held for a website
				if instr(A_ThisHotkey, "^")
				{
					Run % "chrome.exe " instr(GSEARCH, ".com") ? "www." GSEARCH ".com": "www." GSEARCH
					GUI, Destroy
					return
				}
				
				Google(GSEARCH) ; regular google search
				GUI, Destroy
				return
			}
		}
	}
	
	GUI, Submit, NoHide		
	
	; Get command from JSON file	
	Execute("[" buttonList[A_GuiControl].Cmd.Type "] " buttonlist[A_GuiControl].Cmd.Arg, buttonlist[A_GuiControl].Text)	
return

;}<<<==== Main GUI Button Click =====



;{===== Side GUI Button click ====>>>

3ButtonPress:
	Next_Kill := A_GUI + 1
	
	SetTitleMatchMode, 3
	if !(WinExist(A_GuiControl))
		GUI, %NEXT_KILL%:Destroy ; kill GUI 2 before in case another GUI is selected

	SetTitleMatchMode, 1
	WinGetActiveTitle, A_TITLE
	
	if (A_TITLE = "Bookmarks")
	{
		MyFavs := A_MyDocuments "\..\Favorites\Links"
		Run, % MyFavs "\" A_GuiControl ".url"
		GUI, 1:Destroy
		return
	}

	Execute("[" ChildrenList[A_GuiControl].Cmd.Type "] " childrenList[A_GuiControl].Cmd.Arg, ChildrenList[A_GuiControl].Text)
return

;}<<<==== Side GUI Button click =====	



closer:
	ExitApp
return
	

	
	
	
	
	
	