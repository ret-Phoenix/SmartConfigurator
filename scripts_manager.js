var choicer = new ActiveXObject("SvcSvc.Service");
var WshShell = WScript.CreateObject("WScript.Shell");

function JSTrim(vValue)
{
	return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function echo(prmTxt)
{
	with (new ActiveXObject("WScript.Shell")) res = Popup("<"+prmTxt+">", 0, "title", 0);
}


function SelectValue(values, header) {
	return choicer.FilterValue(values, 273, header, 0, 0, 0, 0);
}

function Run()
{
	var array_commands = [
	   { key: 'Добавить перенос строк', value: 'wscript format.js null format_block_vert' },  
	   { key: 'Убрать перенос строк', value: 'wscript format.js null un_format_block_vert' }
	]	
	   
	var array_run = new Array();
	str_select = "";
	for (var i = 0, len = array_commands.length; i < len; i++) {
		str_select += array_commands[i].key + '\r\n';
	}
	run_command = JSTrim(SelectValue(str_select, 'Команда'));
	// echo(run_command);
	for (var i = 0, len = array_commands.length; i < len; i++) {
		if (array_commands[i].key == run_command) {
			// echo(array_commands[i].value);
			WshShell.Run(array_commands[i].value,1,true);	
			break;
		}
	}
	
}

Run();