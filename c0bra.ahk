#NoEnv
#SingleInstance, Force
#Include %A_ScriptDir%\lib\JSON.ahk
#Escapechar ``
#CommentFlag ;
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
DetectHiddenWindows, On
SetTitleMatchMode, 2


;{===== Global Settings ====>>>

	global COBRA             := A_ScriptDir
	global cobraPath         := A_ScriptFullPath
	global buttonSettings    := A_AppData "\c0bra\Buttons.c0bra"
	global c0braSettings     := A_AppData "\c0bra\Settings.c0bra"
	global slrButtonSettings := A_AppData "\c0bra\SLRButtons.c0bra"
	global _reloaded         := false
	global disableMainHKList := ""
	global closeTabWinList   := ""
	global disableCloseList  := ""

	if (!FileExist(buttonSettings) || !FileExist(c0braSettings) || !FileExist(slrButtonSettings))
	{
		if (!FileExist(A_AppData "\c0bra"))
			FileCreateDir, %A_AppData%\c0bra
		if (A_IsCompiled)
		{			
			FileInstall, config\Buttons.c0bra, %buttonSettings%
			FileInstall, config\Settings.c0bra, %c0braSettings%
			FileInstall, config\SLRButtons.c0bra, %slrButtonSettings%
		}
		else
		{
			FileCopy, %A_ScriptDir%\config\Buttons.c0bra, %A_AppData%\c0bra\Buttons.c0bra
			FileCopy, %A_ScriptDir%\config\Settings.c0bra, %A_AppData%\c0bra\Settings.c0bra
			FileCopy, %A_ScriptDir%\config\SLRButtons.c0bra, %A_AppData%\c0bra\SLRButtons.c0bra
		}
		TrayTip, c0bra Launcher, New configuration files copied to user settings directory!, 2, 1
	}

	try
	{
		global Settings := JSON_Load(c0braSettings)
	}
	catch e 
	{
		MsgBox, 4144, Cobra Config Error, % "There is an error in your config file: " e.file 
					. "`n`n" e.message (e.extra ? "`n`n" e.extra : "") "`n`nPlease correct this issue and then reload C0bra."
		ExitApp
	}

	Menu, Tray, Icon, % FileExist(tIco := (A_ScriptDir "\res\c0bra.ico")) ? tIco : ""

;}<<<==== Global Settings =====


;{===== Update User Config Version ====>>>

	if (FileExist(serverSettings := (A_ScriptDir "\config\Settings.json")))
	{
		serverConfig := JSON_Load(serverSettings)
		if (serverConfig.Version != Settings.Version)
		{
			RegExMatch(serverConfig.Version, "(\d+?)\.(\d+?)(?:\.(\d+?)(?:\.(\d+))?)?", sVer)
			RegExMatch(Settings.Version, "(\d+?)\.(\d+?)(?:\.(\d+?)(?:\.(\d+))?)?", uVer)
			if (sVer1 > uVer1)
				UpdateVer(serverConfig.Version)
			if (sVer1 = uVer1 && sVer2 > uVer2)
				UpdateVer(serverConfig.Version)
			if (sVer1 = uVer1 && sVer2 = uVer2 && sVer3 > uVer3)
				UpdateVer(serverConfig.Version)
			if (sVer1 = uVer1 && sVer2 = uVer2 && sVer3 = uVer3 && sVer4 > uVer4)
				UpdateVer(serverConfig.Version)
		}
	}

;}<<<==== Update User Config Version =====


;{==== Handle CmdLine Args ====>>

	if 0 > 0
	{
		WinKill, % "ahk_id " %1%
		
		prompt = %2%
		title = %3%
		title := title ? title : "Cobra Launcher Config"		
		if (prompt || title)
			TrayTip, %title%, %prompt%, 3500, 1
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


	Hotkey, IfWinNotActive, ahk_group NoCloserGroup
	Hotkey, % Settings.theCloser.hotkey, theCloser
	;}

	;{```` Submit Search Hotkey ````}
	Hotkey, IfWinActive, c0bra Main GUI
	Hotkey, Enter, ButtonPress
	Hotkey, IfWinActive
	Hotkey, ^Enter, ButtonPress
	Hotkey, IfWinActive
	;}

;}<<<==== Register Hotkeys =====



;{===== Tray Menu ====>>>

	;{````  SUB-MENU: About  ````}
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, DeleteAll
	Menu, SubMenu_About, Add, Creators - Nugh && Shugh, TrayText
	Menu, SubMenu_About, Disable, Creators - Nugh && Shugh
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, Add, % "Version " Settings.version, TrayText
	Menu, SubMenu_About, Disable, % "Version " Settings.version
	;}


	;{```` Create The Tray Menu ````}
	Menu, Tray, NoStandard
	Menu, Tray, Add, About, :SubMenu_About
	Menu, Tray, Add
	Menu, Tray, Add, % "Trigger: " Settings.mainHotkey.mainHotkey, meOptions
	Menu, Tray, Add
	Menu, Tray, Add, Options, meOptions
	Menu, Tray, Add
	Menu, Tray, Add, Reload, reloadMe
	if (!A_IsCompiled)
		Menu, Tray, Add, Edit Script, editMe
	Menu, Tray, Add
	Menu, Tray, Add, Exit, closer
	Menu, Tray, Default, Reload
	Menu, Tray, tip, c0bra!
	;}
	
;}<<<==== Tray Menu =====

OnMessage(0x200, "WM_MOUSEMOVE")

if (_reloaded)
	goto, GUI
return


#Include %A_ScriptDir%\lib
#Include Gui.ahk
#Include Methods.ahk
#Include Class_CTLCOLORS.ahk
#Include ColorChooser.ahk
#Include ContextMenu.ahk
#Include Settings.ahk

;TillaGoto.ScanFile=lib\Gui.ahk
;TillaGoto.ScanFile=lib\Methods.ahk
;TillaGoto.ScanFile=lib\ColorChooser.ahk
;TillaGoto.ScanFile=lib\ContextMenu.ahk
;TillaGoto.ScanFile=lib\Settings.ahk