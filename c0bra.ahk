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

global settings:=[], files:=[], btnSettingsPath, mainSettingsPath, slrBtnSettingsPath, disableMainHKList, closeTabWinList, disableCloseList

files.userDir:=A_AppData "\c0bra\"
files.
[ "Buttons.c0bra", "Settings.c0bra", "SLRButtons.c0bra" ]

btnSettingsPath    := A_AppData "\c0bra\Buttons.c0bra"
mainSettingsPath   := A_AppData "\c0bra\Settings.c0bra"
slrBtnSettingsPath := A_AppData "\c0bra\SLRButtons.c0bra"

FileCheck(info="") {
	fList := []
	if !(FileExist(btnSettingsPath) || FileExist(mainSettingsPath) || FileExist(slrBtnSettingsPath)) {
		if (!FileExist(A_AppData "\c0bra"))
			FileCreateDir, %A_AppData%\c0bra
		if (A_IsCompiled) {
			FileInstall, config\Buttons.c0bra, %btnSettingsPath%
			FileInstall, config\Settings.c0bra, %mainSettingsPath%
			FileInstall, config\SLRButtons.c0bra, %slrBtnSettingsPath%
		} else {
			FileCopy, %A_ScriptDir%\config\Buttons.c0bra, %A_AppData%\c0bra\Buttons.c0bra
			FileCopy, %A_ScriptDir%\config\Settings.c0bra, %A_AppData%\c0bra\Settings.c0bra
			FileCopy, %A_ScriptDir%\config\SLRButtons.c0bra, %A_AppData%\c0bra\SLRButtons.c0bra
		}
		TrayTip, c0bra Launcher, New configuration files copied to user settings directory!, 2, 1
	}
}

try Settings := JSON_Load(mainSettingsPath)
catch e {
	m("There's an error with your config file:", e.file,, e.message, e.extra, "Please correct the issue and reload Cobra", "ico:!")
	ExitApp
}
if (FileExist(serverSettings := (A_ScriptDir "\config\Settings.c0bra"))) {
	serverConfig := JSON_Load(serverSettings)
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