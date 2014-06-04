#NoEnv
#SingleInstance, Force
#Include <JSON>
#Escapechar ``
#CommentFlag ;
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

OnMessage(0x200, "WM_MOUSEMOVE")


;{==== Handle CMD Parameters ====>>

if 0 > 0
{
	DetectHiddenWindows, On
	WinKill, % "ahk_id " %1%
	
	if 2 = /prompt
	{
		TrayTip, %3%, %4%, 2000, 1
	}
}
	
;}<<==== Handle CMD Parameters ====


;{===== Global Constants ====>>>

global COBRA 				:= A_ScriptDir
global cobraPath			:= A_ScriptFullPath
global buttonSettings 		:= A_ScriptDir "\config\Buttons.C0bra"
global guiSettings 			:= A_ScriptDir "\config\Gui.C0bra"
global c0braSettings 	 	:= A_ScriptDir "\config\Settings.C0bra"
global slrButtonSettings 	:= A_ScriptDir "\config\SLRButtons.C0bra"	
global disableMainHKList	:= ""
global closeTabWinList		:= ""
global disableCloseList		:= ""

Guis 	 := JSON_Load(guiSettings)
Settings := JSON_Load(c0braSettings)

;}<<<==== Global Constants =====




;{===== User Hotkeys ====>>>

for i, val in Settings.userHotkeys
	Hotkey, % i, superShorts

;}<<<==== User Hotkeys =====




;{===== Built-In Hotkeys ====>>>
	
	for i, val in Settings.mainHotkey.disableIfActive
	{
		disableMainHKList := ((disableMainHKList != "") ? (disableMainHKList ",") : "") val
		GroupAdd, NoRunGroup, % val
	}

	for i, val in Settings.theCloser.disableIfActive
	{
		disableCloseList := ((disableCloseList != "") ? (disableCloseList ",") : "") val
		GroupAdd, NoCloserGroup, % val
	}				
	for i, val in Settings.theCloser.closeTabIfActive
		closeTabWinList := ((closeTabWinList != "") ? (closeTabWinList ",") : "") val
	
	;{```` Main Hotkey ````}
	Hotkey, IfWinNotActive, ahk_group NoRunGroup
	Hotkey, % Settings.mainHotkey.mainHotkey, mainTrigger	
	;}

	;{```` The Closer Hotkey ````}
	Hotkey, IfWinNotActive, ahk_group NoCloserGroup
	Hotkey, % Settings.theCloser.hotkey, theCloser
	;}

	
	;{===== Hotkey: Submit Search ====>>>

	Hotkey, IfWinActive, c0bra Main GUI
	Hotkey, Enter, ButtonPress
	Hotkey, IfWinActive

	;}<<<==== Hotkey: Submit Search =====

;}<<<==== Built-In Hotkeys ===== 




;{===== Tray Menu ====>>>
	
	Menu, Tray, Icon, % FileExist(tIco := (A_ScriptDir "\res\c0bra.ico")) ? tIco : ""
	

	;{```` SUB-MENU: About ````}
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, DeleteAll
	Menu, SubMenu_About, Add, Creators - Nugh && Shugh, TrayText
	Menu, SubMenu_About, Disable, Creators - Nugh && Shugh
	Menu, SubMenu_About, Add
	Menu, SubMenu_About, Add, % "Version " Settings.version, TrayText
	Menu, SubMenu_About, Disable, % "Version " Settings.version
	;}
	
	
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

return

#Include <Gui>
#Include <Methods>
#Include <Class_CTLCOLORS>
#Include <cIni>
#Include <ColorChooser>

