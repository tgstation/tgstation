/datum/whim/make_babies
	name = "Make babies"
	priority = 2
	scan_radius = 7
	scan_every = 8
	abandon_rescan_length = 40 SECONDS

/datum/whim/make_babies/can_start()
	if(owner.gender != FEMALE || owner.stat || !owner.childtype || !owner.animal_species || !SSticker.IsRoundInProgress())
		return FALSE

	var/mob/living/simple_animal/partner
	var/children = 0

	for(var/mob/potential_partner in view(owner, scan_radius))
		if(potential_partner.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue

		if(is_type_in_list(potential_partner, (owner.childtype))) //Check for children SECOND.
			children++
			if(children > 3)
				return FALSE
		else if(istype(potential_partner, owner.animal_species))
			if(potential_partner.ckey)
				continue
			else if(potential_partner.gender == MALE && !(potential_partner.flags_1 & HOLOGRAM_1)) //Better safe than sorry ;_;
				partner = potential_partner

		else if(isliving(potential_partner) && !owner.faction_check_mob(potential_partner)) //shyness check. we're not shy in front of things that share a faction with us.
			return //we never mate when not alone, so just abort early

	return partner


/datum/whim/make_babies/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || !isturf(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	form_babby()

/datum/whim/make_babies/proc/form_babby()
	var/childspawn = pickweight(owner.childtype)
	var/turf/target = get_turf(owner)
	if(target)
		. = new childspawn(target)
		abandon() // abandon the baby making, not the baby (hopefully!)

/datum/whim/make_babies/gutlunch
	name = "Make babies (gutlunch)"

/datum/whim/make_babies/gutlunch/can_start()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/asteroid/gutlunch/our_gutlunch = owner
	if(our_gutlunch.udder.reagents.total_volume < our_gutlunch.udder.reagents.maximum_volume)
		return FALSE

/datum/whim/make_babies/gutlunch/form_babby()
	. = ..()
	if(.)
		var/mob/living/simple_animal/hostile/asteroid/gutlunch/our_gutlunch = owner
		our_gutlunch.udder.reagents.clear_reagents()
		our_gutlunch.regenerate_icons()
