#lang scribble/manual
@(require (@for-label)
            "../cmd-parser.rkt"
            "../db.rkt"
            "../tasks.rkt"
            "../match.rkt"
            racket
            racket/sandbox
            scribble/example)

@(define my-evaluator
   (parameterize ([sandbox-output 'string]
                  [sandbox-error-output 'string]
                  [sandbox-memory-limit 50])
     (make-evaluator 'racket
        #:requires (list "db.rkt" 
                         "tasks.rkt"
                         "cmd-parser.rkt"
                         "match.rkt"))))

@title{Deepika}
@author{basp}

Deepika is a MOO in the spirit of 
@hyperlink["https://en.wikipedia.org/wiki/LambdaMOO"]{LambdaMOO}. MOO stands 
for MUD object oriented. MUD stands for multi-user domain. It is the predecessor 
to what we nowadays call an MMO. A MOO is a multi-user domain object oriented 
environment.

The current state of the project can be found at 
@hyperlink["https://github.com/basp/deepika"]{github.com/basp/deepika}.

@table-of-contents[]
@section{Overview}

@subsection{Interface}
Using the original LambdaMOO as a reference, we can typically divide a MOO into
a few key components. At the very core is a TCP server that is not unlike a
typical chat server. It reads lines of text and it sends lines of text.
Unlike a chat server, a MOO server has a world state which is represented as 
a database of objects. Clients (i.e. players) are part of this state and 
represented by objects as well.

And even though nowadays most chat servers will do some amount of parsing or
basic text replacement, a MOO has a command parser with a simple but 
surprisingly powerful syntax and evaluation behavior. In short, it will accept
natural language (English) commands and match them to executable
code (called verbs) in the object database.

When you consider that this player invoked code can create objects, destroy or
relocate them, add properties or verbs (executable code) and manipulate their
values, it is apparent that this leads to a very dynamic environment.

@subsection{Implementation}
Conceptually, there is only a single thread that is taking care of the 
resources. This includes the database, the task queue and the connections. Since
a MOO is generally slow-paced compared to modern games we are operating in the
realm of seconds instead of milliseconds which gives us a lot of spare time 
to perform computations in between each @italic{frame}.

This thread, known as the @italic{game loop} ticks about 60 times each second
by default if the hardware is capable. This corresponds to a 
@italic{frame rate}, or @italic{tick rate} rather, of 60Hz. The 
@italic{tick rate} setting can be configured on server startup. In general, 
a @italic{tick rate} of 15Hz is pretty fast for a MOO.

@section{Reference}

This section is an overview of the public interface provided by the modules
that make up @racket[deepika].

@subsection{Database}
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

@subsubsection{Objects}
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

@examples[
    #:eval my-evaluator
    (define container (create-object!))
    container
    (define thing1 (create-object!))
    (define thing2 (create-object!))
    (set-location! thing1 container)
    (set-location! thing2 container)
    (get-contents container)
    (get-location thing1)
    (get-location thing2)
]

@subsubsection{Properties}
TODO

@subsubsection{Verbs}
TODO

@subsection{Tasks}
@defmodule[deepika/tasks]

Note that the tasks module does not actually execute any tasks. Instead, it is
merely a storage device and as such, actual execution of the tasks that are
queued and ready to run is solely up to the client of this module.

@defproc[(task? [x any/c]) boolean?]{
    Returns @racket[#t] if @racket[x] is a task structure.
}

@defproc[(task-id [x task?]) integer?]{
    Returns the id of the task given by @racket[x].
}

@defproc[(task-th [x task?]) procedure?]{
    Returns the @italic{thunk} of the task given by @racket[x].
}

@defproc[(task/valid? [id integer?]) boolean?]{
    Like @racket[valid?] but for tasks instead. It will return @racket[#t] if
    there is a task with specified @racket[id].
}

@defproc[(task-start! [del integer?] [th procedure?]) task/valid?]{
    Queues @racket[thunk] as a new task to start after @racket[del] seconds 
    have elapsed. The result of this function is the id of the queued task.
}

@defproc[(task-ready? [id task/valid?]) boolean?]{
    Returns @racket[#t] if the task specified by @racket[id] is ready to run.
}

@examples[
    #:eval my-evaluator
    (define tid (task-start! 5 (λ () (displayln "Go!"))))
    tid
    (task-ready? tid)
    (sleep 5)
    (task-ready? tid)]

@defproc[(task-remove! [id task/valid?]) any]{
    Irrevocably removes the task specified by @racket[id] from the queue. It 
    will not be executed.
}

@defproc[(get-task [id task/valid?]) task?]{
    Returns the task data associated with task @racket[id]. The result can be
    queried with @racket[task-id] and @racket[task-proc].
}

@defproc[(tasks) (listof task/valid?)]{
    Returns a list of ids of all tasks currently on the queue.
}

@examples[
    #:eval my-evaluator
    (define tid (task-start! 30 (λ () (displayln "Uhmmm..."))))
    tid
    (task/valid? tid)
    (tasks)
    (task-remove! tid)
    (task/valid? tid)
    (tasks)    
]

Note that the queue will never remove tasks unless it is explicitly asked to do 
so. That's why the latent task of the previous example shows up in this example
as well.

@defproc[(tasks/ready) (listof task/valid?)]{
    Like @racket[tasks] but returns only those tasks that are ready to run 
    (i.e. when @racket[task-ready?] returns @racket[#t]).
}

@subsection{Command Parser}
@defmodule[deepika/cmd-parser]

@defproc[(string->args [s string?]) (listof string?)]{
    Tokenizes the string on whitespace and treats quoted strings as one token.
}

@examples[
    #:eval my-evaluator
    (define argstr "foo \"bar mumble\" baz\" \"fr\"otz\" bl\"o\"rt")
    (string->args argstr)
]

@subsection{Match}
@defmodule[deepika/match]

@defproc[(match-verb-spec [s string?] [spec string?]) boolean?]{
    Returns @racket[#t] if @racket[s] matches given @racket[spec].
}

Verbs do not have definite names and the database supports duplicate names as 
well. There are valid use cases for this since verb lookup does not only allow
for multiple names but multiple variants of @italic{verb args} as well. In
effect this allows two verbs to share names but operate in different contexts.

A @italic{verb-spec} is a name specification for a verb. It consists of a
string that optionally includes an @racket[#\*] character. The position of the
asterisk specifies the minimum match length @italic{n} of the verb spec.

Every verb has one or more @italic{verb descriptions}. All of these are kept in 
a single string, separated by spaces. In the simplest case, a 
@italic{verb-desc} is just a word made up of any characters other than spaces 
and stars (i.e., @racket[#\space] and @racket[#\*]). In this case, the 
@italic{verb-desc} matches only itself; that is, the name must be matched 
exactly.

If the name contains a single star, however, then the name matches any prefix 
of itself that is at least as long as the part before the star. For example, 
the @italic{verb-desc} @racket["foo*bar"] matches any of the strings 
@racket["foo"], @racket["foob"], @racket["fooba"], or @racket["foobar"]. Note 
that the star itself is not considered part of the name. If the 
@italic{verb-desc} ends in a star, then it matches any string that begins with 
the part before the star. For example, the verb-name @racket["foo*"] matches 
any of the strings @racket["foo"], @racket["foobar"], @racket["food"], or 
@racket["foogleman"], among many others. As a special case, if the 
@italic{verb-desc} is @racket["*"] (i.e., a single star all by itself), then it 
matches anything at all.

@examples[
    #:eval my-evaluator
    (match-verb-spec "foo" "foo*bar")
    (match-verb-spec "foobar" "foo*bar")
    (match-verb-spec "fo" "foo*bar")
    (match-verb-spec "foobarx" "foo*bar")
    (match-verb-spec "foo" "foo*")
    (match-verb-spec "foobar" "foo*")
    (match-verb-spec "food" "foo*")
    (match-verb-spec "foogleman" "foo*")
    (match-verb-spec "literally anything" "*")]
