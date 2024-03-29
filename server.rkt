#lang racket/base

(require racket/class
         racket/unit
         racket/match
         racket/tcp
         racket/port         
         "gen-server-callbacks-sig.rkt"
         "gen-server-sig.rkt"
         "gen-server-unit.rkt"
         "db.rkt"
         "cmd-parser.rkt")

(define socket%
  (class object%
    (init-field in out)
    (field [obj $nothing])
    (super-new)))

(define-unit server-callbacks@
  (import gen-server^)
  (export gen-server-callbacks^)

  (struct socket (in out obj) #:transparent)

  (define clients (make-hasheq))

  (define (serve port-no)
    (define listener (tcp-listen port-no 5 #t))
    (define (loop)
      (accept-and-handle listener)
      (loop))
    (define t (thread loop))
    (lambda ()
      (kill-thread t)
      (tcp-close listener)))

  (define (accept-and-handle listener)
    (define-values (I O) (tcp-accept listener))
    (define s (socket I O $nothing))
    (define t (thread (lambda () (handle s))))
    (hash-set! clients s t))
 
  (define (handle s)
    (define-values (I O) (values (socket-in s) (socket-out s)))
    
    (define (syntax-error e) (displayln 'syntax-error O))
    
    (define (close-connection)
      (hash-remove! clients s)
      (close-input-port I)
      (close-output-port O))
    
    (define evt (sync (read-line-evt I 'any)
                      (thread-receive-evt)))    

    (match evt
      [eof
       #:when (eof-object? eof)
       (close-connection)]
      [cmd
       #:when (string? cmd)
       (with-handlers ([exn:fail? syntax-error])
         (let ([res (eval (read (open-input-string cmd)))])
           (displayln res O)))
       (flush-output O)
       (handle s)]
      [else
       (match (thread-receive)
         [(list 'disconnect)
          (close-connection)]
         [(list 'notify msg)
          (displayln msg O)
          (flush-output O)
          (handle s)])]))
   
  (define (init args)
    (match args
      [(list port-no)
       #:when (integer? port-no)
       (let ([s (serve port-no)])
         (list 'ok s))]
      [else
       (list 'invalid-start-args else)]))
  
  (define (terminate state)
    (void))

  (define (handle-cast req)
    (match req
      [(list 'notify who msg)
       #:when (and (string? msg) (socket? who))
       (let ([t (hash-ref clients who)])
         (thread-send t (list 'notify msg)))]
      [else (void)]))

  (define (handle-call req)
    (match req
      ['clients clients]
      [else else])))

(define-compound-unit/infer server+callbacks@
  (import)
  (export gen-server^ gen-server-callbacks^)
  (link gen-server@ server-callbacks@))

(define-values/invoke-unit/infer server+callbacks@)

(define (tell who msg)
  (cast (list 'notify who msg)))

(define (wall msg)
  (for/list ([x (hash-keys (call 'clients))])
    (tell x msg)))