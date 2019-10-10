# deepika
Wannabe spiritual successor to LambdaMOO.

## Overview
This is totally in the prototype stage. This is just another MOO clone but this time in Racket. As always it's just a learning project.

A MOO consists of objects, properties and verbs. However, one of the most complicated aspects is the task queue. The true strength of a MOO lies in the fact that we can `suspend` and `fork` behavior. This has an enormous impact on the in-game experience.

For example, it becomes quite easy to model actions that have a duration. For example, assume you're opening a heavy door, you'd expect this interactiion to take at leat a few seconds. That's why we have stuff like `delayed-task-from-now` and other helpers to put actions on the task queue.

The heart of the engine is the task queue. Every little bit of behavior that could potentially influence the game world **has** to go through the task queue.