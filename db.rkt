#lang racket

(define-struct objid (id)
  #:prefab)

(define-struct propdef (name value)
  #:transparent)

(define-struct object
  (id
   name
   parent
   location
   contents)
  #:transparent)

(define $nothing (objid -1))
(define $ambiguous-match (objid -2))
(define $failed-match (objid -3))

(define (is-nothing? oid)
  (equal? (objid-id $nothing) (objid-id oid)))

(define-signature db^
  (remove-from-contents
   add-to-contents
   (contracted
    [db/ref (-> objid? any/c)]
    [db/remove! (-> objid? void?)]
    [db/has-key? (-> objid? boolean?)]
    [db/set! (-> objid? object? void?)]
    [db/update! (-> objid? (-> object? object?) boolean?)]
    [db/create-object! (-> objid? objid?)]      
    [db/find-object (-> objid? (or/c object? objid?))]
    [db/destroy-object! (-> objid? any/c)]
    [db/set-parent! (-> objid? objid? any/c)]
    [db/objects (-> (listof object?))]
    [db/location (-> objid? objid?)]
    [db/contents (-> objid? (listof objid?))]
    [db/parent (-> objid? objid?)]
    ;[db/move! (-> objid? objid? boolean?)]
    [valid? (-> objid? boolean?)]
    [last-used-objid (-> objid?)])))

(define-unit db@
  (import)
  (export db^)
  
  (define idx (make-hash))

  (define (db/ref oid)
    (hash-ref idx (objid-id oid)))

  (define (db/remove! oid)
    (hash-remove! idx (objid-id oid)))

  (define (db/has-key? oid)
    (hash-has-key? idx (objid-id oid)))

  (define (db/set! oid new-value)
    (hash-set! idx (objid-id oid) new-value))

  (define (db/update! oid updater)
    (match (valid? oid)
      (#f #f)
      (#t (begin
            (hash-update! idx (objid-id oid) updater)
            #t))))
      
  (define (last-used-id)
    (match (hash-keys idx)
      ('() -1)
      (keys (apply max keys))))

  (define (last-used-objid)
    (objid (last-used-id)))

  (define (next-id)
    (add1 (last-used-id)))

  (define (remove-from-contents obj thing)
    (match (db/contents obj)
      ('() '())
      (old-contents
       (let ([updater (λ (x) (struct-copy object x [contents (remove old-contents thing)]))])
         (db/update! obj updater)))))

  (define (add-to-contents obj thing)
    (let* ([contents (db/contents obj)]
           [updater (λ (x) (struct-copy object x [contents (cons thing contents)]))])
      (db/update! obj updater)))
  
  (define (db/create-object! parent)
    (define id (next-id))
    (define obj (object (objid id) "" parent $nothing '()))
    (hash-set! idx id obj)
    (objid id))

  (define (db/find-object oid)
    (match (valid? oid)
      (#t (db/ref oid))
      (#f $nothing)))

  (define (db/destroy-object! oid)
    (match (valid? oid)
      (#t (db/remove! oid))
      (#f $nothing)))

  (define (valid? oid)
    (and (> (objid-id oid) 0)
         (db/has-key? oid)))

  (define (db/set-parent! oid pid)
    (db/update! oid (λ (x) (struct-copy object x [parent pid])) #f))

  (define (db/objects)
    (hash-values idx))

  (define (db/location oid)
    (match (valid? oid)
      (#t (object-location (db/ref oid)))
      (#f $nothing)))

  (define (db/contents oid)
    (match (valid? oid)
      (#t (object-contents (db/ref oid)))
      (#f '())))

  (define (db/parent oid)
    (match (valid? oid)
      (#t (object-parent (db/ref oid)))
      (#f $nothing)))
  
  (define (db/move! thing location)
    (if (and (valid? thing) (valid? location))
        (#t)
        (#f)))

  (db/create-object! $nothing))







