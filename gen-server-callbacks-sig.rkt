#lang racket

(define-signature gen-server-handlers^
  (init
   terminate
   handle-cast
   handle-call))

(provide gen-server-handlers^)