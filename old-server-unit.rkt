#lang racket/base

(require racket/unit
         racket/match
         racket/tcp
         racket/class
         "common.rkt"
         "server-sig.rkt"
         "db-sig.rkt")

; The server has two main threads:
; - The main loop where all the important stuff is happening (the kernel).
; - A listener thread that will listen for incoming connections this thread is
;   spawned by the main loop.
; 
; In addition to that, the listener thread will spawn a worker thread that runs
; during the lifetime of each client connection. This worker thread is mainly
; responsible for dealing with input from the client. However, it might be also
; a good place to do some initial work before handing it off to the server or
; kernel (like parsing commands for example).
;
; Since all threads want access to the kernel we have to find a way to give it
; to them in a reasonable way. In case of the main loop this is a non-issue
; since that thread is explicitly responsible for managing all the resources.
;
; The only way other threads influence the main thread is by sending a message
; to its mailbox. The server will inspect the mailbox every frame and deal with
; any incoming requests. Although we could pass along the server thread to all
; other threads directly it might be nicer to abstract this as a kernel% class.
;
; TODO:
; Design kernel% class as an abstraction to database, built-in functions, task
; queue and other server/environment related stuff. This class should represent
; the server to any clients (mostly tasks and connection handlers) that want
; access to server related functionality.

(define client%
  (class object%
    (init-field thread socket)
    (field [player $nothing])
    (super-new)))

(define-unit server@
  (import db^)
  (export server^)

  (define connections (make-hasheq))
  
  (define (main)
    (match (thread-receive)
      ['connections
       (for/list ([c (hash-keys connections)])
         (displayln c))
       (flush-output)
       (main)]
      [x #:when (number? x)
         (displayln "a number")
         (main)]
      [x (displayln "something else")
         (main)]))

  (define (start-listening port-no)
    (define listener (tcp-listen port-no))
    (define (loop)
      (accept-and-handle listener)
      (loop))
    (define t (thread loop))
    (lambda ()
      (kill-thread t)
      (tcp-close listener)))

  (define (accept-and-handle listener)
    (define-values (I O) (tcp-accept listener))
    (define s (socket I O))
    (define handler (thread (lambda () (handle s))))
    (hash-set! connections s handler))

  (define (handle s)
    (define-values (I O) (values (socket-in s) (socket-out s)))
    ; this should probably not go outside of the polling loop
    (define cmd (read-line I 'return-linefeed))
    (define (close-connection)
      (hash-remove! connections s)
      (close-input-port I)
      (close-output-port O))
    (match (thread-try-receive)
      [(list 'disconnect)
       (close-connection)]
      [(list 'notify msg)
       (displayln msg O)]
      [#f
       (if (eof-object? cmd)
           (close-connection)
           (begin
             (displayln (string-append "> " cmd) O)
             (displayln "OK." O)
             (flush-output O)
             (handle s)))]))

  (define (close-connections)
    (for/list ([t (hash-values connections)])
      (thread-send t (list 'disconnect))))
  
  (define main-thread
    (thread
     (lambda ()
       ((main)))))

  (define (server-test x)
    (thread-send main-thread x))
  
  (define (server-start)
    (define stop-listening (start-listening 7777))
    (lambda ()
      (displayln "Shutdown sequence initiated.")
      ; 1. stop listening for incoming connections (stop-listening)
      (stop-listening)
      ; 2. close all existing connections
      (close-connections)
      ; 3. finish remaining tasks
      ; 4. serialize the database
      ; 5. exit the main loop
      (displayln "OK."))))

(provide server@)



















