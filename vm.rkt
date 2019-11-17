#lang racket/base

(require racket/hash
         racket/unit
         racket/match
         "gen-server-callbacks-sig.rkt"
         "gen-server-sig.rkt"
         "gen-server-unit.rkt")

(define-unit server-callbacks@
  (import gen-server^)
  (export gen-server-callbacks^)

  (define (init args)
    (list 'ok null))

  (define (terminate state)
    (void))

  (define (handle-cast req)
    (match req
      [(list 'notify msg) (displayln msg)]
      ; just drop weird requests
      [else (void)]))
  
  (define (handle-call req)
    #f))

(define-compound-unit/infer queue+callbacks@
  (import)
  (export gen-server^ gen-server-callbacks^)
  (link gen-server@ server-callbacks@))

(define-values/invoke-unit/infer queue+callbacks@)

; * A VM has a memory (slots)
; * It can be loaded with a `program`
; * A program consists of a set of constants
; * As well as a main vector of bytecode
; * And zero or more forked vectors of bytecode
; * The VM is a stack machine
; * The VM can be paused, resumed and serialized
; * A VM is associated with one or more tasks if it is running
; * A VM is connected to the server (synchronized)

(struct program
  (literals
   main
   forks)
  #:transparent)

(struct vm
  (prog
   env)
  #:transparent)

(define (get-literal vm name)
  (hash-ref (program-literals (vm-prog vm)) name))

(define (get-var vm name)
  (hash-ref (vm-env vm) name))

(define (set-var! vm name value)
  (hash-set! (vm-env vm) name value))

(define (eval! vm ins)
  #f)

(define (step vm)
  vm)