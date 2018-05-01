# Forth
Simple forth-inspired programming langugage interpreter, written in Pascal
## Words
`: ; + - * < = > / ! @ /MOD 2DROP 2DUP AND BEGIN BYE DO DROP DUP ELSE IF NOT LOOP OR OVER REPEAT ROT SWAP THEN UNTIL WHILE XOR`
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
