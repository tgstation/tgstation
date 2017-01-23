/mob/living/Crossed(atom/movable/AM)
	..()

	if(isliving(AM) && lying)
		var/mob/living/L = AM
		L.trample(L.mob_size)

/mob/living/proc/trample(size_multiplier, trample_damage = TRAMPLE_DAMAGE) //tramples all lying mobs in the tile
	if(world.time <= next_move)
		return FALSE
	if(m_intent != MOVE_INTENT_RUN || buckled || get_num_legs() < 2 || lying || incapacitated(TRUE, TRUE) || (movement_type & FLYING))
		return FALSE
	changeNext_move(CLICK_CD_RAPID)
	var/list/targets = list()
	for(var/mob/living/L in loc)
		if(L.lying && L.mob_size <= mob_size)
			targets += L
	var/targets_len = LAZYLEN(targets)
	if(!targets_len)
		return FALSE
	shuffle(targets)
	if(size_multiplier)
		trample_damage *= size_multiplier //do more damage based on size; tiny mobs can't trample, bigger mobs can
	var/tripchance = max((targets_len * 10) - (movement_delay() * (targets_len * 5)), 0) //for 5 targets, this is a 50% chance to trip minus an amount based on your movement delay
	if(prob(tripchance) && Weaken(3, FALSE)) //don't update canmove immediately
		for(var/obj/item/I in held_items)
			accident(I)
		update_canmove() //update it after throwing shit
		trample_damage *= 0.5
		tripchance = TRUE //did trip!
	else
		tripchance = FALSE //did not trip!
	var/list/tramplemessage = list("<span class='danger'>")
	var/list/tramplelogs = list()
	for(var/i in targets)
		var/mob/living/L = i
		if(targets_len == 1) //one trampled!
			tramplemessage += "[L]"
		else if(targets[targets_len] == L) //multiple trampled, and this is the last!
			tramplemessage += "and [L]"
		else if(targets_len > 2)
			tramplemessage += "[L], "
		else
			tramplemessage += "[L] "
		if(L.be_trampled(trample_damage, src))
			if(targets[targets_len] == L) //multiple trampled, and this is the last!
				tramplelogs += "and [L ? "[L]":"NON-EXISTANT SUBJECT"]"
			else if(targets_len > 2)
				tramplelogs += "[L ? "[L]":"NON-EXISTANT SUBJECT"], "
			else
				tramplelogs += "[L ? "[L]":"NON-EXISTANT SUBJECT"] "
	add_logs(src, null, "trampled [tramplelogs.Join()]")
	tramplemessage += " [targets_len == 1 ? "is":"are"] trampled by [name]"
	var/tramplermessage = "<span class='warning'>You trampled [targets_len == 1 ? "somebody":"multiple somebodies"]!</span>"
	if(tripchance)
		tramplemessage += ", who trips!</span>"
		tramplermessage = "<span class='userdanger'>You trampled [targets_len == 1 ? "somebody":"multiple somebodies"] and tripped!</span>"
	else
		tramplemessage += "!</span>"
	visible_message(tramplemessage.Join(), tramplermessage, null, COMBAT_MESSAGE_RANGE)

	return TRUE

/mob/living/proc/be_trampled(trample_damage, mob/living/trampler)
	var/limb_to_hit = get_bodypart(pick("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg"))
	src << "<span class='userdanger'>You are trampled by [trampler]!</span>"
	apply_damage(trample_damage, BRUTE, limb_to_hit, run_armor_check(limb_to_hit, "melee"))
	add_logs("[trampler.name][trampler.ckey ? "([trampler.ckey])" : ""]", src, "trampled")
	return TRUE
