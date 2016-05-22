pasteTextFromFile() {
  FileRead, newText, tmp\module.txt
  ClipWait, 1
  Clipboard := newText
  ClipWait, 1
  SendInput +{ins}
}

set_locale_ru()
{
	SendMessage, 0x50,, 0x4190419,, A
}

set_locale_en()
{
  SendMessage, 0x50,, 0x4090409,, A 
}

;From http://forum.script-coding.info  (http://forum.script-coding.info/viewtopic.php?id=1073)
ClipPutText(Text, LocaleID=0x419)
{
  CF_TEXT:=1, CF_LOCALE:=16, GMEM_MOVEABLE:=2
  TextLen   :=StrLen(Text)
  HmemText  :=DllCall("GlobalAlloc", UInt, GMEM_MOVEABLE, UInt, TextLen+1)  ; Запрос перемещаемой
  HmemLocale:=DllCall("GlobalAlloc", UInt, GMEM_MOVEABLE, UInt, 4)  ; памяти, возвращаются хэндлы.
  If(!HmemText || !HmemLocale)
    Return
  PtrText   :=DllCall("GlobalLock",  UInt, HmemText)   ; Фиксация памяти, хэндлы конвертируются
  PtrLocale :=DllCall("GlobalLock",  UInt, HmemLocale) ; в указатели (адреса).
  DllCall("msvcrt\memcpy", UInt, PtrText, Str, Text, UInt, TextLen+1) ; Копирование текста.
  NumPut(LocaleID, PtrLocale+0)		     ; Запись идентификатора локали.
  DllCall("GlobalUnlock",     UInt, HmemText)   ; Расфиксация памяти.
  DllCall("GlobalUnlock",     UInt, HmemLocale)
  If not DllCall("OpenClipboard", UInt, 0)	; Открытие буфера обмена.
  {
    DllCall("GlobalFree", UInt, HmemText)    ; Освобождение памяти,
    DllCall("GlobalFree", UInt, HmemLocale)  ; если открыть не удалось.
    Return
  }
  DllCall("EmptyClipboard")			   ; Очистка.
  DllCall("SetClipboardData", UInt, CF_TEXT,   UInt, HmemText)   ; Помещение данных.
  DllCall("SetClipboardData", UInt, CF_LOCALE, UInt, HmemLocale)
  DllCall("CloseClipboard")						  ; Закрытие.
}




ClipGetText(CodePage=1251)
{
  CF_TEXT:=1, CF_UNICODETEXT:=13, Format:=0
  If not DllCall("OpenClipboard", UInt, 0)		     ; Открытие буфера обмена.
    Return
  Loop
  {
    Format:=DllCall("EnumClipboardFormats", UInt, Format)  ; Перебор форматов.
    If(Format=0 || Format=CF_TEXT || Format=CF_UNICODETEXT)
	Break
  }
  If(Format=0)	  ; Текста не найдено.
    Return
  If(Format=CF_TEXT)
  {
    HmemText:=DllCall("GetClipboardData", UInt, CF_TEXT)  ; Получение хэндла данных.
    PtrText :=DllCall("GlobalLock",	 UInt, HmemText) ; Конвертация хэндла в указатель.
    TextLen :=DllCall("msvcrt\strlen",    UInt, PtrText)  ; Измерение длины найденного текста.
    VarSetCapacity(Text, TextLen+1)  ; Переменная под этот текст.
    DllCall("msvcrt\memcpy", Str, Text, UInt, PtrText, UInt, TextLen+1) ; Текст в переменную.
    DllCall("GlobalUnlock", UInt, HmemText)  ; Расфиксация памяти.
  }
  Else If(Format=CF_UNICODETEXT)
  {
    HmemTextW:=DllCall("GetClipboardData", UInt, CF_UNICODETEXT)
    PtrTextW :=DllCall("GlobalLock",	 UInt, HmemTextW)
    TextLen  :=DllCall("msvcrt\wcslen",    UInt, PtrTextW)
    VarSetCapacity(Text, TextLen+1)
    DllCall("WideCharToMultiByte", UInt, CodePage, UInt, 0, UInt, PtrTextW
					   , Int, TextLen+1, Str, Text, Int, TextLen+1
					   , UInt, 0, Int, 0)  ; Конвертация из Unicode в ANSI.
    DllCall("GlobalUnlock", UInt, HmemTextW)
  }
  DllCall("CloseClipboard")  ; Закрытие.
  Return Text
} 