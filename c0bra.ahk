#NoEnv
#SingleInstance, Force
#Include <JSON>
#Escapechar ``
#CommentFlag ;
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
DetectHiddenWindows, On
SetTitleMatchMode, 2


;{===== Global Settings ====>>>
	
	global COBRA 				:= A_ScriptDir
	global cobraPath			:= A_ScriptFullPath
	global buttonSettings 		:= A_AppData "\c0bra\Buttons.C0bra"
	global guiSettings 			:= A_AppData "\c0bra\Gui.C0bra"
	global c0braSettings 	 	:= A_AppData "\c0bra\Settings.C0bra"
	global slrButtonSettings 	:= A_AppData "\c0bra\SLRButtons.C0bra"
	global _reloaded			:= false
	global disableMainHKList	:= ""
	global closeTabWinList		:= ""
	global disableCloseList		:= ""
	
	if (!FileExist(buttonSettings) || !FileExist(guiSettings) || !FileExist(c0braSettings) || !FileExist(slrButtonSettings))
	{
		IfNotExist, %A_AppData%\c0bra, FileCreateDir, %A_AppData%\c0bra
		FileCopy, %A_ScriptDir%\config\pristine\Buttons.c0bra, %A_AppData%\c0bra\Buttons.c0bra
		FileCopy, %A_ScriptDir%\config\pristine\Settings.c0bra, %A_AppData%\c0bra\Settings.c0bra
		FileCopy, %A_ScriptDir%\config\pristine\Gui.c0bra, %A_AppData%\c0bra\Gui.c0bra
		FileCopy, %A_ScriptDir%\config\pristine\SLRButtons.c0bra, %A_AppData%\c0bra\SLRButtons.c0bra
		TrayTip, c0bra Launcher, New configuration files copied to user settings directory!, 2, 1
	}

	Guis 	 := JSON_Load(guiSettings)
	Settings := JSON_Load(c0braSettings)	
	
	Menu, Tray, Icon, % FileExist(tIco := (A_ScriptDir "\res\c0bra.ico")) ? tIco : ""
	
;}<<<==== Global Settings =====



;{==== Handle CmdLine Args ====>>

	if (%0% > 0)
	{
		loop %0%
			paramStr .= %A_Index%
		objParams := Arguments(paramStr)
		
		if (objParams.kill)
		{
			WinKill, % "ahk_id " objParams.kill
			If (!ErrorLevel)
				msgbox, 4160, , Successfully applied setting!!
		}
		if (objParams.x && objParams.y)
		{
			_reloaded := true
			XPOS := objParams.X
			YPOS := objParams.Y
		}
	}
	
;}<<==== Handle CmdLine Args ====



;{===== Register Hotkeys ====>>>

	;{````  User Hotkeys  ````}
	for i, val in Settings.userHotkeys
		Hotkey, % i, superShorts
	;}
	
	;{```` Main Hotkey ````}
	for i, val in Settings.mainHotkey.disableIfActive
	{
		disableMainHKList := ((disableMainHKList != "") ? (disableMainHKList ",") : "") val
		GroupAdd, NoRunGroup, % val
	}	
	Hotkey, IfWinNotActive, ahk_group NoRunGroup
	Hotkey, % Settings.mainHotkey.mainHotkey, mainTrigger
	;}
	
	;{```` The Closer Hotkey ````}	
	for i, val in Settings.theCloser.disableIfActive
	{
		disableCloseList := ((disableCloseList != "") ? (disableCloseList ",") : "") val
		GroupAdd, NoCloserGroup, % val
	}				
	for i, val in Settings.theCloser.closeTabIfActive
		closeTabWinList := ((closeTabWinList != "") ? (closeTabWinList ",") : "") val

	for i, val in Settings.theCloser.closeTabSpecialIfActive
	{
		closeTabSpecialWinList := ((closeTabSpecialWinList != "") ? (closeTabSpecialWinList ",") : "") val
		GroupAdd, closeTabSpecialGroup, val
	}
	
	
	Hotkey, IfWinNotActive, ahk_group NoCloserGroup
	Hotkey, % Settings.theCloser.hotkey, theCloser
	;}
	
	;{```` Submit Search Hotkey ````}
	Hotkey, IfWinActive, c0bra Main GUI
	Hotkey, Enter, ButtonPress
	Hotkey, IfWinActive
	;}

;}<<<==== Register Hotkeys =====



;{===== Tray Menu ====>>>
	
	;{________  SUB-MENU: About  ________}
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, DeleteAll
	Menu, SubMenu_About, Add, Creators - Nugh && Shugh, TrayText
	Menu, SubMenu_About, Disable, Creators - Nugh && Shugh
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, Add, % "Version " Settings.version, TrayText
	Menu, SubMenu_About, Disable, % "Version " Settings.version
	;____________________________________}
		
	;{```` SUB-MENU: Hotkeys ````}
	Menu, SubMenu_Hotkeys, Add
	Menu, SubMenu_Hotkeys, DeleteAll
	Menu, SubMenu_Hotkeys, Add, Add New Hotkey, TrayText
	Menu, SubMenu_Hotkeys, Add
	
	for aHotkey, aPath in Settings.userHotkeys
		Menu, SubMenu_Hotkeys, Add, <%aHotkey%> - <%aPath%>, TrayText
	;}
	
	;{```` SUB-MENU: GUI Opions ````}
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
	;}
		
	Menu, SubSearch, Add
	Menu, SubSearch, DeleteAll	
	Menu, SubSearch, Add, Gui Options, :GuiOptions
	Menu, SubSearch, Add
	Menu, SubSearch, Add, Search Bar, QuickEditMenu
	Menu, SubSearch, % guis.mainGui.search ? "Check" : "Uncheck", Search Bar
	Menu, SubSearch, Add, % "Change Text: " guis.search.searchBackText, QuickEditMenu
	Menu, SubSearch, Add
		
		
		;{ ___ No run add and edit
		
			Menu, SubSearch1, Add
			Menu, SubSearch1, DeleteAll
			Menu, SubSearch1, Add, Add to no-run list, QuickEditMenu
			Menu, SubSearch1, Add
			
			Loop, Parse, disableMainHKList, `,
				Menu, SubSearch1, Add, %A_LoopField%, QuickEditMenu
			
		;}
		

		;{ ___ Closer Hotkey
		
			Menu, SubSearch2, Add
			Menu, SubSearch2, DeleteAll
			Menu, SubSearch2, Add, Closer Hotkey, QuickEditMenu
			Menu, SubSearch2, Add
			
			;{ ___ Closer tab list
			
				Menu, SubSearch3, Add
				Menu, SubSearch3, DeleteAll
				Menu, SubSearch3, Add, Add to close tab list, QuickEditMenu
				Menu, SubSearch3, Add
				Loop, Parse, closeTabWinList, `,
					Menu, SubSearch3, Add, %A_LoopField%, QuickEditMenu
				
			;}
			
			
			;{ ___ Closer disable list
			
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
	
	
	;{```` Create The Tray Menu ````}
	Menu, Tray, NoStandard
	Menu, Tray, Add, About, :SubMenu_About
	Menu, Tray, Add
	Menu, Tray, Add, % "Trigger: " Settings.mainHotkey.mainHotkey, TrayText
	Menu, Tray, Add
	Menu, Tray, Add, Hotkeys, :SubMenu_Hotkeys
	Menu, Tray, Add, Options, :SubSearch
	Menu, Tray, Add
	Menu, Tray, Add, Reload, reloadMe
	Menu, Tray, Add, Edit Script, editMe
	Menu, Tray, Add
	Menu, Tray, Add, Exit, closer
	Menu, Tray, Default, Reload
	Menu, Tray, tip, c0bra!
	
;}<<<==== Tray Menu =====
	
	OnMessage(0x200, "WM_MOUSEMOVE")
	
	if (_reloaded)
		goto, GUI
return


#Include <Gui>
#Include <Methods>
#Include <Class_CTLCOLORS>
#Include <cIni>
#Include <ColorChooser>
#Include <Arguments>
#Include <ContextMenu>


;TillaGoto.ScanFile=lib\Gui.ahk
;TillaGoto.ScanFile=lib\Methods.ahk
;TillaGoto.ScanFile=lib\ColorChooser.ahk
;TillaGoto.ScanFile=lib\Arguments.ahk
;TillaGoto.ScanFile=lib\ContextMenu.ahk
