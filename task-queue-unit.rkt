#lang racket

(require "task-queue-sig.rkt")

(define-unit task-queue@
  (import)
  (export task-queue^)

  (define task (start-time proc) #:transparent)

  