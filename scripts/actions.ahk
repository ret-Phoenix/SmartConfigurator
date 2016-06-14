; #include KeyCodes.ahk
; #include core\WorkWithModule.ahk

actionShowMethodsList() {
	Global

	putModuleInFile()
	SendInput, {home}
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os СписокМетодов,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}
	SendInput, {home}
	SendInput, ^{NumpadAdd}
}

actionShowRegionsList() {
	Global

	putModuleInFile()
	SendInput, {home}
	ClipWait
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os СписокОбластей,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}
	SendInput, {home}
	SendInput, ^{NumpadAdd}
}

actionShowExtFilesList() {
	Global

	RunWait, wscript scripts\ExtFiles.js

	NewText := getTextFromFile()
	If (NewText <> "") {
		; FileRead, newText, tmp\module.txt
		; Clipboard := newText
		ClipWait
		Sleep 1
		set_locale_ru()
		SendInput, !%KeyA%
		SendInput, {DOWN}{DOWN}{Enter}
		Sleep 1000
		SendInput, ^%KeyV%
		Sleep 1000
		SendInput, {Enter}
	}
}

actionShowScriptManager() {
	putSelectionInFile()
	RunWait, wscript scripts\scripts_manager.js
	pasteTextFromFile()
}

actionShowPrevWords() {
	putModuleInFile()
	RunWait, wscript scripts\scripts.js tmp\module.txt words
	pasteTextFromFile()
}

actionGotoMethodBegin() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os НачалоМетода,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}   
	SendInput, {home}
}

actionGotoMethodEnd() {
	Global

	getTextUp()
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os НачалоМетода,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
		SendInput ^{SC01A}
	}   
	SendInput, {home}
}

actionShowRegExSearch() {
	Global

	putModuleInFile()

	SendInput, {home}
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os RegExSearch,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		Sleep 1
		SendInput ^%KeyG%%nStr%{ENTER}
	}   
	SendInput, {home}
}

actionShowRegExSearchLastResult() {
	Global

	SendInput, {home}
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os РезультатПоследнегоПоиска,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}   
	SendInput, {home}
}

actionShowLastSelect() {
	Global

	SendInput, {home}
	; RunWait, wscript scripts.js null last
	RunWait, system\OneScript\bin\oscript.exe scripts\Навигация\НавигацияПоМодулю.os ПоказатьПоследнийСписокВыбора,,Hide
	if (ErrorLevel > 0) {
		nStr := ErrorLevel
		SendInput ^%KeyG%%nStr%{ENTER}
	}   
	SendInput, {home}
	SendInput, ^{NumpadAdd}
}


actionRunAuthorComments(data) {
	putSelectionInFile()
	RunWait, wscript scripts\author.js %data%
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
	SendInput, %text%	
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
	SendInput, ^!%KeyO%
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
		; show search dlg
		SendInput, ^%KeyF%
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
				SendInput +{ins}
			
				SendInput, !{Insert}
				ClipWait
				SendInput, {Enter}
				SendInput, {Enter}
			}
		}
	}
}