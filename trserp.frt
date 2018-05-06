( Программа, выводящая треугольник Серпинского )
: cr      ( -- )             10 emit ;
: space   ( -- )             32 emit ;
: spaces  ( n -- )           0 do space loop ;
: nextnum ( NUM -- NEXTNUM ) dup 2 * xor ;
: star    ( -- )             42 emit ;
: outnum  ( NUM -- )         begin dup 0 > while dup 2 mod IF star else space then space 2 / repeat drop ;
: trserp  ( NUM -- )         1 + 1 swap dup 1 do cr dup i - spaces swap dup outnum nextnum swap loop drop ;
16 trserp
