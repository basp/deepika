#lang racket/base

(struct program
  (main
   forks
   literals)
  #:transparent)


