#lang racket

(require "task-queue-sig.rkt"
         "common.rkt")

(define-unit task-queue@
  (import)
  (export task-queue^)

  (struct task (id start-time proc) #:transparent)

  (define tasks (make-hash))

  (define (max-id)
    (match (hash-keys tasks)
      (xs #:when (null? xs) 0)
      (xs (apply max xs))))

  (define (next-id)
    (add1 (max-id)))
  
  (define (task-start! delay proc)
    (let* ([id (next-id)]
           [tid (taskid id)]
           [t (task tid (+ (current-seconds) delay) proc)])
      (hash-set! tasks id t)
      tid))

  (define (task-ready? tid)
    (define id (taskid-id tid))
    (match (hash-has-key? tasks id)
      [#t (let ([t (hash-ref tasks (taskid-id tid))])
            (<= (task-start-time t) (current-seconds)))]
      [x x]))

  (define (task-remove! tid)
    (hash-remove! tasks (taskid-id tid)))

  (define (task-list)
    (map (λ (x) (taskid x)) (hash-keys tasks)))

  (define (task-list/ready)
    (filter task-ready? (task-list))))