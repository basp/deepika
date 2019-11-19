#lang racket/base

(require srfi/13
         parser-tools/lex
         (prefix-in : parser-tools/lex-sre)
         rackunit)

; comment
; delimiter
; identifier
; keyword
; line-comment
; literal
; operator
; string
; text
; unknown
; white-space
; https://github.com/dotnet/roslyn/blob/master/src/Compilers/CSharp/
; Portable/Syntax/SyntaxKind.cs

(define-tokens literals
  (INT
   FLOAT
   STRING
   OBJECT
   ID))

(define-empty-tokens punctuation
  (+ - * / % ^ !
   EQ NE < LE > GE
   = ? PIPE ARROW
   $ : SEMICOLON
   DOT ..
   BACKTICK SQUOTE
   LPAREN RPAREN
   LBRACE RBRACE
   LBRACK RBRACK))

(define-empty-tokens keywords
  (IN AND OR
   TRUE FALSE
   FOR ENDFOR
   WHILE ENDWHILE
   BREAK CONTINUE RETURN
   IF ELSEIF ELSE ENDIF
   TRY EXCEPT FINALLY ENDTRY))

(define-lex-abbrevs
  [digit (:/ #\0 #\9)]
  [digit+ (:+ digit)]
  [digit* (:* digit)]
  [objid (:seq "#" (:? "-") digit+)]
  [alpha (:or (:/ #\A #\Z) (:/ #\a #\z) "_")]
  [alphanumeric (:or alpha digit)]
  [name (:seq alpha (:* alphanumeric))]
  [string (:seq #\" (:* any-char) #\")]
  [float (:or (:seq digit* "." digit+)
              (:seq digit* (:? ".") digit+ "e" (:? "-") digit+))]
  [int digit+])

(define get-string-token
  (lexer
   [(:~ #\" #\\) (cons (car (string->list lexeme))
                       (get-string-token input-port))]
   [(:: #\\ #\\) (cons #\\ (get-string-token input-port))]
   [(:: #\\ #\") (cons #\" (get-string-token input-port))]
   [#\" null]))

(define pika-lexer
  (lexer-src-pos
   [(eof) 'EOF]
   [whitespace (return-without-pos (pika-lexer input-port))]
   ["(" 'LPAREN]
   [")" 'RPAREN]
   ["{" 'LBRACE]
   ["}" 'RBRACE]
   ["[" 'LBRACK]
   ["]" 'RBRACK]
   ["." 'DOT]
   [(char-set "=<>+-*/%^!?:$") (string->symbol lexeme)]
   [".." (string->symbol lexeme)]
   ["and" 'AND]
   ["or" 'OR]
   ["in" 'IN]
   ["true" 'TRUE]
   ["false" 'FALSE]
   [name (token-ID lexeme)]
   [float (token-FLOAT (string->number lexeme))]
   [int (token-INT (string->number lexeme))]
   [#\" (token-STRING (list->string (get-string-token input-port)))]))

(provide pika-lexer)

(module+ test
  (define (lex ip)
    (position-token-token (pika-lexer ip)))
  (test-begin
   (define ip (open-input-string ""))
   (check-equal? (lex ip) 'EOF))
  (test-begin
   (define ip (open-input-string "\"foo \\\" bar\" quux"))
   (check-equal? (lex ip) (token-STRING "foo \" bar")))
  (test-begin
   (define ip (open-input-string "(){}[]"))
   (check-equal? (lex ip) 'LPAREN)
   (check-equal? (lex ip) 'RPAREN)
   (check-equal? (lex ip) 'LBRACE)
   (check-equal? (lex ip) 'RBRACE)
   (check-equal? (lex ip) 'LBRACK)
   (check-equal? (lex ip) 'RBRACK))  
  (test-begin
   (define ip (open-input-string "in and or true false"))
   (check-equal? (lex ip) 'IN)
   (check-equal? (lex ip) 'AND)
   (check-equal? (lex ip) 'OR)
   (check-equal? (lex ip) 'TRUE)
   (check-equal? (lex ip) 'FALSE))
  (test-begin
   (define ip (open-input-string "123 .5 1.5 1e5 1e-5 .1e-5"))
   (check-equal? (lex ip) (token-INT 123))
   (check-equal? (lex ip) (token-FLOAT 0.5))
   (check-equal? (lex ip) (token-FLOAT 1.5))
   (check-equal? (lex ip) (token-FLOAT 1e5))
   (check-equal? (lex ip) (token-FLOAT 1e-5))
   (check-equal? (lex ip) (token-FLOAT 1e-6))))
