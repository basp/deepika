#lang racket/base

(require (rename-in racket/class [object% x:object%])
         racket/set
         racket/match
         racket/unit
         racket/contract
         "structures.rkt"
         "db-sig.rkt")

(define-unit db@
  (import)
  (export db^)

  (define object%
    (class x:object%
      (init-field id)
      (init-field [parent $nothing])
      (field [name ""])
      (field [location $nothing])
      (field [contents (set)])
      (super-new)))

  (define $nothing (objid -1))
  (define $ambiguous-match (objid -2))
  (define $failed-match (objid -3))

  (define (nothing? oid)
    (equal? oid $nothing))

  (define idx (make-hash))

  (define (last-used-id)
    (match (hash-keys idx)
      (xs #:when (null? xs) -1)
      (xs (apply max xs))))

  (define (next-id)
    (add1 (last-used-id)))

  (define (create-object! parent)
    (define id (next-id))
    (define oid (objid id))
    (define obj (new object% [id oid] [parent parent]))
    (hash-set! idx id obj)
    oid)

  (define (destroy-object! oid)
    (hash-remove! idx (objid-id oid)))

  (define (objects)
    (filter valid? (map (λ (x) (get-field id x)) (hash-values idx))))

  (define (find-object oid)
    (define id (objid-id oid))
    (match (hash-has-key? idx id)
      (#t (hash-ref idx id))
      (#f $nothing)))

  (define (valid? oid)
    (define id (objid-id oid))
    (and (> id 0)
         (hash-has-key? idx (objid-id oid))))

  (define (get-object-name oid)
    (get-field name (find-object oid)))

  (define (set-object-name! oid v)
    (set-field! name (find-object oid) v))

  (define (get-parent oid)
    (get-field parent (find-object oid)))

  (define (set-parent! oid v)
    (set-field! parent (find-object oid) v))
 
  (define (get-location oid)
    (get-field location (find-object oid)))

  (define (set-location! oid v)
    (set-field! location (find-object oid) v))
  
  (create-object! $nothing))

(provide db@)
