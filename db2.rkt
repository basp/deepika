#lang racket/base

(require (rename-in racket/class [object% x:object%])
         racket/set
         racket/match)

(struct objid (id) #:transparent)

(define $nothing (objid -1))

(define ($nothing? oid)
  (equal? oid $nothing))

(define object%
  (class x:object%
    (init-field id)
    (init-field [parent $nothing])
    (field [name ""])
    (field [location $nothing])
    (field [contents (set)])
    (super-new)))

(define idx (make-hash))

(define (last-used-id)
  (match (hash-keys idx)
    (xs #:when (null? xs) -1)
    (xs (apply max xs))))

(define (next-id)
  (add1 (last-used-id)))

(define (create! parent)
  (define id (next-id))
  (define oid (objid id))
  (define obj (new object% [id oid] [parent parent]))
  (hash-set! idx id obj)
  oid)

(define (objects)
  (map (λ (x) (get-field id x)) (hash-values idx)))

(define (find-object oid)
  (define id (objid-id oid))
  (match (hash-has-key? idx id)
    (#t (hash-ref idx id))
    (#f $nothing)))

(define (valid? oid)
  (define id (objid-id oid))
  (and (> id 0)
       (hash-has-key? idx id)))




