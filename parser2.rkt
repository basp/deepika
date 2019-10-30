#lang racket/base

(require racket/match)

; foo "bar mumble" baz" "fr"otz" bl"o"rt
; => "foo" "bar mumble" "baz frotz" "blort"

(define (quotation-mark? char)
  (equal? #\" char))

(define (skip-blank chars)
  (match chars
    [(list a rest ...)
     #:when (char-blank? a)
     (skip-blank rest)]
    [rest rest]))

(define (parse-word* chars [acc null])
  (match chars
    [(list a b rest ...)
     #:when (and (quotation-mark? a) (char-blank? b))
     (cons (list->string (reverse acc)) rest)]
    [(list a rest ...)
     #:when (quotation-mark? a)
     (parse-word* rest acc)]
    [(list a rest ...)
     (parse-word* rest (cons a acc))]
    [else
     (cons (list->string (reverse acc)) null)]))

(define (parse-word chars [acc null])
  (match chars
    [(list a rest ...)
     #:when (quotation-mark? a)
     (parse-word* rest acc)]
    [(list a rest ...)
     #:when (char-blank? a)
     (cons (list->string (reverse acc)) chars)]
    [(list a rest ...)
     (parse-word rest (cons a acc))]
    [else
     (cons (list->string (reverse acc)) null)]))

(define (parse/args chars [acc null])
  (match (skip-blank chars)
    [(list a rest ...)
     (if (quotation-mark? a)         
         (let* ([res (parse-word* (cons a rest))]
                [w (car res)]
                [t (cdr res)])
           (parse/args t (cons w acc)))
         (let* ([res (parse-word (cons a rest))]
                [w (car res)]
                [t (cdr res)])
           (parse/args t (cons w acc))))]
    [rest (reverse acc)]))

(module+ test
  (require rackunit)
  (define argstr "foo \"bar mumble\" baz\" \"fr\"otz\" bl\"o\"rt")
  (define args (parse/args (string->list argstr)))
  (check-equal? args '("foo" "bar mumble" "baz frotz" "blort")))