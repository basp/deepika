#lang racket

(define-struct objid (id)
  #:transparent)

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
  ((contracted
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
    [db/contents (-> objid? generic-set?)]
    [db/parent (-> objid? objid?)]
    [db/move! (-> objid? objid? boolean?)]
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
      (old-contents #:when (set-empty? old-contents) old-contents)
      (old-contents
       (let* ([new-contents (set-remove old-contents thing)]
              [updater (λ (x) (struct-copy object x [contents new-contents]))])
         (db/update! obj updater)))))

  (define (add-to-contents obj thing)
    (let* ([old-contents (db/contents obj)]
           [new-contents (set-add old-contents thing)]
           [updater (λ (x) (struct-copy object x [contents new-contents]))])
      (db/update! obj updater)))
  
  (define (db/create-object! parent)
    (define id (next-id))
    (define obj (object (objid id) "" parent $nothing (set)))
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
    (let ([updater (λ (x) (struct-copy object x [parent pid]))])
      (db/update! oid updater)))

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
  
  (define (db/move! thing new-location)
    (if (and (valid? thing) (valid? new-location))
        (let ([old-location (db/location thing)])
          (remove-from-contents old-location thing)
          (add-to-contents new-location thing)
          (db/update! thing (λ (x) (struct-copy object x [location new-location]))))
        (#f)))

  (db/create-object! $nothing))
