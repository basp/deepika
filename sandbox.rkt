#lang racket/base

(require racket/class
         racket/set)

(struct objid (num) #:prefab)

(define (number->objid x)
  (objid x))

(define (objid->number x)
  (objid-num x))

(define $system (objid 0))
(define $nothing (objid -1))
(define $ambiguous-match (objid -2))
(define $failed-match (objid -3))

(define (nothing? x)
  (equal? x $nothing))

(define (ambiguous-match? x)
  (equal? x $ambiguous-match))

(define (failed-match? x)
  (equal? x $failed-match))

(define db:object%
  (class object%
    (init-field id
                [parent $nothing])
    
    (field [name ""]
           [location $nothing]
           [contents (mutable-set)]
           [children (mutable-set)])

    (define (move to) #f)
   
    (super-new)))