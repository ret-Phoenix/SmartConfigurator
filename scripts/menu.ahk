createMenuItems() {

    ; Магия, чтобы нормально работал разделитель меню
    Menu, Popup, Add, 
    Menu, Popup, DeleteAll 

   Menu, Popup, Add, Конец&Если, КонецЕсли
   Menu, Popup, Add, Конец&Цикла, КонецЦикла
   Menu, Popup, Add, Конец&Процедуры, КонецПроцедуры
   Menu, Popup, Add, Конец&Функции, КонецФункции
   Menu, Popup, Add, 
   Menu, Popup, Add, Выравнить по &равно, ВыравнитьПоРавно
   Menu, Popup, Add, &Обрамление текста, ОбрамлениеТекста

   Пустышка:
   Return

   КонецЕсли:
      SendRaw, КонецЕсли;
   Return

   КонецЦикла:
      SendRaw, КонецЦикла;
   Return

   КонецПроцедуры:
      SendRaw, КонецПроцедуры;
   Return

   КонецФункции:
      SendRaw, КонецФункции;
   Return

   ВыравнитьПоРавно:
      RunWait, system\OneScript\bin\woscript.exe scripts\format.os align-equal-sign
   Return   

   ОбрамлениеТекста:
      RunWait, system\OneScript\bin\woscript.exe scripts\auto\ОбрамлениеКода.os
   Return   


}

