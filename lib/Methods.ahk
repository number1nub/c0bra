

superShorts:
	command := Settings.userHotkeys[A_ThisHotkey]
	execute(command, Txt)
return



reloadMe:	
	Reload	
return

; Reload the script & display the specified tray tip
QuickReload(prompt = "", title = "")
{
	Run, %A_ScriptFullPath% %A_ScriptHwnd% `"%prompt%`" `"%title%`"
}


editMe:
	run, edit %COBRA%\c0bra.ahk
return


meOptions:
	Gui_Settings()
return
	

theCloser:
	mousegetpos,,, win
	WinGetTitle, winTitle, ahk_id %win%
	WinGetClass, winClass, ahk_id %win%
	
	IfWinActive, ahk_group closeTabSpecialGroup
	{
		Send, {Blind}^w
		return
	}
	if winTitle contains %closeTabWinList%
		Send, {Blind}^{F4}
	else if winClass contains %closeTabWinList%
		Send, {Blind}^{F4}
	else
		WinClose, ahk_id %win%
return



CopyTo:
	GetKeyState, keyState, Alt, P
	if (keyState = "D")
	{
		try CopyToRun()
		catch e
		{
			msgbox % e
			return
		}
	}
	else
	{
		try copyToNotepad()
		catch e
		{
			MsgBox % e
			return
		}
	}
return




ScreenCheck(ByRef MouseX, ByRef MouseY, GuiWidth, GuiHeight)
{
	SysGet, NumMon, MonitorCount
	loop, %NumMon%
	{
		SysGet, Mon%A_Index%, Monitor, %A_Index%
		if (MouseX >= Mon%A_Index%Left && MouseX <= Mon%A_Index%Right) ; which screen
		{
			aScreen := A_Index
			if (MouseX >= Mon%A_Index%Right - GuiWidth)
				MouseX := Mon%A_Index%Right - GuiWidth
			if (MouseY >= Mon%A_Index%Bottom - GuiHeight)
				MouseY := Mon%A_Index%Bottom - GuiHeight
		}			
	}
	return
}



/*!
	Function: addButton(aText, CMD, typeCmd, argsCmd, aColor, Children, aParent)
		Adds a new button to the c0bra GUI.
		
	Parameters:
		aText    - Button's text
		CMD      - Button's command string
		typeCmd  - Button's command type
		argsCmd  - Button's command arguments
		aColor   - Object containing the button's color settings
		Children - Object containing button's child buttons
		aParent  - Button's parent button
*/
addButton(aText, CMD="", typeCmd="", argsCmd="", aColor="", Children=0, aParent=0)
{
	global buttons, buttonSettings
	
	buttonKey				:= buttons.maxindex() + 1
	buttons[buttonKey]		:= {}
	buttons[buttonKey].Text	:= aText
	
	if (CMD)
	{
		buttons[buttonKey].Cmd		:= {}
		buttons[buttonKey].Cmd.Type:= typeCmd
		buttons[buttonKey].Cmd.Arg	:= argsCmd
	}
	
	buttons[buttonKey].BackColor 	:= aColor[1]
	buttons[buttonKey].TextColor 	:= aColor[2]
	buttons[buttonKey].HlBackColor := aColor[3]
	buttons[buttonKey].HlTextColor := aColor[4]
	
	if (Children)
		buttons[buttonKey].Children := []		
	if (aParent)
	{
		buttons[buttonKey].Level := 1		
		for parentKey, value in buttons
			if (value.text = aParent)
				buttons[parentKey].Children.Insert(aText)
	}
	
	JSON_Save(buttons, buttonSettings)
}


/*!
	Function: deleteButton(aText)
		Deletes a button from the c0bra GUI.
		
	Parameters:
		aText - 
*/
deleteButton(aText)
{
	global buttons, buttonSettings
	
	; Remove button
	for key, value in buttons
		if (value.Text = aText)
		{
			if (value.Children[1])
			{
				MsgBox, 4148, Remove Button, The <%aText%> button has buttons in it.  Deleting the <%aText%> button will remove these buttons as well.`n`nAre you sure you want to delete the <%aText%> button?
				ifmsgbox No
					return
			}
			buttons.Remove(key)
		}
	
	; Remove button from Parent
	for key, value in buttons
		for childKey, childValue in value.Children
			if (childValue = aText)
				value.Children.Remove(childKey)
	
	JSON_Save(buttons, buttonSettings)
}
	


buttonCheck(jObject, bName)
{
	for key, value in jObject
		if (value.text = bName)
		{
			MsgBox, 4113, c0bra Button Namer, The button %newName% already exists.`n`nChoose another name that does not exist.
			IfMsgBox OK
				return 1
		}
}


modReplace(str)
{
	StringReplace, v, str, +, Shift+
	StringReplace, v, v, ^, Ctrl+
	StringReplace, v, v, !, Alt+	
	StringReplace, v, v, #, Win+
	return v
}



ON_LEFT(CONTROL_POSX)
{
	global
	
	MIDPOINT := ((2 * buttonWidth) + (3 * buttonSpacing)) / 2
	
	if (CONTROL_POSX < MIDPOINT)
		return 1
	else
		return 0
}


Google(GSEARCH)
{
	GSEARCH := RegExReplace(GSEARCH, "i)\s", "+")
	GSEARCH := "http://www.google.com/search?hl=en&source=hp&q=" GSEARCH "&aq=f&aqi=&aql=&oq="
	Run chrome.exe %GSEARCH%
}



/*!
	Function: GetModifiers()
		Returns a string of symbols representing which modifier keys are currently being held down. ^ = Ctrl ! = ALt
		+ = Shift # = Win

	Returns:
		Returns a string containing the character representation of the modifier keys

	Example:
		> ; Assuming Ctrl and Alt are currently held down
		> mods := GetModifiers()
		> MsgBox Current modifiers are %mods%.	; MsgBox Output: Current modifiers are ^!.
*/
GetModifiers()
{
	Modifiers := GetKeyState("Ctrl", "P") ? "^" : ""
	Modifiers .= GetKeyState("Alt", "P") ? "!" : ""
	Modifiers .= GetKeyState("Shift", "P") ? "+" : ""
	Modifiers .= GetKeyState("LWin", "P") ? "#" : ""

	Return, Modifiers
}
	

ColorPicker()
{	
	theColor := RegExReplace(ColorChooser(), "i)0x")
	if (theColor = "0" || theColor <> "")
	{
		if ((theLen := StrLen(theColor)) < 6)
		{
			if (theLen = 5)
				theColor := "0" theColor
			else if (theLen = 4)
				theColor := "00" theColor
			else if (theLen = 3)
				theColor := "000" theColor
			else if (theLen = 2)
				theColor := "0000" theColor
			else if (theLen = 1)
				theColor := "00000" theColor
		}

		SetFormat, integer, d
		return % theColor
	}
}
	


Execute(command, Txt)
{
	If (!command)
		return
	
	; Remove duplicate spaces
	command := RegExReplace(command, "\s+", " ")

	; Get command description from in-line comment if one
	; exists, and remove the description from the command string
	RegExMatch(command, ";\K.+?$", Description)
	command := RegExReplace(command, ";" Description "$")
	command := Trimmer((Description && ReturnDescription) ? Description : command)
	
	Transform, command, Deref, % command
	
	;~~~~~~~~~~~~~~~~~~~~~~
	;[F] FUNCTION AS ACTION
	
		If (RegExMatch(command, "i)^\[F\]\s(?P<Func>\w+)(\(\s*(?P<Params>.+?)\s*\))?", m) && IsFunc(mFunc))
		{
			If mParams
			{
				Loop, Parse, mParams, CSV
					param%A_Index% := Trimmer(A_LoopField)
			}			
			Gui, 1:Destroy
			%mFunc%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
		}
	
	;~~~~~~~~~~~~~~~~~~~
	;[L] LABEL AS ACTION
	
		Else If (RegExMatch(command, "i)^\[L\]\s\K.+", Label) && IsLabel(Label))
		{
			Gui, 1:Destroy
			Gosub, %LABEL%
		}
		
	
	;~~~~~~~~~~~~~~~~~~~
	;[S] SEND AS ACTION
	
		Else If RegExMatch(Command, "i)^\[S\]\s*\K.+", macro)
		{
			Gui, Destroy
			Gui, 1:Destroy
			SendInput, {Blind}%macro%
		}
	
	
	;~~~~~~~~~~~~~~~~~~~~~	
	; [R] Run as Action
	
		Else if RegExMatch(command, "i)^\[R\]\s\K.+", runPath)
		{
			Gui, 1:Destroy
			Run, % ExpandEnv(runPath),, UseErrorLevel
			If ErrorLevel
				MsgBox, 262160, Run :, % "Error with this command!`n" ExpandEnv(runPath), 2
		}
		
			
	;~~~~~~~~~~~~~~~~~~~~~
	;[P] PROGRAM AS ACTION
	
		else if RegExMatch(command, "i)^\[P\]\s\K.+", theProgram)
		{
			Gui, 1:Destroy
			TMM := A_TitleMatchMode
			SetTitleMatchMode, 2
			SplitPath, theProgram, programName,,,programNameNoExt
				
			Process, Exist, % programName ".exe"
			if (!ErrorLevel)
				Process, Exist, % programName " *32.exe"

			If (WinExist(programNameNoExt) || ErrorLevel)
			{
				WinShow, %programNameNoExt% ahk_pid %ErrorLevel%
				WinActivate, %programNameNoExt% ahk_pid %ErrorLevel%
				WinRestore, %programNameNoExt% ahk_pid %ErrorLevel%
			}
			else
			{
				Run, % ExpandEnv(theProgram),, UseErrorLevel
				if (ErrorLevel)
					MsgBox, 262160, Run :, % "Error with this command!`n" ExpandEnv(runPath), 2
			}

			SetTitleMatchMode, %TMM%
		}
			
			
	;~~~~~~~~~~~~~~~~~~~~~~
	; SIDE GUI AS ACTION
		
		else
			SIDE_GUI()
}


Trimmer(str, omitchars=" `t")
{ ; Allow to use Trim() with AutoHotkey basic
	If !StrLen(omitchars)
		Return, str
	str := RegExReplace(str, "^[" omitchars "]+") ; Trims from the beginning
	str := RegExReplace(str, "[" omitchars "]+$")	; Trims from the end
	Return, str
}

	

/*!
	Function: ToggleCase([toCase, origStr])
		Converts a string to either upper, lower or title case. Can be used to replace selected
		text or to return a converted string based on a passed value.

	Parameters:
		toCase - (Optional) The case that text should be converted to; if blank or omitted, the default is 
				upper case, otherwise, one of the following values should be passed:
				* **U** - Upper case (Default)
				* **L** - Lower case
				* **T** - Title case
*/
ToggleCase(toCase = "U")
{
	BLB := A_BatchLines, KDB := A_KeyDelay, CBB := Clipboard
	SetKeyDelay, -1
	SetBatchLines, -1
	Clipboard := ""
	sleep 50
	
	Send, {Blind}^c
	ClipWait, 2
	If (ErrorLevel)
	{
		TrayTip, C0bra Launcher, Could't get selected text., 1500
		return
	}
	
	if (toCase = "L")
		StringLower, v, Clipboard
	else if (toCase = "T")
		StringUpper, v, Clipboard, T
	else (toCase = "U")
		StringUpper, v, Clipboard
	;~ else
		;~ throw "Invalid value for toCase parameter """ toCase """.`n`nShould be either 'U', 'L' or 'T'."
	
	PasteVal(v)

	Clipboard := CBB
	SetKeyDelay, %KDB%
	SetBatchLines, %BLB%	
}




/*!
	Function: PasteVal(sendTxt)
		Uses the Windows clipboard to insert text at the current
		carat position, avoiding slow usage of the Send command.
		The user's clipboard contents are not changed/lost.
	Parameters:
		sendTxt - Text to insert.
*/
PasteVal(sendTxt)
{
	WinGetClass, wClass, A
	BLBU := A_BatchLines, KDBU := A_KeyDelay, CBBU := Clipboard
	SetKeyDelay, -1
	SetBatchLines, -1
	Clipboard := ""
	sleep 20
	Clipboard := ExpandEnv(sendTxt)
	ClipWait, 1
	If (!ErrorLevel)
	{
		sleep 20
		if (wClass = "ConsoleWindowClass")
		{
			Send, {Blind}!{Space}
			send, {Blind}ep
		}		
		else		
			Send, {Blind}^v
	}
	sleep 150
	Clipboard := CBBU
	SetKeyDelay, %KDBU%
	SetBatchLines, %BLBU%
}



/*!
	Function: GetSelection([CutTxt, NoRestore])
		Returns the current selection.
		
	Returns:
		User's current selection in specified format. The defualt value returned by the function would return a
		string of any highlighted text, if text were highlighted, or a string of file paths, if for example, files
		were selected.
*/
GetSelection()
{
	BLBU := A_BatchLines, KDBU := A_KeyDelay, CBB := Clipboard
	SetKeyDelay, -1
	SetBatchLines, -1
	Clipboard := ""
	sleep 20
	
	Send, {Blind}^c
	ClipWait, 1
	If (ErrorLevel)
		throw "No text selected or copy command timeout."
	
	selTxt := Clipboard
	sleep 100	
	Clipboard := CBB
	SetKeyDelay, %KDBU%
	SetBatchLines, %BLBU%			
	return, sel
}



/*!
	Function: StrUpper(v)
		Converts the given string to upper case
	Parameters:
		v - String to convert
	Returns: The upper-cased string
*/
StrUpper(v)
{
	StringUpper, v, v
	return v
}



/*!
	Function: StrLower(v)
		Converts the given string to lower case
	Parameters:
		v - String to convert
	Returns:
		The lowercased string
*/
StrLower(v)
{
	StringLower, v, v
	return v
}



/*!
	Function: SaveSelection()
		Saves the user's selection in a txt file
*/
SaveSelection()
{
	try Selection := GetSelection()
	catch e
	{
		throw "Failed to get selected text"
	}
	fileselectfile, Path, S 24,, Where should the file be saved?, Text Files (*.txt)
	If (ErrorLevel || Path = "")
	{
		throw "Invalid output file path."
		return
	}
	try
	{
		FileDelete, % Path
		FileAppend, % Selection, % Path
	}
	catch e
	{
		throw "Error occured during " e.what
	}
		
}



/*!
	Function: CopyToNotepad()
		Copies the selected text into a new Notepad window
*/
CopyToNotepad()
{
	try selText := GetSelection()
	catch e 
	{
		msgbox % e
		return
	}
	noteFilePath := A_Temp "\CopyToNotepad.txt"
	noteFileObj := FileOpen(noteFilePath, "w")	
	if (!IsObject(noteFileObj))
	{
		msgbox Failed to create temp text file in user's temp folder...
		return
	}
	noteFileObj.Write(selText)
	noteFileObj.Close()
	try Run, %noteFilePath%	
	catch
	{
		msgbox Failed to run the created text file...
	}
	noteFileObj := ""
}



/*!
	Function: CopyToRun()
		Copies the current selected text into a Run command window.
*/
CopyToRun()
{
	try Selection := GetSelection()
	catch e 
	{
		msgbox % e
		return
	}
	TTM := A_TitleMatchMode
	SetTitleMatchMode, 3
	Send, {Blind}#r
	WinWait, Run,,1.5
	If (ErrorLevel)
	{
		msgbox Unable to open/find Run prompt.
		return
	}
	Send, {Blind}^v
	SetTitleMatchMode, %TTM%
}



/*!
	Function: Volume([dwn])
		Increases or decreases the system volume.
	Parameters:
		dwn - (Optional) If set to 1, volume is DECREASED.
*/
Volume(dwn = 0)
{
	SoundSet, % dwn ? "-5" : "+5"
	SoundGet, curVol
	TrayTip, Volume, % round(curVol), 1
}



/*!
	Function: RMApp_NCHITTEST()
		Determines what part of a window the mouse is currently over.
*/
RMApp_NCHITTEST()
{
	CoordMode, Mouse, Screen
	MouseGetPos, x, y, z
	SendMessage, 0x84, 0, (x&0xFFFF)|(y&0xFFFF)<<16,, ahk_id %z%
	RegExMatch("ERROR TRANSPARENT NOWHERE CLIENT CAPTION SYSMENU SIZE MENU HSCROLL VSCROLL MINBUTTON MAXBUTTON LEFT RIGHT TOP TOPLEFT TOPRIGHT BOTTOM BOTTOMLEFT BOTTOMRIGHT BORDER OBJECT CLOSE HELP", "(?:\w+\s+){" ErrorLevel+2&0xFFFFFFFF "}(?<AREA>\w+\b)", HT)
	Return HTAREA
}



MeasurePixels:
	On := (On = 1) ? 0 : 1
	If On
	{
		MouseGetPos, GetPixX, GetPixY
		SetTimer, GetPixels, 50
	}
	Else
	{
		SetTimer, GetPixels, Off
		ToolTip
	}
return



GetPixels:	
	MouseGetPos, GetPixX2, GetPixY2
	Loop,2
	{
		var := (A_Index = 1) ? "GetPixX" : "GetPixY"
		%var%2 := %var%2 - %var%
		If !%var%2
			dir%var% := ""
		else
			dir%var% := (%var%2 > 0) ? (A_Index = 1 ? "Right" : "Down") : (A_Index = 1 ? "Left" : "Up")
		%var%2 := Abs(%var%2)
	}
	ToolTip, % "X: " GetPixX2 A_Tab dirX "`nY: " GetPixY2 A_Tab dirY
return


TToff:
	settimer, TToff, off
	tooltip
	traytip
return



WM_MOUSEMOVE()
{
	global
	BBU := A_BatchLines
	SetBatchLines, -1
	ErrorLevel := 0
	MouseGetPos,,,, thisHwnd, 2
	MouseGetPos,,, mouseWin, controlname
	WinGetTitle, thisWin, ahk_id %mouseWin%
	ControlGetText, controltext, %controlname%
	
	if (instr(thisWin, "c0bra")) ; all c0bra settings guis have "c0bra" in them
	{
		if !(instr(thisWin, "Main") || instr(thisWin, "SLR"))
			return
	}
	

	; Still In same control --> Do Nothing 
	if (PREV_HWND = thisHwnd)
	{
		SetBatchLines, % BBU
		return
	}
	
	; Button in Bookmarks in selected.. change prevtext to
	; Bookmarks for same color scheme as bookmark button
	if !(thisWin = "c0bra SLR")
	{
		if controlText not in %allButtons%
			controlText := "Bookmarks"
	}
	if !(prevWin = "c0bra SLR")
	{
		if prevText not in %allButtons%
			prevText := "Bookmarks"
	}
	
	; Set previous and current button color schemes for highlighting
	prevBColor := prevWin = "c0bra SLR" ? slrList[PrevText].BackColor : ButtonList[PrevText].BackColor
	prevTColor := prevWin = "c0bra SLR" ? slrList[PrevText].TextColor : ButtonList[PrevText].TextColor

	curHlBColor := thisWin = "c0bra SLR" ? slrList[controlText].HlBackColor : ButtonList[controlText].HlBackColor
	curHlTColor := thisWin = "c0bra SLR" ? slrList[controlText].HlTextColor : ButtonList[controlText].HlTextColor

	; Just entered a non-button control --> switch previous control to 'non-hover' colors
	if (thisHwnd = backsearch || thisHwnd = "" || controlname = "" || thisHwnd = FOOTER || !InStr(controlName, "static"))
	{
		CTLCOLORS.Change(PREV_HWND, prevBColor, prevTColor)
		PREV_HWND := ""
		SetBatchLines, % BBU
		return
	}

	; New button --> change the colors
	CTLCOLORS.Change(PREV_HWND, prevBColor, prevTColor)
	CTLCOLORS.Change(thisHwnd, curHlBColor, curHlTColor)
	
	; Set control text and hwnd for next hover
	PREV_HWND := thisHwnd
	PrevText := controltext
	prevWin := thisWin
	SetBatchLines, % BBU
}



/*!
	Function: ExpandEnv(str)
		Convert all environment variables in str to their values.
	Parameters:
		str - String containing environment variables to be expanded.
	Returns: A string with all environment variables expanded to their values.
*/
ExpandEnv(str) 
{
   VarSetCapacity(dest, 2000)
   DllCall("ExpandEnvironmentStrings", "str", str, "str", dest, int, 1999, "Cdecl int")
   Return dest
}