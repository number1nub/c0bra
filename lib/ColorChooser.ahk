
ColorChooser()
{

	SizeOfStructForChooseColor = 0x24 
	VarSetCapacity(StructForChooseColor, SizeOfStructForChooseColor, 0) 
	VarSetCapacity(StructArrayForChooseColor, 64, 0) 

	InsertInteger(SizeOfStructForChooseColor, StructForChooseColor, 0)  ; DWORD lStructSize 
	InsertInteger(GuiHWND, StructForChooseColor, 4)  ; HWND hwndOwner (makes dialog "modal"). 
	InsertInteger(0x0 ,    StructForChooseColor, 8)  ; HINSTANCE hInstance 
	InsertInteger(0x0 ,    StructForChooseColor, 12)  ; clr.rgbResult =  0;
	InsertInteger(&StructArrayForChooseColor , StructForChooseColor, 16)  ; COLORREF *lpCustColors
	InsertInteger(0x00000100 , StructForChooseColor, 20)  ; Flag: Anycolor
	InsertInteger(0x0 ,    StructForChooseColor, 24)  ; LPARAM lCustData
	InsertInteger(0x0 ,    StructForChooseColor, 28)  ; LPCCHOOKPROC lpfnHook
	InsertInteger(0x0 ,    StructForChooseColor, 32)  ; LPCTSTR lpTemplateName
	
	nRC := DllCall("comdlg32\ChooseColorA", str, StructForChooseColor)  ; Display the dialog.
	if (errorlevel <> 0) || (nRC = 0)
	{
		;~ MsgBox error while calling ChooseColor Errorlevel: %errorlevel% - RC: %nRC%
		return
	}

	; Otherwise, the user pressed OK in the dialog, so determine what was selected. 
	SetFormat, integer, hex  ; Show RGB color extracted below in hex format.
	return % BGRtoRGB(ExtractInteger(StructForChooseColor, 12)) 
	SetFormat, integer, d 
}



ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4) 
; See DllCall documentation for details. 
{ 
   SourceAddress := &pSource + pOffset  ; Get address and apply the caller's offset. 
   result := 0  ; Init prior to accumulation in the loop. 
   Loop %pSize%  ; For each byte in the integer: 
   { 
      result := result | (*SourceAddress << 8 * (A_Index - 1))  ; Build the integer from its bytes. 
      SourceAddress += 1  ; Move on to the next byte. 
   } 
   if (!pIsSigned OR pSize > 4 OR result < 0x80000000) 
      return result  ; Signed vs. unsigned doesn't matter in these cases. 
   ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart: 
   return -(0xFFFFFFFF - result + 1) 
} 

InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4) 
; To preserve any existing contents in pDest, only pSize number of bytes starting at 
; pOffset are altered in it. The caller must ensure that pDest has sufficient capacity. 
{ 
   mask := 0xFF  ; This serves to isolate each byte, one by one. 
   Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data. 
   { 
      DllCall("RtlFillMemory", UInt, &pDest + pOffset + A_Index - 1, UInt, 1  ; Write one byte. 
         , UChar, (pInteger & mask) >> 8 * (A_Index - 1))  ; This line is auto-merged with above at load-time. 
      mask := mask << 8  ; Set it up for isolation of the next byte. 
   } 
} 

BGRtoRGB(oldValue)
{
  Value := (oldValue & 0x00ff00)
  Value += ((oldValue & 0xff0000) >> 16)
  Value += ((oldValue & 0x0000ff) << 16)  
  return Value
}
