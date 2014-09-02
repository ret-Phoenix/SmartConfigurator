fso = new ActiveXObject("Scripting.FileSystemObject");
choicer = new ActiveXObject("SvcSvc.Service");

function setDefaultCfg() {
	Folder = fso.GetFolder('configs/')
	Files = new Enumerator(Folder.Files);
	cfgName = '';
	for (var i=0; i < Folder.Files.Count; i++)
	{
		if (Files.item()!=undefined) 
		{
			cfgName += Files.item().Name + "\r\n";
		}
		Files.moveNext()
	}
	vRes = SelectValue(cfgName);
	wtiteToResultFile('configs/default.txt', vRes);
	wtiteToResultFile('tmp/module.txt', '');
	WScript.Quit(1);
	return;
}


function SelectValue(values, header) {
	return choicer.FilterValue(values, 273, header, 0, 0, 0, 0);
}

function ResultList(prmStr,prmCaption)
{
	vRes = choicer.FilterValue(prmStr, 273, prmCaption, 0, 0, 0, 0);
	if (!(vRes) == "")
	{
		return vRes;
	}
}

function GetFromClipboard() {
	clip = new ActiveXObject("WshExtra.Clipboard");
	str = clip.Paste();
	clip = 0;
	return str;
}

// function SetToClipboard(dataToClip) {
	// clip = new ActiveXObject("WshExtra.Clipboard");
	// clip.Copy(dataToClip);
	// clip = 0;
// }

function choiceMDObject() {
    
	// Выбор текущего файла метаданных
	File = fso.GetFile("configs/default.txt");
	TextStream = File.OpenAsTextStream(1);
	cfg_file_name = TextStream.ReadLine();
	
	File = fso.GetFile("configs/"+cfg_file_name);
	TextStream = File.OpenAsTextStream(1);
	
	// Получаем список доступных объектов метаданных
	str = TextStream.ReadLine();
	File = 0;
	str1 = str.replace(/\,/g,"\r\n");
	
	// Выбираем Объект
	md_obj = ResultList(str1,"");
	
	// Находим номер строки в файле для данного объекта метаданных
	var lList = str1.split('\r').join('').split('\n');
	pos = -1;
	for (var i = 0; i < lList.length; i++) {
		if (lList[i]==md_obj) {
			pos = i;
		}
	}
	
	// Получаем структуру объекта метаданных
	str = TextStream.ReadAll();
	var lList = str.split('\r').join('').split('\n');
	str = lList[pos];
	
	return str;
}


function wtiteToResultFile(file_name, file_data) {
	f = fso.CreateTextFile(file_name, true);
	f.Write(file_data);
	f.Close();
}

function ModuleFromSimpleToManagment()
{
	str = choiceMDObject();
	if (str == "") {
		wtiteToResultFile("tmp/module.txt","");
		WScript.Quit(0);
		return;
	}
	
	// Получаем реквизиты шапки
	item_ar = str.split('|');
	str_items = item_ar[1];
	
	// Получаем названия табличных частей
	for (var i = 2; i < item_ar.length; i++) {
		item_ar_sub = item_ar[i].split(',');
		str_items = str_items + item_ar_sub[0] + ",";
	}
	
	// Преобразуем идентификаторы для замены
	str_items = str_items.replace(/\,/g,'|');
	str_items = str_items.substring(0,str_items.length-1);
	
	// Выбираем название основного реквизита формы
	result = ResultList("Объект\r\nОтчет\r\n","Реквизит");
	var re = new RegExp("[\\W]("+str_items+").\\W", "ig");
	str_module = GetFromClipboard();
	
	// Производим замену кода
	// 1. Обрамляем пробелами управляющие символы
	str_module = str_module.replace(/[\*\-\+\=\/\(]/g,' $& ');
	// 2. Добавляем название основного реквизита в модуле
	str_module = str_module.replace(re," "+result+".$&").replace(/\.\s/g, '.');
	
	// Пишем результат в файл
	wtiteToResultFile("tmp/module.txt",str_module);
}

function printArrayToCodeGen(text, arr, start_pos, prefix) {
	for (var i = start_pos; i < arr.length; i++) {
		if (arr[i] != '') {
			text += prefix + '.' +arr[i] + ' = ;\r\n';
		}
	}
	return text;
}

function generateCodeMDObject(md_obj_part) {
	str = choiceMDObject();
	if (str == "") {
		wtiteToResultFile("tmp/module.txt","");
		WScript.Quit(0);
		return;
	}
	vars = ('док,спр,запись').replace(/\,/g,'\r\n');
	varName = SelectValue(vars);
	
	// Получаем реквизиты шапки
	item_ar = str.split('|');
	md_type = item_ar[0];
	md_type_ar = md_type.split('.');
	
	text = '';
	
	if ((md_type_ar[0] == 'Документ') || (md_type_ar[0] == 'Справочник')) {
		if (md_type_ar[0] == 'Документ') {
			text += varName + ' = Документы.' + md_type_ar[1] + '.СоздатьДокумент();\n'
		}
		if (md_type_ar[0] == 'Справочник') {
			text += varName + ' = Справочники.' + md_type_ar[1] + '.СоздатьЭлемент();\n'
		}
		// Шапка
		text = printArrayToCodeGen(text, item_ar[1].split(','),0,varName);
		
		if (md_obj_part == 'Шапка') {
			wtiteToResultFile('tmp/module.txt', text);
			WScript.Quit(1);
			return;
		}

		if (md_obj_part == 'Табличная часть') {
			text = '';

			details_list = '';
			// Получаем названия табличных частей
			for (var i = 2; i < item_ar.length; i++) {
				item_ar_sub = item_ar[i].split(',');
				details_list += item_ar_sub[0] + '\r\n';
			}
			
			detName = SelectValue(details_list,'');
			if (detName == "") {
				wtiteToResultFile('tmp/module.txt', '');
				WScript.Quit(0);
				return;
			}
			
			for (var i = 2; i < item_ar.length; i++) {
				item_ar_sub = item_ar[i].split(',');
				if (item_ar_sub[0] == detName) {
					text += 'Строка = ' + varName + '.' + item_ar_sub[0] + '.Добавить();\r\n';
					text = printArrayToCodeGen(text, item_ar[i].split(','), 1, 'Строка');
					text += '\r\n\r\n';
				}
			}
			
			wtiteToResultFile('tmp/module.txt', text);
			WScript.Quit(1);
			return;
		}

		
		text += '\r\n\r\n';
		// Получаем названия табличных частей
		for (var i = 2; i < item_ar.length; i++) {
			item_ar_sub = item_ar[i].split(',');
			text += 'Строка = ' + varName + '.' + item_ar_sub[0] + '.Добавить();\r\n';
			text = printArrayToCodeGen(text, item_ar[i].split(','), 1, 'Строка');
			text += '\r\n\r\n';
		}
	} 
	else {
		text += varName + ' = Движения.' + md_type_ar[1] + '.Добавить();\r\n'
		// Стандартные реквизиты
		text += '\r\n';
		text += '// Стандартные реквизиты';
		text += '\r\n';
		text = printArrayToCodeGen(text, item_ar[1].split(','),0,varName);
		// Получаем измерения
		text += '\r\n// Измерения\r\n';
		text = printArrayToCodeGen(text, item_ar[2].split(','), 0, varName);
		// Получаем ресурсы
		text += '\r\n// Ресурсы\r\n';
		text = printArrayToCodeGen(text, item_ar[3].split(','), 0, varName);
		// Получаем реквизиты
		text += '\r\n// Реквизиты\r\n';
		text = printArrayToCodeGen(text, item_ar[4].split(','), 0, varName);
	}
	
	wtiteToResultFile('tmp/module.txt', text);
}

function codeGenerator() {
	lstrRes = ("Объект метаданных,Табличная часть,Шапка,Конфигурация по умолчанию").replace(/\,/g,'\r\n');;
	vRes = SelectValue(lstrRes);
	if (vRes == 'Конфигурация по умолчанию') {
		setDefaultCfg();
	}
	else {
		generateCodeMDObject(vRes);	
	}
	
}

function Run() {
	
    arg=WScript.Arguments;

    fso = new ActiveXObject("Scripting.FileSystemObject");
	if (arg(0) != 'null') {
		f=fso.OpenTextFile(arg(0),1);
		var lTxt=f.ReadAll();
		var lList =lTxt.split('\r').join('').split('\n');
		f.close();
	}
	switch (arg(1)) {
		case "simple-managment":
			ModuleFromSimpleToManagment();
			break;
		case "generator":
			codeGenerator();
			break;
		default:
			return; // не должно быть в принципе
	}
}

Run();