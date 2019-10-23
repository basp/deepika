deepika
=======
```
(for/list ([x (hash-keys (call 'clients))]) 
    (notify me-socket (~a x)))
```
