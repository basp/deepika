#lang racket

; Tasks
; -----
; There are two kinds of result from a task:
; - The task can return "done" in which case it ran to completion
; - The task can return "suspended"
;
; In the case of a suspended task the result will contain:
; - Either a next run time or some kind of delay
; - A thunk containing the rest of the program to run
;
; A forked task will be created on the run queue directly so
; these will have no impact on the result of the task that
; they were originally forked from.
;
; Task Queue
; ----------
; task        ; struct (integer? integer? proc?)
; task-create ; integer? proc? -> task-id?
; task-kill   ; task-id? -> (or/c task? boolean?)
; task-ready? ; task-id? -> boolean?
; task-list   ; -> (listof task?)
  




