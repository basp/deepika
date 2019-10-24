#lang scribble/manual
@(require (@for-label racket)
          "../parser.rkt"
          "../db.rkt"
          scribble/example
          racket/sandbox)

@(define my-evaluator
   (parameterize ([sandbox-output 'string]
                  [sandbox-error-output 'string]
                  [sandbox-memory-limit 50])
     (make-evaluator 'racket
        #:requires (list "db.rkt"))))

@title{deepika}
@author{basp}

@defmodule[deepika/parser]

@defproc[(parse/args [s string?]) (listof string?)]{
    Parses a string into arguments. This tokenizes the string on whitespace and
    treats quoted strings as one token.
}

@defmodule[deepika/db]

The database module is responsible for persisting the state of the world. In our
case, the world consists mainly of three things: objects, properties and verbs.

@defthing[objid objid?]{
    An object id is just a simple wrapper around an integer. 
    We need these to keep them apart from regular integer values.    
}

@defthing[$nothing nothing?]{
    Represents the absence of a value and can generally be used as a sensible
    default for database values.
}

@defproc[(nothing? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is @racket[$nothing].
}

@defproc[(objid? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is an object id and @racket[#f] otherwise.

    Note that the result of this function only confirms the data type. It does
    not confirm the existance of a valid object. Use @racket[valid?] for that
    case instead.
}

@defproc[(objid->number [oid objid?]) number?]{
    Converts object id @racket[oid] into an integer number.
}

@defproc[(number->objid [num integer?]) objid?]{
    Converts number @racket[num] into an object id.
}

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

@defproc[(create-object! [pid valid+?]) objid?]{
    Create a new object. If @racket[pid] is not specified then the object's 
    parent property will be set to @racket[$nothing].
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
    Returns the @racket[oid] of the parent of the object referenced by object
    @racket[oid].
}

@defproc[(set-parent! [oid valid?] [new-parent valid+?]) any]{
    Sets the parent of the object referenced by object id @racket[oid] to the 
    new parent specified by the @racket[new-parent] object id.
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
    Returns the object id of the location of the object specified by 
    @racket[oid].
}

@defproc[(set-location! [oid valid?] [new-location valid+?]) any]{
    Sets the location of the object referenced by object id @racket[oid] to the
    new location specifiedc by the @racket[new-location] object id.
}
