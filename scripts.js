var fso;
var WshShell = WScript.CreateObject("WScript.Shell");

function JSTrim(vValue)
{
	return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function delFP(vValue)
{
	return  vValue.replace(/\s*(процедура|функция|procedure|function)\s+/i, "");
}

function getTextBeforeBracket(prmTxt)
{
	var nEnd = prmTxt.indexOf("(");
	return prmTxt.substring(0,nEnd);
}


function echo(prmTxt)
{
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}

function ResultList(prmStr,prmCaption)
{
	choicer = new ActiveXObject("SvcSvc.Service");
	vRes = choicer.FilterValue(prmStr, 273, prmCaption, 0, 0, 0, 0);
	if (!(vRes) == "")
	{
		var nEnd = vRes.indexOf(")")
		var nStr = vRes.substring(1,nEnd);

		WScript.Quit(nStr);
	}
}

function GetMethList(lStrings)
{

	var re_meth = /^\s*(процедура|функция|procedure|function)\s+/i;
	var lListProcFunc = "";

	for(var i=0; i<lStrings.length; i++)
	{
		lStrCurrent = "";
		lStr = lStrings[i];

		var matches = lStr.match(re_meth);
		if (matches != null)
		{
			j = i+1;
			lStrLong = JSTrim(delFP(lStr));
			FuncName = getTextBeforeBracket(lStrLong);
			// FuncPrm = lStrLong.substring(nEnd+1,lStrLong.length-1);
			lListProcFunc += "(" + j + ") "+delFP(FuncName) + "\r\n";
		}
	}
	ResultList(lListProcFunc,"Список процедур\функций");
}


function ExtSearch(prmTxt)
{

	list = "";
	list += "^/?([^/]/?)*ВыражениеТолькоНеКомментариях\r\n"
	list += "//+.*ВыражениеТолькоВКомментариях\r\n";
	list += "//+.*TODO\r\n";
	list += "//+.*FIXME\r\n";
	list += "//+.*BUG\r\n";

	// cs = new ActiveXObject("OpenConf.CommonServices");
	// var vRes = cs.SelectValue(list, "Значение поиска", "", true, true);
	// cs = 0
	
	choicer = new ActiveXObject("SvcSvc.Service");
	vRes = choicer.FilterValue(list, 273, "Значение поиска", 0, 0, 0, 0);	
	
	// res = fso.CreateTextFile("searchresult.txt", true);
	
	if (!(vRes) == "")
	{
		var re = new RegExp(vRes,"ig");
	}
	else
	{
		return;
	}

    var i;
	var lStr = "";
	var lstrRes = "";

    for (i=0; i<prmTxt.length; i++)
    {
        if (prmTxt[i] != "")
        {
			lStr = prmTxt[i];
			var matches = lStr.match(re);
			if (matches != null)
			{
				
				if (i != 0)
				{
					j=i+1;
					
					lstrRes += "(" + j + ") "+ JSTrim(lStr).replace("|","") + "\r\n";
					// res.WriteLine(lstrRes);
					/*
					WScript.Sleep(5);
					WshShell.SendKeys("{HOME}");
					WScript.Sleep(50);
					WshShell.SendKeys("^(g)");
					WshShell.SendKeys("^(п)");
					//
					WScript.Sleep(20);
					WshShell.SendKeys(""+j);

					WScript.Sleep(5);
					WshShell.SendKeys("{HOME}");


					WScript.Sleep(10);
					WshShell.SendKeys("{ENTER}");
					WScript.Sleep(10);
					WshShell.SendKeys("%{F2}");
					WScript.Sleep(5);
					WshShell.SendKeys("{ESC}");
					*/
				}
			}
		}
    }
	// res.Close();
	fso = new ActiveXObject("Scripting.FileSystemObject");
	f = fso.CreateTextFile("search.txt", true);
	f.Write(lstrRes);
	f.Close();
	
	ResultList(lstrRes, "Значение поиска");
}

function lastSearchResultShow() {
	fso = new ActiveXObject("Scripting.FileSystemObject");
	t_file = fso.OpenTextFile("search.txt", 1); 
	str = t_file.ReadAll();
	t_file.Close();
	fso = 0;
	return ResultList(str, "Значение поиска");
}

function preroclist(arg){
	lstrRes = "&НаКлиенте\r\n&НаСервере\r\n\&НаСервереБезКонтекста";
	
	choicer = new ActiveXObject("SvcSvc.Service");
	vRes = choicer.FilterValue(lstrRes, 273, "", 0, 0, 0, 0);
	f = fso.CreateTextFile("module.txt", true);
	f.Write(vRes);
	f.Close();
}

/*function showPrevSarchResult(prmTxt)
{
	var lstrRes = "";
    for (i=0; i<prmTxt.length; i++)
    {
        if (prmTxt[i] != "")
        {
			// lStr = prmTxt[i];
			lstrRes += prmTxt[i] + "\r\n";
		}
    }
	 // lstrRes = "sss\r\n sss\r\n";
	
	ResultList(lstrRes, "Значение поиска");
}*/


function Run()
{
    arg=WScript.Arguments;


    fso = new ActiveXObject("Scripting.FileSystemObject");
	if (arg(0) != 'null') {
		f=fso.OpenTextFile(arg(0),1);
		var lTxt=f.ReadAll();
		var lList =lTxt.split('\r').join('').split('\n');
		f.close();
	}
	switch (arg(1)) {
		case "search":
			ExtSearch(lList);
			break;
		case "search-last":
			lastSearchResultShow();
			break;
		case "proclist":
			GetMethList(lList);
			break;
		case "preprocmenu":
			preroclist();
			break;
		default:
			return; // не должно быть в принципе
	}

}

Run();