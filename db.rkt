#lang racket/base

(require racket/class
         racket/set
         racket/match
         racket/contract
         "common.rkt")

; This is prefab since we *want* anybody to create
; object ids without depending on this module.
; The fast serialization is a nice bonus.
(struct objid (num) #:prefab)

(define $system (objid 0))
(define $nothing (objid -1))
(define $ambiguous-match (objid -2))
(define $failed-match (objid -3))

(define idx (make-hash))

(define (number->objid x)
  (objid x))

(define (objid->number x)
  (objid-num x))

(define (nothing? x)
  (equal? x $nothing))

(define (ambiguous-match? x)
  (equal? x $ambiguous-match))

(define (failed-match? x)
  (equal? x $failed-match))

(struct prop (name value info) #:transparent)

(define db:property%
  (class object%
    (init-field name
                [value $nothing]
                [info null])
    (super-new)))

(define db:verb%
  (class object%
    (init-field desc)
    (field [owner $nothing])
    (field [args null])
    (field [prog null])
    (super-new)))

(define db:object%
  (class object%
    (init-field id
                [parent $nothing])    
    (field [name ""]
           [location $nothing]
           [contents (mutable-set)]
           [children (mutable-set)]
           [props (make-hash)]
           [verbs (mutable-set)])
    
    (super-new)))

(define (transfer! oid to-oid field-name child-field-name)
  (define obj (find-object oid))
  (define from (find-object (dynamic-get-field child-field-name obj)))
  (define to (find-object to-oid))
  (define (exec-set-op op obj)
    (match obj
      [x #:when (nothing? x) (void)]
      [x (let* ([set (dynamic-get-field field-name x)]
                [args (list set oid)])
           (apply op args))]))
  (exec-set-op set-remove! from)
  (exec-set-op set-add! to)
  (dynamic-set-field! child-field-name obj to-oid))

(define (find-object oid)
  (define k (objid->number oid))
  (match (hash-has-key? idx k)
    [#t (hash-ref idx k)]
    [_ $nothing]))

(define (find-property oid name)
  (match (find-object oid)
    [x #:when (nothing? x)
       $nothing]
    [x (let ([h (get-field props x)])
         (if (hash-has-key? h name)
             (hash-ref h name)
             $nothing))]))

(define (max-object-id)
  (max-id (hash-keys idx) 0))

(define (next-object-id)
  (add1 (max-object-id)))

(define (valid? x)
  (match x
    [(objid num)
     (and (> num 0) (hash-has-key? idx num))]
    [_ #f]))

(define (valid+? x)
  (or (nothing? x) (valid? x)))

(define (create-object! [parent $nothing])
  (define k (next-object-id))
  (define oid (number->objid k))
  (hash-set! idx k (new db:object% [id oid] [parent parent]))
  oid)

(define (destroy-object! oid)
  (define k (objid->number oid))
  (hash-remove! idx k))

(define (get-object-name oid)
  (get-field name (find-object oid)))

(define (set-object-name! oid new-name)
  (set-field! name (find-object oid) new-name))

(define (get-location oid)
  (get-field location (find-object oid)))

(define (set-location! oid new-location)
  (transfer! oid new-location 'contents 'location))

(define (get-parent oid)
  (get-field parent (find-object oid)))

(define (set-parent! oid new-parent)
  (transfer! oid new-parent 'children 'parent))

(define (get-contents oid)
  (set->list (get-field contents (find-object oid))))

(define (get-children oid)
  (set->list (get-field children (find-object oid))))

(define (get-props oid)
  (hash-keys (get-field props (find-object oid))))

(define (add-prop! oid name value [info null])
  (define p (new db:property%
                 [name name]
                 [value value]
                 [info info]))
  (define o (find-object oid))
  (define h (get-field props o))
  (if (hash-has-key? h name)
      (error 'E_INVARG)
      (hash-set! h name p)))

(define (remove-prop! oid name)
  (define o (find-object oid))
  (define h (get-field props o))
  (if (hash-has-key? h name)
      (hash-remove! h name)
      (error 'E_PROPNF)))

(define (get-prop-value oid name)
  (match (find-property oid name)
    [x #:when (nothing? x)
       $nothing]
    [x (get-field value x)]))

(define (set-prop-value! oid name v)
  (match (find-property oid name)
    [x #:when (nothing? x)
       $nothing]
    [x (set-field! value x v)
       oid]))

(define (objects)
  (filter valid? (map (λ (x) (number->objid x))
                      (hash-keys idx))))

(provide
 objid?
 objid
 $nothing
 $ambiguous-match
 $failed-match
 (contract-out
  [number->objid (-> integer? objid?)]
  [objid->number (-> objid? integer?)]
  [valid? (-> any/c boolean?)]
  [valid+? (-> any/c boolean?)]
  [create-object! (->* () (valid+?) valid?)]
  [destroy-object! (-> valid? any)]
  [get-object-name (-> valid? string?)]
  [set-object-name! (-> valid? string? any)]
  [get-parent (-> valid? valid+?)]
  [set-parent! (-> valid? valid+? any)]
  [get-location (-> valid? valid+?)]
  [set-location! (-> valid? valid+? any)]
  [get-contents (-> valid? (listof valid?))]
  [get-children (-> valid? (listof valid?))]
  [get-props (-> valid? (listof string?))]
  [add-prop! (-> valid? string? any/c any)]
  [remove-prop! (-> valid? string? any)]
  [set-prop-value! (-> valid? string? any/c any)]
  [objects (-> (listof valid?))]))