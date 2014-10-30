
/*!
	Function: Arguments(paramList)
		Searches through a given string for all switch/value pairs. Useful in parsing
		command line parameters for windows CMD-like parameter handling.
	
	Parameters:
		paramList - A string containing potential switch/value pairs.		
	
	Remarks:
		The function will recognize switches and switch/value pairs that use the following
		formatting. See the example below for clarification.
		* Switch identifier characters: dash (-) or slash (/)
		* Switch/value separator characters: colon (:), equal sign (=) or a single space ( )
		* Grouping characters: double-quotes (") or single-quotes (')
	
	Returns:
		Returns an array object containing one item for each switch found. The value of each switch is stored
		in the array using switch's name as the key/index. See the example below for clarification.
		
		**Note:** For any switch that does not have a corresponding value, the value will be stored as 1.
		This allows for verification that a switch was passed using a simple *if* statement.
		
	Example:
		> ; Example CmdLine argument string. Note that the
		> ; "Verify" switch does not have an associated value.
		> argString = -first first-val /second='Second - one' -third:3rd string/value -Verify
		> 
		> ; Retrieve an object containing switch/value info
		> objParams := Arguments(argString)
		> 
		> ; Parse the object and display formatted results
		> for c, v in objParams
		> 	switchValList .= (switchValList ? "`n`t" : "`t") c " = " v
		> 
		> MsgBox, ORIGINAL ARG STRING:`n`t`"%argString%`"`n`nRESULTS:`n%switchValList%
		**Program Output:**
		> ,=================================================================================,
		> |								Output MsgBox										|
		> '================================================================================='
		> |	Original Arg String:															|
		> |	  "-first first-val /second='Second - one' -third:3rd string/value -Verify"		|
		> |																					|
		> |	Results:																		|
		> |	  first  = first-val															|
		> |	  second = Second - one															|
		> |	  third  = 3rd string/value														|
		> |	  Verify = 1																	|
		> '================================================================================='
		> 
*/
Arguments(paramList)
{	;
	; Change all dashes (-) and slashes (/) found within value strings (anywhere not
	; denoting a new switch) to <dash> and <slash>, respectively, to avoid confusion
	;	
	paramList := RegExReplace(paramList, "(?:([^\s])-|(\s+)-(\s+))", "$1$2<dash>$3")
	paramList := RegExReplace(paramList, "(?:([^\s])/|(\s+)/(\s+))", "$1$2<slash>$3")
	
	regex = (?<=[-|/])([a-zA-Z0-9]*)[ |:|=|"|']*([\w|.|@|?|#|$|`%|=|*|,|<|>|^|{|}|\[|\]|;|(|)|_|&|+| |:|!|~|\\]*)["| |']*(.*)
	
	count	:= 0
	options	:= {}
	
	while paramList
	{
		count++
		
		RegExMatch(paramList, regex, data) 
		
		name := data1
		value := data2
		;
		; Change <dash> and <slash> back to - and /
		;
		value := RegExReplace(value , "<dash>", "-")
		value := RegExReplace(value , "<slash>", "/")
				
		if (!value)
			options[name] := 1
		else
			options[name] := value
		
		paramList := data3
	}
	ErrorLevel := count 
	Return options
}


class ArgVals
{
	
}