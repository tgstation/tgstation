///Datum for basic mobs to define what they can attack.
/datum/targetting_datum


/datum/targetting_datum/proc/can_attack(mob/living/basic/basic_mob, atom/target)
	return

/datum/targetting_datum/proc/find_hidden_mobs(mob/living/basic/basic_mob, atom/target)
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		var/atom/target_hiding_location = target.loc
	return target_hiding_location

/datum/targetting_datum/basic

/datum/targetting_datum/basic/can_attack(mob/living/basic/basic_mob, atom/target)
	if(isturf(the_target) || !the_target) // bail out on invalids
		return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(basic_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(basic_mob.z != the_target.z)
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/L = the_target
		var/faction_check = faction_check_mob(L)
		if(faction_check || L.stat)
			return FALSE
		return TRUE

	if(ismecha(the_target)) //Targetting vs mechas
		var/obj/vehicle/sealed/mecha/M = the_target
		for(var/occupant in M.occupants)
			if(CanAttack(basic_mob, occupant)) //Can we attack any of the occupants?
				return TRUE

	if(istype(the_target, /obj/machinery/porta_turret)) //Cringe turret! kill it!
		var/obj/machinery/porta_turret/P = the_target
		if(P.in_faction(basic_mob)) //Don't attack if the turret is in the same faction
			return FALSE
		if(P.has_cover && !P.raised) //Don't attack invincible turrets
			return FALSE
		if(P.machine_stat & BROKEN) //Or turrets that are already broken
			return FALSE
		return TRUE

	if(isobj(the_target))
		if(basic_mob.basic_mob_flags & TARGET_ALL_OBJECTS || is_type_in_typecache(the_target, wanted_objects))
			return TRUE
	return FALSE
