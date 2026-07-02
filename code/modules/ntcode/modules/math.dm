/datum/ntcode/module/math
	module_name = "math"
	
/datum/ntcode/module/math/New()
	. = ..()
	
	add_constant("PI", 3.141592653)
	add_constant("E",  2.718281828459045360)
	
	add_constant("false", FALSE)
	add_constant("true",  TRUE)

	add_byond_proc("sqrt",  TYPE_PROC_REF(/datum/ntcode/module/math, math_sqrt),  list("number"))
	add_byond_proc("abs",   TYPE_PROC_REF(/datum/ntcode/module/math, math_abs),   list("number"))
	add_byond_proc("floor", TYPE_PROC_REF(/datum/ntcode/module/math, math_floor), list("number"))
	add_byond_proc("ceil",  TYPE_PROC_REF(/datum/ntcode/module/math, math_ceil),  list("number"))
	add_byond_proc("round", TYPE_PROC_REF(/datum/ntcode/module/math, math_round), list("number"))
	add_byond_proc("clamp", TYPE_PROC_REF(/datum/ntcode/module/math, math_clamp), list("number", "min", "max"))

/datum/ntcode/module/math/proc/math_sqrt(n)
	if(!isnum(n))
		return
	return sqrt(n)

/datum/ntcode/module/math/proc/math_abs(n)
	if(!isnum(n))
		return
	return abs(n)

/datum/ntcode/module/math/proc/math_floor(n)
	if(!isnum(n))
		return
	return floor(n)

/datum/ntcode/module/math/proc/math_ceil(n)
	if(!isnum(n))
		return
	return ceil(n)

/datum/ntcode/module/math/proc/math_round(n)
	if(!isnum(n))
		return
	return round(n)

/datum/ntcode/module/math/proc/math_clamp(n, min, max)
	if(!isnum(n) || !isnum(min) || !isnum(max))
		return
	return max(min(n, max), min)