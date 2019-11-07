#lang racket/base

(require racket/match
         racket/list
         "ast.rkt")

(struct imm (x) #:transparent)
(struct ref (x) #:transparent)

(define (compile-list xs)
  (append (list 'make-empty-list)
          (flatten (map (λ (y) (list (compile y) 'list-add-tail)) xs))))

(define (compile ast)
  (match ast
    [(expr-const x)
     (list (imm x))]
    [(expr-id x)
     (list (ref x))]
    [(expr-list '())
     (list 'make-empty-list)]
    [(expr-list xs)
     (compile-list xs)]
    [(expr-unary op x)
     (append (compile x)
             (list op))]
    [(expr-binary op x y)
     (append (compile x)
             (compile y)
             (list op))]
    [(expr-prop obj name)
     (append (compile obj)
             (compile name)
             (list 'get-prop))]
    [(expr-verb obj vdesc args)
     (append (compile obj)
             (compile vdesc)
             (compile args)
             (list 'call-verb))]))

(provide compile
         (struct-out imm)
         (struct-out ref))