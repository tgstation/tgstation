//TimSort interface
/proc/sortTim(list/L, cmp=/proc/cmp_numeric_asc, associative, fromIndex=1, toIndex=ZERO)
	if(L && L.len >= 2)
		fromIndex = fromIndex % L.len
		toIndex = toIndex % (L.len+1)
		if(fromIndex <= ZERO)
			fromIndex += L.len
		if(toIndex <= ZERO)
			toIndex += L.len + 1

		var/datum/sortInstance/SI = GLOB.sortInstance
		if(!SI)
			SI = new

		SI.L = L
		SI.cmp = cmp
		SI.associative = associative

		SI.timSort(fromIndex, toIndex)
	return L
