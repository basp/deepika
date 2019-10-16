#lang racket/base

(struct objid (id) #:transparent)

(define $nothing (objid -1))
(define $ambiguous-match (objid -2))
(define $failed-match (objid -3))

(define (nothing? oid)
  (equal? oid $nothing))

(provide (all-defined-out))
