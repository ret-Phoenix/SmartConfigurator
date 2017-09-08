#IfWinActive ahk_class V8TopLevelFrame


readTextFromFile() {
  FileRead, newText, tmp\module.txt
  Return %newText%
}

getTextFromFile() {
  FileRead, newText, tmp\module.txt
  ClipWait, 1
  Clipboard := newText
  ClipWait, 1
  
  Return %newText%
}

pasteTextFromFile( fileName=0, TrimRightCount=0 ) {

  if (fileName = 0) {
		fileName = tmp\module.txt	
	}
  module := fileName
  FileRead, newText, %module%
  StringTrimRight, newText, newText, TrimRightCount
  ClipWait, 1
  Clipboard := newText
  ClipWait, 1
  SendInput +{ins}
}

set_locale_ru() {
	SendMessage, 0x50,, 0x4190419,, A
}

set_locale_en() {
  SendMessage, 0x50,, 0x4090409,, A 
}

putTextFromResultWindowInFile(fileName=0, flagSaveClipboard = 1) {

	clipboard := 
	set_locale_ru()
	if (flagSaveClipboard = 1)
		SaveClipboard()

	if (fileName = 0) {
		fileName = tmp\module.txt	
	}

	module := fileName
	SendInput, ^{ins}
	ClipWait
	
	FileDelete %module%
	FileAppend, %clipboard%`r`n, %module%

	if (flagSaveClipboard = 1)
		RestoreClipboard()
}

putSelectionInFile(fileName=0, flagSaveClipboard = 1) {

	wType := getWindowType()
	If (wType <> "TextEditor") {
		Return "NotTextEditor"
	}
	
	clipboard := 
	set_locale_ru()
	if (flagSaveClipboard = 1)
		SaveClipboard()

	if (fileName = 0) {
		fileName = tmp\module.txt	
	}

	module := fileName
	SendInput, ^{ins}
	ClipWait
	
	FileDelete %module%
	FileAppend, %clipboard%`r`n, %module%, UTF-8

	if (flagSaveClipboard = 1)
		RestoreClipboard()
}

putModuleInFile() {
	PutCurrentModuleTextIntoFileFast(0, 1)
}

putModuleInFileWithSavePosition() {

	SaveClipboard()

	module = tmp\module.txt

	FileDelete %module%

	set_locale_ru()

	clipboard := 
	SendInput, ^+{Home}^{ins}{Right}
	ClipWait
	FileAppend, %clipboard%, %module%, UTF-8

	clipboard := 
	SendInput, ^+{End}^{ins}{Left} 
	ClipWait
	FileAppend, %clipboard%, %module%, UTF-8

	RestoreClipboard()	
}


/*
; Don't work selectValue, why?
putModuleInFile(fileName = 0) {

	if (fileName = 0) {
		module = tmp\module.txt
	} else {
		module = fileName
	}

	FileDelete %module%

	set_locale_ru()

	clipboard := ""
	SendInput, ^+{Home}^{ins}{Right}
	ClipWait
	ClipWait
	FileAppend, %clipboard%, %module%

	clipboard := ""
	SendInput, ^+{End}^{ins}{Left} 
	ClipWait
	ClipWait
	FileAppend, %clipboard%, %module%
	
}
*/
getTextUp() {
	clipboard := 
	SendInput, {CTRLDOWN}{ALTDOWN}{SHIFTDOWN}{Home}{CTRLUP}{ALTUP}{SHIFTUP}{CTRLDOWN}{INS}{CTRLUP}{Right}
	ClipWait
	FileDelete tmp\module.txt
	FileAppend, %clipboard%, tmp\module.txt, UTF-8
	clipboard := 
}

getTextDown() {
	clipboard := 
	SendInput, ^+{End}^{ins}{Left} 
	ClipWait
	FileDelete tmp\module.txt
	FileAppend, %clipboard%, tmp\module.txt, UTF-8
	clipboard := 
}


PutCurrentModuleTextIntoFileFast(fileName = 0, flagSaveClipboard = 1) {
	set_locale_ru()
	if (flagSaveClipboard = 1)
		SaveClipboard()

	module = tmp\module.txt
	if (fileName <> 0) {
		module = fileName
	}

	;Sleep 30
	SendInput ^{SC01E}^{ins}{Left}
	ClipWait
	
	FileDelete %module%
	FileAppend, %clipboard%, %module%, UTF-8

	if (flagSaveClipboard = 1)
		RestoreClipboard()
}

PutCurrentModuleTextIntoFile(fileName, flagSaveClipboard = 1) {
	set_locale_ru()
	if (flagSaveClipboard = 1)
		SaveClipboard()

	module := fileName
	;set_locale_ru()

	;Sleep 30
	SendInput ^{SC01E} ; CTRL-A
	;Sleep 30
	SendInput, ^{ins}
	;Sleep 30
	ClipWait
	
	FileDelete %module%
	FileAppend, %clipboard%, %module%, UTF-8

	if (flagSaveClipboard = 1)
		RestoreClipboard()
}

PutCurrentModuleTextIntoTempFile() {
	module = tmp\module.1s
	PutCurrentModuleTextIntoFile(module)
}

gClipSavedInner45 :=

SaveClipboard()
{
	global gClipSavedInner45 ;
	gClipSavedInner45 := ClipboardAll
	clipboard =

	ClipWait , 1
}

RestoreClipboard()
{
	global gClipSavedInner45 ;
	Clipboard := gClipSavedInner45
	gClipSavedInner45 =
}