#lang br/quicklang

(require brag/support
         br-parser-tools/lex-sre)

(define (make-tokenizer port)
  (define (next-token)
    (define moo-lexer
      (lexer-srcloc
       [(:+ whitespace)
        (token 'WHITESPACE lexeme)]
       ["if"
        (token 'KEYWORD lexeme)]
       ["for"
        (token 'KEYWORD lexeme)]
       ["then"
        (token 'KEYWORD lexeme)]
       [(:+ numeric)
        (token 'NUMBER lexeme)]
       [(from/to "\"" "\"")
        (token 'STRING (trim-ends "\"" lexeme "\""))]
       [(:+ alphabetic)
        (token 'IDENT lexeme)]
       [any-char
        (token 'CHAR lexeme)]))
    (moo-lexer port))
  next-token)

(provide make-tokenizer)
