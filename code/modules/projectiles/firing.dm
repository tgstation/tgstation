/obj/item/ammo_casing/proc/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, distro, quiet)
	distro += variance
	for (var/i = max(1, pellets), i > 0, i--)
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet)
		var/spread = 0
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = (rand() - 0.5) * distro
			else //Smart spread
				spread = (i / pellets - 0.5) * distro
		if(!throw_proj(targloc, user, params, spread))
			return 0
		if(i > 1)
			newshot()
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return 1

/obj/item/ammo_casing/proc/ready_proj(atom/target as mob|obj|turf, mob/living/user, quiet)
	if (!BB)
		return
	BB.original = target
	BB.firer = user
	BB.def_zone = user.zone_sel.selecting
	BB.suppressed = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(var/turf/targloc, mob/living/user as mob|obj, params, spread)
	var/turf/curloc = user.loc
	if (!istype(targloc) || !istype(curloc) || !BB)
		return 0
	if(targloc == curloc)			//Fire the projectile
		user.bullet_act(BB)
		del(BB)
		return 1
	BB.loc = get_turf(user)
	BB.starting = get_turf(user)
	BB.current = curloc
	BB.yo = targloc.y - curloc.y
	BB.xo = targloc.x - curloc.x

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			BB.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			BB.p_y = text2num(mouse_control["icon-y"])
		if(mouse_control["screen-loc"])
			//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
			var/list/screen_loc_params = text2list(mouse_control["screen-loc"], ",")

			//Split X+Pixel_X up into list(X, Pixel_X)
			var/list/screen_loc_X = text2list(screen_loc_params[1],":")

			//Split Y+Pixel_Y up into list(Y, Pixel_Y)
			var/list/screen_loc_Y = text2list(screen_loc_params[2],":")
			// world << "X: [screen_loc_X[1]] PixelX: [screen_loc_X[2]] / Y: [screen_loc_Y[1]] PixelY: [screen_loc_Y[2]]"
			var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
			var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32
			var/ox = round(480/2) //"origin" x - Basically center of the screen. This is a bad way of doing it because if you are able to view MORE than 15 tiles at a time your aim will get fucked.
			var/oy = round(480/2) //"origin" y - Basically center of the screen.
			// world << "Pixel position: [x] [y]"
			var/angle = Atan2(y - oy, x - ox)
			// world << "Angle: [angle]"
			BB.Angle = angle
	if(spread)
		BB.Angle += spread
	if(BB)
		BB.fire()
	BB = null
	return 1

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

//	gaussian(0, distro)