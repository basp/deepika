#lang racket/base

(require parser-tools/yacc
         "shared.rkt"
         "lexer.rkt"
         "ast.rkt")

(define moo-parse
  (parser
   (start start)
   (end EOF)
   ;; make the parser expect src-pos tokens
   (src-pos) 
   (tokens
    value-tokens
    keyword-tokens
    op-tokens
    symbol-tokens
    error-tokens)
   ;; this needs some additional work
   (error
    (λ (tok-ok? tok-name tok-value start-pos end-pos)
      (displayln start-pos)
      (displayln tok-ok?)
      (displayln tok-name)
      (displayln tok-value)))
   (precs (right =)
          (nonassoc ? PIPE)
          (left OR AND)
          (left EQ NE < LE > GE IN)
          (left + -)
          (left * / %)
          (right ^)
          (left ! NEG)
          (nonassoc DOT COLON $
                    LBRACK LPAREN))
   (grammar
    (start [() #f]
           [(expr) $1]
           [(statements) $1])
    ;; maybe empty list
    (arglist [() null]
             [(ne-arglist) (reverse $1)])
    ;; non-empty list
    (ne-arglist [(expr) (list $1)]
                [(ne-arglist COMMA expr)
                 (cons $3 $1)])
    ;; key-value pair for hash
    (kvp [(expr ARROW expr)
          (cons $1 $3)])
    ;; maybe empty hash
    (hash [() null]
          [(ne-hash) (reverse $1)])
    ;; non-empty hash
    (ne-hash [(kvp) (list $1)]
             [(ne-hash COMMA kvp)
              (cons $3 $1)])
    ;; default value for catch expression
    (:default [() (expr-const 0)]
              [(ARROW expr) $2])
    ;; error codes to catch
    (codes [(ANY) (expr-const 0)]
           [(ne-arglist) (expr-list $1)])
    ;; maybe empty elseif arms
    (elseifs [() null]
             [(ne-elseifs) (reverse $1)])
    ;; non-empty elseif arms
    (ne-elseifs [(elseifs ELSEIF LPAREN expr RPAREN statements)
                 (cons (cond-arm $4 $6) $1)])
    ;; else for if-statement
    (elsepart [() null]
              [(ELSE statements) $2])
    ;; statement list
    (statements [(ne-statements)
                 (reverse $1)])
    ;; non-empty statement list
    (ne-statements [(stmt) (list $1)]
                   [(ne-statements stmt)
                    (cons $2 $1)])
    ;; statements
    (stmt [(expr SEMICOLON)
           (stmt-expr $1)]
          [(IF LPAREN expr RPAREN statements elseifs elsepart ENDIF)
           (stmt-cond (cons (cond-arm $3 $5) $6) $7)])
    ;; expressions
    (expr [(INTEGER)
           (expr-const $1)]
          [(FLOAT)
           (expr-const $1)]
          [(STRING)
           (expr-const $1)]
          [(OBJECT)
           (expr-const (objid $1))]
          [(ID)
           (expr-id $1)]
          [(ERROR)
           (expr-error $1)]
          [(TRUE)
           (expr-const 1)]
          [(FALSE)
           (expr-const 0)]
          [($ ID)
           (expr-prop (objid 0) $2)]
          [(expr COLON ID LPAREN arglist RPAREN)
           (expr-verb $1 (expr-id $3) (expr-list $5))]
          [(expr COLON LPAREN expr RPAREN LPAREN arglist RPAREN)
           (expr-verb $1 $4 (expr-list $7))]
          [(expr LPAREN arglist RPAREN)
           (expr-call $1 (expr-list $3))]
          [(expr LBRACK expr RBRACK)
           (expr-binary 'idx $1 $3)]
          [(expr + expr)
           (expr-binary 'add $1 $3)]
          [(expr - expr)
           (expr-binary 'sub $1 $3)]
          [(expr * expr)
           (expr-binary 'mul $1 $3)]
          [(expr / expr)
           (expr-binary 'div $1 $3)]
          [(expr % expr)
           (expr-binary 'mod $1 $3)]
          [(expr ^ expr)
           (expr-binary 'exp $1 $3)]
          [(expr AND expr)
           (expr-binary 'and $1 $3)]
          [(expr OR expr)
           (expr-binary 'or $1 $3)]
          [(expr = expr)
           (expr-set! $1 $3)]
          [(- expr)
           (prec NEG)
           (expr-unary 'neg $2)]
          [(! expr)
           (expr-unary 'not $2)]
          [(LPAREN expr RPAREN)
           $2]
          [(LBRACE arglist RBRACE)
           (expr-list $2)]
          [(LBRACK hash RBRACK)
           (expr-hash (make-hash $2))]
          [(expr ? expr PIPE expr)
           (expr-cond $1 $3 $5)]
          [(BACKTICK expr ! codes :default SQUOTE)
           (expr-catch $2 $4 $5)]           
          [(expr DOT LPAREN expr RPAREN)
           (expr-prop $1 $4)]
          [(expr DOT ID)
           (expr-prop $1 (expr-id $3))]))))

(define (parse/string s)
  (define ip (open-input-string s))
  (moo-parse (λ () (moo-lex ip))))

(provide parse/string)

(module+ test
  (require rackunit)
  (let ([ast (parse/string "true")])
    (check-equal? ast (expr-const 1)))
  (let ([ast (parse/string "false")])
    (check-equal? ast (expr-const 0)))
  (let ([ast (parse/string "123")])
    (check-equal? ast (expr-const 123)))
  (let ([ast (parse/string "123.456")])
    (check-equal? ast (expr-const 123.456)))
  (let ([ast (parse/string "\"frotz\"")])
    (check-equal? ast (expr-const "frotz")))
  (let ([ast (parse/string "-123")])
    (check-equal? ast (expr-unary 'neg (expr-const 123))))
  (let ([ast (parse/string "-123.456")])
    (check-equal? ast (expr-unary 'neg (expr-const 123.456))))
  (let ([ast (parse/string "#123")])
    (check-equal? ast (expr-const (objid 123))))
  (let ([ast (parse/string "#-123")])
    (check-equal? ast (expr-const (objid -123))))
  (let ([ast (parse/string "E_TYPE")])
    (check-equal? ast (expr-error 'E_TYPE)))
  (let ([ast (parse/string "E_ARGS")])
    (check-equal? ast (expr-error 'E_ARGS)))
  (let ([ast (parse/string "{}")])
    (check-equal? ast (expr-list null)))
  (let ([ast (parse/string "[]")])
    (check-equal? ast (expr-hash (make-hash))))
  (let ([ast (parse/string "{1, foo, \"bar\"}")])
    (check-equal? ast (expr-list
                       (list
                        (expr-const 1)
                        (expr-id "foo")
                        (expr-const "bar")))))
  (let ([ast (parse/string "[1 => 2]")])
    (check-equal? ast (expr-hash
                       (make-hash
                        (list
                         (cons (expr-const 1)
                               (expr-const 2)))))))
  (let ([ast (parse/string "[foo => bar, \"quux\" => 123.456]")])
    (check-equal? ast (expr-hash
                       (make-hash
                        (list
                         (cons (expr-id "foo")
                               (expr-id "bar"))
                         (cons (expr-const "quux")
                               (expr-const 123.456)))))))
  (let ([ast (parse/string "{foo}")])
    (check-equal? ast (expr-list (list (expr-id "foo"))))))

