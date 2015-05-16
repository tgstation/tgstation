// OKAY I DON'T KNOW WHO THE FUCK ORIGINALLY CODED THIS BUT THEY ARE OFFICIALLY FIRED FOR BEING DRUNK AND STUPID
// FUCK YOU MYSTERY CODERS
// FOR THIS SHIT I'M GOING TO MAKE ALL MY COMMENTS IN CAPS

/atom
	var/list/canSmoothWith=list() // TYPE PATHS I CAN SMOOTH WITH~~~~~

// MOVED INTO UTILITY FUNCTION FOR LESS DUPLICATED CODE.
/atom/proc/findSmoothingNeighbors()
	// THIS IS A BITMAP BECAUSE NORTH/SOUTH/ETC ARE ALL BITFLAGS BECAUSE BYOND IS DUMB AND
	// DOESN'T FUCKING MAKE SENSE, BUT IT WORKS TO OUR ADVANTAGE
	var/junction = 0
	for(var/cdir in cardinal)
		var/turf/T = get_step(src,cdir)
		if(isSmoothableNeighbor(T))
			junction |= cdir
			continue // NO NEED FOR FURTHER SEARCHING IN THIS TILE
		for(var/atom/A in T)
			if(isSmoothableNeighbor(A))
				junction |= cdir
				break // NO NEED FOR FURTHER SEARCHING IN THIS TILE

	return junction

/atom/proc/isSmoothableNeighbor(var/atom/A)
	return is_type_in_list(A,canSmoothWith)

/turf/simulated/wall/isSmoothableNeighbor(var/atom/A)
	if(is_type_in_list(A,canSmoothWith))
		// COLON OPERATORS ARE TERRIBLE BUT I HAVE NO CHOICE
		if(src.mineral == A:mineral) //mineral not walltype so reinf still smooths with normal and vice versa
			return 1
	return 0

/**
 * WALL SMOOTHING SHIT
 *
 * IN /ATOM BECAUSE /TURFS ARE /ATOMS AND SO ARE /OBJ/STRUCTURE/FALSEWALLS
 * THIS IS STUPID BUT IS FAIRLY ELEGANT FOR BYOND
 *
 * HOWEVER, INSTEAD OF MAKING ONE BIG GODDAMN MONOLITHIC PROC LIKE A FUCKING
 * SHITTY FUNCTIONAL PROGRAMMER, WE WILL BE COOL AND MODERN AND USE INHERITANCE.
 */
/atom/proc/relativewall()
	return // DOES JACK SHIT BY DEFAULT. OLD BEHAVIOR WAS TO SPAM LOOPS ANYWAY.

/*
 * SEE?  NOW WE ONLY HAVE TO PROGRAM THIS SHIT INTO WHAT WE WANT TO SMOOTH
 * INSTEAD OF BEING DUMB AND HAVING A BIG FUCKING IFTREE WITH TYPECHECKS
 * MY GOD, WE COULD EVEN MOVE THE CODE TO BE WITH THE REST OF THE WALL'S CODE!
 * HOW FUCKING INNOVATIVE.  ISN'T INHERITANCE NICE?
 *
 * WE COULD STANDARDIZE THIS BUT EVERYONE'S A FUCKING SNOWFLAKE
 */
/turf/simulated/wall/relativewall()
	var/junction=findSmoothingNeighbors()
	icon_state = "[walltype][junction]" // WHY ISN'T THIS IN UPDATE_ICON OR SIMILAR

// AND NOW WE HAVE TO YELL AT THE NEIGHBORS FOR BEING LOUD AND NOT PAINTING WITH HOA-APPROVED COLORS
/atom/proc/relativewall_neighbours()
	// OPTIMIZE BY NOT CHECKING FOR NEIGHBORS IF WE DON'T FUCKING SMOOTH
	if(canSmoothWith.len>0)
		relativewall()
		for(var/cdir in cardinal)
			var/turf/T = get_step(src,cdir)
			if(isSmoothableNeighbor(T))
				T.relativewall()
			for(var/atom/A in T)
				if(isSmoothableNeighbor(A))
					A.relativewall()

/turf/simulated/wall/New()
	..()
	relativewall_neighbours()

/turf/simulated/wall/Destroy()

	var/temploc = src.loc

	if(!del_suppress_resmoothing)
		spawn(10)
			relativewall_neighbours(at=temploc)

	// JESUS WHY
	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	..()

// DE-HACK
/turf/simulated/wall/vault/relativewall()
	return


/obj/structure/alien/resin/relativewall()
	var/junction = findSmoothingNeighbors()
	icon_state = "[resintype][junction]"
	return
