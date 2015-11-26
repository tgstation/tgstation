/obj/item/ammo_casing/proc/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, var/distro, var/quiet, zone_override = "")
	distro += variance
	for (var/i = max(1, pellets), i > 0, i--)
		// var/curloc = user.loc
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet, zone_override)
		// if(distro) //legacy bullet spread not supported. It never worked correctly anyway.
		// 	targloc = spread(targloc, curloc, distro)
		var/spread = 0
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
				// world << "[spread] spread!"
			else //Smart spread
				spread = round((i / pellets - 0.5) * distro)
				// world << "[spread] spread! [pellets] pellets! [i] i! [distro] variance!"
		if(!throw_proj(targloc, user, params, spread))
			return 0
		if(i > 1)
			newshot()
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	update_icon()
	return 1

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, var/quiet, zone_override = "")
	if (!BB)
		return
	BB.original = target
	BB.firer = user
	BB.def_zone = user.zone_sel.selecting
	BB.suppressed = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume) //For chemical darts/bullets
		qdel(reagents)
	return

/obj/item/ammo_casing/proc/throw_proj(var/turf/targloc, mob/living/user as mob|obj, params, spread)
	var/turf/curloc = user.loc
	if (!istype(targloc) || !istype(curloc) || !BB)
		return 0
	if(targloc == curloc)			//Fire the projectile
		user.bullet_act(BB)
		del(BB)
		return 1
	BB.preparePixelProjectile(targloc, user, params, spread)
	if(BB)
		BB.fire()
	BB = null
	return 1

/obj/item/ammo_casing/proc/spread(var/turf/target, var/turf/current, var/distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

//This exists to simplify pixel calculations for mechas and other things.
/obj/item/projectile/proc/preparePixelProjectile(var/turf/targloc, mob/living/user as mob|obj, params, spread)
	var/turf/curloc = user.loc
	src.loc = get_turf(user)
	src.starting = get_turf(user)
	src.current = curloc
	src.yo = targloc.y - curloc.y
	src.xo = targloc.x - curloc.x

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			src.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			src.p_y = text2num(mouse_control["icon-y"])
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

			//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
			var/screenview = (user.client.view * 2 + 1) * world.icon_size //Refer to http://www.byond.com/docs/ref/info.html#/client/var/view for mad maths

			var/ox = round(screenview/2) //"origin" x
			var/oy = round(screenview/2) //"origin" y
			// world << "Pixel position: [x] [y]"
			var/angle = Atan2(y - oy, x - ox)
			// world << "Angle: [angle]"
			src.Angle = angle
	if(spread)
		src.Angle += spread