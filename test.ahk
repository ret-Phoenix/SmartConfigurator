; Сохранить Отчет как внешний {F11}
^j::
; 	WinWaitActive, Конфигуратор - Конфигурация
	WinWaitActive, , 
	Send, {CTRLDOWN}t{CTRLUP}{APPSKEY}
	IfWinNotActive, , , WinActivate, , 
	WinWaitActive, , 
	Send, {DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{ENTER}
Return


^k::
WinWait, Конфигуратор - Конфигурация, Отчет ОтчетПоЗадачам
IfWinNotActive, Конфигуратор - Конфигурация, Отчет ОтчетПоЗадачам, WinActivate, Конфигуратор - Конфигурация, Отчет ОтчетПоЗадачам
WinWaitActive, Конфигуратор - Конфигурация, Отчет ОтчетПоЗадачам
MouseClick, left,  623,  96
Sleep, 100
Send, {CTRLDOWN}t{CTRLUP}{APPSKEY}
; WinWait, , 
IfWinNotActive, , , WinActivate, , 
WinWaitActive, , 
Send, {DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{ENTER}
Return