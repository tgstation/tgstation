/proc/get_area_by_type(N)
	for(var/area/A in world)
		if(A.type == N)
			return A
	return FALSE