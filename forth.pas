{
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

  Simple Forth-inspired language interpreter
  Author: Kruchinin Tim
}

type
 Pstack = ^stack;
 stack = record
  next: Pstack;
  value: longint;
 end;

function stack_init(val: longint): Pstack;
 var
  t: Pstack;
 begin
  new(t);
  t^.value := val;
  t^.next := nil;
  stack_init := t;
 end;

function stack_depth(s: Pstack): longint;
 var
  d: integer;
 begin
  d := 0;
  while s^.next <> nil do
   begin
    inc(d);
    s := s^.next;
   end;
  stack_depth := d;
 end;

procedure stack_delete(var s: Pstack);
 var
  t: Pstack;
 begin
  while (s^.next <> nil) do
   begin
    t := s;
    s := s^.next;
    dispose(t);
   end
 end;

type
 Pdict = ^dict;
 dict = record
  name: string;
  code: string;
  next: Pdict;
 end;

function dict_init(name, code: string): Pdict;
 var
  t: Pdict;
 begin
  new(t);
  t^.name := name;
  t^.code := code;
  t^.next := nil;
  dict_init := t;
 end;

const
  RAMsize = 65536;
type vars = record
  arr: array of byte;
  size: word;
end;

procedure push(var s: Pstack; n: longint; var e: boolean);              // ( -- n )
 var
  t: Pstack;
 begin
  e := false;
  t := stack_init(n);
  t^.next := s;
  s := t;
 end;

procedure pop(var s: Pstack; var n: longint; var e: boolean);           // ( n -- )
 var
  t: Pstack;
 begin
  e := false;
  if (s^.next = nil) then
   begin
    e := true;
    write('Error: stack underflow ');
   end
  else
   begin
    n := s^.value;
    t := s;
    s := s^.next;
    dispose(t);
   end;
 end;

procedure add(var s: Pstack; var e: boolean);                           // ( a b -- {a + b} )
 var
  a,b: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
      push(s,a+b,e);
   end;
 end;

procedure sub(var s: Pstack; var e: boolean);                           // ( a b -- { a - b } )
 var
  a,b: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
      push(s,b-a,e);
   end;
 end;

procedure mult(var s: Pstack; var e: boolean);                          // ( a b -- { a * b} )
 var
  a,b: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
      push(s,a*b,e);
   end;
 end;

procedure divmod(var s: Pstack; var e: boolean);                        // ( a b -- {a div b} {a mod b} )
 var
  a,b: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
     begin
      push(s,b mod a,e);
      push(s,b div a,e);
     end;
   end;
 end;

procedure dup(var s: Pstack; var e: boolean);                           // ( a -- a a )
 var
  n: longint;
 begin
  pop(s,n,e);
  if (not e) then
   begin
    push(s,n,e);
    push(s,n,e);
   end;
 end;

procedure swap(var s: Pstack; var e: boolean);                          // ( a b -- b a )
 var
  a,b: longint;
 begin
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
     begin
      push(s,a,e);
      push(s,b,e);
     end;
   end;
 end;

procedure over(var s: Pstack; var e: boolean);                          // ( a b -- a b a )
 var
  a,b: longint;
 begin
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if (not e) then
     begin
      push(s,b,e);
      push(s,a,e);
      push(s,b,e);
     end;
   end;
 end;

procedure drop(var s: Pstack; var e: boolean);                          // ( a -- )
 var
  t: longint;
 begin
  pop(s,t,e);
 end;

procedure rot(var s: Pstack; var e: boolean);                           // ( a b c -- b c a )
 var
   a,b,c: longint;
 begin
  pop(s,a,e);
  if (not e) then
   begin
    pop(s,b,e);
    if not e then
     begin
      pop(s,c,e);
      if (not e) then
       begin
        push(s,b,e);
        push(s,a,e);
        push(s,c,e);
       end;
     end;
   end;
 end;

procedure print(var s: Pstack; var e: boolean);                         // ( a -- )
 var
  a: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
    write(a,' ')
 end;

procedure printUns(var s: Pstack; var e: boolean);                      // ( u -- )
 var
  a: longint;
  b: longword;
 begin
  pop(s,a,e);
  b := a;
  if (not e) then
    write(b,' ');
 end;

procedure emit(var s: Pstack; var e: boolean);                          // ( a -- )
 var
  a: longint;
 begin
  e := false;
  pop(s,a,e);
  if (not e) then
    write(chr(a mod 256))
 end;

function isNumeric(s: string): boolean;
 var
  n,e: longint;
 begin
  val(s,n,e);
  isNumeric := e = 0;
 end;

function value(s: string): longint;
 var
  n,e: longint;
 begin
  val(s,n,e);
  value := n;
 end;

procedure printStack(s: Pstack);                                        // ( -- )
 var
  i: longint;
 begin
  write('S<',stack_depth(s),'> ');
  for i := 1 to stack_depth(s) do
   begin
    write(s^.value,' ');
    s := s^.next;
   end;
  writeln;
 end;

procedure pushret(var ret,stk: Pstack; var e: boolean);                 // ( a -- , a )
 var
   n: longint;
 begin
  pop(stk,n,e);
  if not e then
    push(ret,n,e);
 end;

procedure popret(var ret,stk: Pstack; var e: boolean);                  // ( , a -- a )
 var
   n: longint;
 begin
  pop(ret,n,e);
  if not e then
    push(stk,n,e);
 end;

procedure copyret(var ret,stk: Pstack; var e: boolean);                 // ( , a -- a , a )
 var
   n: longint;
 begin
  pop(ret,n,e);
  if not e then
   begin
    push(ret,n,e);
    if not e then
      push(stk,n,e);
   end;
 end;

procedure eq(var stk: Pstack; var e: boolean);                          // ( a b -- {a == b} )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       if a = b then
         push(stk,-1,e)
       else
         push(stk,0,e);
    end;
 end;

procedure less(var stk: Pstack; var e: boolean);                        // ( a b -- {a < b} )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       if b < a then
         push(stk,-1,e)
       else
         push(stk,0,e);
    end;
 end;

procedure more(var stk: Pstack; var e: boolean);                        // ( a b -- { a > b } )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       if b > a then
         push(stk,-1,e)
       else
         push(stk,0,e);
    end;
 end;

procedure unsLess(var stk: Pstack; var e: boolean);                     // ( u1 u2 -- { u1 < u2 } )
 var
  a,b: longint;
  c,d: longword;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
      begin
       c := a;
       d := b;
       if d < c then
         push(stk,-1,e)
       else
         push(stk,0,e);
      end;
    end;
 end;

procedure unsMore(var stk: Pstack; var e: boolean);                     // ( u1 u2 -- { u1 > u2 } )
 var
  a,b: longint;
  c,d: longword;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
      begin
       c := a;
       d := b;
       if d > c then
         push(stk,-1,e)
       else
         push(stk,0,e);
      end;
    end;
 end;

procedure opand(var stk: Pstack; var e: boolean);                       // ( a b -- {a & b} )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       push(stk,a and b,e);
    end;
 end;

procedure opor(var stk: Pstack; var e: boolean);                        // ( a b -- {a || b} )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       push(stk,a or b,e);
    end;
 end;

procedure opxor(var stk: Pstack; var e: boolean);                       // ( a b -- {a ^ b} )
 var
   a,b: longint;
 begin
   pop(stk,a,e);
   if not e then
    begin
     pop(stk,b,e);
     if not e then
       push(stk,a xor b,e);
    end;
 end;

procedure opnot(var stk: Pstack; var e: boolean);
 var
   n: longint;
 begin
  pop(stk,n,e);
  if not e then
    if n = 0 then
      push(stk,-1,e)
    else
      push(stk,0,e);
 end;

procedure opinc(var stk: Pstack; var e: boolean);
 var
  n: longint;
 begin
  pop(stk,n,e);
  if not e then
   begin
    inc(n);
    push(stk,n,e);
   end;
 end;

procedure opdec(var stk: Pstack; var e: boolean);
 var
  n: longint;
 begin
  pop(stk,n,e);
  if not e then
   begin
    dec(n);
    push(stk,n,e);
   end;
 end;

procedure writeRAM(var s: Pstack; var RAM: vars; var e: boolean);       // ( n addr -- )
 var
  a,k: longint;
  n: longword;
 begin
  pop(s,a,e);
  if not e then
   begin
    pop(s,k,e);
    if not e then
      if (a >= RAMsize-1) or (a < 0) then
     begin
      write('Error: Adress does not exist ');
      e := true;
     end
    else
     n := k;
     RAM.arr[a] := n div 16777216;
     RAM.arr[a+1] := n div 65536 mod 256;
     RAM.arr[a+2] := n div 256 mod 256;
     RAM.arr[a+3] := n mod 256;
   end;
 end;

procedure readRAM(var s: Pstack; var RAM: vars; var e: boolean);        // ( addr -- n )
 var
  a: longint;
  n: longword;
 begin
  pop(s,a,e);
  if not e then
    if (a >= RAMsize-1) or (a < 0) then
   begin
    write('Error: Adress does not exist ');
    e := true;
   end
  else
   begin
    n := RAM.arr[a]*16777216+RAM.arr[a+1]*65536+RAM.arr[a+2]*256+RAM.arr[a+3];
    push(s,n,e);
   end
 end;

procedure plusRAM(var s: Pstack; var RAM: vars; var e: boolean);
 begin
  dup(s,e);
  if not e then
   begin
    readRAM(s,RAM,e);
    if not e then
     begin
      rot(s,e);
      if not e then
       begin
        add(s,e);
        if not e then
         begin
          swap(s,e);
          if not e then
            writeRAM(s,RAM,e);
         end;
       end;
     end
   end;
 end;

procedure writeChr(var s: Pstack; var RAM: vars; var e: boolean);
 var
  k,a: longint;
  n: longword;
 begin
  pop(s,a,e);
  if not e then
   begin
    if (a < 0) or (a > RAMsize-1) then
     begin
      e := true;
      write('Error: Adress does not exist ');
     end
    else
     begin
      pop(s,k,e);
      if not e then
       begin
        n := k;
        RAM.arr[a] := n mod 256;
       end;
     end;
   end
 end;

procedure readChr(var s: Pstack; var RAM: vars; var e: boolean);
 var
  a: longint;
  n: byte;
 begin
  pop(s,a,e);
  if not e then
   begin
    if (a < 0) or (a > RAMsize-1) then
     begin
      e := true;
      write('Error: Adress does not exist ');
     end
    else
     begin
       n := RAM.arr[a];
       push(s,n,e);
     end;
   end
 end;

function exec(str: string; var stk, ret: Pstack; var words: Pdict; var RAM: vars; automatic: boolean; var e: boolean): boolean; forward;

function parse(slovo: string; var stk,ret: Pstack; var words: Pdict; var RAM: vars; var e: boolean): boolean;
 var
  isWOrd: boolean;
  t: Pdict;
 begin
  parse := false;
  isWord := false;
  t := words;
  while (t^.next <> nil) do
   begin
    if (not isWord) and (t^.name = slovo) then
     begin
      exec(t^.code, stk, ret, words, RAM, true, e);
      isWord := true;
     end;
    t := t^.next;
   end;
  if not isWord then
   begin
        if slovo = '+' then
     add(stk,e)
   else if slovo = '-' then
     sub(stk,e)
   else if slovo = '*' then
     mult(stk,e)
   else if slovo = '/MOD' then
     divmod(stk,e)
   else if slovo = '/' then
    begin
     divmod(stk,e);
     if not e then
      begin
       swap(stk,e);
       if not e then
         drop(stk,e);
      end;
    end
   else if slovo = 'MOD' then
    begin
     divmod(stk,e);
     if not e then
       drop(stk,e);
    end
   else if slovo = '1+' then
     opinc(stk,e)
   else if slovo = '1-' then
     opdec(stk,e)
   else if (slovo = '=') or (slovo = 'U=') then
     eq(stk,e)
   else if slovo = '>' then
     more(stk,e)
   else if slovo = '<' then
     less(stk,e)
   else if slovo = 'U>' then
     unsMore(stk,e)
   else if slovo = 'U<' then
     unsLess(stk,e)
   else if (slovo = 'NOT') or (slovo = '0=') then
     opnot(stk,e)
   else if slovo = 'AND' then
     opand(stk,e)
   else if slovo = 'OR' then
     opor(stk,e)
   else if slovo = 'XOR' then
     opxor(stk,e)
   else if slovo = 'DUP' then
     dup(stk,e)
   else if slovo = '2DUP' then
    begin
     over(stk,e);
     if not e then
       over(stk,e);
    end
   else if slovo = '2DROP' then
    begin
     drop(stk,e);
     if not e then
       drop(stk,e);
    end
   else if slovo = 'SWAP' then
     swap(stk,e)
   else if slovo = 'OVER' then
     over(stk,e)
   else if slovo = 'ROT' then
     rot(stk,e)
   else if slovo = 'DROP' then
     drop(stk,e)
   else if slovo = 'NIP' then
    begin
     swap(stk,e);
     if not e then
       drop(stk,e);
    end
   else if slovo = '>R' then
      pushret(ret,stk,e)
    else if slovo = 'R>' then
      popret(ret,stk,e)
    else if (slovo = 'R@') or (slovo = 'I') then
      copyret(ret,stk,e)
    else if (slovo = '!') then
      writeRAM(stk,ram,e)
    else if (slovo = '!+') then
      plusRAM(stk,ram,e)
    else if (slovo = '@') then
      readRAM(stk,ram,e)
    else if (slovo = 'C!') then
      writeChr(stk,ram,e)
    else if (slovo = 'C@') then
      readChr(stk,ram,e)
    else if (slovo = '?') then
      exec('@ . ',stk,ret,words,RAM,true,e)
    else if slovo = '.' then
      print(stk,e)
    else if slovo = 'U.' then
      printUns(stk,e)
    else if slovo = 'EMIT' then
      emit(stk,e)
    else if slovo = '.S' then
      printStack(stk)
    else if (slovo = 'BYE') or (slovo = 'LEAVE') then
     begin
      parse := true;
     end
    else if isNumeric(slovo) then
      push(stk,value(slovo),e)
    else
     begin
      e := true;
      write(slovo,'?')
     end;
   end;
 end;

procedure format(var str: string);
 begin
  while (pos('  ', str) <> 0) do                                        //Пока есть двойные пробелы
    delete(str,pos('  ',str),1);                                        //  Уничтожаем их
  if copy(str,1,1) <> ' ' then                                          //Если первый символ не пробел
    str := ' ' + str;                                                   //  Добавляем его
  if copy(str,length(str),1) <> ' ' then                                //Если последний символ не пробел
   str := str + ' ';                                                    //  Добавляем его
 end;

procedure upperCase(var str: string);
 var
   min,max: string;
   i: integer;
 begin
  min := 'abcdefghijklmnopqrstuvwxyz';
  max := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  for i := 1 to length(str) do                                          //Проходимся по строке
   begin
     if pos(copy(str,i,1), min) <> 0 then                               //  Если перед нами маленькая буква
      begin
        insert(copy(max,pos(copy(str,i,1), min),1),str,i);              //  Добавляем большую
        delete(str,i+1,1);                                              //    А маленькую удаляем
      end;
   end;
 end;

procedure macro(var str: string);
 var
  i: longint;
 begin
  for i := 2 to length(str)-1 do                                        // Проходимся по строке
    if copy(str,i-1,3) = ' ( ' then                                     //  Если есть слово (
     if pos(')',str) = 0 then                                           //    Если нет ограничителя
       delete(str,i,length(str))                                        //      Удаляем до конца строки
     else                                                               //    Иначе
       delete(str,i,pos(')',str)-i+1);                                  //      Удаляем до ограничителя
  upperCase(str);                                                       //Делаем все буквы большими
  while pos(' DO ', str) <> 0 do                                        //Пока есть слова DO
   begin
    insert(' SWAP >R >R BEGIN ',str,pos(' DO ', str));                  //  Применяем макрос
    delete(str,pos(' DO ', str),4);                                     //  Удаляем слово DO
   end;
  while pos(' LOOP ', str) <> 0 do                                      //Пока есть слова LOOP
   begin
    insert(' R> R> SWAP 1+ SWAP 2DUP >R >R = UNTIL R> R> 2DROP ',
str,pos(' LOOP ', str));                                                //  Применяем макрос
    delete(str,pos(' LOOP ', str),6);                                   // Удаляем слово LOOP
   end;
 end;

procedure addword(var words: Pdict; wordname, wordcode: string; var e: boolean);
 var
  t: Pdict;
 begin
  e := false;
  t := dict_init(wordname, wordcode);
  t^.next := words;
  words := t;
 end;

procedure newWord(var str: string; var words: Pdict; var e: boolean);
 var
  wst, slovo: string;
 begin
   wst := '';
   repeat                                                               //Повторяем
     slovo := copy(str,1,pos(' ', str) - 1);                            //  Достаём слово
     delete(str,1,pos(' ', str));                                       //  Удаляем слово
     if (slovo <> ';') and (slovo <> ':') then                          //  Если слово не относится к словообразованию
        wst := wst + slovo + ' '                                        //  Добавляем его
   until not ((str <> '') and (slovo <> ';') and (slovo <> ':'));       //Пока строка не пуста и слово не относится к словообразованию
   if (str = '') and (slovo <> ';') then                                //Если строка закончилась
    begin
     e := true;                                                         //  ОШИБКА
     write('Error: multiline definition ');                             //  Выводим сообщение
    end;
   if (slovo = ':') then                                                //Если слово объявляется в слове
    begin
     e := true;                                                         //  ОШИБКА
     write('Error: word loop ');                                        //  Выводим сообщение
    end;
   if (slovo = ';') then                                                //Если слово закончилось
    begin
     format(wst);                                                       //  Приводим строку в нормальный вид
     delete(wst,1,1);                                                   //  Удалем первый пробел
     addword(words,copy(wst,1,pos(' ',wst)-1),
copy(wst,pos(' ',wst),length(wst)),e);                                  //  Добавляем статью
    end;
 end;

procedure execIf(var str: string; var stk: Pstack; var e: boolean);
 var
  slovo: string;
  n: longint;
 begin
   pop(stk,n,e);                                                        //Получаем значение со стека
   if not e then                                                        //Если нет ошибки
     if n = 0 then                                                      //  Если условие не выполнено
      begin
       n := 1;
       repeat                                                           //    Повторяем
         slovo := copy(str,1,pos(' ', str) - 1);                        //      Достаём слово
         delete(str,1,pos(' ', str));                                   //      Удаляем слово
         if (slovo = 'IF') then                                         //      Если слово IF
           inc(n)                                                       //        Увеличиваем вложенность
         else if (slovo = 'THEN') then                                  //      Иначе если слово THEN
           dec(n)                                                       //        Уменьшаем вложенность
         else if (slovo = 'ELSE') and (n = 1) then                      //     Если нет вложенности и слово ELSE
           dec(n);                                                      //        Уменьшаем вложенность
       until (str = '')  or (n = 0);                                    //    Пока строка не пуста и м в ифе
       if (str = '') and (slovo <> 'THEN') and (slovo <> 'ELSE') then   //    Если строка пуста и мы в ифе
        begin
         e := true;                                                     //      ОШИБКА
         write('Error: multiline IF ');                                 //      Выводим сообщение
        end;
     end;
 end;

procedure execElse(var str: string; var e: boolean);
 var
  n: longint;
  slovo: string;
 begin
  n := 1;
  repeat                                                                //Повторяем
    slovo := copy(str,1,pos(' ', str) - 1);                             //  Достаём слово
    delete(str,1,pos(' ', str));                                        //  Удаляем его
    if (slovo = 'IF') then                                              //  Если слово IF
      inc(n)                                                            //     Увеличиваем вложенность
    else if (slovo = 'THEN') then                                       //  Иначе если слово THEN
      dec(n);                                                           //    Уменьшаем вложенность
  until (str = '') or (n = 0);                                          //Пока мы не вышли из ифа или строка не пуста
  if (str = '') and (slovo <> 'THEN') then                              //Если строка пуста, а мы не вышли из ифа
   begin
    e := true;                                                          //  ОШИБКА
    write('Error: multiline IF ');                                      //  Выводим сообщение
   end;
 end;

procedure execCycle(var str: string; var stk,ret: Pstack; var words: Pdict; var RAM: vars; var e: boolean);
 var
   wst, nst, slovo: string;
   n: longint;
   f: boolean;
 begin
  wst := '';
  nst := '';
  n := 1;
  f := true;
  repeat                                                                //Повторяем
    slovo := copy(str,1,pos(' ', str) - 1);                             //  Достаём слово
    delete(str,1,pos(' ', str));                                        //  Удаляем его
    if (slovo = 'WHILE') and (n = 1) then                               //  Если нет вложенности и цикл WHILE
      f := false                                                        //    Начинаем тело
    else if (slovo = 'UNTIL') or (slovo = 'REPEAT') then                //  Иначе если слово закрывает цикл
      dec(n)                                                            //    Уменьшаем вложенность
    else if (slovo = 'BEGIN') then                                      //  Иначе если слово открывает цикл
       inc(n);                                                          //    Увеличиваем вложенность
    if not((((slovo = 'UNTIL') or (slovo = 'REPEAT')) and (n = 0))
or ((slovo = 'WHILE') and (n = 1))) then                                //  Если слово не образует текущий цикл
      if f then                                                         //    Если мы пишем тело цикла BEGIN-UNTIL или условие цикла BEGIN-WHILE-REPEAT
        wst := wst + slovo + ' '                                        //      Добавляем слово в одну строку
      else                                                              //    Иначе
        nst := nst + slovo + ' '                                        //      Добавляем его в другую строку
  until not (str <> '') or (n = 0) ;                                    //Пока строка не закончислась и мы в цикле
  f := false;
  if (str = '') and (slovo <> 'UNTIL') and (slovo <> 'REPEAT')  then    //Если строка пуста и мы не дошли до конца цикла
   begin
    e := true;                                                          //  ОШИБКА
    write('Error: multiline BEGIN-(WHILE)-UNTIL(REPEAT) ');             //    Выводим сообщение
   end
  else if (slovo = 'REPEAT') then                                       //Иначе если наш цикл BEGIN-WHILE-REPEAT
   begin
    format(wst);                                                        //  Приводим в нормальный вид условие
    format(nst);                                                        //  Приводим в нормальный вид тело
    exec(wst,stk,ret,words,RAM,true,e);                                 //  Выполняем условие
    pop(stk,n,e);                                                       //  Снимаем флаг
    while not e and not f and (n <> 0) do                               //  Пока нет ошибки и флаг истинный
     begin
      f := exec(nst,stk,ret,words,RAM,true,e);                          //    Выполняем тело
      if not e and not f then                                           //    Если нет ошибки
       begin
        exec(wst,stk,ret,words,RAM,true,e);                             //      Выполняем условие
        if not e and not f then                                         //      Если нет ошибки
         pop(stk,n,e);                                                  //        Снимаем флаг
       end;
     end;
   end
   else if (slovo = 'UNTIL') then                                       //Иначе если наши цикл BEGIN-UNTIL
    begin
     format(wst);                                                       //  Приводим в нормальнй вид тело
     repeat                                                             //  Повторяем
       f := exec(wst,stk,ret,words,RAM,true,e);                         //    Выполняем тело
       if not e and not f then                                          //    Если нет ошибки
         pop(stk,n,e);                                                  //    Снимаем флаг
     until (n <> 0) or e or f;                                          //  Пока нет ошибки и флаг ложен
   end;
 end;

function exec(str: string; var stk,ret: Pstack; var words: Pdict; var RAM: vars; automatic: boolean; var e: boolean): boolean;
 var
   slovo: string;
   f: boolean;
 begin
  e := false;
  f := false;
  exec := false;
  while ((str <> '') and not e and not f) do                            //Пока нет ошибок и есть чего исполнять
   begin
    slovo := copy(str,1,pos(' ', str) - 1);                             //  Выбираем слово
    delete(str,1,pos(' ', str));                                        //  Удаляем его из строки
    if slovo = ':' then                                                 //  Если слово :
      newWord(str,words,e)                                              //    Добавляем новое слово
    else if (slovo = 'IF') then                                         //  Иначе если слово IF
      execIf(str,stk,e)                                                 //    Обрабатываем условие
    else if (slovo = 'ELSE') then                                       //  Иначе если слово ELSE
      execElse(str,e)                                                   //    Обходим ветвь ELSE THEN
    else if (slovo = 'THEN') then                                       //  Иначе если слово THEN
       slovo := ''                                                      //    Пропускаем его
    else if (slovo = 'BEGIN') then                                      //  Иначе если слово BEGIN
      execCycle(str,stk,ret,words,RAM,e)                                //    Запускаем цикл
    else if slovo <> '' then                                            //  Иначе если  слово не пустое
      f := parse(slovo, stk, ret, words, RAM, e);                       //    Выполняем его
   end;
  exec := f;
  if not automatic then                                                 //Если мы запускались вручную
   begin
    if (not e and not f) then                                           //  Если нет ошибки
      write(' ok');                                                     //    Всё OK
    writeln;                                                            //  Пропускаем строку
   end;
   if e then                                                            //Если ошибка
     stack_delete(stk);                                                 //  Очищаем стек
 end;

procedure init(var stk,ret: Pstack; var words: Pdict; var RAM: vars);
 begin
  stk := stack_init(0);
  ret := stack_init(0);
  words := dict_init('', '');
  RAM.size := 0;
  setLength(RAM.arr,RAMsize);
 end;

function getfile(filename: string): string;
 var
  f: text;
  st, t: string;
 begin
  assign(f, filename);
  reset(f);
  st := '';
  while not eof(f) do
   begin
    readln(f, t);
    st := st + t + ' ';
   end;
  getfile := st;
 end;

var
  bye,e: boolean;
  stk, ret: Pstack;
  words: Pdict;
  RAM: vars;
  str: string;
begin
  init(stk,ret,words,RAM); 	                                            //Инициализируем структуры
  bye := false;
  if ParamCount = 0 then                                                //Если нет аргументов
    while not bye and not eof do                                        //  Пока не закончили
     begin
      readln(str);                                                      //    Вводим строку
      format(str);                                                      //    Форматируем строку
      macro(str);                                                       //    Применяем маросы
      bye := exec(str,stk,ret,words,RAM,false,e);                       //    Исполняем
     end
   else                                                                 //Иначе
    begin
     str := getfile(ParamStr(1));                                       //  Вводим файл
     format(str);                                                       //  Форматируем строку
     macro(str);                                                        //  Применяем макросы
     exec(str, stk, ret, words, RAM, true, e);                          //  Исполняем
    end;
end.
