#lang racket/base

(require racket/match
         racket/list
         "ast.rkt")

(struct imm (x) #:transparent)
(struct ref (x) #:transparent)

(struct op (x) #:transparent)

(struct mel () #:transparent)
(struct msl () #:transparent)
(struct lat () #:transparent)

(struct getp () #:transparent)
(struct calv () #:transparent)

(define (compile-list xs)
  (append (compile (car xs))
          (list (msl))
          (flatten (map (λ (y) (list (compile y) (lat))) (cdr xs)))))

(define (compile ast)
  (match ast
    [(expr-const x)
     (list (imm x))]
    [(expr-id x)
     (list (ref x))]
    [(expr-list '())
     (list (mel))]
    [(expr-list xs)
     #:when (equal? 1 (length xs))
     (append (compile (car xs))
             (list (msl)))]
    [(expr-list xs)
     (compile-list xs)]
    [(expr-unary o x)
     (append (compile x)
             (list (op o)))]
    [(expr-binary o x y)
     (append (compile x)
             (compile y)
             (list (op o)))]
    [(expr-prop obj name)
     (append (compile obj)
             (compile name)
             (list (getp)))]
    [(expr-verb obj vdesc args)
     (append (compile obj)
             (compile vdesc)
             (compile args)
             (list (calv)))]))

(provide compile
         (struct-out imm)
         (struct-out ref))