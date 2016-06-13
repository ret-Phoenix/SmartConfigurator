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