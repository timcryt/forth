( Программа, выводящая факториалы чисел от 1 до 10 )
: bs      ( -- )      8 emit ;
: cr      ( -- )      10 emit ;
: space   ( -- )      32 emit ;
: print!= ( n -- )    bs 33 emit 10 < if space then space 61 emit space ;
: fact    ( n -- n! ) dup 1 > if dup 1- fact * else drop 1 then ;
11 1 do i . i print!= i fact . cr loop
