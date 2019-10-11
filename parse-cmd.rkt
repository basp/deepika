#lang racket

(require megaparsack megaparsack/text)
(require data/monad data/applicative)

(define arg-char/p (char-not-in/p "\" "))

(define arg/p
  (do [h <- arg-char/p]    
      [t <- (many/p arg-char/p)]
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

(define (parse/cmd argstr)
  (parse-result! (parse-string args/p argstr)))