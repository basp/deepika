#lang racket/base

(require racket/match
         racket/contract
         srfi/13)

(define (min-match-length spec)
  (match (string-contains spec "*")
        [#f (string-length spec)]
        [idx idx]))

(define (priv/match-verb-spec x spec)
  (match (regexp-match (regexp x) (string-delete #\* spec))
    [#f (cons #f x)]
    [m (let* ([x (car m)])
         (cons (>= (string-length x)
                   (min-match-length spec))
               x))])) 

(define (priv/match-verb-spec* x spec)
  (match (regexp-match (regexp (string-delete #\* spec)) x)
    [#f (cons #f (car x))]
    [x (cons #t (car x))]))

(define (match-verb-spec x spec)
  (match spec
    ["*"
     (cons #t x)]
    [x
     #:when (string-suffix? "*" spec)
     (priv/match-verb-spec* x spec)]
    [else
     (priv/match-verb-spec x spec)]))

(provide
 (contract-out
  [match-verb-spec (-> string? string? (cons/c boolean? any/c))]))

(module+ test
  (require rackunit)
  (check-true (car (match-verb-spec "foo" "foo*bar")))
  (check-true (car (match-verb-spec "foobar" "foo*bar")))
  (check-true (car (match-verb-spec "fooba" "foo*bar")))
  (check-true (car (match-verb-spec "quux" "*")))
  (check-true (car (match-verb-spec "frotz" "*")))
  (check-false (car (match-verb-spec "foobarx" "foo*bar")))
  (check-false (car (match-verb-spec "fo" "foo*bar"))))
