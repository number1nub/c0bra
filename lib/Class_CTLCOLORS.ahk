; ======================================================================================================================
; AHK 1.1 +
; ======================================================================================================================
; Function:          Helper object to color controls on WM_CTLCOLOR... notifications.
;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;                    Checkboxes and Radios accept background colors only due to design.
; AHK version:       1.1.05.00 (U32)
; Language:          English
; Tested on:         Win XPSP3, Win VistaSP2 (32 Bit)
; Version:           0.9.01.00/2012-04-05/just me
;
; How to use:        To register a control for coloring call
;                       CTLCOLORS.Attach()
;                    passing up to three parameters:
;                       Hwnd        - Hwnd of the GUI control                                   (Integer)
;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
;                                     or "" for default color
;                       ------------- Optional -------------------------------------------------------------------------
;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
;                                     or "" for default color
;                    If both BkColor and TextColor are "" the control will not be added and the call returns False.
;
;                    To change the colors for a registered control call
;                       CTLCOLORS.Change()
;                    passing up to three parameters:
;                       Hwnd        - see above
;                       BkColor     - see above
;                       ------------- Optional -------------------------------------------------------------------------
;                       TextColor   - see above
;                    Both BkColor and TextColor may be "" to reset them to default colors.
;                    If the control is not registered yet, CTLCOLORS.Attach() is called internally.
;
;                    To unregister a control from coloring call
;                       CTLCOLORS.Detach()
;                    passing one parameter:
;                       Hwnd      - see above
;
;                    To stop all coloring and free the resources call
;                       CTLCOLORS.Free()
;                    It's a good idea to insert this call into the scripts exit-routine.
;
;                    To check if a control is already registered call
;                       CTLCOLORS.IsAttached()
;                    passing one parameter:
;                       Hwnd      - see above
;
;                    To get a control's Hwnd use either the option "HwndOutputVar" with "Gui, Add" or the command
;                    "GuiControlGet" with sub-command "Hwnd".
;
;                    Names of "private" properties/methods/functions are prefixed with underscores, they must not be
;                    set/called by the script!
;
; Special features:  On the first call for a specific control class the function registers the _CTLCOLORS_OnMessage()
;                    function as message handler for WM_CTLCOLOR messages of this class(es).
;
;                    Buttons (Checkboxes and Radios) do not make use of the TextColor to draw the text, instead of
;                    that they use it to draw the focus rectangle.
;
;                    After displaying the GUI per "Gui, Show" you have to execute "WinSet, Redraw" once.
;                    It's no bad idea to do it using a GuiSize label, because it avoids rare problems when restoring 
;                    a minimized window:
;                       GuiSize:
;                          If (A_EventInfo != 1) {
;                             Gui, %A_Gui%:+LastFound
;                             WinSet, ReDraw
;                          }
;                       Return
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class CTLCOLORS {
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PRIVATE Properties and Methods ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; Registered Controls
   Static _Controls := {}
   ; OnMessage Handlers
   Static _OnMessage := {Edit: 0, ListBox: 0, Static: 0}
   ; Message Handler Function
   Static _MessageHandler := "_CTLCOLORS_OnMessage"
   ; Windows Messages
   Static _WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
   ; HTML Colors (BGR)
   Static _HTML := {AQUA:    0xFFFF00, BLACK:   0x000000, BLUE:    0xFF0000, FUCHSIA: 0xFF00FF, GRAY:    0x808080
                  , GREEN:   0x008000, LIME:    0x00FF00, MAROON:  0x000080, NAVY:    0x800000, OLIVE:   0x008080
                  , PURPLE:  0x800080, RED:     0x0000FF, SILVER:  0xC0C0C0, TEAL:    0x808000, WHITE:   0xFFFFFF
                  , YELLOW:  0x00FFFF}
   ; System Colors
   Static _SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
   ; ===================================================================================================================
   ; This class is only a helper object, you must not instantiate it.
   ; ===================================================================================================================
   __New() {
      Return False
   }
   __Delete() {
      This.Free()
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD _CheckColors       - Check parameters BkColor and TextColor not to be empty both
   ; ===================================================================================================================
   _CheckColors(BkColor, TextColor) {
      This.ErrorMsg := ""
      If (BkColor = "") && (TextColor = "") {
         This.ErrorMsg := "Both parameters BkColor and TextColor are empty!"
         Return False
      }
      Return True
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD _CheckBkColor      - Check parameter BkColor
   ; ===================================================================================================================
   _CheckBkColor(ByRef BkColor, Class) {
      This.ErrorMsg := ""
      If (BkColor != "") && !This._HTML.HasKey(BkColor) && !RegExMatch(BkColor, "i)^[0-9A-F]{6}$") {
         This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
         Return False
      }
      BkColor := BkColor = "" ? This._SYSCOLORS[Class]
               : This._HTML.HasKey(BkColor) ? This._HTML[BkColor]
               : "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; PRIVATE METHOD _CheckTextColor    - Check parameter TextColor
   ; ===================================================================================================================
   _CheckTextColor(ByRef TextColor) {
      This.ErrorMsg := ""
      If (TextColor != "") && !This._HTML.HasKey(TextColor) && !RegExMatch(TextColor, "i)^[\dA-F]{6}$") {
         This.ErrorMsg := "Invalid parameter TextColor: " . TextColor
         Return False
      }
      TextColor := TextColor = "" ? ""
                 : This._HTML.HasKey(TextColor) ? This._HTML[TextColor]
                 : "0x" . SubStr(TextColor, 5, 2) . SubStr(TextColor, 3, 2) . SubStr(TextColor, 1, 2)
      Return True
   }
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; PUBLIC Interface ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; Error message in case of errors
   Static ErrorMsg := ""
   ; ===================================================================================================================
   ; METHOD Attach         Register control for coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ;                       ------------- Optional ----------------------------------------------------------------------
   ;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Attach(Hwnd, BkColor, TextColor = "") {
      ; Names of supported classes
      Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
      ; Button styles
      Static BS_CHECKBOX := 0x2
           , BS_RADIOBUTTON := 0x8
      ; Editstyles
      Static ES_READONLY := 0x800
      ; Default class background colors
      Static COLOR_3DFACE := 15
           , COLOR_WINDOW := 5
      ; Initialize default background colors on first call -------------------------------------------------------------
      If (This._SYSCOLORS.Edit = "") {
         This._SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE)
         This._SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW)
         This._SYSCOLORS.ListBox := This._SYSCOLORS.Edit
      }
      ; Check Hwnd -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      If !(CtrlHwnd := Hwnd + 0)
      Or !DllCall("User32.dll\IsWindow", "UPtr", Hwnd) {
         This.ErrorMsg := "Invalid parameter Hwnd: " . Hwnd
         Return False
      }
      If This._Controls.HasKey(Hwnd) {
         This.ErrorMsg := "Control " . Hwnd . " is already registered!"
         Return False
      }
      Hwnds := [CtrlHwnd]
      ; Check control's class ------------------------------------------------------------------------------------------
      Classes := ""
      WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
      This.ErrorMsg := "Unsupported control class: " . CtrlClass
      If !ClassNames.HasKey(CtrlClass)
         Return False
      ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
      If (CtrlClass = "Edit") {
         If (CtrlStyle & ES_READONLY)
            Classes := ["Static"]
      }
      If (CtrlClass = "Button") {
         IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
            Classes := ["Static"]
         Else
            Return False
      }
      If (CtrlClass = "ComboBox") {
         VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
         NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
         DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
         Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2)) + 0)
         Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize) + 0)
         Classes := ["Edit", "ListBox"]
      }
      If !IsObject(Classes)
         Classes := [CtrlClass]
      ; Check colors ---------------------------------------------------------------------------------------------------
      If !This._CheckColors(BkColor, TextColor)
         Return False
      ; Check background color -----------------------------------------------------------------------------------------
      If !This._CheckBkColor(BkColor, Classes[1])
         Return False
      ; Check text color -----------------------------------------------------------------------------------------------
      If !This._CheckTextColor(TextColor)
         Return False
      ; Activate message handling on the first call for a class --------------------------------------------------------
      For I, V In Classes {
         If (This._OnMessage[V] = 0)
            OnMessage(This._WM_CTLCOLOR[V], This._MessageHandler)
         This._OnMessage[V] += 1
      }
      ; Store values for Hwnd ------------------------------------------------------------------------------------------
      Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor)
      For I, V In Hwnds
         This._Controls[V] := {Brush: Brush, TextColor: TextColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
      ; Redraw control -------------------------------------------------------------------------------------------------
      DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
      This.ErrorMsg := ""
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Change         Change control colors
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ;                       BkColor     - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ;                       ------------- Optional ----------------------------------------------------------------------
   ;                       TextColor   - HTML color name, 6-digit hex value ("RRGGBB")             (String)
   ;                                     or "" for default color
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; Remarks:              If the control isn't registered yet, METHOD Add() is called instead internally.
   ; ===================================================================================================================
   Change(Hwnd, BkColor, TextColor = "") {
      ; Check Hwnd -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      Hwnd += 0
      If !This._Controls.HasKey(Hwnd)
         Return This.Attach(Hwnd, BkColor, TextColor)
      CTL := This._Controls[Hwnd]
      ; Check Colors ---------------------------------------------------------------------------------------------------
;       If !This._CheckColors(BkColor, TextColor)
;          Return False
      ; Check BkColor --------------------------------------------------------------------------------------------------
      If !This._CheckBkColor(BkColor, CTL.Classes[1])
         Return False
      ; Check TextColor ------------------------------------------------------------------------------------------------
      If !This._CheckTextColor(TextColor)
         Return False
      ; Store Colors ---------------------------------------------------------------------------------------------------
      If (BkColor <> CTL.BkColor) {
         If (CTL.Brush) {
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
            This._Controls[Hwnd].Brush := 0
         }
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor)
         This._Controls[Hwnd].Brush := Brush       
         This._Controls[Hwnd].BkColor := BkColor
      }
      This._Controls[Hwnd].TextColor := TextColor
      This.ErrorMsg := ""
      DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
      Return True
   }
   ; ===================================================================================================================
   ; METHOD Detach         Stop control coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ; Return values:        On success  - True
   ;                       On failure  - False, CTLCOLORS.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Detach(Hwnd) {
      This.ErrorMsg := ""
      Hwnd += 0
      If This._Controls.HasKey(Hwnd) {
         CTL := This._Controls[Hwnd].Clone()
         If (CTL.Brush)
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
         For I, V In CTL.Classes {
            If This._OnMessage[V] > 0 {
               This._OnMessage[V] -= 1
               If This._OnMessage[V] = 0
                  OnMessage(This._WM_CTLCOLOR[V], "")
         }  }
         For I, V In CTL.Hwnds
            This._Controls.Remove(V, "")
         DllCall("User32.dll\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
         CTL := ""
         Return True
      }
      This.ErrorMsg := "Control " . Hwnd . " is not registered!"
      Return False
   }
   ; ===================================================================================================================
   ; METHOD Free           Stop coloring for all controls and free resources
   ; Return values:        Always True
   ; ===================================================================================================================
   Free() {
      For K, V In This._Controls
         DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
      For K, V In This._OnMessage
         If (V > 0) {
            OnMessage(This._WM_CTLCOLOR[K], "")
            This._OnMessage[K] := 0
         }
      This._Controls := {}
      Return True
   }
   ; ===================================================================================================================
   ; METHOD IsAttached     Check if the control is registered for coloring
   ; Parameters:           Hwnd        - HWND of the GUI control                                   (Integer)
   ; Return values:        On success  - True
   ;                       On failure  - False
   ; ===================================================================================================================
   IsAttached(Hwnd) {
      Return This._Controls.HasKey(Hwnd)
   }
}
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; PRIVATE Functions ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ======================================================================================================================
; PRIVATE FUNCTION _CTLCOLORS_OnMessage
; This function is destined for self-acting on CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
_CTLCOLORS_OnMessage(wParam, lParam) {
   Global CTLCOLORS
   Static SetTextColor := 0, SetBkColor := 0
   Critical
   If (SetTextColor = 0) {
      HM := DllCall("Kernel32.dll\GetModuleHandle", "Str", "Gdi32.dll")
      SetTextColor := DllCall("Kernel32.dll\GetProcAddress", "Ptr", HM, "AStr", "SetTextColor")
      SetBkColor := DllCall("Kernel32.dll\GetProcAddress", "Ptr", HM, "AStr", "SetBkColor")
   }
   Hwnd := lParam + 0, HDC := wParam + 0
   If CTLCOLORS.IsAttached(Hwnd) {
      CTL := CTLCOLORS._Controls[Hwnd]
      If (CTL.TextColor != "")
         DllCall(SetTextColor, "Ptr", HDC, "UInt", CTL.TextColor)
      DllCall(SetBkColor, "Ptr", HDC, "UInt", CTL.BkColor)
      Return CTL.Brush
   }
}
