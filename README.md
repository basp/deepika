deepika
=======
```
(define me (first (hash-keys (call 'clients))))
(for/list ([x (hash-keys (call 'clients))]) 
    (notify me (~a x)))
```
