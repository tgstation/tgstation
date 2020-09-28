/// Animals making babies, ported over to whims so we don't have to scan a 7x7 box every single tick per female cat and dog. TODO: port runtime's special baby handling.
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

	for(var/mob/living/potential_partner in view(owner, scan_radius))
		if(potential_partner.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue

		if(is_type_in_list(potential_partner, owner.childtype)) //Check for children SECOND.
			children++
			if(children > 3)
				return FALSE
		else if(istype(potential_partner, owner.animal_species))
			if(potential_partner.ckey)
				continue
			else if(potential_partner.gender == MALE && !(potential_partner.flags_1 & HOLOGRAM_1)) //Better safe than sorry ;_;
				partner = potential_partner // hurray, we found a partner, but we still have to keep checking for too many children or people we're shy of

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

/// Diverted into its own proc so that gutlunches and runtime can add on their own stuff (make this a callback somehow?)
/datum/whim/make_babies/proc/form_babby()
	var/childspawn = pickweight(owner.childtype)
	. = new childspawn(get_turf(owner))
	abandon() // abandon the baby making, not the baby (hopefully!)

/// Gutlunches are special (and gross) and need some extra handling
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
	var/mob/living/simple_animal/hostile/asteroid/gutlunch/our_gutlunch = owner
	if(!istype(our_gutlunch))
		CRASH("Non-Gutlunch mob [owner] trying to use Gutlunch's special make_babies datum")
		return
	if(.)
		our_gutlunch.udder.reagents.clear_reagents()
		our_gutlunch.regenerate_icons()

/// Runtime keeps track of her babies (make this a callback somehow?)
/datum/whim/make_babies/runtime
	name = "Make babies (Runtime)"

/datum/whim/make_babies/runtime/form_babby()
	. = ..()
	var/mob/baby = .
	var/mob/living/simple_animal/pet/cat/runtime/our_runtime = owner
	if(!istype(our_runtime))
		CRASH("Non-Runtime mob [owner] trying to use Runtime's special make_babies datum")
		return
	if(baby)
		our_runtime.children += baby
