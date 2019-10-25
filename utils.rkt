#lang racket/base

(require racket/match)

(define (max-id ids [start-value 0])
  (match ids
    [xs #:when (null? xs) 0]
    [xs (apply max xs)]))

(provide (all-defined-out))