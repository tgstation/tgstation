/datum/spy_bounty
	var/name = "Do something"
	var/help = "Do something to someone in somewhere."
	var/difficulty = "unset"
	var/initalized = FALSE

/datum/spy_bounty/New()
	. = ..()
	if(init_bounty())
		initalized = TRUE

/datum/spy_bounty/proc/init_bounty()
	return FALSE

/datum/spy_bounty/proc/is_stealable(atom/movable/stealing, mob/living/spy)
	return FALSE

/datum/spy_bounty/proc/complete_bounty(mob/living/spy)
	return

/// Steal an item
/datum/spy_bounty/item
	var/datum/objective_item/desired_item

/datum/spy_bounty/item/init_bounty()
	var/list/valid_possible_items = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(length(item.special_equipment))
			continue
		if(!item.target_exists())
			continue
		valid_possible_items += item

	if(!length(valid_possible_items))
		return FALSE
	desired_item = pick(valid_possible_items)
	return TRUE

/datum/spy_bounty/machine
	var/area/location_type

/// Subtype for a bounty that targets a specific crew member
/datum/spy_bounty/targets_person

/datum/spy_bounty/targets_person/limb

/datum/spy_bounty/targets_person/organ
