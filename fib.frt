( Программа, выводящая первые 20 чисел Фиббоначи )
: bs       ( -- )          8 emit ;
: cr       ( -- )          10 emit ;
: space    ( -- )          32 emit ;
: printfib ( -- )          70 emit 73 emit 66 emit 40 emit ;
: endf     ( n -- )        41 emit 10 < if space then space 61 emit space ;
: fib      ( n -- fib{n} ) dup 2 > if 1- dup 1- fib swap fib + else drop 1 then ;
21 1 do printfib i . bs i endf i fib . cr loop
