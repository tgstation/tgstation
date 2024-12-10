/obj/item/ammo_casing/proc/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	distro += variance
	var/targloc = get_turf(target)
	ready_proj(target, user, quiet, zone_override, fired_from)
	var/obj/projectile/thrown_proj
	if(pellets == 1)
		if(distro) //We have to spread a pixel-precision bullet. throw_proj was called before so angles should exist by now...
			if(randomspread)
				spread = round((rand() - 0.5) * distro)
			else //Smart spread
				spread = round(1 - 0.5) * distro
		thrown_proj = throw_proj(target, targloc, user, params, spread, fired_from)
		if(isnull(thrown_proj))
			return FALSE
	else
		if(isnull(loaded_projectile))
			return FALSE
		AddComponent(/datum/component/pellet_cloud, projectile_type, pellets)

	var/next_delay = click_cooldown_override || CLICK_CD_RANGE
	if(HAS_TRAIT(user, TRAIT_DOUBLE_TAP))
		next_delay = round(next_delay * 0.5)
	user.changeNext_move(next_delay)

	if(!tk_firing(user, fired_from))
		user.newtonian_move(get_angle(target, user), drift_force = newtonian_force)
	else if(ismovable(fired_from))
		var/atom/movable/firer = fired_from
		if(!firer.newtonian_move(get_angle(target, fired_from), instant = TRUE, drift_force = newtonian_force))
			var/throwtarget = get_step(fired_from, get_dir(target, fired_from))
			firer.safe_throw_at(throwtarget, 1, 2)
	update_appearance()

	SEND_SIGNAL(src, COMSIG_FIRE_CASING, target, user, fired_from, randomspread, spread, zone_override, params, distro, thrown_proj)

	return TRUE

/obj/item/ammo_casing/proc/tk_firing(mob/living/user, atom/fired_from)
	return fired_from != user && !user.contains(fired_from)

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
		var/obj/item/gun/gun = fired_from

		var/integrity_mult = 0.5 + gun.get_integrity_percentage() * 0.5
		if(integrity_mult >= 0.95) //Guns that are only mildly smudged don't debuff projectiles.
			integrity_mult = 1

		loaded_projectile.damage *= gun.projectile_damage_multiplier * integrity_mult
		loaded_projectile.stamina *= gun.projectile_damage_multiplier * integrity_mult

		loaded_projectile.speed *= gun.projectile_speed_multiplier * integrity_mult

		loaded_projectile.wound_bonus += gun.projectile_wound_bonus
		loaded_projectile.wound_bonus *= loaded_projectile.wound_bonus >= 0 ? 1 : 2 - integrity_mult
		loaded_projectile.bare_wound_bonus += gun.projectile_wound_bonus
		loaded_projectile.bare_wound_bonus *= loaded_projectile.bare_wound_bonus >= 0 ? 1 : 2 - integrity_mult

	if(tk_firing(user, fired_from))
		loaded_projectile.ignore_source_check = TRUE

	if(reagents && loaded_projectile.reagents)
		reagents.trans_to(loaded_projectile, reagents.total_volume, transferred_by = user) //For chemical darts/bullets
		qdel(reagents)
	SEND_SIGNAL(src, COMSIG_CASING_READY_PROJECTILE, target, user, quiet, zone_override, fired_from)

/obj/item/ammo_casing/proc/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread, atom/fired_from)
	var/turf/curloc = get_turf(fired_from)
	if (!istype(targloc) || !istype(curloc) || !loaded_projectile)
		return null

	var/firing_dir
	if(loaded_projectile.firer)
		firing_dir = get_dir(fired_from, target)
	if(!loaded_projectile.suppressed && firing_effect_type && !tk_firing(user, fired_from))
		new firing_effect_type(user || get_turf(src), firing_dir)

	var/direct_target
	if(target && curloc.Adjacent(targloc, target=targloc, mover=src)) //if the target is right on our location or adjacent (including diagonally if reachable) we'll skip the travelling code in the proj's fire()
		direct_target = target
	loaded_projectile.aim_projectile(target, fired_from, params2list(params), spread)
	var/obj/projectile/loaded_projectile_cache = loaded_projectile
	loaded_projectile = null
	loaded_projectile_cache.fire(null, direct_target)
	return loaded_projectile_cache

/obj/item/ammo_casing/proc/spread(turf/target, turf/current, distro)
	var/dx = abs(target.x - current.x)
	var/dy = abs(target.y - current.y)
	return locate(target.x + round(gaussian(0, distro) * (dy+2)/8, 1), target.y + round(gaussian(0, distro) * (dx+2)/8, 1), target.z)
