#lang racket

; start -> init
; stop -> terminate
; cast -> handle cast
; call -> handle call

(define-signature gen-server^
  (start    
   stop
   cast
   call))

