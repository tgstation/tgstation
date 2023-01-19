///This proc is used by basic mobs to give them a simple ranged attack! In theory this could be extended to
/datum/element/ranged_attacks
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/casingtype = /obj/item/ammo_casing/glockroach
	var/projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	var/projectiletype

/datum/element/ranged_attacks/Attach(atom/movable/target, casingtype, projectilesound, projectiletype)
	. = ..()
	if(!isbasicmob(target))
		return COMPONENT_INCOMPATIBLE

	src.casingtype = casingtype
	src.projectilesound = projectilesound
	src.projectiletype = projectiletype

	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, PROC_REF(fire_ranged_attack))

	if(casingtype && projectiletype)
		CRASH("Set both casing type and projectile type in [target]'s ranged attacks element! uhoh! stinky!")

/datum/element/ranged_attacks/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOB_ATTACK_RANGED)
	return ..()

/datum/element/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(async_fire_ranged_attack), firer, target, modifiers)


/datum/element/ranged_attacks/proc/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	var/turf/startloc = get_turf(firer)

	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(firer, projectilesound, 100, TRUE)
		var/target_zone
		if(ismob(target))
			var/mob/target_mob = target
			target_zone = target_mob.get_random_valid_zone()
		else
			target_zone = ran_zone()
		casing.fire_casing(target, firer, null, null, null, target_zone, 0,  firer)
		casing.AddElement(/datum/element/temporary_atom, 30 SECONDS)

	else if(projectiletype)
		var/obj/projectile/P = new projectiletype(startloc)
		playsound(firer, projectilesound, 100, TRUE)
		P.starting = startloc
		P.firer = firer
		P.fired_from = firer
		P.yo = target.y - startloc.y
		P.xo = target.x - startloc.x
		P.original = target
		P.preparePixelProjectile(target, firer)
		P.fire()
