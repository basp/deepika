#lang racket

(define client%
  (class object%
    (init-field socket)
    (define/public (start)
      #f)
    (super-new)))

(define server%
  (class object%
    (super-new)))

