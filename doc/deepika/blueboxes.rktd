1435
((3) 0 () 2 ((q lib "deepika/tasks.rkt") (q lib "deepika/db.rkt")) () (h ! (equal) ((c def c (c (? . 0) q get-task)) q (1495 . 3)) ((c def c (c (? . 0) q task-id)) q (1106 . 3)) ((c def c (c (? . 1) q valid+?)) q (313 . 3)) ((c def c (c (? . 1) q objid?)) q (82 . 3)) ((c def c (c (? . 1) q get-object-name)) q (508 . 3)) ((c def c (c (? . 0) q task/valid?)) q (1214 . 3)) ((c def c (c (? . 0) q task-remove!)) q (1434 . 3)) ((c def c (c (? . 1) q get-parent)) q (664 . 3)) ((c def c (c (? . 1) q create-object!)) q (366 . 3)) ((c def c (c (? . 1) q get-children)) q (820 . 3)) ((c def c (c (? . 1) q get-location)) q (891 . 3)) ((q def ((lib "deepika/parser.rkt") parse/args)) q (1650 . 3)) ((c def c (c (? . 0) q task-th)) q (1159 . 3)) ((c def c (c (? . 0) q task?)) q (1055 . 3)) ((c def c (c (? . 0) q tasks)) q (1554 . 2)) ((c def c (c (? . 1) q objid->number)) q (134 . 3)) ((c def c (c (? . 1) q set-object-name!)) q (573 . 4)) ((c def c (c (? . 0) q tasks/ready)) q (1599 . 2)) ((c def c (c (? . 0) q task-start!)) q (1276 . 4)) ((c def c (c (? . 1) q set-parent!)) q (724 . 4)) ((c def c (c (? . 1) q set-location!)) q (953 . 4)) ((c def c (c (? . 1) q valid?)) q (261 . 3)) ((c def c (c (? . 0) q task-ready?)) q (1369 . 3)) ((c def c (c (? . 1) q nothing?)) q (28 . 3)) ((c def c (c (? . 1) q number->objid)) q (197 . 3)) ((c def c (c (? . 1) q destroy-object!)) q (445 . 3)) ((c def c (c (? . 1) q $nothing)) q (0 . 2))))
value
$nothing : nothing?
procedure
(nothing? x) -> boolean?
  x : any/c
procedure
(objid? x) -> boolean?
  x : any/c
procedure
(objid->number oid) -> number?
  oid : objid?
procedure
(number->objid num) -> objid?
  num : integer?
procedure
(valid? x) -> boolean?
  x : any/c
procedure
(valid+? x) -> boolean?
  x : any/c
procedure
(create-object! [oid]) -> objid?
  oid : valid+? = $nothing
procedure
(destroy-object! oid) -> any/c
  oid : valid?
procedure
(get-object-name oid) -> string?
  oid : valid?
procedure
(set-object-name! oid value) -> any
  oid : valid?
  value : string?
procedure
(get-parent oid) -> valid+?
  oid : valid?
procedure
(set-parent! oid new-parent) -> any
  oid : valid?
  new-parent : valid+?
procedure
(get-children oid) -> (listof valid?)
  oid : valid?
procedure
(get-location oid) -> valid+?
  oid : valid?
procedure
(set-location! oid new-location) -> any
  oid : valid?
  new-location : valid+?
procedure
(task? x) -> boolean?
  x : any/c
procedure
(task-id x) -> integer?
  x : task?
procedure
(task-th x) -> procedure?
  x : task?
procedure
(task/valid? id) -> boolean?
  id : integer?
procedure
(task-start! del th) -> task/valid?
  del : integer?
  th : procedure?
procedure
(task-ready? id) -> boolean?
  id : task/valid?
procedure
(task-remove! id) -> any
  id : task/valid?
procedure
(get-task id) -> task?
  id : task/valid?
procedure
(tasks) -> (listof task/valid?)
procedure
(tasks/ready) -> (listof task/valid?)
procedure
(parse/args s) -> (listof string?)
  s : string?
