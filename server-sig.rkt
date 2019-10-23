#lang racket

(define-signature server^
  (start
   stop
   call
   cast))

(provide server^)