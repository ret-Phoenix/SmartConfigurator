var listFiles = '';
var fso = new ActiveXObject("Scripting.FileSystemObject");
var choicer = new ActiveXObject("SvcSvc.Service");
var WshShell = WScript.CreateObject("WScript.Shell");

function JSTrim(vValue)
{
        return  vValue.replace(/(^\s*)|(\s*$)/g, "");
}

function SelectValue(values, header) {
        return choicer.FilterValue(values, 273+512, header, 0, 0, 0, 0);
}


function wtiteToResultFile(file_name, file_data) {
        f = fso.CreateTextFile(file_name, true);
        f.Write(file_data);
        f.Close();
}

function Main() {
//Пример запуска

        var FileSystem = new ActiveXObject('Scripting.FileSystemObject');
        try {
                var Drive = FileSystem.Drives.Item('D'); 
        } catch (e){
                Log.Write(1, 'Диск не найден');
                return
        }
        var RegExpMask = /.*(\.epf|\.erf|\.cf)/igm;//<--файлы с расширением .avi
        // var Folder = Drive.RootFolder;//Можно использовать метод GetFolder('имя папки') для подпапок
        var Folder = FileSystem.GetFolder('c:\\work\\db\\');

        listFiles = '';

        SearchFile(Folder, RegExpMask);

        // Folder = FileSystem.GetFolder('c:\\work\\db\\xUnitFor1C\\xUnitFor1C-ext\\');
        // SearchFile(Folder, RegExpMask);

        vRes = SelectValue(listFiles,"файлы");
        wtiteToResultFile("tmp/module.txt",JSTrim(vRes));
}
 
function SearchFile(Folder, RegExpMask){
//Рекурсивная функция поиска файлов по маске
        //поиск файлов в папке Folder
        var FilesEnumerator = new Enumerator(Folder.Files);
        while (!FilesEnumerator.atEnd()){
                var File = FilesEnumerator.item();
                var FileName = File.Name;//имя файла
                var FilePath = File.Path;//полный путь к файлу
                var FileSize = File.Size;//размер файла
                RegExpMask.compile(RegExpMask);
                var FileByMask = RegExpMask.exec(FileName);
                // System.ProcessMessages();//<--здесь можно двигать бегунок
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