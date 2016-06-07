#include WorkWithModule.ahk

^+1::
	putSelectionInFile()
	RunWait, c:\work\portable\OpenServer\modules\php\PHP-5.2\php.exe example.php
	pasteTextFromFile()
return

^+2::
	putSelectionInFile()
	RunWait, example.py
	pasteTextFromFile()
return

