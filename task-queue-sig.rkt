#lang racket

(require "common.rkt")

(define-signature task-queue^
  ((contracted
    [task-start (-> integer? procedure? taskid?)]
    [task-kill (-> taskid? any/c)]
    [task-ready? (-> taskid? boolean?)]
    [task-list (-> (listof taskid?))])))

(provide task-queue^)
