#lang racket/base

(require racket/match
         racket/list
         "ast.rkt")

(struct imm (x) #:transparent)
(struct ref (x) #:transparent)

(struct op (x) #:transparent)

(struct make-empty-list () #:transparent)
(struct make-singleton-list () #:transparent)
(struct list-add-tail () #:transparent)

(struct get-prop () #:transparent)
(struct call-verb () #:transparent)

(define (compile-list xs)
  (append (compile (car xs))
          (list (make-singleton-list))
          (flatten (map (λ (y) (list (compile y) (list-add-tail))) (cdr xs)))))

(define (compile ast)
  (match ast
    [(expr-const x)
     (list (imm x))]
    [(expr-id x)
     (list (ref x))]
    [(expr-list '())
     (list (make-empty-list))]
    [(expr-list xs)
     #:when (equal? 1 (length xs))
     (append (compile (car xs))
             (list (make-singleton-list)))]
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
             (list (get-prop)))]
    [(expr-verb obj vdesc args)
     (append (compile obj)
             (compile vdesc)
             (compile args)
             (list (call-verb)))]))

(provide compile
         (struct-out imm)
         (struct-out ref))