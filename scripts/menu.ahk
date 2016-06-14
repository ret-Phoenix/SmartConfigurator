createMenuItems() {
   Menu, Popup, Add, КонецЕсли, КонецЕсли
   Menu, Popup, Add, КонецЦикла, КонецЦикла
   Menu, Popup, Add, КонецПроцедуры, КонецПроцедуры
   Menu, Popup, Add, КонецФункции, КонецФункции
   Menu, Popup, Add, 
   Menu, Popup, Add, Выравнить по равно, ВыравнитьПоРавно

   Пустышка:
   Return

   КонецЕсли:
      SendInput, КонецЕсли;
   Return

   КонецЦикла:
      SendInput, КонецЦикла;
   Return

   КонецПроцедуры:
      SendInput, КонецПроцедуры;
   Return

   КонецФункции:
      SendInput, КонецФункции;
   Return

   ВыравнитьПоРавно:
      putSelectionInFile()
      RunWait, system\OneScript\bin\oscript.exe scripts\format.os align-equal-sign,,Hide
      pasteTextFromFile()
   Return   

}

