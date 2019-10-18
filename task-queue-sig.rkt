#lang racket

(require "common.rkt")

(define-signature task-queue^
  ((contracted
    [task-start (-> integer? procedure?)]
    [task-kill (-> task-id?)]
    [task-list (-> (listof any/c))])))

(provide task-queue^)
