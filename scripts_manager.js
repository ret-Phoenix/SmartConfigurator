var WshShell = WScript.CreateObject("WScript.Shell");

function JSTrim(vValue) {
	return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function echo(prmTxt) {
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}

function wtiteToResultFile(file_name, file_data) {
		var fso = new ActiveXObject("Scripting.FileSystemObject");
        f = fso.CreateTextFile(file_name, true);
        f.Write(file_data);
        f.Close();
}

function readFile(fileName) {
        fs = new ActiveXObject("Scripting.FileSystemObject");
        t_file = fs.OpenTextFile(fileName, 1); 
        str = t_file.ReadAll();
        t_file.Close();
        fs= 0;
        return str;
}

function SelectValue(values, header) {
        
        wtiteToResultFile("tmp/app.txt",values);

        WshShell.Run("system\\SelectValueSharp.exe tmp/app.txt", 1, true);
        str = readFile("tmp/app.txt");
        return str;
}

function Run() {
	var array_commands = [
	   { key: 'Добавить перенос строк', value: 'wscript format.js null format_block_vert' },  
	   { key: 'Убрать перенос строк', value: 'wscript format.js null un_format_block_vert' },
	   { key: '----------------------------------------', value: '' },
	   { key: 'Выделение в верхний регистр', value: 'system\\OneScript\\bin\\oscript.exe РаботаСРегистромТекста.os up' },
	   { key: 'Выделение в нижний регистр', value: 'system\\OneScript\\bin\\oscript.exe РаботаСРегистромТекста.os down' },
	   { key: 'Выделение в нормальный регистр', value: 'system\\OneScript\\bin\\oscript.exe РаботаСРегистромТекста.os normal' },
	   { key: '----------------------------------------', value: '' },
	   { key: 'Выравнять по равно', value: 'system\\OneScript\\bin\\oscript.exe format.os align-equal-sign' },
	   { key: 'Выравнять по первой запятой', value: 'system\\OneScript\\bin\\oscript.exe format.os align-first-comma' },
	   { key: 'Выравнять по выбранному значению', value: 'system\\OneScript\\bin\\oscript.exe format.os align-user-symbol' },
	   { key: '----------------------------------------', value: '' },
	   { key: 'Очистить модуль', value: 'system\\OneScript\\bin\\oscript.exe ModuleCleaner.os' },
	   { key: 'Убрать пробелы на конце строк', value: 'system\\OneScript\\bin\\oscript.exe format.os rtrim' }
	]	
	   
	var array_run = new Array();
	str_select = "";
	for (var i = 0, len = array_commands.length; i < len; i++) {
		str_select += array_commands[i].key + '\r\n';
	}
	run_command = JSTrim(SelectValue(str_select, 'Команда'));

	if (run_command != "") {
		for (var i = 0, len = array_commands.length; i < len; i++) {
			if (array_commands[i].key == run_command) {
				if (array_commands[i].value != "") {
					WshShell.Run(array_commands[i].value,0,true);	
					break;
				}
			}
		}
	}
	
}

Run();