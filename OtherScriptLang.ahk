#include WorkWithModule.ahk
; Ctrl + shit + 1
^+1::
	putSelectionInFile()
	RunWait, c:\work\portable\OpenServer\modules\php\PHP-5.2\php.exe scripts\example.php
	pasteTextFromFile()
return

; Ctrl + shit + 2
^+2::
	putSelectionInFile()
	RunWait, scripts\example.py
	pasteTextFromFile()
return

