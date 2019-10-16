#lang racket/base

(require (rename-in racket/class [object% x:object%])
         racket/set
         racket/match
         racket/unit
         racket/contract
         "common.rkt")

(define-signature db^
  ((contracted
    [valid? (-> any/c boolean?)]
    [valid*? (-> any/c boolean?)]
    [create-object! (-> valid*? valid?)]
    [destroy-object! (-> valid? void?)]
    [objects (-> (listof valid?))]
    [get-object-name (-> valid? string?)]
    [set-object-name! (-> valid? string? void?)]
    [get-parent (-> valid? valid*?)]
    [set-parent! (-> valid? valid*? void?)]
    [get-location (-> valid? valid*?)]
    [set-location! (-> valid? valid*? void?)]
    [get-contents (-> valid? set?)]
    [get-children (-> valid? set?)]
    [for/objects (-> procedure? void?)])))

(provide db^)
