//Dead mobs can exist whenever. This is needful
/mob/dead/New(loc)
	..()
	if(!initialized)
		args[1] = FALSE
		Initialize(arglist(args))	//EXIST DAMN YOU!!!

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return
