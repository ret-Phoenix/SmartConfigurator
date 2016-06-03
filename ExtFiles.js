var listFiles = '';
var fso = new ActiveXObject("Scripting.FileSystemObject");
var WshShell = WScript.CreateObject("WScript.Shell");


function log(msg) {
        f = fso.OpenTextFile("log.txt", 8,true);
        f.WriteLine(msg);
        f.Close();
}

function JSTrim(vValue)
{
        return  vValue.replace(/(^\s*)|(\s*$)/g, "");
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


function wtiteToResultFile(file_name, file_data) {
        f = fso.CreateTextFile(file_name, true);
        f.Write(file_data);
        f.Close();
}

function Main() {
        var FileSystem = new ActiveXObject('Scripting.FileSystemObject');
        var RegExpMask = /.*(\.epf|\.erf|\.cf)/igm;
        var Folder = FileSystem.GetFolder('c:\\work\\db\\ExtForms\\v8extforms\\');

        listFiles = '';

        SearchFile(Folder, RegExpMask);

        // Folder = FileSystem.GetFolder('c:\\work\\');
        // SearchFile(Folder, RegExpMask);

        vRes = SelectValue(listFiles,"файлы");
        wtiteToResultFile("tmp/module.txt",JSTrim(vRes));
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
                        listFiles += FilePath + "\r\n";
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

Main();