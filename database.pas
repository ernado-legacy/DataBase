program PDataBase;
uses
  crt{, repository}{, .. };

const
  DBFPATH = 'database.db';

type Tuser = record
  name, surname, school, city, dob: string;
end;

type TDataBase = object
     dataFile:text;
     count:byte;
     session:boolean;
     private
     _iterator:word;
     public
     constructor init(path:string);
     procedure openSession;
     procedure closeSession;
     function iterator:word;
     function getUser:Tuser;
     private
     function checkFormat:boolean;
     procedure loadParams;
     procedure skipLine;
     function getLine:string;
end;

var
  dataBase:TDataBase;

{выводит на экран сообщение об ошибке и завершает программу с кодом
         msg - сообщение
         stop - завершене программы после отображения ошибки}

procedure raiseError(msg:string; stop:boolean=true);
begin
     ClrScr;
     WriteLn('RUNTIME ERROR');
     Writeln(msg);
     ReadKey;
     if stop then halt(-1);
end;

{конвертирует строку в число с обработкой ошибок
              s - строка, содержащая число}
function value(s:string):integer;
var
  _code:integer;
  _t:string;
begin
     val(s,value,_code);
     if _code <> 0 then
     begin
        _t := 'CONVERTING ERROR on converting <' + s + '> to integer';
        raiseError(_t);
     end;
end;

{иницирует базу данных с обработкой ошибок
           path - путь к базе данных}
Constructor TdataBase.init(path:string);
begin
     {$I-}Assign(dataFile,path);
     if (IOResult <> 0) then raiseError('IO ERROR on database read');   {$I+}
     if not checkFormat then raiseError('DATABASE FORMAT ERROR on database read');
     loadParams;
end;

{проверяет на сооветствие файла базы данных}
function TdataBase.checkFormat:boolean;
var _t:string;
begin
     checkFormat:=false;
     Reset(dataFile);
     ReadLn(datafile,_t);
     if (_t='database') then checkFormat:=true;
     closeSession;
end;

{открывает файл на чтение}
procedure TdataBase.openSession;
begin
     if session then raiseError('SESSION ALREADY OPENED on session start');
     {$I-}
     Reset(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR on session start');
     {$+}

     session := true;
end;

{закрывает сессию}
procedure TdataBase.closeSession;
begin
     if not session then raiseError('NO SESSION TO CLOSE on session close');
     {$I-}
     Close(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR on session close');
     {$I+}
end;

{загружает информацию о базе данных}
procedure TdataBase.loadParams;
begin
     openSession;
     skipLine;
     count := value(getLine);
     _iterator := value(getLine);
     closeSession;
end;

{возвращает уникальный идентификатор}
function TdataBase.iterator:word;
begin
     inc(_iterator);
     iterator:=_iterator;
end;

procedure TdataBase.skipLine;
begin
     if no session then raiseError('NO SESSION ERROR on skip line');
     {$I-}
     ReadLn(dataFile);
     if (IOResult <> 0) then raiseError('IO ERROR on skip line');
     {$I+}
end;

{возвращает следующую строку в файле}
function TdataBase.getLine:string;
var
   _t:string;
begin
     ReadLn(dataFile,_t);
     getLine := _t;
end;

{вовзращает сущность из базы данных}
function TdataBase.getUser:TUser;
begin
     if not session then raiseError('NO SESSION ERROR on getUser');
     {$I-}
     if (getLine <> 'user') then raiseError('TYPE ERROR on getUser');
     with getUser do
     begin
          name:=getLine;
          surname:=getLine;
          dob:=getLine;
          school:=getLine;
          city:=getLine;
     end;
     if (getLine <> 'enduser') then raiseError('TYPE ERROR on getUser');
     if (IOResult <> 0) then  raiseError('IO ERROR on getUser');
     {$I+}
end;

begin
{ChDir('D:\Work\liceum\database');}
dataBase.init(DBFPATH);
WriteLn(dataBase.count);
WriteLn(dataBase.iterator);
ReadKey;
end.
