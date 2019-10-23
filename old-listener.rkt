#lang racket

(require "gen-server-sig.rkt"
         "gen-server-unit.rkt"
         "gen-server-handlers-sig.rkt")

(define-unit listener-handlers@
  (import gen-server^)
  (export gen-server-handlers^)

  (define (init args)
    (match args
      [(list port-no)
       #:when (integer? port-no)
       (list 'ok null)]
      [else
       (list 'invalid-start-args else)]))

  (define (terminate state)
    (void))

  (define (handle-cast req)
    (void))  

  (define (handle-call req)
    req))  

(define-compound-unit/infer server+handlers@
  (import)
  (export gen-server^ gen-server-handlers^)
  (link gen-server@ listener-handlers@))

(define-values/invoke-unit/infer server+handlers@)

(define (start-listener port-no)
  (start (list port-no)))

(define (stop-listener)
  (stop))