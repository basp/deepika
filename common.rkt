#lang racket/base

(struct objid (id) #:transparent)
(struct task-id (id) #:transparent)
(struct prop (name val) #:transparent)
(struct verb (name proc) #:transparent)

(define $nothing (objid -1))
(define $ambiguous-match (objid -2))
(define $failed-match (objid -3))

(define (nothing? oid)
  (equal? oid $nothing))

(define (ambiguous-match? oid)
  (equal? oid $ambiguous-match))

(define (failed-match? oid)
  (equal? oid $failed-match))

(provide (all-defined-out))