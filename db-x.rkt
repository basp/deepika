#lang racket/base

(require racket/class
         racket/set)

(struct objid (z) #:prefab)

(struct prop (name value info) #:transparent)
(struct verb (desc code info args) #:transparent) 

(define (objid->number oid) (objid-z oid))
(define (number->objid num) (objid num))

(define $nothing (number->objid -1))

(define db:object%
  (class object%
    (init-field id
                [parent $nothing])
    (field [name ""]
           [location $nothing]
           [contents (set)]
           [children (set)]
           [verbs (set)]
           [properties (make-hash)])
    (super-new)))