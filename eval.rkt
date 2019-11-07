#lang racket/base

(require racket/match
         "compiler.rkt")

(define stack null)

(define (priv/push x)
  (set! stack (cons x stack)))

(define (priv/pop)
  (let ([x (car stack)])
    (set! stack (cdr stack))
    x))

(define (eval/asm asm)
  (match asm
    ['() 0]
    [(push x) (priv/push x)]
    ['add
     (let ([x (priv/pop)]
           [y (priv/pop)])
       (displayln (+ x y)))]))

(provide eval/asm)
