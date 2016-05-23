; #include Clipboard_rus_subs.ahk
#include KeyCodes.ahk
#include WorkWithModule.ahk

Ctrl_A = ^{SC01E}
Ctrl_L = ^{SC026}
Ctrl_Shift_Z = ^+{SC02C}

; форматирование модуля
F6::
	putModuleInFile()
	RunWait, perl code_beautifier.pl -f %module%
	pasteTextFromFile()
	;FileRead, text, %module%
	;SaveClipboard()
	;clipboard =
	;ClipPutText(text)
	;ClipWait
	;SendInput +{ins}
	;RestoreClipboard()
return
; ----------------------------------
; Ctrl + 1 Вызов списка процедур
^1::
	module = tmp\module.1s
	PutCurrentModuleTextIntoFileFast(module)
	SendInput, {home}
	RunWait, wscript scripts.js %module% proclist
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}
	SendInput, {home}
	SendInput, ^{NumpadAdd}
return

;-----------------------------------------------
; --- Поиск с Регулярными выражениями ---
; Alt + f - поиск с рег.выражениями
!f::
   module = tmp\module.1s
   PutCurrentModuleTextIntoFileFast(module)
   SendInput, {home}
   RunWait, wscript scripts.js %module% search
   if (ErrorLevel > 0) {
	  nStr := ErrorLevel
	  Sleep 1
	  SendInput ^%KeyG%%nStr%{ENTER}
   }   
   SendInput, {home}
   SendInput, ^{NumpadAdd}
return
;-----------------------------------------------
; Alt + r - результаты последнего поиска
!r::
   SendInput, {home}
   RunWait, wscript scripts.js null search-last
   if (ErrorLevel > 0) {
	  nStr := ErrorLevel
	  SendInput ^%KeyG%%nStr%{ENTER}
   }   
   SendInput, {home}
   SendInput, ^{NumpadAdd}
return

; --- Прочее ---
; ctrl + / (ctrl + .) - Закоментировать строку:
^/:: Send, {home}//

; Ctrl + i - Развернуть модуль: 
^i:: SendInput, ^+{NumpadAdd}

; Ctrl+y - удаление строки
$^SC015:: SendInput %Ctrl_L%

; Ctrl-, - символ '<'
$^,:: SendInput <

; Ctrl-. символ '>'
$^.:: SendInput >

; Ctrl-\ символ '|'
$^\:: SendInput |

; Alt - [ - символ '['
$!SC01A::Send [ 

; Alt + ] - символ ']'
$!SC01B::Send ] 

; Ctrl - & - символ '&'
$^SC008::Send &

; Ctrl + D - Копирование текущей строки и вставка в следующей
^d:: Send, {HOME}{SHIFTDOWN}{END}{SHIFTUP}{CTRLDOWN}{INS}{CTRLUP}{END}{ENTER}{SHIFTDOWN}{INS}{SHIFTUP}

; ----------------------------------------
; авторские комментарии
; ----------------------------------------
runAuthorComments(prmVar)
{
	putSelectionInFile()
	RunWait, wscript author.js %prmVar%
	pasteTextFromFile()
}

!s::	runAuthorComments("new") ; alt+s - блок добавлен
!e::	runAuthorComments("edit") ; alt+e - блок изменен
!d::	runAuthorComments("del") ; alt+d - блок удален

; КОНЕЦ авторские комментарии
; ----------------------------------------

;Закрытие окна сообщение Ctrl+z (не всем нравится)
;$^SC02C::SendInput %Ctrl_Shift_Z%

;-----------------------------------
; переходы по процедурам в стиле OpenConf
;
; Ctrl + Enter - переход в процедуру (как в OpenConf)
^Enter::
	SendInput, {F12}
return

; Alt + - возврат на предыдущую позицию (как в OpenConf)
!left::
	SendInput, ^-
return
;------------------------------------

; Alt+h - добавление ссылки на реквизит в модуле
!h::
	putSelectionInFile()
	RunWait, wscript generator.js null simple-managment
	pasteTextFromFile()
return

; Alt+g - Вызов генераторов кода
!g::
	putSelectionInFile()
	RunWait, wscript generator.js null generator
	pasteTextFromFile()	
return


; Alt+7 - Препроцессор функции
!SC008::
	set_locale_ru()
	RunWait, wscript scripts.js null preprocmenu
	set_locale_ru()
	FileRead, text, tmp\module.txt
	set_locale_ru()
	SendInput, %text%
return

; Ctrl + m - Прочие скрипты
^m::
	putSelectionInFile()
	RunWait, wscript scripts_manager.js
	pasteTextFromFile()
return

; Ctrl + w Выбор ранее набранного слова
^w::
	putModuleInFile()
	RunWait, wscript scripts.js tmp\module.txt words
	pasteTextFromFile()
return

; Alt + J - Поиск по метаданным
!j::
	SendInput, ^+%KeyC%
	Sleep 10
	SendInput ^%KeyF%
return

; Ctrl + b - В начало метода
^b::
	getTextUp()
	RunWait, wscript scripts.js tmp\module.txt BeginMethod
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}   
	SendInput, {home}
return

; Ctrl + e - В конец метода
^e::
	getTextUp()
	RunWait, wscript scripts.js tmp\module.txt EndMethod
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
		SendInput ^{SC01A}
	}   
	SendInput, {home}
return

; Ctrl + 2 - Вызов списка секций
^2::
	putModuleInFile()
	SendInput, {home}
	RunWait, wscript scripts.js tmp\module.txt sectionslist
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}
	SendInput, {home}
	SendInput, ^{NumpadAdd}
return

; Ctrl + 3 - Открытие внешних файлов
^3::
	RunWait, wscript ExtFiles.js
	FileRead, newText, tmp\module.txt
	Clipboard := newText
	ClipWait
	Sleep 1
	set_locale_ru()
	SendInput, !%KeyA%
	SendInput, {DOWN}{DOWN}{Enter}
	Sleep 1000
	SendInput, ^%KeyV%
	Sleep 1000
	SendInput, {Enter}
return