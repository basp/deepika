# deepika
Wannabe spiritual successor to LambdaMOO.

# overview
**Deepika** is a **LambdaMOO** clone that is designed mostly for educational purposes. It is designed to be run in a **Racket** environment but all of the concepts can be translated to your programming language of choice.

# rationale
**Deepika** goes a bit deeper than most toy VM implementations. Since it is modelled on **LambdaMOO** we have a very dynamic environment that includes objects and tasks that can be forked and suspended. Additionally, we can set quota on execution time and *ticks* of these tasks in order to prevent rogue programs from monopolizing the server. On top of that, any decent MOO has a TCP interface in order for remote clients to actually interact with the server. A **MOO** basically has all of the above so it's an excellent venue to explore a language, its libraries and its ecosystem.
