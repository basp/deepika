#lang racket/base

(require racket/match
         racket/contract
         "common.rkt")

(struct task (id start-time thunk))

(define idx (make-hash))

(define (max-task-id)
  (max-id (hash-keys idx) 0))

(define (next-task-id)
  (add1 (max-task-id)))

(define (task/valid? id)
  (hash-has-key? idx id))

(define (get-task id)
  (hash-ref idx id))

(define (task-start! del thunk)
  (let* ([id (next-task-id)]
         [t (task id (+ (current-seconds) del) thunk)])
    (hash-set! idx id t)
    id))

(define (task-ready? id)
  (let ([t (hash-ref idx id)])
    (<= (task-start-time t) (current-seconds))))

(define (task-remove! id)
  (hash-remove! idx id))

(define (tasks)
  (hash-keys idx))

(define (tasks/ready)
  (filter task-ready? (tasks)))

(provide
 (contract-out
  [task? (-> any/c boolean?)]
  [task-id (-> task? integer?)]
  [task-thunk (-> task? procedure?)]
  [task/valid? (-> integer? boolean?)]
  [task-start! (-> integer? procedure? task/valid?)]
  [task-ready? (-> task/valid? boolean?)]
  [task-remove! (-> task/valid? any)]
  [get-task (-> task/valid? task?)]
  [tasks (-> (listof task/valid?))]
  [tasks/ready (-> (listof task/valid?))]))
