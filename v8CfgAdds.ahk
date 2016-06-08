; #include Clipboard_rus_subs.ahk
#include KeyCodes.ahk
#include WorkWithModule.ahk
#include actions.ahk

Ctrl_A = ^{SC01E}
Ctrl_L = ^{SC026}
Ctrl_Shift_Z = ^+{SC02C}

; ----------------------------------
; Ctrl + 1 Вызов списка процедур
^1:: actionShowMethodsList()

; Ctrl + 2 - Вызов списка секций
^2:: actionShowRegionsList()

; Ctrl + 3 - Открытие внешних файлов
^3:: actionShowExtFilesList()

; Ctrl + Shift + m - Прочие скрипты
^+m:: actionShowScriptManager()

; Ctrl + w Выбор ранее набранного слова
^w:: actionShowPrevWords()

; ----------------------------------
; НАЧАЛО: Навигация внутри метода

; Ctrl + b - В начало метода
^b:: actionGotoMethodBegin()

; Ctrl + e - В конец метода
^e:: actionGotoMethodEnd()
; КОНЕЦ: Навигация внутри метода
; ----------------------------------

;-----------------------------------------------
; --- Поиск с Регулярными выражениями ---
; Alt + f - поиск с рег.выражениями
!f:: actionShowRegExSearch()
;-----------------------------------------------
; Alt + r - результаты последнего поиска
!r:: actionShowRegExSearchLastResult()

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
!s:: actionRunAuthorComments("new") ; alt+s - блок добавлен
!e:: actionRunAuthorComments("edit") ; alt+e - блок изменен
!d:: actionRunAuthorComments("del") ; alt+d - блок удален
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
!h:: actionRunLinksToItems()

; Alt+g - Вызов генераторов кода
!g:: actionShowCodeGenerator()

; Alt+7 - Препроцессор функции
!SC008:: actionShowPreprocMethod()

;------------------------------------
; Навигация по метаданным

; Alt + J - Поиск по метаданным
^k:: actionShowSimpleMetaSearch()

; Ctrl +j - Переход к объекту метаданных из типа текущего реквизита
$^sc24:: actionShowIncomingObjectTypes()

; Ctrl + shift + j - Переход к объекту метаданных
$^+sc24:: actionShowMetadataNavigator()
;------------------------------------
