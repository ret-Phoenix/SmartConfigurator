var fso = new ActiveXObject("Scripting.FileSystemObject");
//var choicer = new ActiveXObject("SvcSvc.Service");
var WshShell = WScript.CreateObject("WScript.Shell");

function JSTrim(vValue)
{
	return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function delFP(vValue)
{
	return  vValue.replace(/\s*(процедура|функция|procedure|function|#Область|#region)\s+/i, "");
}

function getTextBeforeBracket(prmTxt)
{
	var nEnd = prmTxt.indexOf("(");
	return prmTxt.substring(0,nEnd);
}

function log(msg) {
	// OpenTextFile("C:\Test.txt", 2, True)
	f = fso.OpenTextFile("log.txt", 8,true);
	f.WriteLine(msg);
	f.Close();
	f=0;
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

function echo(prmTxt)
{
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}

function ResultList(prmStr, prmCaption)
{
	wtiteToResultFile("tmp/app.txt", prmStr);

	WshShell.Run("system\\SelectValueSharp.exe tmp\\app.txt",1,true);
	str = readFile("tmp/app.txt");

	if (JSTrim(str) != "") {
		var nEnd = str.indexOf(")")
		var nStr = str.substring(1,nEnd);
		WScript.Quit(nStr);
	} else {
		WScript.Quit(0);
	}
}


// function ResultListDLL(prmStr, prmCaption)
// {
// 	vRes = choicer.FilterValue(prmStr, 273+512, prmCaption, 0, 0, 0, 0);
// 	if (!(vRes) == "")
// 	{
// 		var nEnd = vRes.indexOf(")")
// 		var nStr = vRes.substring(1,nEnd);

// 		WScript.Quit(nStr);
// 	}
// }

function SelectValue(values, header) {
	
	if (JSTrim(values) == "") {
		return "";
	}
	
	wtiteToResultFile("tmp/app.txt",values);

	WshShell.Run("system\\SelectValueSharp.exe tmp/app.txt",1,true);
	str = readFile("tmp/app.txt");
	//echo(str);
	return str;
	
	//return choicer.FilterValue(values, 273+512, header, 0, 0, 0, 0);
}

function wtiteToResultFile(file_name, file_data) {
	f = fso.CreateTextFile(file_name, true);
	f.Write(file_data);
	f.Close();
}

function actionGoToType(lStrings) {
	
	var lListProcFunc = "";

	data = lStrings;
	StrToChoice = '';
	UpCount = 0;

	data = lStrings.reverse();
	var re_meth = /(ссылается на)/i;

	CntRows = data.length;
	// rowBM = 1;
	for(var i=0; i < CntRows; i++)
	{
		lStr = data[i];
		var matches = lStr.match(re_meth);
		if (matches != null)
		{
			break;
		}
		if (JSTrim(lStr) != "") {
			UpCount++;
			StrToChoice +=  "("+UpCount+") "+ lStr + "\r\n";
		}
	}
	if (UpCount == 1) {
		WScript.Quit(1);
	} else if (UpCount == 0) {
		WScript.Quit(0);
	} else {
		vRes = ResultList(StrToChoice,"");
	}
	//wtiteToResultFile("tmp/module.txt",JSTrim(vRes));
}

function actionGoToObject(lStrings) {
	
	var lListProcFunc = "";

	data = lStrings;
	StrToChoice = '';
	UpCount = 0;

	CntRows = data.length;
	for(var i=1; i < CntRows-1; i++)
	{
		var str = data[i];
		StrToChoice +=  str + "\r\n";
		UpCount++;
	}
	if (StrToChoice != "") {
		if (UpCount > 1) {
			var resultStr = SelectValue(StrToChoice);
			wtiteToResultFile("tmp/module.txt", JSTrim(resultStr));
		} else {
			wtiteToResultFile("tmp/module.txt", "");
		}
	} else {
		wtiteToResultFile("tmp/module.txt","");
		echo("Пустой список");
	}
}


function Run()
{
    arg=WScript.Arguments;

    fso = new ActiveXObject("Scripting.FileSystemObject");
	if (arg(0) != 'null') {
		File = fso.GetFile(arg(0));
		if (File.Size > 0) {
			f=fso.OpenTextFile(arg(0),1);
			var lTxt = f.ReadAll();
			var lList = lTxt.split('\r').join('').split('\n');
			f.close();
		} else {
			var lList = [];
		}
		
	} 
	switch (arg(1)) {
		case "gototype":
			actionGoToType(lList);
			break;
		case "gotoobject":
			actionGoToObject(lList);
			break;
		default:
			return; // не должно быть в принципе
	}

}

Run();