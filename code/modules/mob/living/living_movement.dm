/mob/living/Crossed(atom/movable/AM)
	..()

	if(isliving(AM) && lying)
		var/mob/living/L = AM
		L.trample()

/mob/living/proc/trample(trample_damage = TRAMPLE_DAMAGE, trample_verb = "trample", trampled_verb = "trampled") //tramples all lying mobs in the tile
	if(world.time <= next_move)
		return FALSE
	if(!(movement_type & TRAMPLER) && (m_intent != MOVE_INTENT_RUN || (movement_type & FLYING)) || buckled || get_num_legs() < 2 || lying || incapacitated(TRUE, TRUE) || !mob_has_gravity())
		return FALSE
	changeNext_move(CLICK_CD_RANGE)
	var/list/targets = list()
	var/trip_chance = 0
	for(var/mob/living/L in loc)
		if(L.lying && L.mob_size <= mob_size)
			targets += L
			if(L.stat == CONSCIOUS)
				trip_chance += 10
	var/targets_len = LAZYLEN(targets)
	if(!targets_len)
		return FALSE
	shuffle(targets)
	var/tripped = FALSE
	if(prob(trip_chance) && Weaken(3, FALSE))
		for(var/obj/item/I in held_items)
			accident(I)
		update_canmove()
		trample_damage *= 0.5
		tripped = TRUE //did trip!
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
		if(L.be_trampled(trample_damage, src, trampled_verb))
			if(targets[targets_len] == L) //multiple trampled, and this is the last!
				tramplelogs += "and [L ? "[L]":"NON-EXISTANT SUBJECT"]"
			else if(targets_len > 2)
				tramplelogs += "[L ? "[L]":"NON-EXISTANT SUBJECT"], "
			else
				tramplelogs += "[L ? "[L]":"NON-EXISTANT SUBJECT"] "
	add_logs(src, null, "trampled [tramplelogs.Join()]")
	tramplemessage += " [targets_len == 1 ? "is":"are"] [trampled_verb] by [name]"
	var/tramplermessage = "<span class='warning'>You [trample_verb] [targets_len == 1 ? "somebody":"multiple somebodies"]!</span>"
	if(tripped)
		tramplemessage += ", who trips!</span>"
		tramplermessage = "<span class='userdanger'>You [trample_verb] [targets_len == 1 ? "somebody":"multiple somebodies"] and tripped!</span>"
	else
		tramplemessage += "!</span>"
	visible_message(tramplemessage.Join(), tramplermessage, null, COMBAT_MESSAGE_RANGE)

	return TRUE

/mob/living/proc/be_trampled(trample_damage, mob/living/trampler, trample_verb = "trampled")
	var/limb_to_hit = get_bodypart(pick("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg"))
	src << "<span class='userdanger'>You are [trample_verb] by [trampler]!</span>"
	if(trampler.mob_size > mob_size)
		trample_damage *= 1 + trampler.mob_size - mob_size //if the trampler is bigger than us, multiply the damage by the difference
	apply_damage(trample_damage, BRUTE, limb_to_hit, run_armor_check(limb_to_hit, "melee"))
	add_logs("[trampler.name][trampler.ckey ? "([trampler.ckey])" : ""]", src, trample_verb)
	return TRUE
