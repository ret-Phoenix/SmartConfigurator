var fso = new ActiveXObject("Scripting.FileSystemObject");
var str_from_file = "";

function echo(prmTxt)
{
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}

function GetFromClipboard() {
	clip = new ActiveXObject("WshExtra.Clipboard");
	str = clip.Paste();
	clip = 0;
	return str;
}

function JSTrim(vValue)
{
	return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function wtiteToResultFile(file_name, file_data) {
	f = fso.CreateTextFile(file_name, true);
	f.Write(file_data);
	f.Close();
}

function un_format_block_vert(arg){
	var list_rows = str_from_file.split('\r').join('').split('\n');;

	new_str_arr = "";
	for (var i = 0; i < list_rows.length; i++) {
		cur_row = JSTrim(list_rows[i]);
		if (cur_row.substring(0,1) == "|") {
			cur_row = cur_row.substring(1);
		}
		new_str_arr += cur_row + '\r\n';
	}
	wtiteToResultFile("tmp/module.txt", JSTrim(new_str_arr));
}

function format_block_vert(arg){
	var list_rows = str_from_file.split('\r').join('').split('\n');;

	new_str_arr = "";
	for (var i = 0; i < list_rows.length; i++) {
		new_str_arr += "|	" + JSTrim(list_rows[i]) + '\r\n';
	}
	new_str_arr = JSTrim(new_str_arr);
	wtiteToResultFile("tmp/module.txt", new_str_arr);
}

function Run()
{
    arg=WScript.Arguments;

    fso = new ActiveXObject("Scripting.FileSystemObject");
	if (arg(0) != 'null') {
		f=fso.OpenTextFile(arg(0),1);
		var lTxt=f.ReadAll();
		str_from_file =lTxt.split('\r').join('').split('\n');
		f.close();
	} else {
		str_from_file = GetFromClipboard();
	}
	switch (arg(1)) {
		case "format_block_vert":
			format_block_vert(str_from_file);
			break;
		case "un_format_block_vert":
			un_format_block_vert(str_from_file);
			break;
		default:
			return; // не должно быть в принципе
	}
}

Run();