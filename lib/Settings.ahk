#NoEnv
#SingleInstance, Force
#Escapechar ``
#CommentFlag ;

;~ Interface for Gui Settings

	;~ Gui Settings Call (call Main, Side, or SLR)

		Gui_Settings()
		{
			global
			
			;Guis := JSON_Load(guiSettings)
			
			;{````  Create CSV button lists  ````}
			Buttons := JSON_Load(buttonSettings)
			ButtonList 	:= []
			
			For key, value in Buttons
			{
				tempButton := value.text
				ButtonList.Insert(value.text, value)
			}
			;}
			
			;~ theGui := theGui
			
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
			Gui, Settings:Add, ListBox, xp y+5 w320 h110 vdisableIfActive, %aList%
			Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddTriggerDisable, Add
			Gui, Settings:Add, Button, x+25 yp wp hp gremTriggerDisable, Remove
			
			Gui, Settings:Add, GroupBox, x340 y35 w330 h280 Center, USER HOTKEYS
			Gui, Settings:Add, Text, xp+5 yp+30 w320 h30 Center Section, Manage any personal hotkeys below:
			
			bList :=
			for key, value in Settings.userHotkeys
				bList := (bList = "" ? "" : bList "|") key "`t-  " value
			Gui, Settings:Add, ListBox, xp y+7 wp h190 vuserHotkeys, %bList%
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
			Gui, Settings:Add, Button, x+15 ys-5 w150 h30 Center vBackColor gDefaultColor, % ButtonList.Default.BackColor
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vTextColor gDefaultColor,  % ButtonList.Default.TextColor
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLBackColor gDefaultColor,  % ButtonList.Default.HLBackColor
			Gui, Settings:Add, Button, xp y+5 wp h30 Center vHLTextColor gDefaultColor,  % ButtonList.Default.HLTextColor
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
			Gui, Settings:Add, ListBox, xp y+5 w320 h150 vcloserDisable, %cList%
			Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddCloserDisable, Add
			Gui, Settings:Add, Button, x+25 yp wp hp gremCloserDisable, Remove
			
			Gui, Settings:Add, GroupBox, x340 y35 w330 h280 Center, TAB CLOSER
			Gui, Settings:Add, Text, xp+5 yp+25 w320 h35 Wrap Center Section, The Closer will close a tab instead of the window for the following items:
			
			dList :=
			for key, value in Settings.theCloser.closeTabIfActive
				dList := (dList = "" ? "" : dList "|") value
			Gui, Settings:Add, ListBox, xp y+7 wp h190 vCloserTabs, %dList%
			Gui, Settings:Add, Button, xs+45 y+5 w100 h30 gaddCloserTabs, Add
			Gui, Settings:Add, Button, x+25 yp w100 hp gremCloserTabs, Remove
			
			
			;{````  End Tab Control  ````}
			Gui, Settings:Tab
			
			Gui, Settings:Add, Button, x210 y325 w100 h30 gallSet Default Disabled, ALL SET
			Gui, Settings:Add, Button, x+50 yp wp hp gsettingsCancel, CANCEL
			
			Gui, Settings:Show, Center, c0bra Settings
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
		
		
		
		addTriggerDisable:
		
		return
		
		
		
		remTriggerDisable:
		
		return
		
		
		
		addUserHotkey:
		
		return
		
		
		
		remUserHotkey:
		
		return
		
		
		
		addCloserDisable:
		
		return
		
		
		
		remCloserDisable:
		
		return
		
		
		
		addCloserTabs:
		
		return
		
		
		
		remCloserTabs:
		
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
		
