# Forth
Simple forth-inspired programming langugage interpreter, written in Pascal
## Words
`: ; + - * < = > / . .S ! @ /MOD 1+ 1- 2DROP 2DUP AND BEGIN BYE DO DROP DUP ELSE IF NIP NOT LEAVE LOOP OR OVER REPEAT ROT SWAP THEN U. U< U> UNTIL WHILE XOR`
## Features
OR AND XOR operators - bitwise

NOT operator logical

`: ... ;`|`BEGIN ... WHILE ... REPEAT`|`BEGIN ... UNTIL`|`IF ... ( ELSE ) .,. THEN ` construnctions cannot be multiline.

Warning: in some pascal compilators maximal string size is 255

## Using
### In Linux
Compiling `fpc forth.pas`

Running   `./forth [< file]`

### In Windows

Use PascalABC.NET IDE to compile and run this program

### Warning: last string of program must be BUY word

## Возможности
Операторы OR AND XOR - логические

Конструкции `: ... ;`|`BEGIN ... WHILE ... REPEAT`|`BEGIN ... UNTIL`|`IF ... ( ELSE ) .,. THEN ` не могут быть многострочными.

Внимание: некоторые компиляторы Pascal имеют ограничение на длину строки в 255 символов

## Использование
### Под Linux
Компиляция `fpc forth.pas`

Запуск `./forth [< file]`

### Под Windows

Используйте для этого среду разработки PascalABC.NET для компиляции и запуска

## Документация
Здесь представлена документация по словам данного языка
### Основы
В основе данного языка лежит стек, набирая число, вы кладёте его значение в стек.

Стек  это структура данных, основанная по прицпипу LIFO (Последним вошел - первым вышел), например программа
`1 2 3 4 . . . .` даст вывод `4 3 2 1`.

Когда стек пуст, если взять с него элемент - произойдёт ошибка, и интерпретатор выведет
`Error: stack undefflow`, если же положить на стек слишком много элементов, то произойдёт
переполнение стека `Error: stack overflow`.
### Стековая нотация
Все слова в данной документации имеют так называемую стековую нотацию, она имеет вид
`( <стек до исполения> [, <стек возвратов до исполнения>] -- <стек после исполнения> [, <стек возвратов после исплнения>] )`
При этом выражения содержащие пробелы берутся в круглые скобки, а верхний элемент стека находится справа.
Виды аргументов

k - любое значение

n - число

s - число со знаком

u - число без знака

a - адресс

c - символ

f - флаг

### Слова
! ( k a -- ) \ Записывает значение n по адресу a

@ ( a -- k ) \ Читает значение n по адрему a

&#58; ( -- ) \ Начало определиния

; ( -- ) \ Конец определения

&#43; ( n1 n2 -- {n1 + n2} )

&#45; ( n1 n2 -- {n1 - n2} )

&#42; ( n1 n2 -- {n1 * n2} )

/ ( s1 s2 -- {s1 / s2} )

MOD ( s1 s2 -- {s1 mod s2} )

/MOD (s1 s2 -- {s1 mod s2} {s1 / s2} )

1+ ( n -- {n + 1} )

1- ( n -- {n - 1} )

DUP ( k -- k k )

2DUP ( k1 k2 -- k1 k2 k1 k2 )

SWAP ( k1 k2 -- k2 k1 )

OVER ( k1 k2 -- k1 k2 k1 )

ROT ( k1 k2 k3 -- k2 k3 k1 )

NIP ( k1 k2 -- k2 )

DROP ( k -- )

2DROP ( k1 k2 -- )

. ( s -- ) \ Выводит значение числа на экран

EMIT ( c -- ) \ Выводит символ на экран

= ( k1 k2 -- { k1 == k2} )

&gt; ( s1 s2 -- {s1 &gt; s2} )

&lt; ( s1 s2 -- {s1 &lt; s2} )

U. ( u -- ) \ Выводит значение числа без знака на экран

U&gt; ( u1 u2 -- {u1 &gt; u2} )

U&lt; ( u1 u2 -- {u1 &lt; u2} )

OR ( f1 f2 -- {f1 | f2} )

AND ( f1 f2 -- {f1 & f2} )

XOR ( f1 f2 -- {f1 ^ f2} )

NOT ( f -- !f )

IF ( f -- ) \ Если f<>0 ничего не делает, иначе переходит на соответствующий THEN или ELSE

THEN ( -- )

ELSE ( -- ) \ Переходит на соответствующий THEN

BEGIN ( -- )

UNTIL ( f -- ) \ Если f<>0 ничего не делает, иначе переходит на соответсвующий BEGIN

REPEAT (  -- ) \ Переходит на соответствующий BEGIN

WHILE ( f -- ) \ Если f<>0 ничего на делает, иначе переходит на слово за соответствующим REPEAT

DO ( n1 n2 -- , n1 n2 )

LOOP ( , n1 n2 -- , n1 n2 ) \ Если n1<>n2 переходит на слово за соответствующим DO, иначе удаляет со стека возвратов 2 числа

