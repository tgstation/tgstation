	//////////////
GLOBAL_VAR_INIT(NEARSIGHTBLOCK, 0)
GLOBAL_VAR_INIT(EPILEPSYBLOCK, 0)
GLOBAL_VAR_INIT(COUGHBLOCK, 0)
GLOBAL_VAR_INIT(TOURETTESBLOCK, 0)
GLOBAL_VAR_INIT(NERVOUSBLOCK, 0)
GLOBAL_VAR_INIT(BLINDBLOCK, 0)
GLOBAL_VAR_INIT(DEAFBLOCK, 0)
GLOBAL_VAR_INIT(HULKBLOCK, 0)
GLOBAL_VAR_INIT(TELEBLOCK, 0)
GLOBAL_VAR_INIT(FIREBLOCK, 0)
GLOBAL_VAR_INIT(XRAYBLOCK, 0)
GLOBAL_VAR_INIT(CLUMSYBLOCK, 0)
GLOBAL_VAR_INIT(STRANGEBLOCK, 0)
GLOBAL_VAR_INIT(RACEBLOCK, 0)

GLOBAL_LIST(bad_se_blocks)
GLOBAL_LIST(good_se_blocks)
GLOBAL_LIST(op_se_blocks)

GLOBAL_VAR(NULLED_SE)
GLOBAL_VAR(NULLED_UI)

GLOBAL_LIST_EMPTY(all_mutations) // list of hidden mutation things
GLOBAL_LIST_EMPTY(all_mutations_types) // same list but [type] = object instead of [name = object]. Ideally they should all be reworked to this, but it'd would fuck up so many dependencies

GLOBAL_LIST_EMPTY(bad_mutations)
GLOBAL_LIST_EMPTY(good_mutations)
GLOBAL_LIST_EMPTY(not_good_mutations)