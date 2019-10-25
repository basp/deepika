deepika
=======
A reimplementation of the original LambdaMOO that allows you to do weird stuff
like this in evaluation mode.
```
(define me (first (hash-keys (call 'clients))))
(for/list ([x (hash-keys (call 'clients))]) 
    (notify me (~a x)))
```
