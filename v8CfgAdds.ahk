#include Clipboard_rus_subs.ahk
#include WorkWithModule.ahk

Ctrl_A = ^{SC01E}
Ctrl_L = ^{SC026}
Ctrl_Shift_Z = ^+{SC02C}

; форматирование модуля
F6::

	module = %temp%\module.1s
	PutCurrentModuleTextIntoFileFast(module)

	RunWait, perl code_beautifier.pl -f %module%

	FileRead, text, %module%
	
	SaveClipboard()

	clipboard =
	ClipPutText(text)
	ClipWait
	;Sleep 30
	SendInput +{ins}
	;Sleep 30

	RestoreClipboard()

	Return


; ----------------------------------

; Вызов списка процедур: ctrl +1
^1::
	module = %temp%\module.1s
	PutCurrentModuleTextIntoFileFast(module)

	SendInput, {home}
; 	Sleep 5
	RunWait, wscript.exe scripts.js %module% proclist
	if (ErrorLevel > 0)
	{
		nStr := ErrorLevel
		SendMessage, 0x50,, 0x4090409,, A ;переходим на lat раскладку, чтобы работал SendInput
; 		SendInput ^g^п%nStr%{ENTER}
		 SendInput ^g%nStr%{ENTER}
	}
	
	SendInput, {home}
	SendInput, ^{NumpadAdd}

Return

;-----------------------------------------------
; поиск с рег.выражениями: Alt+f
!f::
   module = %temp%\module.1s
   PutCurrentModuleTextIntoFileFast(module)
   SendInput, {home}
;    SendInput, ^+{NumpadAdd} ; развернем все строки
   SendMessage, 0x50,, 0x4090409,, A ;переходим на lat раскладку, для упрощения управления
   RunWait, wscript scripts.js %module% search
   if (ErrorLevel > 0)
   {
	  nStr := ErrorLevel
	  SendMessage, 0x50,, 0x4090409,, A ;переходим на lat раскладку, чтобы работал SendInput
	  SendInput ^g%nStr%{ENTER}
   }   
   SendInput, {home}
   SendInput, ^{NumpadAdd}
Return

;-----------------------------------------------
; поиск с рег.выражениями: Alt+r
!r::
   SendInput, {home}
   SendMessage, 0x50,, 0x4090409,, A ;переходим на lat раскладку, для упрощения управления
   RunWait, wscript scripts.js null search-last
   if (ErrorLevel > 0)
   {
	  nStr := ErrorLevel
	  SendMessage, 0x50,, 0x4090409,, A ;переходим на lat раскладку, чтобы работал SendInput
	  SendInput ^g%nStr%{ENTER}
   }   
   SendInput, {home}
   SendInput, ^{NumpadAdd}
Return

;-----------------------------------------------------------

; Закоментировать строку: ctrl + / (ctrl + .)
^/::
   Send, {home}//
Return

; ---------------------------
;  Развернуть модуль: ctrl+i
^i::
   SendInput, ^+{NumpadAdd}
Return

;-----------------------------------------

; удаление строки Ctrl+y
$^SC015::	SendInput %Ctrl_L%

; ----------------------------------------
; авторские комментарии
; ----------------------------------------
runAuthorComments(prmVar)
{
	SendInput, ^{ins}
	ClipWait , 1
	RunWait, wscript author.js %prmVar%
	ClipWait , 1
	FileRead, text, tmp\actxt.tmp
	ClipWait , 1
	ClipPutText(text)
	ClipWait , 1
	SendInput +{ins}
}

!s::	runAuthorComments("new") ; alt+s - блок добавлен
!e::	runAuthorComments("edit") ; alt+e - блок изменен
!d::	runAuthorComments("del") ; alt+d - блок удален

; КОНЕЦ авторские комментарии
; ----------------------------------------

;Закрытие окна сообщение Ctrl+z (не всем нравится)
;$^SC02C::SendInput %Ctrl_Shift_Z%


;символ '<' по Ctrl-,
$^,::	SendInput <


;символ '>' по Ctrl-.
$^.::	SendInput >

;символ '|' по Ctrl-\
$^\::	SendInput |

; Копирование текущей строки и вставка в следующей: ctrl+shift+c
^+c:: 
	Send, {HOME}{SHIFTDOWN}{END}{SHIFTUP}{CTRLDOWN}{INS}{CTRLUP}{END}{ENTER}{SHIFTDOWN}{INS}{SHIFTUP}
return

;-----------------------------------
; переходы по процедурам в стиле OpenConf
;
; переход в процедуру (как в OpenConf)
^Enter::
	SendInput, {F12}
return

; возврат на предыдущую позицию (как в OpenConf)
!left::
	SendInput, ^-
return
;------------------------------------

; Alt+h - добавление ссылки на реквизит в модуле
!h::
	SendInput, ^{ins}
	ClipWait , 1
	;module = %temp%\module.1s
	;PutCurrentModuleTextIntoFile(module)
	ClipWait , 1
	RunWait, wscript generator.js null simple-managment
	ClipWait , 1
	FileRead, text, tmp\module.txt
	ClipWait , 1
	ClipPutText(text)
	ClipWait , 1
	SendInput +{ins}
return

; Alt+g - Вызов генераторов кода
!g::
	SendInput, ^{ins}
	ClipWait , 1
	;module = %temp%\module.1s
	;PutCurrentModuleTextIntoFile(module)
	ClipWait , 1
	RunWait, wscript generator.js null generator
	ClipWait , 1
	FileRead, text, tmp\module.txt
	ClipWait , 1
	ClipPutText(text)
	ClipWait , 1
	SendInput +{ins}
return


; Alt+7 - Препроцессор функции
!7::
	set_locale_ru()
	RunWait, wscript scripts.js null preprocmenu
	FileRead, text, tmp\module.txt
	SendInput, %text%
; 	ClipWait , 1
; 	ClipPutText(text)
; 	ClipWait , 1
; 	SendInput +{ins}
return

; Ctrl+m - Препроцессор функции
^m::
	SendInput, ^{ins}
	ClipWait , 1
	RunWait, wscript scripts_manager.js
	FileRead, text, tmp\module.txt
	ClipWait , 1
	ClipPutText(text)
	ClipWait , 1
	SendInput +{ins}
return

; Ctrl +w Выбор ранее набранного слова
^w::
	SendInput, ^+{Home}^{ins}{Right} 
	FileAppend, %clipboard%, tmp\moduletext.txt
	SendInput, ^+{End}^{ins}{Left} 
	FileAppend, %clipboard%, tmp\moduletext.txt
; 	RunWait, wscript scripts.js tmp\module.txt words
	RunWait, wscript scripts.js tmp\moduletext.txt words
	FileRead, text, tmp\module.txt
	ClipWait , 1
	ClipPutText(text)
	ClipWait , 1
	SendInput +{ins}

Return