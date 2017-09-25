var listFiles = [];
var WshShell = WScript.CreateObject("WScript.Shell");
var fso = new ActiveXObject("Scripting.FileSystemObject");


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
	str = "";
	try {
		str = t_file.ReadAll();
		t_file.Close();
		fs= 0;
	} catch(e) {
		
	}
	return str;
}

function SelectValue(values, header) {
        
        wtiteToResultFile("tmp/app.txt",values);

        WshShell.Run("system\\SelectValueSharp.exe tmp/app.txt", 1, true);
        str = readFile("tmp/app.txt");
        return str;
}

function SearchFile(Folder, RegExpMask){
        var FilesEnumerator = new Enumerator(Folder.Files);
        while (!FilesEnumerator.atEnd()){
                var File = FilesEnumerator.item();
                var FileName = File.Name;//имя файла
                var FilePath = File.Path;//полный путь к файлу
                var FileSize = File.Size;//размер файла
                RegExpMask.compile(RegExpMask);
                var FileByMask = RegExpMask.exec(FileName);
                if (FileByMask){
                        // Log.Write(1, FilePath);//здесь можно выполнять любые действия с найденным файлом
                        //WScript.StdOut.WriteLine(FilePath);
                        //listFiles += FilePath + "\r\n";

                         FileExt = fso.GetExtensionName(FilePath);
                         if (FileExt == "os") {
                         	FilePath = "system\\OneScript\\bin\\oscript.exe " + "\"" + FilePath + "\"";
                         } else {
                         	FilePath = "wscript " + FilePath;
                         }

                        listFiles[listFiles.length] = { key: FileName, value: FilePath };
                }
                FilesEnumerator.moveNext();
        }
        //поиск в подпапках 
        var SubFoldersEnumerator = new Enumerator(Folder.SubFolders);    
        while (!SubFoldersEnumerator.atEnd()){
                var Folder = SubFoldersEnumerator.item();               
                //System.ProcessMessages();//<--здесь можно двигать бегунок
                //Log.Write(1, Folder.Path);//<--здесь можно выполнять любые действия с найденной папкой
                SearchFile(Folder, RegExpMask);
                SubFoldersEnumerator.moveNext();
        }
}


function Run() {
	var array_commands = [
	   { key: 'Выделение в верхний регистр', value: 'system\\OneScript\\bin\\oscript.exe scripts\\РаботаСРегистромТекста.os up' },
	   { key: 'Выделение в нижний регистр', value: 'system\\OneScript\\bin\\oscript.exe scripts\\РаботаСРегистромТекста.os down' },
	   { key: 'Выделение в нормальный регистр', value: 'system\\OneScript\\bin\\oscript.exe scripts\\РаботаСРегистромТекста.os normal' },
	   { key: '----------------------------------------', value: '' },
	   { key: 'Выравнять по равно', value: 'system\\OneScript\\bin\\oscript.exe scripts\\format.os align-equal-sign' },
	   { key: 'Выравнять по первой запятой', value: 'system\\OneScript\\bin\\oscript.exe scripts\\format.os align-first-comma' },
	   { key: 'Выравнять по выбранному значению', value: 'system\\OneScript\\bin\\oscript.exe scripts\\format.os align-user-symbol' },
	   { key: '----------------------------------------', value: '' },
	   { key: 'Убрать пробелы на конце строк', value: 'system\\OneScript\\bin\\oscript.exe scripts\\format.os rtrim' },
	   { key: '============ Автоматически добавленные ============', value: '' }
	]	
	   
	var FileSystem = new ActiveXObject('Scripting.FileSystemObject');
    var RegExpMask = /.*(\.os|\.js)/igm;
    var Folder = FileSystem.GetFolder('scripts\\auto');

    //listFiles = '';

    SearchFile(Folder, RegExpMask);
	len = listFiles.length;
    for (var i = 0 ; i < len; i++) {
    	//echo(listFiles[i].key)
    	array_commands[array_commands.length] = listFiles[i];
    }


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
					// echo(array_commands[i].value);
					WshShell.Run(array_commands[i].value,0,true);	
					WScript.Quit(1);
					break;
				}
			}
		}
	}
	WScript.Quit(0);
}

Run();