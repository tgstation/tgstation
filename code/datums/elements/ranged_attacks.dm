///This proc is used by basic mobs to give them a simple ranged attack! In theory this could be extended to
/datum/element/ranged_attacks
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
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

	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, .proc/fire_ranged_attack)

	if(casingtype && projectiletype)
		CRASH("Set both casing type and projectile type in [target]'s ranged attacks element! uhoh! stinky!")

/datum/element/ranged_attacks/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOB_ATTACK_RANGED)
	return ..()

/datum/element/ranged_attacks/proc/fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/async_fire_ranged_attack, firer, target, modifiers)


/datum/element/ranged_attacks/proc/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	var/turf/startloc = get_turf(firer)

	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(firer, projectilesound, 100, TRUE)
		casing.fire_casing(target, firer, null, null, null, ran_zone(), 0,  firer)

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
