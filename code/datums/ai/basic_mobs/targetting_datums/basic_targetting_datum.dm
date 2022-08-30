///Datum for basic mobs to define what they can attack.
/datum/targetting_datum

///Returns true or false depending on if the target can be attacked by the mob
/datum/targetting_datum/proc/can_attack(mob/living/living_mob, atom/target)
	return

///Returns something the target might be hiding inside of
/datum/targetting_datum/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	var/atom/target_hiding_location
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		target_hiding_location = target.loc
	return target_hiding_location

/datum/targetting_datum/basic

/datum/targetting_datum/basic/can_attack(mob/living/living_mob, atom/the_target)
	if(isturf(the_target) || !the_target) // bail out on invalids
		return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(living_mob.see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(living_mob.z != the_target.z)
		return FALSE

	if(isliving(the_target)) //Targetting vs living mobs
		var/mob/living/L = the_target
		var/faction_check = living_mob.faction_check_mob(L)
		if(faction_check || L.stat)
			return FALSE
		return TRUE

	if(ismecha(the_target)) //Targetting vs mechas
		var/obj/vehicle/sealed/mecha/M = the_target
		for(var/occupant in M.occupants)
			if(can_attack(living_mob, occupant)) //Can we attack any of the occupants?
				return TRUE

	if(istype(the_target, /obj/machinery/porta_turret)) //Cringe turret! kill it!
		var/obj/machinery/porta_turret/P = the_target
		if(P.in_faction(living_mob)) //Don't attack if the turret is in the same faction
			return FALSE
		if(P.has_cover && !P.raised) //Don't attack invincible turrets
			return FALSE
		if(P.machine_stat & BROKEN) //Or turrets that are already broken
			return FALSE
		return TRUE

	return FALSE



/datum/targetting_datum/hygienebot
	var/max_target_distance = 20

/datum/targetting_datum/hygienebot/can_attack(mob/living/living_mob, atom/the_target)
	if(!ismob(the_target) || !istype(living_mob, /mob/living/basic/bot)) // bail out on invalids
		return FALSE

	var/mob/living/basic/bot/targetting_bot = living_mob
	var/mob/target_mob = the_target

	if(targetting_bot.see_invisible < target_mob.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(targetting_bot.z != target_mob.z)
		return FALSE

	if(get_dist(targetting_bot, target_mob) >= max_target_distance)
		return FALSE

	if((targetting_bot.bot_cover_flags & BOT_COVER_EMAGGED) && target_mob.stat != DEAD)
		return FALSE

	for(var/X in list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING, ITEM_SLOT_FEET))
		var/obj/item/I = target_mob.get_item_by_slot(X)
		if(I && GET_ATOM_BLOOD_DNA_LENGTH(I))
			return FALSE
	return TRUE
