actionShowMethodsList() {
	Global

	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os СписокМетодов
	if (ErrorLevel = 0) {
		return
	}

	nStr := ErrorLevel
	SendInput ^%KeyG%
	WinWait, Перейти по номеру строки
	SendInput, %nStr%{ENTER}

	SendInput, {home}
	SendInput, ^{NumpadAdd}
}

actionShowRegionsList() {
	Global

	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os СписокОбластей,,Hide
	if (ErrorLevel = 0) {
		return
	}

	nStr := ErrorLevel
	SendInput, ^%KeyG%
	WinWait, Перейти по номеру строки
	SendInput, %nStr%{ENTER}

	SendInput, {home}
	SendInput, ^{NumpadAdd}
}

actionShowExtFilesList() {
	Global

	; RunWait, wscript scripts\ExtFiles.js
	RunWait, system\OneScript\bin\woscript.exe scripts\ExtFiles.os,,

	NewText := getTextFromFile()
	If (NewText <> "") {
		ClipWait
		Sleep 1
		set_locale_ru()
		SendInput, !%KeyA%
		SendInput, {DOWN}{DOWN}{Enter}
		WinWait, Открыть
		SendInput, ^%KeyV%{Enter}
	}
}

actionShowScriptManager() {
	result := putSelectionInFile()
	if (result = "NotTextEditor") {
		MsgBox, "Окно не текстовый редактор"
		Exit, 0
	}
	;  RunWait, wscript scripts\scripts_manager.js
	RunWait, system\OneScript\bin\woscript.exe scripts\МенеджерСкриптов.os,,
	if (ErrorLevel > 0) {
		pasteTextFromFile()
	}
}

actionShowPrevWords() {
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os allwords,,
	pasteTextFromFile()
}

actionGotoMethodBegin() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os НачалоМетода,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput, {CtrlDown}%KeyG%{CtrlUp}
		WinWait, Перейти по номеру строки
		SendInput,%nStr%{ENTER}
	}   
	SendInput, {home}
}

actionGotoMethodEnd() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os НачалоМетода,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%
		WinWait, Перейти по номеру строки
		SendInput %nStr%{ENTER}
		SendInput ^{SC01A}
	}   
	SendInput, {home}
}

actionShowRegExSearch() {
	Global

	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os RegExSearch,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		Sleep 1
		SendInput ^%KeyG%
		WinWait, Перейти по номеру строки
		SendInput %nStr%{ENTER}
	}   
	SendInput, {home}
}

actionShowRegExSearchLastResult() {
	Global

	SendInput, {home}
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os РезультатПоследнегоПоиска,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%
		WinWait, Перейти по номеру строки
		SendInput %nStr%{ENTER}
	}   
	SendInput, {home}
}

actionShowLastSelect() {
	Global

	SendInput, {home}
	; RunWait, wscript scripts.js null last
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os ПоказатьПоследнийСписокВыбора,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%
		WinWait, Перейти по номеру строки
		SendInput %nStr%{ENTER}
	}   
	SendInput, {home}
	SendInput, ^{NumpadAdd}
}


actionRunAuthorComments(data) {
	putSelectionInFile()
	RunWait, system\OneScript\bin\oscript.exe scripts\АвторскиеКомментарии.os %data%,,hide
	pasteTextFromFile()
}

actionRunLinksToItems() {
	putSelectionInFile()
	RunWait, wscript scripts\generator.js null simple-managment
	pasteTextFromFile()
}

actionShowCodeGenerator() {
	RunWait, wscript scripts\generator.js null generator
	pasteTextFromFile()	
}

actionShowPreprocMethod() {
	set_locale_ru()
	RunWait, wscript scripts\scripts.js null preprocmenu
	set_locale_ru()
	FileRead, text, tmp\module.txt
	set_locale_ru()
	SendRaw, %text%	
}

actionShowSimpleMetaSearch() {
	Global

	SendInput, ^+%KeyC%
	Sleep 10
	SendInput ^%KeyF%
}

actionShowIncomingObjectTypes() {
	Global

	SendInput, %KeyContextMenu%
	SendInput, {UP}{UP}{UP}{ENTER}
	Sleep 100
	SendInput, {Enter}
	;SendInput, ^!%KeyO%
	ActivateWindowByTitle("Служебные сообщения")
	SendInput, ^%KeyA%
	putSelectionInFile(0)
	module = tmp\module.txt
	SendInput, ^{END}
	RunWait, wscript scripts\scripts.js %module% gototype
	if (ErrorLevel > 0) {
		UpCount := ErrorLevel
		Loop %UpCount%
		{
			SendInput, {UP}
		}	
		SendInput, {ENTER}	
	}
}

actionShowMetadataNavigator() {
	Global

	module = tmp\module.txt

	; clear old data
	FileDelete %module%
	FileAppend,, %module%
	RunWait, system\inputbox.exe %module%

	NewText := getTextFromFile()
	If (NewText <> "") {
		; go to service msgs
		SendInput, ^!%KeyO%
		SendInput, ^+%KeyC%

		; Получаем текущее окно
		ControlGetFocus, WinType
		If (WinType <> "V8Grid1") {
			; Если это окно поиска - тогда перейдем в дерево, послав Таб.
			SendInput {Tab}
		}
		; show search dlg
		SendInput, ^%KeyF%
		WinWait, Поиск объектов метаданных
		pasteTextFromFile()
		;SendInput, !{Insert}
		SendInput, {Enter}
		Sleep 2000
		SendInput, ^%KeyA%
		ClipWait
		SendInput, {Left}{Enter}
		putSelectionInFile(0)
		NewText := getTextFromFile()
		If (NewText <> "") {
			SendInput, ^{END}
			RunWait, wscript scripts\scripts.js %module% gotoobject
			NewText := getTextFromFile()
			If (NewText <> "") {
				SendInput, {Home}
				SendInput, ^%KeyF%
				;WinWait, Поиск объектов метаданных
				SendInput +{ins}
			
				SendInput, !{Insert}
				ClipWait
				SendInput, {Enter}
				SendInput, {Enter}
			}
		}
	}
}

showMenu() {
	createMenuItems()
	Menu, Popup, Show
}

actionRun1Script() {
	module = tmp\module.os
	
	SendInput ^{SC01E}^{ins}{Left}
	ClipWait
	
	FileDelete %module%

	FileAppend, %Clipboard%, %module%, UTF-8
	RunWait, cmd "/K system\OneScript\bin\oscript.exe tmp/module.os"

}

actionGoToPrevContainedWord() {

	clipboard =

	SendInput ^+{left}^{ins}{right}

	module = tmp\module.txt
	ClipWait
	
	FileDelete %module%

	FileAppend, %Clipboard%, %module%, UTF-8
	RunWait, system\OneScript\bin\woscript.exe scripts\РаботаСоСловами.os prev,,Hide
	if (ErrorLevel > 0) {
		UpCount := ErrorLevel
		Loop %UpCount%
		{
			SendInput, {left}
		}	
	}
}

actionGoToNextContainedWord() {

	clipboard =

	SendInput ^+{right}^{ins}{left}

	module = tmp\module.txt
	ClipWait
	
	FileDelete %module%

	FileAppend, %Clipboard%, %module%, UTF-8
	RunWait, system\OneScript\bin\oscript.exe scripts\РаботаСоСловами.os next,,Hide
	if (ErrorLevel > 0) {
		UpCount := ErrorLevel
		Loop %UpCount%
		{
			SendInput, {right}
		}	
	}
}

actionShowMethodName() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМодулю.os ИмяМетода,,

}

actionGenerateServerMethodFromCurMethod() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os СоздатьСерверныйМетод,,Hide

}

actionOneStyleSelection() {
    ; отформатируем выделение средствами 1С, т.к. у только выделенного блока недостаточно информации об отступах
    global
    SendInput, !+%KeyF%
	fileName:="scripts\OneStyle\module.txt"
    putSelectionInFile( fileName )
    RunWait, system\OneScript\bin\oscript.exe scripts\OneStyle\Main.os %fileName%,,Hide
    pasteTextFromFile( fileName )
	FileDelete %fileName%
}

actionWindowsManager() {
	detect_hidden = 0
	WinGet controls, ControlListHwnd
	static WINDOW_TEXT_SIZE := 32767 ; Defined in AutoHotkey source.
	VarSetCapacity(buf, WINDOW_TEXT_SIZE * (A_IsUnicode ? 2 : 1))
	text := ""
	Loop Parse, controls, `n
	{
		if !detect_hidden && !DllCall("IsWindowVisible", "ptr", A_LoopField)
			continue
		if !DllCall("GetWindowText", "ptr", A_LoopField, "str", buf, "int", WINDOW_TEXT_SIZE)
			continue
		if (buf = "Конфигурация") {
			continue
		} 
		text .= buf "`r`n"
	}

	module = tmp\module.txt
	FileDelete %module%
	FileAppend, %text%, %module%, UTF-8

	RunWait, system\SelectValueSharp.exe %module%
	FileRead, text, tmp\module.txt
	Loop Parse, controls, `n
	{
		if !DllCall("GetWindowText", "ptr", A_LoopField, "str", buf, "int", WINDOW_TEXT_SIZE)
			continue
		 if (buf = text) {
		 	WinActivate, ahk_id %A_LoopField%
		 }
	}
}

actionResultSearchFilter() {

	; Активировать результат поиска
	ActivateWindowByTitle("Результаты поиска")

	clipboard =
	; выделили и скопировали данные
	SendInput, ^%KeyA%^{ins}
	;SendInput, ^{ins}
	ClipWait
	SendInput, {home}

	module = tmp\module.txt
	FileDelete %module%
	FileAppend, %Clipboard%, %module%, UTF-8

	SendInput, {home}
	RunWait, system\OneScript\bin\woscript.exe scripts\Навигация\НавигацияПоМетаданным.os РезультатыПоискаПерейти,,Hide
	if (ErrorLevel > 0) {
		UpCount := ErrorLevel
		ActivateWindowByTitle("Результаты поиска")
		Loop %UpCount%
		{
			SendInput, {down}
		}	
		SendInput, {ENTER}	
	}


}


actionTextWinExt() {
	RunWait, system\OneScript\bin\oscript.exe scripts\WinExtTest.os,,
}