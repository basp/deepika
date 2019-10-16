#lang racket/base

(require (rename-in racket/class [object% x:object%])
         racket/set
         racket/match
         racket/unit
         racket/contract
         "structures.rkt")

(define-signature db^
  ((contracted
    [object% class?]
    [$nothing objid?]
    [$ambiguous-match objid?]
    [$failed-match objid?]
    [nothing? (-> any/c boolean?)]
    [valid? (-> any/c boolean?)]
    [create-object! (-> (or/c valid? nothing?) valid?)]
    [destroy-object! (-> valid? void?)]
    [find-object (-> objid? (or/c nothing? object?))]
    [objects (-> (listof valid?))]
    [get-object-name (-> valid? string?)]
    [set-object-name! (-> valid? string? void?)]
    [get-parent (-> valid? (or/c valid? nothing?))]
    [set-parent! (-> valid? (or/c valid? nothing?) void?)])))

(provide db^)
