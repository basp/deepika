#lang racket/base

(require srfi/13
         parser-tools/lex
         parser-tools/yacc
         (prefix-in : parser-tools/lex-sre))

(define-tokens value-tokens
  (INTEGER
   FLOAT
   STRING
   OBJECT
   ID))

(define-empty-tokens keyword-tokens
  (IF
   ELSEE
   ELSEIF
   ENDIF))

(define-empty-tokens symbol-tokens
  (COMMA
   COLON
   LBRACE
   RBRACE
   LPAREN
   RPAREN))

(define-empty-tokens op-tokens
  (=
   ? PIPE
   OR AND
   EQ NE < LE > GE IN
   + -
   * / %
   ^
   ! NEG
   DOT : $
   ARROW
   EOF))

(define-lex-abbrevs
  [digit (:/ #\0 #\9)]
  [digits (:+ digit)]
  [object-id (:seq "#" (:? "-") digits)]
  [name-start-char (:or "_" (:/ #\A #\z))]
  [name-char (:or name-start-char digit)]
  [name (:seq name-start-char (:* name-char))])

(define moo-lex
  (lexer-src-pos
   [(eof) 'EOF]
   [#\. (token-DOT)]
   [whitespace (return-without-pos (moo-lex input-port))]
   [":" (token-COLON)]
   ["," (token-COMMA)]
   ["{" (token-LBRACE)]
   ["}" (token-RBRACE)]
   ["(" (token-LPAREN)]
   [")" (token-RPAREN)]
   ["|" (token-PIPE)]
   ["||" (token-OR)]
   ["&&" (token-AND)]
   ["==" (token-EQ)]
   ["!=" (token-NE)]
   ["<=" (token-LE)]
   [">=" (token-GE)]
   ["in" (token-IN)]
   ["=>" (token-ARROW)]
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

(struct const (val) #:transparent)
(struct id (x) #:transparent)
(struct add (lhs rhs) #:transparent)
(struct sub (lhs rhs) #:transparent)
(struct mul (lhs rhs) #:transparent)
(struct div (lhs rhs) #:transparent)
(struct mod (lhs rhs) #:transparent)
(struct neg (exp) #:transparent)
(struct set (lhs rhs) #:transparent)
(struct objid (val) #:transparent)
(struct arglist (val) #:transparent)
(struct condexpr (pred then else) #:transparent)
(struct propref (obj name) #:transparent)
(struct verbcall (obj vdesc args) #:transparent)

(define moo-parse
  (parser
   (start start)
   (end EOF)
   (src-pos)
   (tokens value-tokens keyword-tokens op-tokens symbol-tokens)
   (error
    (λ (tok-ok? tok-name tok-value start-pos end-pos)
      (displayln start-pos)
      (displayln tok-ok?)
      (displayln tok-name)))
   (precs (right =)
          (nonassoc ? PIPE)
          (left OR AND)
          (left EQ NE < LE GE IN)
          (left - +)
          (left * / %)
          (right ^)
          (left ! NEG)
          (nonassoc DOT COLON $))
   (grammar
    (start [() #f]
           [(expr) $1])
    (arglist [() (objid -1)]
             [(ne-arglist) (reverse $1)])
    (ne-arglist [(expr) (list $1)]
                [(ne-arglist COMMA expr)
                 (cons $3 $1)])
    (expr [(INTEGER)
           (const $1)]
          [(FLOAT)
           (const $1)]
          [(STRING)
           (const $1)]
          [(OBJECT)
           (const (objid $1))]
          [(ID)
           (id $1)]
          [($ ID)
           (propref (objid 0) $2)]
          [(expr COLON ID LPAREN arglist RPAREN)
           (verbcall $1 (id $3) $5)]
          [(expr + expr)
           (add $1 $3)]
          [(expr - expr)
           (sub $1 $3)]
          [(expr * expr)
           (mul $1 $3)]
          [(expr / expr)
           (div $1 $3)]
          [(expr % expr)
           (mod $1 $3)]
          [(expr = expr)
           (set $1 $3)]
          [(- expr)
           (prec NEG)
           (neg $2)]
          [(LPAREN expr RPAREN)
           $2]
          [(LBRACE arglist RBRACE)
           (arglist $2)]
          [(expr ? expr PIPE expr)
           (condexpr $1 $3 $5)]
          [(expr DOT LPAREN expr RPAREN)
           (propref $1 $4)]
          [(expr DOT ID)
           (propref $1 (id $3))]))))

(define (parse/string s)
  (define ip (open-input-string s))
  (moo-parse (λ () (moo-lex ip))))
