#lang scribble/manual
@require[@for-label[deepika
                    racket/base
                    ; racket/set
                    ; racket/class
                    ; racket/unit
                    ; racket/contract
                    racket/match]]

@title{deepika}
@author{Bas Pennings}

@defmodule[deepika]

The @racketmodname[deepika] library is a MOO (MUD object-oriented) that is
heavily inspired by LambdaMOO.

@section{Overview}

The server follows the spirit of LambdaMOO and a lof the concepts that apply
there apply here as well. The server is a unit that is composed from a few
other core units.