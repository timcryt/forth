: !       ( n -- n!)           DUP 1 > IF DUP 1 - ! * ELSE DROP 1 THEN ;
: FIB     ( n -- fib{n} )      1 - 0 1 BEGIN DUP >R + R> SWAP ROT 1 - DUP NOT >R ROT ROT R> UNTIL NIP NIP ;
: SQR     ( x -- {x^2} )       DUP * ;
: BUF     ( a -- bool{a} )     NOT NOT ;
: CR      ( -- )               10 EMIT ;
: SQRT    ( n -- sqrt{n} )     DUP 0 BEGIN >R 2DUP / OVER + 2 / NIP R> 1 + DUP 32 = UNTIL DROP DUP SQR ROT > IF 1 - THEN ;
: ISPRIME ( n -- isprime{n} )  DUP 3 > IF DUP SQRT 1 + >R 2 BEGIN 2DUP MOD NOT  IF 2DROP 0 0 1 ELSE 1 + DUP R@ = THEN UNTIL R> 2DROP BUF ELSE DROP -1 THEN ;
: PRIMES  ( n -- )             1 + 2 DO I ISPRIME IF I . CR THEN LOOP ;
: SPACE   ( -- )               32 EMIT ;
: SPACES  ( n -- )             0 DO SPACE LOOP ;
: NEXTNUM ( NUM -- NEXTNUM )   DUP 2 * XOR ;
: STAR    ( -- )               42 EMIT ;
: OUTNUM  ( NUM -- )           BEGIN DUP 0 > WHILE DUP 2 MOD IF STAR ELSE SPACE THEN SPACE 2 / REPEAT DROP ;
: TRSERP  ( NUM -- )           1 + 1 SWAP DUP 1 DO CR DUP I - SPACES SWAP DUP OUTNUM NEXTNUM SWAP LOOP DROP ;

