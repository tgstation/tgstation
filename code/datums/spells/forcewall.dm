/obj/spell/forcewall
	name = "Forcewall"
	desc = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	range = 0 //default creates only a 1x1 forcewall in the user's tile
	var/wall_lifespan = 300 //in deciseconds
	var/wall_visibility = 1 //if 0, the created wall(s) is(are) invisible

/obj/spell/forcewall/Click()
	..()

	if(!cast_check())
		return

	invocation()

	var/list/forcefields = list()

	for(var/turf/T in range(usr,range))
		forcefields += new /obj/forcefield(T)

	spawn (wall_lifespan)
		for(var/obj/forcefield/F in forcefields)
			del(F)
		del(forcefields)

	return