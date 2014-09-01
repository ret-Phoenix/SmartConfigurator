

function ResultList(prmStr,prmCaption)
{
	choicer = new ActiveXObject("SvcSvc.Service");
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

function getMDObj()
{
	
    fso = new ActiveXObject("Scripting.FileSystemObject");
	File = fso.GetFile("AmCham.txt")
	TextStream = File.OpenAsTextStream(1)	
	str = TextStream.ReadLine();
	File = 0;
	str1 = str.replace(/\,/g,"\r\n");
	md_obj = ResultList(str1,"");
	
	var lList = str1.split('\r').join('').split('\n');
	pos = -1;
	for (var i = 0; i < lList.length; i++) {
		if (lList[i]==md_obj) {
			pos = i;
		}
	}
	
	str = TextStream.ReadAll();
	var lList = str.split('\r').join('').split('\n');
	str = lList[pos];
	
	item_ar = str.split('|');
	str_items = item_ar[1];
	
	for (var i = 2; i < item_ar.length; i++) {
		item_ar_sub = item_ar[i].split(',');
		str_items = str_items + item_ar_sub[0] + ",";
	}
	
	str_items = str_items.replace(/\,/g,'|');
	str_items = str_items.substring(0,str_items.length-1);
	
	result = ResultList("Объект\r\nОтчет\r\n","Реквизит");
	var re = new RegExp("[\\W]("+str_items+").\\W", "ig");
	str_module = GetFromClipboard();
	
	str_module = str_module.replace(/[\*\-\+\=\/\(]/g,' $& ');
	str_module = str_module.replace(re," "+result+".$&").replace(/\.\s/g, '.');
	
	f = fso.CreateTextFile("module.txt", true);
	f.Write(str_module);
	f.Close();
}


function Run() {
	
	getMDObj();
}


Run();

