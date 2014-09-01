
var WshShell = WScript.CreateObject("WScript.Shell");

var settings = {
// настройки по умолчанию
	authorName		: "",
	companyName		: "RayCon",
	// dateFormat		: "yyyy-mm-dd HH:SS:MM",
	dateFormat		: "yyyy-mm-dd",
	markerAdded		: "+",
	markerChanged	: "*",
	markerDeleted	: "-",
	markerEndBlock	: "/",
	oneliner		: null,
	signature		: "%Author% %Company% %Date%",
	splitter		: " -------- заменено на:",
	doNotIndent		: null,
	doNotSignAtEnd	: null,
	doNotCopyOldCode: null,
	addModDateTimeAtEnd: null
}

function GetFromClipboard() {
	clip = new ActiveXObject("WshExtra.Clipboard");
	str = clip.Paste();
	clip = 0;
	return str;
}


function echo(prmTxt)
{
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}

function indent(line)
{
    var m = line.match(/^(\s*)/);
    if (m) {
        if (m[0] !== line) {
            return m[1];
        }
    }
    return '';
}

function get1CUser(_)
{
	return "";
}

function getOSUser(_)
{
	return WshShell.ExpandEnvironmentStrings("%USERNAME%");
}


function setMarker(markerType, newCode)
{

	s = settings;
	// маркер
	var AC_Marker = "";
	switch (markerType) {
		case 1:
			AC_Marker = s.markerAdded;
			break;
		case 2:
			AC_Marker = s.markerChanged;
			break;
		case 3:
			AC_Marker = s.markerDeleted;
			break;
		default:
			return; // не должно быть в принципе
	}
	
	// разделитель старого и нового кода при замене
	var AC_Splitter = s.splitter; 

	// Дата и время
	var AC_Date = getCurrentDate(s.dateFormat);
	var AC_Time = getCurrentTime(); // перемення %Time% осталась для совместимости

	// Автор
	var AC_Author = s.authorName.replace(/%1CUser%/i, get1CUser()).replace(/%OSUser%/i, getOSUser());
	// Сигнатура
	var AC_Sign = s.signature.replace(/%Author%/i, AC_Author)
				.replace(/%Company%/i, s.companyName)
				.replace(/%Date%/i, AC_Date)
				.replace(/%Time%/i, AC_Time);

		var block		= newCode ;
		var lines	= block.split(/\r\n/);
		var ind		= s.doNotIndent?"":indent(lines[0]);									
		// открывающий маркер блока
		block = "\r\n" + ind + "//" + AC_Marker + AC_Sign + "\r\n";
		// удаление или замена кода - комментируем блок
		if (markerType != 1) {	
			if ((markerType != 2) || !s.doNotCopyOldCode) {
				block += commentLines(lines, ind);		
			}
		}
	
		// замена кода - добавляем разделитель старого и нового кода
		if (markerType == 2) {
			// при копировании одной строки разделителя не ставим (XXX может сделать опционально?)
			if (AC_Splitter && !s.doNotCopyOldCode) {
			// if (AC_Splitter && !s.doNotCopyOldCode && (doc.SelStartLine != doc.SelEndLine)) {
				block += ind + "//" + AC_Splitter + "\r\n";
			}	
		}
			
		// добавленный или скопированный код
		if (markerType != 3) {					
			block += (newCode?newCode:lines.join("\r\n")) + "\r\n";
		}
			
		// закрывающий маркер блока
		block += ind + "//" + s.markerEndBlock + (s.doNotSignAtEnd?"":AC_Sign) + "\r\n";

		fso = new ActiveXObject("Scripting.FileSystemObject");
		var defFile = fso.CreateTextFile("actxt.tmp",true);
		defFile.WriteLine(block);
		defFile.Close();
}

function PasteTextFromClipboard(prmVar)
{
	clipboard = GetFromClipboard();

	if (!clipboard) {
		return;
	}
	setMarker(prmVar, clipboard);
}

function commentLines(lines, ind)
{
	var ret = "";
	for (var i=0; i<lines.length; i++) {
		ret += ind + "//" + lines[i] + "\r\n";
	}
	return ret;
}

// посвящается Шарлин Спитери из TEXAS :-)
function ZeroZero(num)
{
	return (num>9)?num:('0'+num);
}

function getCurrentDate(format)
{
    with (new Date) {        	
		return format.replace(/yyyy/, getYear())
		.replace(/yy/, (new String(getYear())).substr(2,2))
		.replace(/dd/, ZeroZero(getDate()))
		.replace(/mm/, ZeroZero(getMonth()+1))
		.replace(/HH/, ZeroZero(getHours()))
		.replace(/MM/, ZeroZero(getMinutes()))
		.replace(/SS/, ZeroZero(getSeconds()))
	}
}

function getCurrentTime(_)
{
	with (new Date) {
		return getHours() + ':' + (getMinutes() + 1) + '.' + getSeconds();
	}
}

function Init(_) // Фиктивный параметр, чтобы процедура не попадала в макросы
{
	arg=WScript.Arguments;
	try {
		arg=WScript.Arguments;

		switch (arg(0)) {
			case "new":
				PasteTextFromClipboard(1);
				break;
			case "edit":
				PasteTextFromClipboard(2);
				break;
			case "del":
				PasteTextFromClipboard(3);
				break;
			default:
				return; // не должно быть в принципе
		}
	}
	catch (e) {
		echo("Ошибка: "+ e.description);
	}	
}

Init(1);
