#lang scribble/manual
@(require (@for-label)
            "../parser.rkt"
            "../db.rkt"
            "../tasks.rkt"
            racket
            racket/sandbox
            scribble/example)

@(define my-evaluator
   (parameterize ([sandbox-output 'string]
                  [sandbox-error-output 'string]
                  [sandbox-memory-limit 50])
     (make-evaluator 'racket
        #:requires (list "db.rkt" "tasks.rkt"))))

@title{Deepika}
@author{basp}

Deepika is a MOO in the spirit of LambdaMOO.

@table-of-contents[]

@section{Database}
@defmodule[deepika/db]

The database module is responsible for persisting the state of the world. In our
case, the world consists mainly of three things: objects, properties and verbs.

@defthing[$nothing nothing?]{
    Represents the absence of a value and can generally be used as a sensible
    default for database values.
}

@defproc[(nothing? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is @racket[$nothing].
}

@defthing[objid objid?]{
    An object id is just a simple wrapper around an integer. 
    We need these to keep them apart from regular integer values.    
}

@defproc[(objid? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is an object id and @racket[#f] otherwise.

    Note that the result of this function only confirms the data type. It does
    not confirm the existance of a valid object. Use @racket[valid?] for that
    case instead.
}

@defproc[(objid->number [oid objid?]) number?]{
    Converts an object id @racket[oid] into an number.
}

@defproc[(number->objid [num integer?]) objid?]{
    Converts a number @racket[num] into an object id.
}

@examples[
    #:eval my-evaluator
    (objid->number (objid 123))
    (number->objid 123)
    (objid->number (number->objid 123))
]

Note that @racket[number->objid] can be used to create object id's that are 
not @racket[valid?] nor @racket[valid+?].

@examples[
    #:eval my-evaluator
    (objid->number $nothing)
    (valid? (number->objid -1))
    (valid+? (number->objid -123))
]

@defproc[(valid? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is an object id that points to an actual 
    object and @racket[#f] otherwise.
}

@examples[
    #:eval my-evaluator
    (define oid (number->objid 1))
    (valid? oid)
    (create-object!)
    (valid? (number->objid 1))]

@defproc[(valid+? [x any/c]) boolean?]{
    Like @racket[valid?] but it will also return @racket[#t] if @racket[x] is
    @racket[$nothing].
}

@examples[
    #:eval my-evaluator
    (valid? $nothing)
    (define oid (create-object!))
    (valid? oid)
    (valid? (objid 123))]

@defproc[(create-object! [oid valid+? $nothing]) objid?]{
    Create a new object with its parent set to @racket[oid]. If @racket[oid] is 
    not specified then the object's parent property will be set to 
    @racket[$nothing].
}

@defproc[(destroy-object! [oid valid?]) any/c]{
    Destroy the object with id @racket[oid]. It will no longer be accessible
    from the database.
}

@defproc[(get-object-name [oid valid?]) string?]{
    Returns the name of the object with id @racket[oid].
}

@defproc[(set-object-name! [oid valid?] [value string?]) any]{
    Sets the name of the object referenced by @racket[oid] to @racket[value].
}

@defproc[(get-parent [oid valid?]) valid+?]{
    Returns the parent id of the object with id @racket[oid].
}

@defproc[(set-parent! [oid valid?] [new-parent valid+?]) any]{
    Sets the parent of object with id @racket[oid] to the value of
    @racket[new-parent].
}

@defproc[(get-children [oid valid?]) (listof valid?)]{
    Returns the objects that have @racket[oid] set as their parent object.
}

@examples[
    #:eval my-evaluator
    (define o (create-object!))
    (define p (create-object!))
    (get-parent o)
    (set-parent! o p)
    (get-parent o)
    (get-children (get-parent o))]

@defproc[(get-location [oid valid?]) valid+?]{
    Returns the location id of the object specified by @racket[oid].
}

@defproc[(set-location! [oid valid?] [new-location valid+?]) any]{
    Sets the location of object with id @racket[oid] to the value of
    @racket[new-location].
}

@section{Tasks}
@defmodule[deepika/tasks]

Note that the tasks module does not actually execute any tasks. Instead, it is
merely a storage device and as such, actual execution of the tasks that are
queued and ready to run is solely up to the client of this module.

@defproc[(task-start! [del integer?] [proc procedure?]) integer?]{
    Queues @racket[proc] as a new task to start after @racket[del] seconds have
    elapsed. The result of this function is the id of the queued task.
}

@defproc[(task-ready? [id integer?]) boolean?]{
    Returns @racket[#t] if the task specified by @racket[id] is ready to run.
}

@examples[
    #:eval my-evaluator
    (define tid (task-start! 5 (λ () (displayln "Go!"))))
    (task-ready? tid)
    (sleep 5)
    (task-ready? tid)]

@defproc[(task-remove! [id integer?]) any]{
    Irrevocably removes the task specified by @racket[id] from the queue. It 
    will not be executed.
}

@defproc[(tasks) (listof integer?)]{
    Returns a list of ids of all tasks currently on the queue.
}

@defproc[(tasks/ready) (listof integer?)]{
    Like @racket[tasks] but returns only those tasks that are ready to run.
}

@section{Parser}
@defmodule[deepika/parser]

@defproc[(parse/args [s string?]) (listof string?)]{
    Parses a string into arguments. This tokenizes the string on whitespace and
    treats quoted strings as one token.
}

@racketblock[
    (equal? (parse/args "foo \"bar quux\" frotz")
            (list "foo" "bar quux" "frotz"))
]