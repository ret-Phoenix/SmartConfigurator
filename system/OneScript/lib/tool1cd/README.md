#Чтение файловых баз даннх 1С с помощью tool1cd

Программная скриптовая обертка для популярной утилиты чтения файловых баз данных tool1cd от [awa](http://infostart.ru/profile/13819/) Удобно использовать, например, для работы с хранилищем 1С.

Предоставляет 2 класса:

## ЧтениеТаблицФайловойБазыДанных

Позволяет считать любую таблицу базы данных в виде ТаблицыЗначений

## ЧтениеХранилищаКонфигурации

Использует класс *ЧтениеТаблицФайловойБазыДанных* для доступа к базе Хранилища конфигураций 1С.