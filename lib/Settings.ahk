#NoEnv
#SingleInstance, Force
#Escapechar ``
#CommentFlag ;

;~ Interface for Gui Settings

	;~ Gui Settings Call (call Main, Side, or SLR)

		Gui_Settings(theGui)
		{
			global
			
			Gui 1:Destroy
			
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
						
			buttonHeight 	:= Guis[theGuiJSON].buttonHeight
			buttonWidth 	:= Guis[theGuiJSON].buttonWidth
			buttonSpacing	:= Guis[theGuiJSON].buttonSpacing
			textFont		:= Guis[theGuiJSON].textFont
			textBold 		:= Guis[theGuiJSON].textBold
			textSize 		:= Guis[theGuiJSON].textSize
			guiColor		:= Guis[theGuiJSON].guiBackColor
			
			defBackColor	:= ButtonList.Default.BackColor
			defTextColor	:= ButtonList.Default.TextColor
			defHLBackColor	:= ButtonList.Default.HLBackColor
			defHLTextColor	:= ButtonList.Default.HLTextColor
			
			Gui, Settings:Margin, 2, 10
			Gui, Settings:Font, s11 cBlack w700, Times New Roman
			
			Gui, Settings:Add, GroupBox, x2 y2 w325 h275, GUI SETTINGS
			Gui, Settings:Add, Text, xp+5 yp+30 w160 h30 Section, Button Height (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Width (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Spacing (pixels)
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Font
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Weight
			Gui, Settings:Add, Text, xp y+5 wp hp, Button Text Size
			Gui, Settings:Add, Text, xp y+5 wp hp, Background Color
			
			Gui, Settings:Add, Edit, x+5 ys-5 w150 hp Center vbHeight, %buttonHeight%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vbWidth, %buttonWidth%
			Gui, Settings:Add, Edit, xp y+5 wp hp Center vbSpacing, %buttonSpacing%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vtFont, %textFont%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vtBold, %textBold%
			Gui, Settings:Add, Edit, xp y+10 wp hp Center vtSize, %textSize%
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vguiColor gGuiColor, %guiColor%
			
			if (theGui = "Main")
			{
				Gui, Settings:Add, GroupBox, x2 y+20 w325 h200, DEFAULT BUTTON COLORS
				Gui, Settings:Add, Text, xp+5 yp+30 w160 h30 Section, Back Color
				Gui, Settings:Add, Text, xp y+5 wp hp, Text Color
				Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Back Color
				Gui, Settings:Add, Text, xp y+5 wp hp, Highlight Text Color
				
				Gui, Settings:Add, Button, x+5 ys-5 w150 h30 Center vBackColor gDefaultColor, % theGui = "SLR" ? "N/A" : defBackColor
				Gui, Settings:Add, Button, xp y+5 wp h30 Center vTextColor gDefaultColor,  % theGui = "SLR" ? "N/A" : defTextColor
				Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLBackColor gDefaultColor,  % theGui = "SLR" ? "N/A" : defHLBackColor
				Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLTextColor gDefaultColor,  % theGui = "SLR" ? "N/A" : defHLTextColor
				
				Gui, Settings:Add, CheckBox, xs+5 y+5 w310 hp vChangeDefaults, Change all %theGui% buttons to defaults now?
			}
			
			if (theGui = "SLR")
			{
				GuiControl, Settings:Disable, BackColor
				GuiControl, Settings:Disable, TextColor
				GuiControl, Settings:Disable, HLBackColor
				GuiControl, Settings:Disable, HLTextColor
				GuiControl, Settings:Disable, ChangeDefaults
			}
			
			Gui, Settings:Add, Button, xs+35 y+20 w100 h30 gallSet Default, All Set
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
			quickReload("GUI Settings Updated...")
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
		
		
		
		
		
		
		
		