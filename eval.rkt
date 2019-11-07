#lang racket/base

(require racket/match
         "compiler.rkt")

(define stack null)

(define (push x)
  (set! stack (cons x stack)))

(define (pop)
  (let ([x (car stack)])
    (set! stack (cdr stack))
    x))

(define (eval/asm asm)
  (match asm
    ['() 0]
    [(imm x) (push x)]
    ['add
     (let ([x (pop)]
           [y (pop)])
       (displayln (+ x y)))]))

(provide eval/asm)
