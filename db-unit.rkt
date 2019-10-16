#lang racket/base

(require (rename-in racket/class [object% x:object%])
         racket/set
         racket/match
         racket/unit
         racket/contract
         "common.rkt"
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
      (field [children (set)])
      (field [verbs (set)])
      (field [props (set)])
      (super-new)))

  (define idx (make-hash))

  (define (valid? oid)
    (define id (objid-id oid))
    (and (> id 0)
         (hash-has-key? idx (objid-id oid))))

  (define (valid*? oid)
    (or (nothing? oid)
        (valid? oid)))
  
  (define (transfer! oid from to field-name)
    (define (exec-set-op! op obj)
      (match obj
        (x #:when (nothing? x) (void))
        (x (let* ([old-vs (dynamic-get-field field-name x)]
                  [new-vs (apply op (list old-vs oid))])
             (dynamic-set-field! field-name x new-vs)))))
    (exec-set-op! set-remove from)
    (exec-set-op! set-add to))

  (define (find-object oid)
    (define id (objid-id oid))
    (match (hash-has-key? idx id)
      (#t (hash-ref idx id))
      (#f $nothing)))
 
  (define (max-id)
    (match (hash-keys idx)
      (xs #:when (null? xs) -1)
      (xs (apply max xs))))

  (define (next-id)
    (add1 (max-id)))

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
   
  (define (get-object-name oid)
    (get-field name (find-object oid)))

  (define (set-object-name! oid v)
    (set-field! name (find-object oid) v))
 
  (define (get-parent oid)
    (get-field parent (find-object oid)))

  (define (set-parent! oid v)
    (define obj (find-object oid))
    (define from (find-object (get-field parent obj)))
    (define to (find-object v))
    (transfer! oid from to 'children)
    (set-field! parent (find-object oid) v))
 
  (define (get-location oid)
    (get-field location (find-object oid)))
  
  (define (set-location! oid v)
    (define obj (find-object oid))
    (define from (find-object (get-field location obj)))
    (define to (find-object v))
    (transfer! oid from to 'contents)
    (set-field! location obj v))

  (define (get-verbs oid)
    (set->list (get-field verbs (find-object oid))))

  (define (get-props oid)
    (set->list (get-field props (find-object oid))))

  (define (add-prop oid v)
    (define obj (find-object oid))
    (define old-vs (get-field props obj))
    (define new-vs (set-add old-vs v))
    (set-field! props obj new-vs))

  (define (add-verb oid v)
    (define obj (find-object oid))
    (define old-vs (get-field verbs obj))
    (define new-vs (set-add old-vs v))
    (set-field! verbs obj new-vs))
  
  (define (get-contents oid)
    (get-field contents (find-object oid)))

  (define (get-children oid)
    (get-field children (find-object oid)))

  (define (for/objects proc)
    (for/list ([obj (objects)])
      (apply proc (list obj)))
    (void))

  (create-object! $nothing))

(provide db@)
