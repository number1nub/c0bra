#NoEnv
#SingleInstance, Force
#Escapechar ``
#CommentFlag ;

;~ Interface for Gui Settings

	;~ Gui Settings Call (call Main, Side, or SLR)

		Gui_Settings(theGui)
		{
			global
			
			Guis := JSON_Load(guiSettings)
			Buttons := JSON_Load(buttonSettings)
			
			ButtonList 	:= []
		
			;{````  Create CSV button lists  ````}
			For key, value in Buttons
			{
				tempButton := value.text
				ButtonList.Insert(value.text, value)
			}
			;}
			
			theGui := theGui
			
			if (theGui = "Main")
				theGuiJSON := "mainGui"
			else if (theGui = "Side")
				theGuiJSON := "sideGui"
			else if (theGui = "SLR")
				theGuiJSON := "SLRGui"
						
			buttonHeight 		:= Guis.mainGui.buttonHeight
			buttonWidth 		:= Guis.mainGui.buttonWidth
			buttonSpacing 		:= Guis.mainGui.buttonSpacing
			textFont			:= Guis.mainGui.textFont
			textBold 			:= Guis.mainGui.textBold
			textSize 			:= Guis.mainGui.textSize
			guiColor			:= Guis.mainGui.guiBackColor
			
			sbuttonHeight 		:= Guis.sideGui.buttonHeight
			sbuttonWidth 		:= Guis.sideGui.buttonWidth
			sbuttonSpacing 		:= Guis.sideGui.buttonSpacing
			stextFont			:= Guis.sideGui.textFont
			stextBold 			:= Guis.sideGui.textBold
			stextSize 			:= Guis.sideGui.textSize
			sguiColor			:= Guis.sideGui.guiBackColor
			
			slrbuttonHeight 	:= Guis.SLRGui.buttonHeight
			slrbuttonWidth 		:= Guis.SLRGui.buttonWidth
			slrbuttonSpacing 	:= Guis.SLRGui.buttonSpacing
			slrtextFont			:= Guis.SLRGui.textFont
			slrtextBold 		:= Guis.SLRGui.textBold
			slrtextSize 		:= Guis.SLRGui.textSize
			slrguiColor			:= Guis.SLRGui.guiBackColor
			
			defBackColor		:= ButtonList.Default.BackColor
			defTextColor		:= ButtonList.Default.TextColor
			defHLBackColor		:= ButtonList.Default.HLBackColor
			defHLTextColor		:= ButtonList.Default.HLTextColor
			
			Gui, Settings:Margin, 2, 10
			Gui, Settings:Font, s11 cBlack w700, Times New Roman
			
			Gui, Settings:Add, Tab2, x2 y2 w675 h315 Wrap, Hotkeys|Gui Appearance|Colors / Add-ons|No-Run / Closer
			
			; Hotkeys Tab Controls
			Gui, Settings:Tab, Hotkeys
			Gui, Settings:Add, GroupBox, x5 y35 w330 h280 Center, TRIGGER HOTKEYS
			Gui, Settings:Add, Text, xp+5 yp+30 w140 h30 Section, Main Trigger
			Gui, Settings:Add, Text, xp y+5 wp hp, Hold Trigger Action
			Gui, Settings:Add, Edit, x+5 ys-5 w175 hp, % Settings.mainHotkey.mainHotkey
			Gui, Settings:Add, Edit, xp y+5 wp hp, % Settings.mainHotkey.holdAction
			Gui, Settings:Add, Text, xs y+10 w320 hp Center, Main trigger is disabled for the below items:
			
			aList :=
			for key, value in Settings.mainHotkey.disableIfActive
				aList := (aList = "" ? "" : aList "|") value
			Gui, Settings:Add, ListBox, xp y+5 w320 h110, %aList%
			Gui, Settings:Add, Button, xs+45 y+5 w100 h30, Add
			Gui, Settings:Add, Button, x+25 yp wp hp, Remove
			
			Gui, Settings:Add, GroupBox, x340 y35 w330 h280 Center, USER HOTKEYS
			Gui, Settings:Add, Text, xp+5 yp+30 w320 h30 Section, Text
			
			bList :=
			for key, value in Settings.userHotkeys
				bList := (bList = "" ? "" : bList "|") key "`t-  " value
			Gui, Settings:Add, ListBox, xp y+7 wp h190, %bList%
			Gui, Settings:Add, Button, xs+45 y+5 w100 h30, Add
			Gui, Settings:Add, Button, x+25 yp w100 hp, Remove
			
			
			; Appearance Tab Controls
			Gui, Settings:Tab, Gui Appearance
			;Gui, Settings:Add, GroupBox, x5 y35 h290 w670, GUI SETTINGS
			Gui, Settings:Add, Text, x+5 y+40 w160 h30 Section, Button Height (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Width (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Spacing (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Font
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Boldness
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Size
			Gui, Settings:Add, Text, xp y+5 wp hp, Background Color
			
			Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, MAIN GUI
			Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vbHeight, %buttonHeight%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vbWidth, %buttonWidth%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vbSpacing, %buttonSpacing%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r6 0x100 Center vtFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
				GuiControl, Settings:ChooseString, tFont, %textFont%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r2 0x100 Center vtBold, 400|700
				GuiControl, Settings:ChooseString, tBold, %textBold%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vtSize, %textSize%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vguiColor gGuiColor, %guiColor%
			
			Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, SIDE GUI
			Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vsbHeight, %sbuttonHeight%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vsbWidth, %sbuttonWidth%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vsbSpacing, %sbuttonSpacing%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r6 0x100 Center vstFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
				GuiControl, Settings:ChooseString, stFont, %stextFont%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r2 0x100 Center vstBold, 400|700
				GuiControl, Settings:ChooseString, stBold, %stextBold%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vstSize, %stextSize%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vsguiColor gGuiColor, %sguiColor%
			
			Gui, Settings:Add, GroupBox, x+10 y35 w160 h275 center, SLR GUI
			Gui, Settings:Add, Edit, xp+5 ys-5 w150 h30 Center vslrbHeight, %slrbuttonHeight%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vslrbWidth, %slrbuttonWidth%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vslrbSpacing, %slrbuttonSpacing%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r6 0x100 Center vslrtFont, Lucida Sans Unicode|Times New Roman|Arial|Veranda|Calibri|BankGothic Md Bt
				GuiControl, Settings:ChooseString, slrtFont, %slrtextFont%
			Gui, Settings:Add, DropDownList, xp y+10 wp hp r2 0x100 Center vslrtBold, 400|700
				GuiControl, Settings:ChooseString, slrtBold, %slrtextBold%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vslrtSize, %slrtextSize%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vslrguiColor gGuiColor, %slrguiColor%
			
			
			
			;~ if (theGui = "SLR")
			;~ {
				;~ GuiControl, Settings:Disable, BackColor
				;~ GuiControl, Settings:Disable, TextColor
				;~ GuiControl, Settings:Disable, HLBackColor
				;~ GuiControl, Settings:Disable, HLTextColor
				;~ GuiControl, Settings:Disable, ChangeDefaults
			;~ }
			
			
			; Button Colors Tab Controls
			Gui, Settings:Tab, Colors / Add-ons
			Gui, Settings:Add, GroupBox, x5 y35 w335 h200 Center, DEFAULT BUTTON COLORS
			Gui, Settings:Add, Text, xp+5 yp+30 w160 h30 Section, Back Color
			Gui, Settings:Add, Text, xp y+5 wp hp, Text Color
			Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Back Color
			Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Text Color
			Gui, Settings:Add, Button, x+15 ys-5 w150 h30 Center vBackColor gDefaultColor, %defBackColor%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vTextColor gDefaultColor,  %defTextColor%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLBackColor gDefaultColor,  %defHLBackColor%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLTextColor gDefaultColor,  %defHLTextColor%
			Gui, Settings:Add, CheckBox, xs+5 y+5 w310 hp vChangeDefaults, Update all buttons to default colors now?
			
			Gui, Settings:Add, GroupBox, x+20 y35 w325 h130 Center, MAIN GUI ADD-ONS
			Gui, Settings:Add, CheckBox, xp+5 yp+25 w310 h30 Section vmainSearch, Show Search Bar on Main Gui?
			Gui, Settings:Add, Text, xp y+10 w150 h30, Search Bar Text
			Gui, Settings:Add, Edit, x+5 yp-5 w150 h30 Center vmainSearchText, Search Bar Text
			Gui, Settings:Add, CheckBox, xs y+5 w310 hp vmainFooter, Show Footer on Main Gui?
			
			
			; No-Run / Closer Tab Controls
			Gui, Settings:Tab, No-Run / Closer
			
			
			; End Tab Control
			Gui, Settings:Tab
			
			Gui, Settings:Add, Button, x210 y325 w100 h30 gallSet Default, All Set
			Gui, Settings:Add, Button, x+50 yp wp hp gsettingsCancel, Cancel
			
			Gui, Settings:Show, Center, %theGui% GUI Window Settings
			Return
		}
		
		

		allSet:
			Gui, Settings:Submit
			
			Guis[theGuiJSON].buttonHeight := bHeight
			Guis[theGuiJSON].buttonWidth := bWidth
			Guis[theGuiJSON].buttonSpacing := bSpacing
			Guis[theGuiJSON].textFont := tFont
			Guis[theGuiJSON].textBold := tBold
			Guis[theGuiJSON].textSize := tSize
			GuiControlGet, guiColorText,, guiColor 
			Guis[theGuiJSON].guiBackColor := guiColorText
			
			JSON_save(guis, guiSettings)
			ButtonList := []

			if (ChangeDefaults && theGui = "Main")
			{
				MsgBox, 4132, Main GUI Colors, Would you like to use these colors for the SIDE guis as well?
				IfMsgBox Yes
					sideColor := 1
				else
					sideColor := 0
				
				for key, value in buttons
				{
					tempButton := value.text
					ButtonList.Insert(value.text, value)
					
					if (!sideColor && ButtonList[tempButton].Level = "" && value.text != "Default")
					{
						GuiControlGet, BackColorText, Settings:, BackColor
							buttons[key].BackColor := BackColorText
						GuiControlGet, TextColorText, Settings:, TextColor
							buttons[key].TextColor := TextColorText
						GuiControlGet, HLBackColorText, Settings:, HLBackColor
							buttons[key].HLBackColor := HLBackColorText
						GuiControlGet, HLTextColorText, Settings:, HLTextColor
							buttons[key].HLTextColor := HLTextColorText
					}
					else if (sideColor && value.text != "Default")
					{
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
			}
			
			JSON_Save(buttons, buttonSettings)
			
			Buttons := []
			Gui, Settings:Destroy
		return
		
		
		
		SettingsGuiClose:
		SettingsGuiEscape:
		settingsCancel:
			Gui, Settings:Destroy
			Buttons := []
		return
		
		
		
		guiColor:
			
			ColorButton := A_GuiControl
			ColorGui()
			
			;~ theColor := RegExReplace(ColorChooser(), "i)0x")
			
			;~ if (theColor <> "")
				;~ GuiControl, Settings:, guiColor, %theColor%
		return
		
		
		
		DefaultColor:
			
			ColorButton := A_GuiControl
			ColorGui()
			
		return
		
