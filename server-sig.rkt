#lang racket/base

(require racket/unit
         racket/contract)

(define-signature server^
  ((contracted
    [server-test (-> any/c any/c)]
    [server-start (-> any/c)])))

(provide server^)