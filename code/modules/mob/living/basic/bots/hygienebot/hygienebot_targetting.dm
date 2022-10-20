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
			return TRUE
	return FALSE
