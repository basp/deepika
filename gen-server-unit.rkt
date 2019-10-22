#lang racket

(require "gen-server-handlers-sig.rkt"
         "gen-server-sig.rkt")

(define-unit gen-server@
  (import gen-server-handlers^)
  (export gen-server^)

  (define (loop state)
    (match (thread-receive)
      ['stop
       (idle state)]
      [(list 'cast req)
       (handle-cast req)
       (loop state)]
      [(list 'call from req)
       (let ([res (handle-call req)])
         (thread-send from res))
       (loop state)]
      [_
       (loop state)]))
  
  (define (idle state)
    (match (thread-receive)
      [(list 'start state)
       (loop state)]
      [(list 'call from _)
       (thread-send from 'idle)
       (idle state)]
      [_
       (idle state)]))

  (define thd
    (thread (lambda () (idle null))))
  
  (define (start args)
    (match (init args)
      [(list 'ok state)
       (thread-send thd (list 'start state))]
      [else (error (~a else))]))

  (define (stop)
    (thread-send thd 'stop))

  (define (call req)
    (thread-send thd (list 'call (current-thread) req))
    (thread-receive))

  (define (cast req)
    (thread-send thd (list 'cast req))))

(provide gen-server@)