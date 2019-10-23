#lang racket

(define-signature server-callbacks^
  (init
   terminate
   handle-cast
   handle-call))

(provide server-callbacks^)