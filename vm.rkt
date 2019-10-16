#lang racket

(define stack null)

(define (push! x)
  (set! stack (cons x stack)))

(define (pop!)
  (define x (car stack))
  (set! stack (cdr stack))
  x)

(define (pop/set-var! name env)
  (hash-set! env name (pop!)))

(define (push/get-var! name env)
  (push! (hash-ref env name)))

(define vm%
  (class object%
    (super-new)))