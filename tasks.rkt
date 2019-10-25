#lang racket/base

(require racket/match
         racket/contract
         "common.rkt")

(struct task (id start-time proc) #:transparent)

(define idx (make-hash))

(define (max-task-id)
  (max-id (hash-keys idx) 0))

(define (next-task-id)
  (add1 (max-task-id)))

(define (task-start! del proc)
  (let* ([id (next-task-id)]
         [t (task id (+ (current-seconds) del) proc)])
    (hash-set! idx id t)
    id))

(define (task-ready? id)
  (match (hash-has-key? idx id)
    [#t (let ([t (hash-ref idx id)])
          (<= (task-start-time t) (current-seconds)))]
    [_ #f]))

(define (task-remove! id)
  (hash-remove! idx id))

(define (tasks)
  (hash-keys idx))

(define (tasks/ready)
  (filter task-ready? (tasks)))

(provide
 (contract-out
  [task-start! (-> integer? procedure? integer?)]
  [task-ready? (-> integer? boolean?)]
  [task-remove! (-> integer? any)]
  [tasks (-> (listof integer?))]
  [tasks/ready (-> (listof integer?))]))
