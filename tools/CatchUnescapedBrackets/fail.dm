// Lone brackets, should NOT flag
var/test1 = "this is a lone [] brackets"
var/test2 = "[] at start"
var/test3 = "end []"

// in function calls
bluh("check [] here")
mrrp([]) // literal array usage, different context

// multi-line string
var/multi1 = "line one \
[] \
line three"

var/multi3 = {"
line one
[]
line three
[]"}
