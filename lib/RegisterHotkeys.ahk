RegisterHotkeys()
{
	for i, val in Settings.mainHotkey.disableIfActive
	{
		disableMainHKList := ((disableMainHKList != "") ? (disableMainHKList ",") : "") val
		GroupAdd, NoRunGroup, % val
	}	
	Hotkey, IfWinNotActive, ahk_group NoRunGroup
	Hotkey, % Settings.mainHotkey.mainHotkey, mainTrigger
	
	for i, val in Settings.userHotkeys
		Hotkey, % i, superShorts

	for i, val in Settings.theCloser.disableIfActive
	{
		disableCloseList := ((disableCloseList != "") ? (disableCloseList ",") : "") val
		GroupAdd, NoCloserGroup, % val
	}				
	for i, val in Settings.theCloser.closeTabIfActive
		closeTabWinList := ((closeTabWinList != "") ? (closeTabWinList ",") : "") val
	Hotkey, IfWinNotActive, ahk_group NoCloserGroup
	Hotkey, % Settings.theCloser.hotkey, theCloser

	Hotkey, IfWinActive, c0bra Main GUI
	Hotkey, Enter, ButtonPress
	Hotkey, ^Enter, ButtonPress
	Hotkey, IfWinActive
	;}
}