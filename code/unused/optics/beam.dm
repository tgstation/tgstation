// the laser beam


/obj/effect/beam/laser
	name = "laser beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "full"
	density = 0
	mouse_opacity = 0
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	flags = TABLEPASS
	var/wavelength 		// the (vaccuum) wavelength of the beam
	var/width = 1		// 1=thin, 2=medium, 3=wide

	var/obj/effect/beam/laser/next
	var/obj/effect/beam/laser/prev
	var/obj/master

	New(var/atom/newloc, var/dirn, var/lambda, var/omega=1, var/half=0)

		if(!isturf(loc))
			return

		//world << "creating beam at ([newloc.x],[newloc.y]) with [dirn] [lambda] [omega] [half]"

		icon_state = "[omega]-[half ? "half" : "full"]"
		dir = dirn
		set_wavelength(lambda)
		..(newloc)
		spawn(0)
			src.propagate()
		src.verbs -= /atom/movable/verb/pull



	proc/propagate()
		var/turf/T = get_step(src, dir)
		if(T)
			if(T.Enter(src))
				next = new(T, dir, wavelength, width, 0)
				next.prev = src
				next.master = src.master
			else
				spawn(5)
					propagate()


	proc/remove()
		if(next)
			next.remove()
		del(src)



	proc/blocked(var/atom/A)
		return density || opacity
/*
/turf/Enter(atom/movable/mover as mob|obj)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!
*/


	HasEntered(var/atom/movable/AM)
		if(istype(AM, /obj/effect/beam))
			return
		if(blocked(AM))
			remove(src)
			if(prev)
				prev.propagate()
			else if(master)
				master:turn_on()

	proc/set_wavelength(var/lambda)

		var/w = round(lambda,1)	// integer wavelength
		wavelength = lambda
		// first look for cached version of the icon at this wavelength
		var/icon/cached = beam_icons["[w]"]
		if(cached)
			icon = cached

			return

		// no cached version, so generate a new one

		// this maps a wavelength in the range 380-780 nm to an R,G,B,A value
		var/red = 0
		var/green = 0
		var/blue = 0
		var/alpha = 0

		switch(w)
			if(380 to 439)
				red = (440-w) / 60
				green = 0
				blue = 1
			if(440 to 489)
				red = 0
				green  = (w-440) / 50
				blue = 1
			if(490 to 509)
				red  = 0
				green = 1
				blue = (510 - w) / 20
			if(510 to 579)
				red = (w-510) / 70
				green = 1
				blue = 0
			if(580 to 644)
				red = 1
				green = (645-w) / 65
				blue = 0
			if(645 to 780)
				red = 1
				green = 0
				blue = 0

		// colour is done, now calculate intensity
		switch(w)
			if(380 to 419)
				alpha = 0.75*(w-380)/40
			if(420 to 700)
				alpha = 0.75
			if(701 to 780)
				alpha = 0.75*(780-w)/80

		// remap alpha by intensity gamma
		if(alpha != 0)
			alpha = alpha**0.80

		var/icon/I = icon('icons/effects/beam.dmi')
		I.MapColors(red,0,0,0, 0,green,0,0, 0,0,blue,0, 0,0,0,alpha, 0,0,0,0)
		icon = I

		beam_icons["[w]"] = I



// global cache of beam icons
// this is an assoc list mapping (integer) wavelength to icons

var/list/beam_icons = new()