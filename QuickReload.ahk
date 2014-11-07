; Reload the script & display the specified tray tip
QuickReload(prompt="", title="")
{
	Run, %A_ScriptFullPath% %A_ScriptHwnd% `"%prompt%`" `"%title%`"
}
