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
		if(!throw_proj(target, targloc, user, params, spread))
			return FALSE
	else
		if(isnull(loaded_projectile))
			return FALSE
		AddComponent(/datum/component/pellet_cloud, projectile_type, pellets)
		SEND_SIGNAL(src, COMSIG_PELLET_CLOUD_INIT, target, user, fired_from, randomspread, spread, zone_override, params, distro)

	user.changeNext_move((click_cooldown_override || CLICK_CD_RANGE) * (HAS_TRAIT(user, TRAIT_DOUBLE_TAP) ? 0.5 : 1))

	user.newtonian_move(get_dir(target, user))
	update_appearance()
	return TRUE

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

	if(reagents && loaded_projectile.reagents)
		reagents.trans_to(loaded_projectile, reagents.total_volume, transfered_by = user) //For chemical darts/bullets
		qdel(reagents)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if (!istype(targloc) || !istype(curloc) || !loaded_projectile)
		return FALSE

	var/firing_dir
	if(loaded_projectile.firer)
		firing_dir = loaded_projectile.firer.dir
	if(!loaded_projectile.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)

	var/direct_target
	if(targloc == curloc)
		if(target) //if the target is right on our location we'll skip the travelling code in the proj's fire()
			direct_target = target
	if(!direct_target)
		var/modifiers = params2list(params)
		loaded_projectile.preparePixelProjectile(target, user, modifiers, spread)
	var/obj/projectile/loaded_projectile_cache = loaded_projectile
	loaded_projectile = null
	loaded_projectile_cache.fire(null, direct_target)
	return TRUE

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)
