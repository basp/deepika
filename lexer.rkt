#lang racket/base

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre)
         (only-in srfi/13 string-trim-both))

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

(provide moo-lex
         value-tokens
         keyword-tokens
         error-tokens
         op-tokens
         symbol-tokens)