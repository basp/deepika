#lang racket/base

(require rackunit
         "parser.rkt")

(check-equal?
 (list "foo" "bar")
 (parse/args "foo bar"))

(check-equal?
 (list "foo" "bar" "quux frotz" "zoz")
 (parse/args "   foo    bar  \"quux frotz\"    zoz  "))