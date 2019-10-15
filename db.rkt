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
    [db/create-object! (-> objid? objid?)]      
    [db/find-object (-> objid? (or/c object? boolean?))]
    [db/destroy-object! (-> objid? any/c)]
    [db/set-parent! (-> objid? objid? any/c)]
    [db/objects (-> (listof object?))]
    [db/location (-> objid? objid?)]
    ;[db/contents (-> objid? (listof objid?))]
    ;[db/parent (-> objid? objid?)]
    ;[db/move! (-> objid? objid? boolean?)]
    [valid? (-> objid? boolean?)]
    [last-used-objid (-> objid?)])))

(define-unit db@
  (import)
  (export db^)
  (define idx (make-hash))
  
  (define (last-used-id)
    (match (hash-keys idx)
      ('() -1)
      (keys (apply max keys))))

  (define (last-used-objid)
    (objid (last-used-id)))

  (define (next-id)
    (add1 (last-used-id)))

  (define (db/create-object! parent)
    (define id (next-id))
    (define obj (object (objid id) "" parent $nothing (make-hash)))
    (hash-set! idx id obj)
    (objid id))

  (define (db/find-object oid)
    (match (valid? oid)
      (#t (hash-ref idx (objid-id oid)))
      (#f #f)))

  (define (db/destroy-object! id)
    $nothing)

  (define (valid? id)
    (and (> (objid-id id) 0)
         (hash-has-key? idx (objid-id id))))

  (define (db/set-parent! oid pid)
    (match (db/find-object oid)
      (#f #f)
      (obj (hash-set! idx (objid-id oid) (struct-copy object obj [parent pid])))))

  (define (db/objects)
    (hash-values idx))

  (define (db/location oid)
    (match (valid? oid)
      (#t (object-location (hash-ref idx (objid-id oid))))
      (#f $nothing)))

  (define (db/move! thing new-loc)
    (if (and (valid? thing)
             (valid? new-loc))
        (#t)
        (#f)))

  (db/create-object! $nothing))







