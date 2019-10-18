#lang racket

; we could control the "ticks" or evaluation
; time of a program by having eval halt and
; return a "new" program that can be resumed
; later (or in case it makes it to the end it
; will just return a result.
;
; eval ; prog? -> (or prog? value?)
;
; we could have different eval types that for
; example only eval 1 "step" or eval the prog
; for a particular time or "ticks"
;
; an alternative is returning a thunk instead

(struct const (v) #:transparent)
(struct add (x y) #:transparent)
(struct sub (x y) #:transparent)

(define (eval exp)
  (cond [(const? exp)
         (const-v exp)]
        [(add? exp)
         (let ([x (eval (add-x exp))]
               [y (eval (add-y exp))])
           (+ x y))]
        [(sub? exp)
         (let ([x (eval (sub-x exp))]
               [y (eval (sub-y exp))])
           (- x y))]))  
 
