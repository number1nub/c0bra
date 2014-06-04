

;{ ___ WM_Mousemove
	WM_MOUSEMOVE()
	{
		global
		BBU := A_BatchLines
		SetBatchLines, -1
		ErrorLevel := 0
		MouseGetPos,,,, thisHwnd, 2
		MouseGetPos,,,, controlname
		ControlGetText, controltext, %controlname% 
		WinGetActiveTitle, thisWin
		
		if (thisWin = "c0bra Colors")
			return
		

		; Still In same control --> Do Nothing 
			if (PREV_HWND = thisHwnd)
			{
				SetBatchLines, % BBU
				return
			}
		
		; Button in Bookmarks in selected.. change prevtext to Bookmarks for same color scheme as bookmark button
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
	
;}
	
	
;{ ___ JSON Button add
	addButton(aText, CMD, typeCmd, argsCmd, aColor, Children, aParent)
	{
		global buttons, buttonSettings
		
		buttonKey := buttons.maxindex() + 1

		buttons[buttonKey] := {}
		buttons[buttonKey].Text := aText
		
		if (CMD)
		{
			buttons[buttonKey].Cmd := {}
			buttons[buttonKey].Cmd.Type := typeCmd
			buttons[buttonKey].Cmd.Arg := argsCmd
		}
		
		buttons[buttonKey].BackColor := aColor[1]
		buttons[buttonKey].TextColor := aColor[2]
		buttons[buttonKey].HlBackColor := aColor[3]
		buttons[buttonKey].HlTextColor := aColor[4]
		
		if (Children)
			buttons[buttonKey].Children := []
			
		if (aParent)
		{
			buttons[buttonKey].Level := 1
			
			for parentKey, value in buttons
			{
				if (value.text = aParent)
					buttons[parentKey].Children.Insert(aText)
			}
		}
		
		JSON_Save(buttons, buttonSettings)
	}

;}


;{ ___ JSON Button delete
	deleteButton(aText)
	{
		global buttons, buttonSettings
		
		;TODO: delete children of button deleted		
		
		; Remove button
		for key, value in buttons
		{		
			if (value.Text = aText)
			{
				if (value.Children[1])
				{
					MsgBox, You must delete all children before deleting this button.
					return
				}
			
				buttons[key] := {}
				buttons.Remove(key)
			}
		}
		
		; Remove button from Parent
		for key, value in buttons
		{
			for childKey, childValue in value.Children
				if (childValue = aText)
					value.Children.Remove(childKey)		
		}		
		
		JSON_Save(buttons, buttonSettings)
	}
	
;}


;{ ___ SUPER SHORTCUT
; _______________

	superShorts:
		command := Settings.userHotkeys[A_ThisHotkey]
		execute(command, Txt)
	return

;}


;{ ___ Button Duplicate Check
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
	
;}


;{ ___ RELOAD ME
	reloadMe:	
		Reload	
	return
	
	
	editMe:
		run, edit %COBRA%\c0bra.ahk
	return
	
;}
	
	


;{===== Tray Menu Handler ====>>>

TrayText:
		
	;{```` Change Main Hotkey ````}
	if (A_ThisMenuItem = "Trigger: " mainHotkey)
	{
		InputBox, newTrigger, c0bra Trigger, Enter new c0bra trigger hotkey(s)`nCurrent Hotkey - %mainHotkey%`nExample 1 - ^!1`nExample 2 - ^#1,,,,,,,, % mainHotkey
		if ErrorLevel
			return		
		Settings.mainHotkey.mainHotkey := newTrigger
		JSON_Save(Settings, c0braSettings)
		Run, %cobraPath% %A_ScriptHwnd% /prompt "Main Hotkey Changed" %newTrigger%
	}

	;{```` Add new user hotkey ````}
	else if (A_ThisMenuItem = "Add New Hotkey")
	{
		InputBox, newTrigger, New Hotkey, Hotkey trigger:
		If (ErrorLevel || !newTrigger)
			return
		InputBox, newAction, New Hotkey, % "Hotkey action:`n(use either [F], [L], [R] or [P])"
		If (ErrorLevel || !newAction)
			return
		
		Settings.userHotkeys[newTrigger] := newAction
		JSON_Save(Settings, c0braSettings)
		Run, % A_ScriptFullPath " " A_ScriptHwnd " /prompt ""Added Hotkey <" modReplace(newTrigger) ">"" ""`nACTION:`n" newAction "`n """
	}
	;
	; Edit/Delete existing hotkey
	;
	else if (RegExMatch(A_ThisMenuItem, "i)^<(?P<Trigger>.+?)> - <(?P<Action>.+)>$", hk))
	{
		InputBox, newTrigger, Edit Hotkey, % "Hotkey trigger:`n`n(To DELETE hotkey, input blank value)",,400,175,,,,, % hkTrigger
		If (ErrorLevel)
			return		
		if (!newTrigger)
		{
			Settings.userHotkeys.Remove(hkTrigger)
			JSON_Save(Settings, c0braSettings)
			Run, % A_ScriptFullPath " " A_ScriptHwnd " /prompt ""Deleted Hotkey <" modReplace(hkTrigger) ">"" ."
		}
		InputBox, newAction, Edit Hotkey, % "Hotkey action:",,600,160,,,,, % hkAction
		If (ErrorLevel || !newAction)
			return
		Settings.userHotkeys.Remove(hkTrigger)
		Settings.userHotkeys[newTrigger] := newAction
		JSON_Save(Settings, c0braSettings)
		Run, % A_ScriptFullPath " " A_ScriptHwnd " /prompt ""Updated Hotkey <" modReplace(hkTrigger) ">"" ""`nUPDATED TRIGGER: <" modReplace(newTrigger) ">`n`nUPDATED ACTION:`n" newAction "`n `n"""
	}
return

;}<<<==== Tray Menu Handler =====



modReplace(str)
{
	StringReplace, v, str, +, Shift+
	StringReplace, v, v, ^, Ctrl+
	StringReplace, v, v, !, Alt+	
	StringReplace, v, v, #, Win+
	return v
}



;{ ___ Determine if mouse position is on left or right of gui midpoint
	ON_LEFT(CONTROL_POSX)
	{
		global
		
		MIDPOINT := ((2 * buttonWidth) + (3 * buttonSpacing)) / 2
		
		if (CONTROL_POSX < MIDPOINT)
			return 1
		else
			return 0
	}
	
;}


;{ ___ Google Search
	Google(GSEARCH)
	{
		GSEARCH := RegExReplace(GSEARCH, "i)\s", "+")
		GSEARCH := "http://www.google.com/search?hl=en&source=hp&q=" GSEARCH "&aq=f&aqi=&aql=&oq="
		Run chrome.exe %GSEARCH%
	}

;}



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
	



ColorPicker(attribute)
{	
	MsgBox, 4096, c0bra Colors, Choose the %attribute% color.
	
	theColor := RegExReplace(ColorChooser(), "i)0x")
	if !(theColor)
		return

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

	if !(theColor)
		return

	SetFormat, integer, d
	return % theColor
}
	


GET_COLOR(command, REG_COLOR)
{
	Array := Object()

	command := RegExReplace(command, "\s+", " ")
	RegExMatch(command, ";\K.+?$", Description)
	command := RegExReplace(command, ";" Description "$")
	command := Trimmer((Description && ReturnDescription) ? Description : command)
	
	RegExMatch(command, "^\[.+\]\s*\{\K(.+),(.+),(.+),(.+)\}", THE_COLOR)
	
	If (REG_COLOR)
	{
		Array.Insert(THE_COLOR1)
		Array.Insert(THE_COLOR3)
	} 
	else 
	{
		Array.Insert(THE_COLOR2)
		Array.Insert(THE_COLOR4)
	}
	
	return Array
}
	



Execute(command, Txt)
{
	If (!command)
		return
	;
	; Remove duplicate spaces
	;
	command := RegExReplace(command, "\s+", " ")
	;
	; Get command description from in-line comment if one
	; exists, and remove the description from the command string
	;
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
			
			%mFunc%(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)
			Gui, 1:Destroy
		}
	
	;~~~~~~~~~~~~~~~~~~~
	;[L] LABEL AS ACTION
	
		Else If (RegExMatch(command, "i)^\[L\]\s\K.+", Label) && IsLabel(Label))
		{
			Gui, 1:Destroy
			Gosub, %LABEL%
		}
		
		
	; [R] Run as Action
	
		Else if RegExMatch(command, "i)^\[R\]\s\K.+", runPath)
		{
			Gui, 1:Destroy
			Run, % runPath,, UseErrorLevel
			If ErrorLevel
				MsgBox, 262160, Run :, Error with this command!`n%Path%, 1
		}
		
			
	;~~~~~~~~~~~~~~~~~~~~~
	;[P] PROGRAM AS ACTION
	
		else if RegExMatch(command, "i)^\[P\]\s\K.+", theProgram)
		{
			Gui, 1:Destroy
			SetTitleMatchMode, 2
			SplitPath, theProgram, programName,,,programNameNoExt
				
			Process, Exist, % programName ".exe"
			if !ErrorLevel
				Process, Exist, % programName " *32.exe"

			If (WinExist(programNameNoExt) || ErrorLevel)
			{
				WinShow, %programNameNoExt% ahk_pid %ErrorLevel%
				WinActivate, %programNameNoExt% ahk_pid %ErrorLevel%
				WinRestore, %programNameNoExt% ahk_pid %ErrorLevel%
			}
			else
				Run % theProgram

			SetTitleMatchMode, 1
		}
			
			
	;~~~~~~~~~~~~~~~~~~~~~~
	; SIDE GUI AS ACTION
		
		else
			SIDE_GUI()
}




;{ ___ Trimmer
	Trimmer(str, omitchars=" `t")
	{ ; Allow to use Trim() with AutoHotkey basic
		If !StrLen(omitchars)
			Return, str
		str := RegExReplace(str, "^[" omitchars "]+") ; Trims from the beginning
		str := RegExReplace(str, "[" omitchars "]+$")	; Trims from the end
		Return, str
	}
	
;}


;{ ___ theCloser
	theCloser:
		mousegetpos,,, win
		WinGetTitle, winTitle, ahk_id %win%
		WinGetClass, winClass, ahk_id %win%
		
		if winTitle contains %closeTabWinList%
			Send, {Blind}^{F4}
		else if winClass contains %closeTabWinList%
			Send, {Blind}^{F4}
		else
			WinClose, ahk_id %win%
	return

;}
	
	

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
		origStr - (Optional) String to be converted. If blank or omitted, the currently selected text
				will be converted and replaced.
*/
ToggleCase(toCase = "U", origStr = "")
{
	if (!origStr)
	{
		replaceSel := 1
		try origStr := GetSelection(1)
		catch e
		{
			ToolTip, % "Toggle Case Error:`n`n" e
			SetTimer, TTOff, 1000
			return
		}
	}
	
	if (toCase = "L")
		StringLower, v, origStr
	else if (toCase = "T")
		StringUpper, v, origStr, T
	else if (toCase = "U")
		StringUpper, v, origStr
	else
		throw "Invalid value for toCase parameter """ toCase """.`n`nShould be either 'U', 'L' or 'T'."
	
	if (replaceSel)
	{
		CBB := Clipboard
		Clipboard := ""
		Clipboard := v
		sleep 50
		send, {Blind}^v
		return
	}
	return v
}




;{___ CopyTo
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
	
;}


/*!
	Function: GetSelection([CutTxt, NoRestore])
		Returns the current selection. Optionally deletes the selection.

	Parameters:
		CutTxt - (Optional) Flag indicating that selected text should be cut rather than copied. Default action
				is to copy text.
		NoRestore - (Optional) Flag indicating that the original clipboard contents should not be restored.
				
	Returns:
		User's current selection in specified format. The defualt value returned by the function would return a
		string of any highlighted text, if text were highlighted, or a string of file paths, if for example, files
		were selected.
*/
GetSelection(CutTxt=0, NoRestore=0)
{
	CBB := Clipboard
	Clipboard := ""
	sleep 50
	Send, % (CutTxt ? "{Blind}^x" : "{Blind}^c")
	ClipWait, 1
	If (ErrorLevel)
		throw "No text selected or copy command timeout."
		
	Selection := PlainText ? ClipboardAll : Clipboard
	Clipboard := NoRestore ? cbb : Clipboard
			
	return, Selection
}



;{ ___ StrUpper
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
	
;}


;{ ___ StrLower
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

;}


;{ ___ Save Selection
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

;}


;{ ___ Copy to notepad
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

;}


;{ ___ Copy to run
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

;}


;{ ___ Get SciTEpath
	/*!
		Function: GetSciTEpath()
			Returns the full path to SciTE on the current machine.
		Returns:
			Returns the full path to the SciTE4AutoHotkey executable (if found).
			If SciTE isn't found then an empty string is returned.
	*/
	GetSciTEpath()
	{
		ahkDir := Trim(RegExReplace(Trim(A_AhkPath), "i)\\AutoHotkey.exe$"))
		SciTEdir := ""
		Loop, %ahkDir%\*, 1
		{
			if instr(A_LoopFileName, "SciTE")
			{
				FileGetAttrib, attribs, %A_LoopFileFullPath%
				if instr(attribs, "D")
				{
					SciTEdir := A_LoopFileFullPath
					break
				}
			}
		}
		if !(SciTEdir)
			return
		loop, %SciTEdir%\*
			if (instr(A_LoopFileName, "SciTE") && (A_LoopFileExt = "exe"))
				return A_LoopFileFullPath
		return
	}
	
;}


;{___ runner

	;~ runner(THE_WINDOW)
	;~ {
		;~ SetTitleMatchMode, 2
		;~ Process, Exist, % THE_WINDOW ".exe"
		;~ If (WinExist(THE_WINDOW) || ErrorLevel != 0)
		;~ {
			;~ WinShow, %THE_WINDOW% ahk_pid %ErrorLevel%
			;~ WinActivate, %THE_WINDOW% ahk_pid %ErrorLevel%
			;~ WinRestore, %THE_WINDOW% ahk_pid %ErrorLevel%
		;~ }
		;~ else
			;~ Run % THE_WINDOW
		;~ SetTitleMatchMode, 1
	;~ }

;}


;{___ activeOpen

	;~ activeOpen(ACTIVE_WIN, OPEN_FILE)
	;~ {
		;~ TMMbu := A_TitleMatchMode
		;~ SetTitleMatchMode, 2
		;~ IfWinActive, %ACTIVE_WIN%
			;~ Run, % OPEN_FILE
		;~ else
			;~ send, {%A_ThisHotkey%
		;~ SetTitleMatchMode, % TMMbu
	;~ }
	
;}



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