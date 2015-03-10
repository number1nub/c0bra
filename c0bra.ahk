#NoEnv
#SingleInstance, Force
#Include %A_ScriptDir%\lib\JSON.ahk
#Escapechar ``
#CommentFlag ;
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
DetectHiddenWindows, On
SetTitleMatchMode, 2


global settings:=[], files:=[], disableMainHKList, closeTabWinList, disableCloseList

files.userDir:=A_AppData "\c0bra\", files.cleanDir:=A_ScriptDir "\config\"
files.names := ["Buttons.c0bra","Settings.c0bra","SLRButtons.c0bra"]

FileCheck()

try Settings := JSON_Load(files.user.Settings)
catch e {
	m("There's an error with your config file:", e.file,, e.message, e.extra, "Please correct the issue and reload Cobra", "ico:!")
	ExitApp
}
if (FileExist(files.clean.Settings)) {
	serverConfig := JSON_Load(files.clean.Settings)
	if (serverConfig.Version != Settings.Version) {
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
if 0 > 0
{
	WinKill, % "ahk_id " %1%	
	prompt = %2%
	title = %3%
	title := title ? title : "Cobra Launcher Config"		
	if (prompt || title)
		TrayTip, %title%, %prompt%, 3500, 1
}
RegisterHotkeys()
MenuSetup()
OnMessage(0x200, "WM_MOUSEMOVE")
return


#Include %A_ScriptDir%\lib
#Include Gui.ahk
#Include Methods.ahk
#Include Class_CTLCOLORS.ahk
#Include ColorChooser.ahk
#Include ContextMenu.ahk
#Include Settings.ahk
#Include RegisterHotkeys.ahk
#Include MenuSetup.ahk
#Include FileCheck.ahk