#lang racket

(define-signature gen-server^
  (start
   stop
   call
   cast))

(define-signature gen-server-handlers^
  (init          ; any/c -> any/c
   terminate     ; any/c -> void?
   handle-call   ; any/c -> any/c
   handle-cast   ; any/c -> void?))

(define-unit gen-server-handlers@
  (import)
  (export gen-server-handlers^)

  (define (init args) (list 'ok null)) 

  (define (terminate state) (void))
  
  (define (handle-call req)
    req))  

  (define (handle-cast req)
    (displayln "cast"))

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
       ; send *something* back to avoid block
       ; the from thread for no good reason
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

  ; any/c -> any/c
  (define (call req)
    (thread-send thd (list 'call (current-thread) req))
    (thread-receive))

  ; any/c -> void?
  (define (cast req)
    (thread-send thd (list 'cast req))))

(define-values/invoke-unit/infer gen-server-handlers@)
(define-values/invoke-unit/infer gen-server@)
