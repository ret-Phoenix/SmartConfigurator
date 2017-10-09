   Menu, Tray, Icon, Shell32.dll, 45

   Height := 165  ; высота клиентской области, не включая заголовки вкладок

   Gui, +AlwaysOnTop -DPIScale
   Gui, Color, DAD6CA
   Gui, Add, Tab2, vTab gTab x0 y0 w200 h185 AltSubmit hwndhTab, Получить код|Клавиша по коду
   Tab = 2
   VarSetCapacity(RECT, 16)
   SendMessage, TCM_GETITEMRECT := 0x130A, 1, &RECT,, ahk_id %hTab%
   TabH := NumGet(RECT, 12, "UInt")
   GuiControl, Move, Tab, % "x0 y0 w200 h" TabH + Height
   Gui, Add, Text, % "x8 y" TabH + 8 " w183 +" SS_GRAYFRAME := 0x8 " h" Height - 16

   Gui, Font, q5 s12, Verdana
   Gui, Add, Text, vAction x15 yp+7 w170 Center c0033BB, Нажмите клавишу
   Gui, Add, Text, vKey xp yp+35 wp Center Hidden

   Gui, Font, q5 c333333
   Gui, Add, Text, vTextVK xp+8 yp+37 Hidden, vk =
   Gui, Add, Text, vVK xp+35 yp w62 h23 Center Hidden
   Gui, Add, Text, vTextSC xp-35 yp+35 Hidden, sc =
   Gui, Add, Text, vSC xp+35 yp w62 h23 Center Hidden

   Gui, Font, s8
   Gui, Add, Button, vCopyVK gCopy xp+70 yp-35 w50 h22 Hidden, Copy
   Gui, Add, Button, vCopySC gCopy xp yp+33 wp hp Hidden, Copy

   Gui, Tab, 2
   Gui, Add, Text, % "x8 y" TabH + 8 " w183 +" SS_GRAYFRAME " h" Height - 16
   Gui, Add, Text, x15 yp+7 w170 c0033BB
      , Введите код`nв шестнадцатеричном формате без префикса "0x"

   Gui, Font, q5 s11
   Gui, Add, Text, xp yp+58, vk
   Gui, Add, Edit, vEditVK gGetKey xp+25 yp-2 w45 h23 Limit2 Uppercase Center
   Gui, Add, Text, vKeyVK xp+45 yp+2 w105 Center

   Gui, Add, Text, x15 yp+43, sc
   Gui, Add, Edit, vEditSC gGetKey xp+25 yp-2 w45 h23 Limit3 Uppercase Center
   Gui, Add, Text, vKeySC xp+45 yp+2 w105 Center
   Gui, Show, % "w199 h" TabH + Height - 1, Коды клавиш

   hHookKeybd := SetWindowsHookEx()
   OnExit, Exit
   OnMessage(0x6, "WM_ACTIVATE")
   OnMessage(0x102, "WM_CHAR")
   Return

Tab:
   If (Tab = 2 && !hHookKeybd)
      hHookKeybd := SetWindowsHookEx()
   Else if (Tab = 1 && hHookKeybd)
      DllCall("UnhookWindowsHookEx", UInt, hHookKeybd), hHookKeybd := ""
   Return

Copy:
   GuiControlGet, Code,, % SubStr(A_GuiControl, -1)
   StringLower, GuiControl, A_GuiControl
   Clipboard := SubStr(GuiControl, -1) . SubStr(Code, 3)
   Return

GetKey:
   GuiControlGet, Code,, % A_GuiControl
   tipe := SubStr(A_GuiControl, -1)
   Key := GetKeyName(tipe . Code)
   GuiControl,, % "Key" . tipe, % Key
   Return

GuiClose:
   ExitApp

Exit:
   if hHookKeybd
      DllCall("UnhookWindowsHookEx", Ptr, hHookKeybd)
   ExitApp

WM_ACTIVATE(wp)
{
   global
   if (wp & 0xFFFF = 0 && hHookKeybd)
      DllCall("UnhookWindowsHookEx", UInt, hHookKeybd), hHookKeybd := ""
   if (wp & 0xFFFF && Tab = 2 && !hHookKeybd)
      hHookKeybd := SetWindowsHookEx()
   GuiControl,, Action, % wp & 0xFFFF = 0 ? "Активируйте окно" : "Нажмите клавишу"
}

SetWindowsHookEx()
{
   Return DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
            , Int, WH_KEYBOARD_LL := 13
            , Ptr, RegisterCallback("LowLevelKeyboardProc", "Fast")
            , Ptr, DllCall("GetModuleHandle", UInt, 0, Ptr)
            , UInt, 0, Ptr)
}

LowLevelKeyboardProc(nCode, wParam, lParam)
{
   static once, WM_KEYDOWN = 0x100, WM_SYSKEYDOWN = 0x104

   Critical
   SetFormat, IntegerFast, H
   vk := NumGet(lParam+0, "UInt")
   Extended := NumGet(lParam+0, 8, "UInt") & 1
   sc := (Extended<<8)|NumGet(lParam+0, 4, "UInt")
   Key := GetKeyName("vk" SubStr(vk, 3) " sc" SubStr(sc, 3))

   if (wParam = WM_SYSKEYDOWN || wParam = WM_KEYDOWN)
   {
      GuiControl,, Key, % Key
      GuiControl,, VK, % vk
      GuiControl,, SC, % sc
   }

   if !once
   {
      Controls := "Key|TextVK|VK|TextSC|SC|CopyVK|CopySC"
      Loop, parse, Controls, |
         GuiControl, Show, % A_LoopField
      once = 1
   }

   if Key Contains Control,Alt,Shift,Tab
      Return CallNextHookEx(nCode, wParam, lParam)

   if (Key = "F4" && GetKeyState("Alt", "P"))  ; закрытие окна и выход по Alt + F4
      Return CallNextHookEx(nCode, wParam, lParam)

   Return nCode < 0 ? CallNextHookEx(nCode, wParam, lParam) : 1
}

CallNextHookEx(nCode, wp, lp)
{
   Return DllCall("CallNextHookEx", Ptr, 0, Int, nCode, UInt, wp, UInt, lp)
}

WM_CHAR(wp)
{
   global hBall
   SetWinDelay, 0
   CoordMode, Caret
   WinClose, ahk_id %hBall%
   GuiControlGet, Focus, Focus
   if !InStr(Focus, "Edit")
      Return

   if wp in 3,8,24,26   ; обработка Ctrl + C, BackSpace, Ctrl + X, Ctrl + Z
      Return

   if wp = 22   ; обработка Ctrl + V
   {
      GuiControlGet, Content,, % Focus
      if !StrLen(String := SubStr(Clipboard, 1, 3 - StrLen(Content)))
      {
         ShowBall("Буфер обмена не содержит текста.", "Ошибка!")
         Return 0
      }
      Loop, parse, String
      {
         Text .= A_LoopField
         if A_LoopField not in 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,A,B,C,D,E,F
         {
            ShowBall("Буфер обмена содержит недопустимые символы."
               . "`nДопустимые символы:`n0123456789ABCDEF", "Ошибка!")
            Return 0
         }
      }
      Control, EditPaste, % Text, % Focus, Коды клавиш
      Return 0
   }

   Char := Chr(wp)
   if Char not in 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,A,B,C,D,E,F
   {
      ShowBall("Допустимые символы:`n0123456789ABCDEF", Char " — недопустимый символ")
      Return 0
   }
   Return
}

ShowBall(Text, Title="")
{
   global
   WinClose, ahk_id %hBall%
   hBall := TrackToolTip(Text, A_CaretX+1, A_CaretY+15, Title)
   SetTimer, BallDestroy, -2000
   Return

BallDestroy:
   WinClose, ahk_id %hBall%
   Return
}

TrackToolTip( sText
            , x = ""   ; если не указаны, то вблизи курсора
            , y = ""
            , sTitle = ""
            , h_icon = 0   ; h_icon — 0: None, 1:Info, 2: Warning, 3: Error, n > 3: предполагается hIcon
            , CloseButton = 0
            , nColorBack = 0xFFFFE1
            , nColorText = 0
            , BallonTip = 0   ; BalloonTip — это ToolTip с хвостиком
            , w = 400 )  ; максимальная ширина
{
   TTS_NOPREFIX := 2, TTS_ALWAYSTIP := 1, TTS_BALLOON := 0x40, TTS_CLOSE := 0x80

   hWnd := DllCall("CreateWindowEx", UInt, WS_EX_TOPMOST := 8
                                   , Str, "tooltips_class32", Str, ""
                                   , UInt, TTS_NOPREFIX|TTS_ALWAYSTIP|(CloseButton ? TTS_CLOSE : 0)|(BallonTip ? TTS_BALLOON : 0)
                                   , Int, 0, Int, 0, Int, 0, Int, 0
                                   , Ptr, 0, Ptr, 0, Ptr, 0, Ptr, 0)

   if (x = "" || y = "")
   {
      CoordMode, Mouse
      MouseGetPos, xtt, ytt
      xtt := x = "" ? xtt + 10 : x
      ytt := y = "" ? ytt + 10 : y
   }
   Else
      xtt := x, ytt := y

   NumPut(VarSetCapacity(TOOLINFO, A_PtrSize = 4 ? 48 : 72, 0), TOOLINFO, "UInt")
   NumPut(0x20, TOOLINFO, 4, "UInt")      ; TTF_TRACK = 0x20
   NumPut(&sText, TOOLINFO, A_PtrSize = 4 ? 36 : 48, "UInt")

   DHW := A_DetectHiddenWindows
   DetectHiddenWindows, On
   WinWait, ahk_id %hWnd%

   WM_USER := 0x400
   SendMessage, WM_USER + 24,, w         ; TTM_SETMAXTIPWIDTH
   SendMessage, WM_USER + (A_IsUnicode ? 50 : 4),, &TOOLINFO   ; TTM_ADDTOOL
   SendMessage, WM_USER + (A_IsUnicode ? 33 : 32), h_icon, &sTitle      ; TTM_SETTITLEA и TTM_SETTITLEW
   SendMessage, WM_USER + (A_IsUnicode ? 57 : 12),, &TOOLINFO     ; TTM_UPDATETIPTEXTA и TTM_UPDATETIPTEXTW
   SendMessage, WM_USER + 18,, xtt|(ytt<<16)   ; TTM_TRACKPOSITION
   SendMessage, WM_USER + 17, 1, &TOOLINFO ; TTM_TRACKACTIVATE

   if BallonTip
      xMax := A_ScreenWidth, yMax := A_ScreenHeight
   else
   {
      WinGetPos,,, W, H
      xMax := A_ScreenWidth - W - 10
      yMax := A_ScreenHeight - H - 10
   }
   
   if (xtt > xMax || ytt > yMax)
   {
      WinHide
      xtt := xtt > xMax ? xMax : xtt
      ytt := ytt > yMax ? yMax : ytt
      SendMessage, 1042,, xtt|(ytt<<16)   ; TTM_TRACKPOSITION
      WinShow
   }

   DetectHiddenWindows, % DHW
   Return hWnd
}