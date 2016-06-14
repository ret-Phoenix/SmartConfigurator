Menu, Popup, Add, КонецЕсли, КонецЕсли
Menu, Folders, Add, Мой компьютер, MyComputer
Menu, Folders, Add, Панель управления, Panel
Menu, Folders, Add, Корзина, Bin
Menu, Popup, Add, &Браузер
Menu, Popup, Add, Папки, :Folders
; menu, tray, add, "TestToggle&Check"

#sc02D::Menu, Popup, Show ; Гор. клав. WIN+X

MButton:: ; средняя кнопка мыши на рабочем столе
MouseGetPos, x, y, win
WinGetClass, class, ahk_id %win%
IfEqual, class, Progman
    Menu, Popup, Show
Else
    MouseClick, Middle
Return

КонецЕсли:
   SendInput, КонецЕсли;
Return

&Браузер:
Run, iexplore
Return

MyComputer:
Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
Return

Bin:
Run ::{645ff040-5081-101b-9f08-00aa002f954e}
Return

Panel:
Run rundll32.exe shell32.dll`,Control_RunDLL
Return


::tt::
   SendInput, ^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{Space}{sc4E}{Space}1
Return

#SingleInstance Force
#vk57 up::   ;Ctrl+w
   ClipBoard =
   SendInput ^{vk43}    ;  "C"
   ClipWait, 3
   Sleep, 300
   InputBox, str, Автозамена, %Clipboard%,, 400, 120
   if !ErrorLevel && str
   {
      FileAppend, % "`n::" . str . "::" . Clipboard, %A_ScriptFullPath%
      Reload
   }
Return

::++:: 
   SendInput, ^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4E}{Space}1;
Return

::--:: 
   SendInput, ^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4A}{Space}1;
Return

::-=:: 
   SendInput, ^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4A}{Space}
Return

::+=:: 
   SendInput, ^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4E}{Space}
Return

!^Space:: 
   ;MsgBox, hi
   ;Menu, Popup, Show ; Гор. клав. WIN+X
   Menu, Popup, Show ; Гор. клав. WIN+X
Return
 

