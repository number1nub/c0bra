#NoEnv
#SingleInstance, Force
#Include <JSON>
#Escapechar ``
#CommentFlag ;
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
SetTitleMatchMode, 2


OnMessage(0x200, "WM_MOUSEMOVE")


;{___ Handle CMD Parameters _______________________________________________________________

	if 0 > 0
	{
		DetectHiddenWindows, On
		WinKill, % "ahk_id " %1%
		
		if 2 = /prompt
		{
			TrayTip, %3%, %4%, 2000, 1
		}
	} ;}
	
		

;{___ Global Constants ____________________________________________________________________

	global COBRA 				:= A_ScriptDir
	global cobraPath			:= A_ScriptFullPath
	global buttonSettings 		:= A_ScriptDir "\config\Buttons.C0bra"
	global guiSettings 			:= A_ScriptDir "\config\Gui.C0bra"
	global c0braSettings 	 	:= A_ScriptDir "\config\Settings.C0bra"
	global slrButtonSettings 	:= A_ScriptDir "\config\SLRButtons.C0bra"	
	global disableList			:= ""
	global tabList				:= ""
	global disableCloseList		:= ""
	
	Guis 	 := JSON_Load(guiSettings)
	Settings := JSON_Load(c0braSettings)
	
;}



;{___  Register Hotkeys  __________________________________________________________________

	
	for key, value in Settings.mainHotkey.disableIfActive
	{
		disableList := ((disableList != "") ? (disableList ",") : "") value
		GroupAdd, NoRunGroup, % value
	}
	
	for key, value in Settings.theCloser.disableIfActive
	{
		disableCloseList := ((disableCloseList != "") ? (disableCloseList ",") : "") value
		GroupAdd, NoCloserGroup, % value
	}		
			
	for key, value in Settings.theCloser.closeTabIfActive
		tabList := ((tabList != "") ? (tabList ",") : "") value
	
	;
	; User Hotkeys
	;
	for key, value in Settings.userHotkeys
		Hotkey, % key, superShorts
	
	;
	; Main Hotkey
	;
	mainHotkey := Settings.mainHotkey.mainHotkey
	for key, value in Settings.mainHotkey.disableIfActive
	{
		if (value != "")
			GroupAdd, NoRunGroup, % value
	}
	#If !(GetKeyState("LWin", "P") && GetKeyState("Alt", "P"))
	Hotkey, IfWinNotActive, ahk_group NoRunGroup
		Hotkey, % mainHotkey, mainTrigger 
	Hotkey, ifwinactive,
	#if	;}


;{___  The Closer  ___}
	
	closerHKActions := {}
	closerHK := Settings.theCloser.hotkey
	
	for key, value in Settings.theCloser.disableIfActive
	{
		if (key != "")
		{
			GroupAdd, NoRunGroup, % key
			closerHKActions.Insert(key, value)
		}
	}
	Hotkey, IfWinNotActive, ahk_group NoRunGroup
	Hotkey, %closerHK%, theCloser	;}
	
	
;{___ Google search and website hotkeys ___}
	
	Hotkey, IfWinActive, c0bra Main GUI
	Hotkey, Enter, ButtonPress
	Hotkey, NumpadEnter, ButtonPress
	Hotkey, ^Enter, ButtonPress
	Hotkey, ^NumpadEnter, ButtonPress
	Hotkey, IfWinActive	;}



;{___  Tray Icon/Menu  ____________________________________________________________________

	Menu, Tray, NoStandard
	Menu, Tray, Icon, res\c0bra.ico

	Menu, Sub, Add
	Menu, Sub, DeleteAll
	Menu, Sub, Add, Creators - Nugh && Shugh, TrayText
	Menu, Sub, Disable, Creators - Nugh && Shugh
	Menu, Sub, Add
	Menu, Sub, Add, % "Version " Settings.version, TrayText
	Menu, Sub, Disable, % "Version " Settings.version
	
	Menu, Tray, Add, About, :Sub
	
	
	;{ ___ Hotkeys
	;_____________
	
		Menu, SubHotkeys, Add
		Menu, SubHotkeys, DeleteAll
		Menu, SubHotkeys, Add, New hotkey, TrayText
		Menu, SubHotkeys, Add
		for aHotkey, aPath in Settings.userHotkeys
			Menu, SubHotkeys, Add, <%aHotkey%> - <%aPath%>, TrayText
		
	;}
	
	;{ ___ search bar, footer, no-run
	;________________________________

		Menu, SubSearch, Add
		Menu, SubSearch, DeleteAll
		
			Menu, GuiOptions, Add, Button Height, QuickEditMenu
			Menu, GuiOptions, Add, Button Width, QuickEditMenu
			Menu, GuiOptions, Add, Button Spacing, QuickEditMenu
			Menu, GuiOptions, Add, Text Bold, QuickEditMenu
			Menu, GuiOptions, Add, Text Size, QuickEditMenu
			Menu, GuiOptions, Add, Go Width, QuickEditMenu
			Menu, GuiOptions, Add, Search Height, QuickEditMenu
			Menu, GuiOptions, Add, Search Text Size, QuickEditMenu
			Menu, GuiOptions, Add
			
			Menu, GuiOptions, Add, Footer Color, QuickEditMenu
			Menu, GuiOptions, Add, Gui Background Color, QuickEditMenu
			Menu, GuiOptions, Add, Gui Text Color, QuickEditMenu
			Menu, GuiOptions, Add, SLR Gui Color, QuickEditMenu
			Menu, GuiOptions, Add, Search Text Color, QuickEditMenu
			
		Menu, SubSearch, Add, Gui Options, :GuiOptions
		Menu, SubSearch, Add
		Menu, SubSearch, Add, Search Bar, QuickEditMenu
		Menu, SubSearch, % guis.mainGui.search ? "Check" : "Uncheck", Search Bar
		Menu, SubSearch, Add, % "Change Text: " guis.search.searchBackText, QuickEditMenu
		Menu, SubSearch, Add
		
		
		;{ ___ No run add and edit
		;_________________________
		
			Menu, SubSearch1, Add
			Menu, SubSearch1, DeleteAll
			Menu, SubSearch1, Add, Add to no-run list, QuickEditMenu
			Menu, SubSearch1, Add
			Loop, Parse, disableList, `,
				Menu, SubSearch1, Add, %A_LoopField%, QuickEditMenu
			
		;}
		

		;{ ___ Closer Hotkey
		;___________________
		
			Menu, SubSearch2, Add
			Menu, SubSearch2, DeleteAll
			Menu, SubSearch2, Add, Closer Hotkey, QuickEditMenu
			Menu, SubSearch2, Add
			
			;{ ___ Closer tab list
			;_____________________
			
				Menu, SubSearch3, Add
				Menu, SubSearch3, DeleteAll
				Menu, SubSearch3, Add, Add to close tab list, QuickEditMenu
				Menu, SubSearch3, Add
				Loop, Parse, tabList, `,
					Menu, SubSearch3, Add, %A_LoopField%, QuickEditMenu
				
			;}
			
			
			;{ ___ Closer disable list
			;_________________________
			
				Menu, SubSearch4, Add
				Menu, SubSearch4, DeleteAll
				Menu, SubSearch4, Add, Add to disable close list, QuickEditMenu
				Menu, SubSearch4, Add
				Loop, Parse, disableCloseList, `,
					Menu, SubSearch4, Add, %A_LoopField%, QuickEditMenu
				
			;}
			
			
			Menu, SubSearch2, Add, Close tab, :SubSearch3
			Menu, SubSearch2, Add, Disable closer, :SubSearch4
			
		;}
			

		Menu, SubSearch, Add, No-run, :SubSearch1
		Menu, SubSearch, Add, Closer, :SubSearch2
		Menu, SubSearch, Add
		Menu, SubSearch, Add, Footer, QuickEditMenu
		Menu, SubSearch, % guis.mainGui.Footer ? "Check" : "Uncheck", Footer
		Menu, Title, Add, c0bra Options, :SubSearch
		
	;}
		
	Menu, Tray, Add
	Menu, Tray, Add, Trigger: %mainHotkey%, TrayText
	Menu, Tray, Add
	Menu, Tray, Add, Hotkeys, :SubHotkeys
	Menu, Tray, Add, Options, :SubSearch
	Menu, Tray, Add
	Menu, Tray, Add, Reload, reloadMe
	Menu, Tray, Add, Edit Script, editMe
	Menu, Tray, Add
	Menu, Tray, Add, Exit, closer
	Menu, Tray, Default, Reload
	Menu, Tray, tip, c0bra!
;}


#Include <Gui>
#Include <Methods>
#Include <Class_CTLCOLORS>
#Include <cIni>
#Include <ColorChooser>


