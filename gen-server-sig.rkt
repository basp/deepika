#lang racket

(define-signature gen-server^
  (start
   stop
   call
   cast))

(provide gen-server^)