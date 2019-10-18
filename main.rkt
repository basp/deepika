#lang racket

(require "db-unit.rkt"
         "server-unit.rkt")

(define-values/invoke-unit/infer db@)
(define-values/invoke-unit/infer server@)