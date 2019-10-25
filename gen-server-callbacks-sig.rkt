#lang racket/base

(require racket/unit)

(define-signature gen-server-callbacks^
  (init
   terminate
   handle-cast
   handle-call))

(provide gen-server-callbacks^)