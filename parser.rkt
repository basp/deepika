#lang racket/base

(require racket/match)

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

(define (priv/parse-args chars [acc null])
  (match (skip-blank chars)
    [(list a rest ...)
     (let* ([p (if (quotation-mark? a) parse-word* parse-word)]
            [res (p (cons a rest))]
            [w (car res)]
            [t (cdr res)])
       (priv/parse-args t (cons w acc)))]
    [rest (reverse acc)]))

(define (string->args str)
  (priv/parse-args (string->list str)))

(provide string->args)

(module+ test
  (require rackunit)
  (define argstr "foo \"bar mumble\" baz\" \"fr\"otz\" bl\"o\"rt")
  (define args (string->args argstr))
  (check-equal? args '("foo" "bar mumble" "baz frotz" "blort")))