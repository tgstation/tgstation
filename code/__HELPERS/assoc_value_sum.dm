/proc/assoc_value_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]
