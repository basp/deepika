#lang racket

; TODO: provide access to db/objects

(struct state (env))

(define stack null)

(define (notify x)
  (displayln (string-append "frotz: " x)))

(define (push! x)
  (set! stack (cons x stack)))

(define (pop!)
  (define x (car stack))
  (set! stack (cdr stack))
  x)

(define (push/get-var! name env)
  (push! (hash-ref env name)))

(define (pop/set-var! name env)
  (hash-set! env name (pop!)))

(define (get-prop!)
  (let ([prop (pop!)]
        [obj (pop!)])
    (displayln 'ok)))

(define (set-prop!)
  (let ([val (pop!)]
        [prop (pop!)]
        [obj (pop!)])
    (displayln 'ok)))

(define (call-bi!)
  (let ([args (pop!)]
        [fn (pop!)])
    (apply fn args)))

(define (call-verb!)
  (let ([args (pop!)]
        [verb (pop!)]
        [obj (pop!)])
    (displayln 'ok)))