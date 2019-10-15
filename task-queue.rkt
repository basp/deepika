#lang racket

(struct task (proc))
(struct delayed-task (start-time proc))

(define (start-immediate-task proc)
  (queue (task proc)))

(define (delayed-task-from-now sec proc)
  (queue (delayed-task (+ (current-seconds) sec) proc)))

(define rt
  (thread
   (lambda ()
     (define tasks (list))
     (define (task-ready? t)
       (<= (- (delayed-task-start-time t) (current-seconds)) 0))
     (define (get-ready-tasks)
       (filter task-ready? tasks))
     (define (run-tasks ts)
       (for/list ([t ts])
         ((delayed-task-proc t))))
     (let loop ()
       (begin
         (define ready-tasks (get-ready-tasks))
         (run-tasks ready-tasks)
         (set! tasks (remove* ready-tasks tasks)))
       (match (thread-try-receive)
         [(task proc)
          (proc)
          (loop)]
         [t #:when (delayed-task? t)
            (set! tasks (cons t tasks))
            (loop)]
         ['tasks
          (displayln tasks)
          (loop)]
         [#f
          ; TODO: proper sleep time based on execution time
          (sleep 1/60) 
          (loop)]
         ['done
          (printf "Done~n")])))))

(define (tasks)
  (thread-send rt 'tasks))

(define (queue t)
  (thread-send rt t))

(define (stop)
  (thread-send rt 'done))

(define task-queue%
  (class object%
    (init-field [rate 1/60])
    (define worker
      (thread
       (lambda ()
         (define tasks (list))
         (define (task-ready? t)
           (<= (- (delayed-task-start-time t) (current-seconds)) 0))
         (define (get-ready-tasks)
           (filter task-ready? tasks))
         (define (run-tasks ts)
           (for/list ([t ts])
             ((delayed-task-proc t))))
         (let loop ()
           (begin
             (define ready-tasks (get-ready-tasks))
             (run-tasks ready-tasks)
             (set! tasks (remove* ready-tasks tasks)))
           (match (thread-try-receive)
             [(task proc)
              (proc)
              (loop)]
             [t #:when (delayed-task? t)
                (set! tasks (cons t tasks))
                (loop)]
             ['tasks
              (displayln tasks)
              (loop)]
             [#f
              ; TODO: proper sleep time based on execution time
              (sleep 1/60) 
              (loop)]
             ['done
              (printf "Done~n")])))))
    (super-new)
    (define/public (queue t) #f)))

(define (throw)
  (start-immediate-task (λ () (displayln "You look around for a rock...")))
  (delayed-task-from-now 5 (λ () (displayln "You find a candidate.")))
  (delayed-task-from-now 7 (λ () (displayln "You throw the rock with great athletic finesse.")))
  (delayed-task-from-now 10 (λ () (displayln "You hear a dull thud as the rock hits the ground"))))

(define (throw-poorly)
  (start-immediate-task (λ () (displayln "You look around for a rock...")))
  (delayed-task-from-now 5 (λ () (displayln "You find a candidate. This one looks perfect.")))
  (delayed-task-from-now 7 (λ () (displayln "You try to throw the rock but almost trip over due to the weight.")))
  (delayed-task-from-now 10 (λ () (displayln "Goddammit!")))
  (delayed-task-from-now 13 (λ () (displayln "You decide for another approach this time..."))))