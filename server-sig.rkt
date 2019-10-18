#lang racket

(define-signature server^
  ((contracted
    [server-test (-> any/c any/c)]
    [server-start (-> any/c)])))

(provide server^)