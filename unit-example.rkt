#lang racket

(define-signature toy-factory^
  (build-toys
   repaint
   toy?
   toy-color))

(define-unit simple-factory@
  (import)
  (export toy-factory^)
  (printf "Factory started.\n")
  (define-struct toy (color) #:transparent)
  (define (build-toys n)
    (for/list ([i (in-range n)])
      (make-toy 'blue)))
  (define (repaint t col)
    (make-toy col)))

(define-signature toy-store^
  (store-color
   stock!
   get-inventory))

(define-unit toy-store@
  (import toy-factory^)
  (export toy-store^)
  (define inventory null)
  (define (store-color) 'green)
  (define (maybe-repaint t)
    (if (eq? (toy-color t) (store-color))
        t
        (repaint t (store-color))))
  (define (stock! n)
    (set! inventory
          (append inventory
                  (map maybe-repaint
                       (build-toys n)))))
  (define (get-inventory) inventory))

