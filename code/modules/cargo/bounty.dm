GLOBAL_LIST_EMPTY(bounties_list)

/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits.
	var/claimed = FALSE
	var/high_priority = FALSE

// Displayed on bounty UI screen.
/datum/bounty/proc/completion_string()
	return ""

// Displayed on bounty UI screen.
/datum/bounty/proc/reward_string()
	return "[reward] Credits"

/datum/bounty/proc/can_claim()
	return !claimed

// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		SSshuttle.points += reward
		claimed = TRUE

// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

// When randomly generating the bounty list, duplicate bounties must be avoided.
// This proc is used to determine if two bounties are duplicates, or incompatible in general.
/datum/bounty/proc/compatible_with(other_bounty)
	return TRUE

/datum/bounty/proc/mark_high_priority(scale_reward = 2)
	if(high_priority)
		return
	high_priority = TRUE
	reward = round(reward * scale_reward)

// This proc is called when the shuttle docks at CentCom.
// It handles items shipped for bounties.
/proc/bounty_ship_item_and_contents(atom/movable/AM, dry_run=FALSE)
	if(!GLOB.bounties_list.len)
		setup_bounties()

	var/list/matched_one = FALSE
	for(var/thing in reverseRange(AM.GetAllContents()))
		var/matched_this = FALSE
		for(var/datum/bounty/B in GLOB.bounties_list)
			if(B.applies_to(thing))
				matched_one = TRUE
				matched_this = TRUE
				if(!dry_run)
					B.ship(thing)
		if(!dry_run && matched_this)
			qdel(thing)
	return matched_one

// Returns FALSE if the bounty is incompatible with the current bounties.
/proc/try_add_bounty(datum/bounty/new_bounty)
	if(!new_bounty || !new_bounty.name || !new_bounty.description)
		return FALSE
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(!B.compatible_with(new_bounty) || !new_bounty.compatible_with(B))
			return FALSE
	GLOB.bounties_list += new_bounty
	return TRUE

// Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
/proc/random_bounty()
	switch(rand(1, 9))
		if(1)
			var/subtype = pick(subtypesof(/datum/bounty/item/assistant))
			return new subtype
		if(2)
			var/subtype = pick(subtypesof(/datum/bounty/item/mech))
			return new subtype
		if(3)
			var/subtype = pick(subtypesof(/datum/bounty/item/chef))
			return new subtype
		if(4)
			var/subtype = pick(subtypesof(/datum/bounty/item/security))
			return new subtype
		if(5)
			if(rand(2) == 1)
				return new /datum/bounty/reagent/simple_drink
			return new /datum/bounty/reagent/complex_drink
		if(6)
			return new /datum/bounty/reagent/chemical
		if(7)
			var/subtype = pick(subtypesof(/datum/bounty/virus))
			return new subtype
		if(8)
			var/subtype = pick(subtypesof(/datum/bounty/item/science))
			return new subtype
		if(9)
			var/subtype = pick(subtypesof(/datum/bounty/item/slime))
			return new subtype

// Called lazily at startup to populate GLOB.bounties_list with random bounties.
/proc/setup_bounties()
	for(var/i = 0; i < 3; ++i)
		var/subtype = pick(subtypesof(/datum/bounty/item/assistant))
		try_add_bounty(new subtype)

	for(var/i = 0; i < 1; ++i)
		var/list/subtype = pick(subtypesof(/datum/bounty/item/mech))
		try_add_bounty(new subtype)

	for(var/i = 0; i < 2; ++i)
		var/list/subtype = pick(subtypesof(/datum/bounty/item/chef))
		try_add_bounty(new subtype)

	for(var/i = 0; i < 1; ++i)
		var/list/subtype = pick(subtypesof(/datum/bounty/item/security))
		try_add_bounty(new subtype)

	try_add_bounty(new /datum/bounty/reagent/simple_drink)
	try_add_bounty(new /datum/bounty/reagent/complex_drink)
	try_add_bounty(new /datum/bounty/reagent/chemical)

	for(var/i = 0; i < 1; ++i)
		var/list/subtype = pick(subtypesof(/datum/bounty/virus))
		try_add_bounty(new subtype)

	var/datum/bounty/B = pick(GLOB.bounties_list)
	B.mark_high_priority()

	// Generate these last so they can't be high priority.
	try_add_bounty(new /datum/bounty/item/alien_organs)
	try_add_bounty(new /datum/bounty/item/syndicate_documents)
	try_add_bounty(new /datum/bounty/more_bounties)

/proc/completed_bounty_count()
	var/count = 0
	for(var/i in GLOB.bounties_list)
		var/datum/bounty/B = i
		if(B.claimed)
			++count
	return count

