#lang racket

(struct property (name value info) #:transparent)
(struct verb (owner perms names) #:transparent)

(define $object%
  (class object%
    (field (properties (make-hash)))
    (field (verbs (make-hash)))
    (define/public (add-property prop-name value info)
      (if (hash-has-key? properties prop-name)
          (error 'E_INVARG)          
          (let ([prop (property prop-name value info)])
            (hash-set! properties prop-name prop))))
    (define/public (delete-property prop-name)
      (if (hash-has-key? properties prop-name)
          (hash-remove! properties prop-name)
          (error 'E_PROPNF)))
    (super-new)))

(define (add-property obj prop-name value info)
  (send obj add-property prop-name value info))

(define (delete-property obj prop-name)
  (send obj delete-property prop-name))

(define (properties obj)
  (hash-keys (get-field properties obj)))

(define (verbs obj)
  (hash-keys (get-field verbs obj)))