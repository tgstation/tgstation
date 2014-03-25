/obj/item/ammo_casing/proc/fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, params, var/distro, var/quiet)
	distro += variance
	for (var/i = max(1, pellets), i > 0, i--)
		var/curloc = user.loc
		var/targloc = get_turf(target)
		ready_proj(target, user, quiet)
		if(distro)
			targloc = spread(targloc, curloc, distro)
		if(!throw_proj(targloc, user, params))
			return 0
		if(i > 1)
			newshot()
	user.changeNext_move(4)
	update_icon()
	return 1

/obj/item/ammo_casing/proc/ready_proj(atom/target as mob|obj|turf, mob/living/user, var/quiet)
	if (!BB)
		return
	BB.original = target
	BB.firer = user
	BB.def_zone = user.zone_sel.selecting
	BB.silenced = quiet

	if(reagents && BB.reagents)
		reagents.trans_to(BB, reagents.total_volume) //For chemical darts/bullets
		reagents.delete()
	return

/obj/item/ammo_casing/proc/throw_proj(var/turf/targloc, mob/living/user as mob|obj, params)
	var/turf/curloc = user.loc
	if (!istype(targloc) || !istype(curloc) || !BB)
		return 0
	if(targloc == curloc)			//Fire the projectile
		user.bullet_act(BB)
		qdel(BB)
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

	if(BB)
		BB.process()
	BB = null
	return 1

/obj/item/ammo_casing/proc/spread(var/turf/target, var/turf/current, var/distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)

//	gaussian(0, distro)