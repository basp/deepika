#lang racket/base

(require megaparsack
         megaparsack/text)

(require data/monad
         data/applicative)

(define ident-char/p (char-not-in/p "\" "))

(provide parse/args)

(define arg/p
  (do [h <- ident-char/p]    
      [t <- (many/p ident-char/p)]
      (pure (list->string (cons h t)))))

(define quoted-arg/p
  (do (char/p #\")
      [w <- (many/p (char-not-in/p "\""))]
      (or/p (char/p #\") eof/p)
      (pure (list->string w))))

(define arg*/p
  (do [w <- (or/p arg/p quoted-arg/p)]
      (many/p space/p)
      (pure w)))

(define args/p
  (do (many/p space/p)
      (many/p arg*/p)))

(define (parse/args argstr)
  (parse-result! (parse-string args/p argstr)))