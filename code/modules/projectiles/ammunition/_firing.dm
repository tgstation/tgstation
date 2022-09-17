/obj/item/ammo_casing/proc/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	distro += variance
	var/targloc = get_turf(target)
	ready_proj(target, user, quiet, zone_override, fired_from)
	if(pellets == 1)
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
			else //Smart spread
				spread = round(1 - 0.5) * distro
		if(!throw_proj(target, targloc, user, params, spread, fired_from))
			return FALSE
	else
		if(isnull(loaded_projectile))
			return FALSE
		AddComponent(/datum/component/pellet_cloud, projectile_type, pellets)
		SEND_SIGNAL(src, COMSIG_PELLET_CLOUD_INIT, target, user, fired_from, randomspread, spread, zone_override, params, distro)

	var/next_delay = click_cooldown_override || CLICK_CD_RANGE
	if(HAS_TRAIT(user, TRAIT_DOUBLE_TAP))
		next_delay = round(next_delay * 0.5)

	user.changeNext_move(next_delay)
	if(!tk_firing(user, fired_from))
		user.newtonian_move(get_dir(target, user))
	else if(ismovable(fired_from))
		var/atom/movable/firer = fired_from
		if(!firer.newtonian_move(get_dir(target, fired_from), instant = TRUE))
			var/throwtarget = get_step(fired_from, get_dir(target, fired_from))
			firer.safe_throw_at(throwtarget, 1, 2)
	update_appearance()
	return TRUE

/obj/item/ammo_casing/proc/tk_firing(mob/living/user, atom/fired_from)
	return !user.contains(fired_from)

/obj/item/ammo_casing/proc/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if (!loaded_projectile)
		return
	loaded_projectile.original = target
	loaded_projectile.firer = user
	loaded_projectile.fired_from = fired_from
	loaded_projectile.hit_prone_targets = user.combat_mode
	if (zone_override)
		loaded_projectile.def_zone = zone_override
	else
		loaded_projectile.def_zone = user.zone_selected
	loaded_projectile.suppressed = quiet

	if(isgun(fired_from))
		var/obj/item/gun/G = fired_from
		loaded_projectile.damage *= G.projectile_damage_multiplier
		loaded_projectile.stamina *= G.projectile_damage_multiplier

	if(tk_firing(user, fired_from))
		loaded_projectile.ignore_source_check = TRUE

	if(reagents && loaded_projectile.reagents)
		reagents.trans_to(loaded_projectile, reagents.total_volume, transfered_by = user) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread, atom/fired_from)
	var/turf/curloc = get_turf(fired_from)
	if (!istype(targloc) || !istype(curloc) || !loaded_projectile)
		return FALSE

	var/firing_dir
	if(loaded_projectile.firer)
		firing_dir = get_dir(fired_from, target)
	if(!loaded_projectile.suppressed && firing_effect_type && !tk_firing(user, fired_from))
		new firing_effect_type(get_turf(src), firing_dir)

	var/direct_target
	if(target && curloc.Adjacent(targloc, target=targloc, mover=src)) //if the target is right on our location or adjacent (including diagonally if reachable) we'll skip the travelling code in the proj's fire()
		direct_target = target
	if(!direct_target)
		var/modifiers = params2list(params)
		loaded_projectile.preparePixelProjectile(target, fired_from, modifiers, spread)
	var/obj/projectile/loaded_projectile_cache = loaded_projectile
	loaded_projectile = null
	loaded_projectile_cache.fire(null, direct_target)
	return TRUE

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)
