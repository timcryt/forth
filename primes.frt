( Программа, выводящая простые числа от 2 до 100 )
: cr      ( -- )              10 emit ;
: sqr     ( x -- {x^2} )      dup * ;
: buf     ( a -- bool{a} )    not not ;
: sqrt    ( n -- sqrt{n} )    dup 0 begin >r 2dup / over + 2 / nip r> 1 + dup 32 = until drop dup sqr rot > if 1 - then ;
: isprime ( n -- isprime{n} ) dup 3 > if dup sqrt 1+ >r 2 begin 2dup mod not if 2drop 0 0 1 else 1 + dup R@ = then until r> 2drop buf else drop -1 then ;
: primes  ( n -- )            1 + 2 do i isprime if i . cr then loop ;
100 primes
