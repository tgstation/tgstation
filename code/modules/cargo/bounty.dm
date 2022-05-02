/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits.
	var/claimed = FALSE
	var/high_priority = FALSE

/datum/bounty/proc/can_claim()
	return !claimed

/// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			D.adjust_money(reward * SSeconomy.bounty_modifier)
		claimed = TRUE

/// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

/// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

/** Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
 *
 * *Guided determines what specific catagory of bounty should be chosen.
 */
/proc/random_bounty(guided = 0)
	var/bounty_num
	var/chosen_type
	var/bounty_succeeded = FALSE
	var/datum/bounty/item/bounty_ref
	while(!bounty_succeeded)
		if(guided && (guided != CIV_JOB_RANDOM))
			bounty_num = guided
		else
			bounty_num = rand(1,13)
		switch(bounty_num)
			if(1)
				chosen_type = pick(subtypesof(/datum/bounty/item/assistant))
			if(2)
				chosen_type = pick(subtypesof(/datum/bounty/item/mech))
			if(3)
				chosen_type = pick(subtypesof(/datum/bounty/item/chef))
			if(4)
				chosen_type = pick(subtypesof(/datum/bounty/item/security))
			if(5)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/simple_drink
				else
					chosen_type = /datum/bounty/reagent/complex_drink
			if(6)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/chemical_simple
				else
					chosen_type = /datum/bounty/reagent/chemical_complex
			if(7)
				chosen_type = pick(subtypesof(/datum/bounty/virus))
			if(8)
				if(prob(50))
					chosen_type = pick(subtypesof(/datum/bounty/item/science))
				else
					chosen_type = pick(subtypesof(/datum/bounty/item/slime))
			if(9)
				chosen_type = pick(subtypesof(/datum/bounty/item/engineering))
			if(10)
				chosen_type = pick(subtypesof(/datum/bounty/item/mining))
			if(11)
				chosen_type = pick(subtypesof(/datum/bounty/item/medical))
			if(12)
				chosen_type = pick(subtypesof(/datum/bounty/item/botany))
			if(13)
				chosen_type = pick(subtypesof(/datum/bounty/item/atmospherics))
		bounty_ref = new chosen_type
		if(bounty_ref.can_get())
			bounty_succeeded = TRUE
		else
			qdel(bounty_ref)
	return bounty_ref
