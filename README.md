# deepika
Wannabe spiritual successor to LambdaMOO.

## Overview
This is very much a work in progress. The following stuff is *blissfully* implemented:

* basic database (`db-sig.rkt` and `db-unit.rkt`)
* task queue (`task-queue.rkt`)
* command parser (`parser.rkt` and `parser-test.rkt`)
* common infrastructure such as `objid` and friends (`common.rkt`)
* **very basic** VM (`vm.rkt`)

## Quick start
The object database `unit` is more or less functional although it isn't really hooked up to anything just yet.
```
> (define-values/invoke-unit/infer db@)
> (create-object! $nothing)        
(objid 1)
> (create-object! $nothing)        
(objid 2)
> (objects)                        
(list (objid 1) (objid 2))
> (get-contents (objid 1))         
(set)
> (set-location! (objid 2) (objid 1))
> (get-contents (objid 1))
(set (objid 2))
> (get-location (objid 2))
(objid 1)
```

The VM can barely walk although it *is* able to execute built-in procedures. There are two example procedures in `VM.rkt` that more or less show how it is going to be used in the future (the API *will* change though).
```
> (push! notify)                            ; built-in functiion
> (push! (list "Hello from Deepika~!"))     ; arguments
> (call-bi!)                                ; instruction
frotz: Hello from Deepika~!
```