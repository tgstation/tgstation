// Brackets with contents, should NOT flag
var/test4 = "this is [filled] brackets"
var/test5 = "[start] middle [end]"

// in function calls
bluh("check [stuff] here")
mrrp([1, 2, 3]) // literal array usage, different context

// multi-line string
var/multi2 = "line one \
[bluhguh] \
[iwokeup] \
line four"

var/multi3 = {"
line one
[bracketed_line]
line three
[attheend]"}
