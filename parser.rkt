#lang racket/base

(require parser-tools/lex
         parser-tools/yacc
         (prefix-in : parser-tools/lex-sre)
         (only-in srfi/13 string-trim-both)
         "shared.rkt")

(define-tokens value-tokens
  (INTEGER
   FLOAT
   STRING
   OBJECT
   ID
   ERROR))

(define-empty-tokens keyword-tokens
  (TRUE
   FALSE
   IF
   ELSEE
   ELSEIF
   ENDIF))

(define-empty-tokens error-tokens
  (ANY))

(define-empty-tokens symbol-tokens
  (COMMA
   COLON
   LBRACE
   RBRACE
   LPAREN
   RPAREN
   LBRACK
   RBRACK
   BACKTICK))

(define-empty-tokens op-tokens
  (=
   ? PIPE
   OR AND
   EQ NE < LE > GE IN
   + -
   * / %
   ^
   ! NEG
   SQUOTE
   DOT : $
   ARROW
   EOF))

(define-lex-abbrevs
  [digit (:/ #\0 #\9)]
  [digits (:+ digit)]
  [object-id (:seq "#" (:? "-") digits)]
  [name-start-char (:or "_" (:/ #\A #\Z) (:/ #\a #\z))]
  [name-char (:or name-start-char digit)]
  [name (:seq name-start-char (:* name-char))])

(define moo-lex
  (lexer-src-pos
   [(eof) 'EOF]
   [#\. (token-DOT)]
   [whitespace (return-without-pos (moo-lex input-port))]
   [":" (token-COLON)]
   ["," (token-COMMA)]
   ["`" (token-BACKTICK)]
   ["'" (token-SQUOTE)]
   ["{" (token-LBRACE)]
   ["}" (token-RBRACE)]
   ["(" (token-LPAREN)]
   [")" (token-RPAREN)]
   ["[" (token-LBRACK)]
   ["]" (token-RBRACK)]
   ["|" (token-PIPE)]
   ["||" (token-OR)]
   ["&&" (token-AND)]
   ["==" (token-EQ)]
   ["!=" (token-NE)]
   ["<=" (token-LE)]
   [">=" (token-GE)]
   ["in" (token-IN)]
   ["=>" (token-ARROW)]
   ["ANY" (token-ANY)]
   ["E_TYPE" (token-ERROR 'E_TYPE)]
   ["E_PROPNF" (token-ERROR 'E_PROPNF)]
   ["E_VERBNF" (token-ERROR 'E_VERBNF)]
   ["E_INVARG" (token-ERROR 'E_INVARG)]
   ["E_ARGS" (token-ERROR 'E_ARGS)]
   ["E_PERM" (token-ERROR 'E_PERM)]
   ["E_QUOTA" (token-ERROR 'E_QUOTA)]
   ["true" (token-TRUE)]
   ["false" (token-FALSE)]
   [(char-set "?<>+-*/%^!:$=")
    (string->symbol lexeme)]
   [name
    (token-ID lexeme)]
   [(:seq #\" (:* any-char) #\")
    (token-STRING (string-trim-both lexeme #\"))]
   [object-id
    (token-OBJECT (string->number (substring lexeme 1)))]
   [digits
    (token-INTEGER (string->number lexeme))]
   [(:or (:seq (:? digits) "." digits)
         (:seq digits "."))
    (token-FLOAT (string->number lexeme))]))

(struct expr-const (val) #:transparent)
(struct expr-id (x) #:transparent)
(struct expr-binary (op lhs rhs) #:transparent)
(struct expr-unary (op val) #:transparent)
(struct expr-list (val) #:transparent)
(struct expr-hash (val) #:transparent)
(struct expr-set! (lhs rhs) #:transparent)
(struct expr-cond (pred then else) #:transparent)
(struct expr-prop (obj name) #:transparent)
(struct expr-verb (obj vdesc args) #:transparent)
(struct expr-call (fn args) #:transparent)
(struct expr-catch (try codes except) #:transparent)
(struct expr-error (type) #:transparent)

(define moo-parse
  (parser
   (start start)
   (end EOF)
   (src-pos)
   (tokens
    value-tokens
    keyword-tokens
    op-tokens
    symbol-tokens
    error-tokens)
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
           [(expr) $1])
    (arglist [() null]
             [(ne-arglist) (reverse $1)])
    (ne-arglist [(expr) (list $1)]
                [(ne-arglist COMMA expr)
                 (cons $3 $1)])
    (kvp [(expr ARROW expr)
          (cons $1 $3)])
    (hash [(kvp) (list $1)]
          [(hash COMMA kvp) (cons $3 $1)])
    (:default [() (expr-const 0)]
              [(ARROW expr) $2])
    (codes [(ANY) (expr-const 0)]
           [(ne-arglist) (expr-list $1)])
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
           (expr-const $1)]
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
          [(LBRACE hash RBRACE)
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