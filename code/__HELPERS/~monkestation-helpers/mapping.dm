/proc/are_zs_connected(atom/a, atom/b)
	a = get_turf(a)
	b = get_turf(b)
	if(a.z == b.z)
		return TRUE
	return (b.z in SSmapping.get_connected_levels(a))
