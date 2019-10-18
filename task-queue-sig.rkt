#lang racket

(require "common.rkt")

(define-signature task-queue^
  ((contracted
    [task-start! (-> integer? procedure? taskid?)]
    [task-remove! (-> taskid? any/c)]
    [task-ready? (-> taskid? boolean?)]
    [task-list/ready (-> (listof taskid?))]
    [task-list (-> (listof taskid?))])))

(provide task-queue^)
