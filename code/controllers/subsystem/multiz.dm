SUBSYSTEM_DEF(z_levels)
	name = "Z Levels"
	flags = SS_NO_FIRE
	init_order = 12 //before SSatoms
	var/list/vertical_connections //assoc list of "[Z number]" = list("[Other Z Number]" = TRUE/FALSE)
	var/list/zshadows


/datum/controller/subsystem/z_levels/stat_entry()
	var/c = 0
	for(var/z in vertical_connections)
		var/list/L = vertical_connections[z]
		if(L)
			c += L.len //this will count A<->B twice, since it's A->B and B->A
	..("ZP:[c], ZS:[LAZYLEN(zshadows)]") //"Z Pairs", "Z Shadows"