//Updating pixelshift, position and direction
//Gets called on process, when the grab gets upgraded or the assailant moves
/mob/living/proc/adjust_position(mob/living/carbon/assailant)
	if(buckled || !assailant.canmove || assailant.lying) //So people don't get randomly teleported or something
		return
	var/easing = LINEAR_EASING
	var/time = 5
	if(lying && assailant.grab_state != GRAB_KILL)
		animate(src, pixel_x = 0, pixel_y = -4, time, 1, easing)
		layer = 3.9
		return

	var/shift = 0
	var/adir = get_dir(assailant, src)
	// if(loc = assailant.loc)
	// adir = assailant.dir //Fixes some weird animation issues
	layer = 4
	switch(assailant.grab_state)
		if(GRAB_PASSIVE)
			shift = 8
		if(GRAB_AGGRESSIVE)
			shift = 12
		if(GRAB_NECK)
			shift = -10
			adir = assailant.dir
			setDir(assailant.dir)
			loc = assailant.loc
		if(GRAB_KILL)
			shift = 0
			adir = 1
			setDir(SOUTH)//face up
			loc = assailant.loc
		else
			shift = 0

	var/Pixel_x = 0
	var/Pixel_y = 0
	if(adir & NORTH)
		Pixel_y = -shift
		layer = 3.9
	if(adir & SOUTH)
		Pixel_y = shift
	if(adir & WEST)
		Pixel_x = shift
	if(adir & EAST)
		Pixel_x =-shift

	animate(src, pixel_x = Pixel_x, pixel_y = Pixel_y, time, 1, easing)


/mob/living/Move(atom/newloc, direct)
	. = ..()
	if(pulling && isliving(pulling))
		var/mob/living/L = pulling
		L.adjust_position(src)

/mob/living/grippedby(mob/living/carbon/user)
	. = ..(user)
	adjust_position(user)

/mob/stop_pulling()
	if(pulling && isliving(pulling)) //run this first because pulling is set to null in stop_pulling
		var/mob/living/L = pulling
		var/px = 0
		var/py = 0
		if(!L.buckled)
			px = initial(L.pixel_x)
			py = L.get_standard_pixel_y_offset(L.lying) //used to be an animate, not quick enough for del'ing
		L.layer = initial(L.layer)
		animate(L, pixel_x = px, pixel_y = py, 5, 1, LINEAR_EASING)
	. = ..()

/mob/living/setDir(newDir)
	. = ..()
	if(pulling && isliving(pulling))
		var/mob/living/L = pulling
		L.adjust_position(src)
