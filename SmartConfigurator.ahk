#include core\KeyCodes.ahk
#include core\WorkWithModule.ahk
#include core\WorkWithWindows.ahk
#include scripts\actions.ahk
#include scripts\menu.ahk


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
^+sc32:: actionShowScriptManager()

; Ctrl + w Выбор ранее набранного слова
^sc11:: actionShowPrevWords()

; ----------------------------------
; НАЧАЛО: Навигация внутри метода

; Ctrl + b - В начало метода
^sc30:: actionGotoMethodBegin()

; Ctrl + e - В конец метода
^sc12:: actionGotoMethodEnd()
; КОНЕЦ: Навигация внутри метода
; ----------------------------------

;-----------------------------------------------
; --- Поиск с Регулярными выражениями ---
; Alt + f - поиск с рег.выражениями
!sc21:: actionShowRegExSearch()
;-----------------------------------------------
; Alt + r - результаты последнего поиска
!sc13:: actionShowRegExSearchLastResult()

; shift + alt + r
+!sc13:: actionShowLastSelect()

; --- Прочее ---
; ctrl + / (ctrl + .) - Закоментировать строку:
^/:: Send, {home}//

; Ctrl + i - Развернуть модуль: 
^sc17:: SendInput, ^+{NumpadAdd}

; Ctrl-\ символ '|'
$^\:: SendInput |

; Alt - [ - символ '['
$!SC01A::Send [ 

; Alt + ] - символ ']'
$!SC01B::Send ] 

; Alt - & - символ '&'
$!SC008::Send &

; Ctrl + D - Копирование текущей строки/ выделенного блока и вставка ниже
^sc20:: SendInput, {CTRLDOWN}{INS}{CTRLUP}{Right}{HOME}{HOME}{SHIFTDOWN}{INS}{SHIFTUP}

; ----------------------------------------
; авторские комментарии
; ----------------------------------------
!sc1E:: actionRunAuthorComments("add") ; alt+a - блок добавлен
!sc12:: actionRunAuthorComments("edit") ; alt+e - блок изменен
!sc20:: actionRunAuthorComments("del") ; alt+d - блок удален
; КОНЕЦ авторские комментарии
; ----------------------------------------

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

; Ctrl+7 - Препроцессор функции
^SC008:: actionShowPreprocMethod()

;------------------------------------
; Навигация по метаданным

; Alt + J - Поиск по метаданным
$!sc24:: actionShowSimpleMetaSearch()

; Ctrl +j - Переход к объекту метаданных из типа текущего реквизита
$^sc24:: actionShowIncomingObjectTypes()

; Ctrl + shift + j - Переход к объекту метаданных
$^+sc24:: actionShowMetadataNavigator()
;------------------------------------

;------------------------------------
; Автозамена приращений ++, +=, --, -=
::++:: 
	clipboard =
 	SendInput, ^+{left}^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4E}{Space}1;
Return

::--:: 
 	SendInput, ^+{left}^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4A}{Space}1;
Return

::+=:: 
 	SendInput, ^+{left}^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4E}{Space}
Return

::-=:: 
 	SendInput, ^+{left}^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4A}{Space}
Return

::.=:: 
 	SendInput, ^+{left}^+{left}^{ins}{Right}{space}{scD}{Space}+{ins}{sc4E}{Space}
Return

;------------------------------------

; Win + X - Показать меню
#sc02D:: 
	showMenu()
Return

; Alt + Ctrl + Пробел - выбрать ранее набранное слово
!^Space:: 
   actionShowPrevWords()
Return

; ----------------------------------
; Ctrl + 0 Запуск 1script
^0:: actionRun1Script()

; -----------------------------------
; Перейти к началу слова в составной строке
; Shift + Alt + Left
!+left::
	actionGoToPrevContainedWord()
return

; Перейти к концу слова в составной строке
; Shift + Alt + Right
!+Right::
	actionGoToNextContainedWord()
return

; Win + N - показать имя метода
#sc31::
	actionShowMethodName()
return

; Alt + Up - передвинуть строку вверх
!up::
	SendInput, {HOME}{SHIFTDOWN}{END}{SHIFTUP}{SHIFTDOWN}{DEL}{SHIFTUP}^{sc26}{HOME}{UP}{HOME}{ENTER}{UP}{SHIFTDOWN}{INS}{SHIFTUP}
return

; Alt + down - передвинуть строку вверх
!down::
	SendInput, {HOME}{SHIFTDOWN}{END}{SHIFTUP}{SHIFTDOWN}{DEL}{SHIFTUP}^{sc26}{END}{ENTER}{SHIFTDOWN}{INS}{SHIFTUP}
return

; Ctrl + Alt + F - выполнить форматирование
^!sc21::
	actionOneStyleSelection()
return

; Win + C - Взять в буфер слово под курсором
#sc2E::
	SendInput, {CTRLDOWN}{left}{SHIFTDOWN}{Right}{SHIFTUP}{ins}{CTRLUP}{Right}
return

; Win + W - Менеджер окон
#sc11::
	actionWindowsManager()
return

; Win + S - Фильтрация результатов поиска
#sc1F::
	actionResultSearchFilter()
return

$+$SC01C:: ; Shift+Enter
$+$SC11C:: ; Shift+Enter на "цифровой" клавиатуре
	actionContinueRow()
Return