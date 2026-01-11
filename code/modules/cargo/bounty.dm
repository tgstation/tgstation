/datum/bounty
	var/name
	var/description
	VAR_PROTECTED/reward = CARGO_CRATE_VALUE * 5 // In credits.
	var/allow_duplicate = FALSE

/// Can this bounty be claimed right now?
/datum/bounty/proc/can_claim()
	return FALSE

/// If an item in question can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/shipped)
	return FALSE

/// Called when an object is sent on the bounty pad.
/datum/bounty/proc/ship(obj/shipped)
	return

/// Formats the text for what is required to complete the bounty, for display purposes.
/datum/bounty/proc/print_required()
	return ""

/// Returns the adjusted reward for this bounty, taking into account any global modifiers.
/datum/bounty/proc/get_bounty_reward()
	return reward * SSeconomy.bounty_modifier

/// Called when this bounty is selected by the passed ID card
/datum/bounty/proc/on_selected(obj/item/card/id/id_card)
	return

/// Called when this bounty is successfully claimed by the passed ID card
/datum/bounty/proc/on_claimed(obj/item/card/id/id_card)
	return

/// Called when this bounty is reset from the passed ID card, either from successful claim or from being replaced by another bounty
/datum/bounty/proc/on_reset(obj/item/card/id/id_card)
	return

/** Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
 *
 * * Category determines what specific catagory of bounty should be chosen.
 */
/proc/random_bounty(category = 0)
	var/bounty_num
	var/chosen_type
	var/bounty_succeeded = FALSE
	var/datum/bounty/item/bounty_ref
	while(!bounty_succeeded)
		if(category && (category != CIV_JOB_RANDOM))
			bounty_num = category
		else
			bounty_num = rand(1, MAXIMUM_BOUNTY_JOBS)
		switch(bounty_num)
			if(CIV_JOB_BASIC)
				chosen_type = pick(subtypesof(/datum/bounty/item/assistant))
			if(CIV_JOB_ROBO)
				chosen_type = pick(subtypesof(/datum/bounty/item/mech))
			if(CIV_JOB_CHEF)
				chosen_type = pick(subtypesof(/datum/bounty/item/chef) + subtypesof(/datum/bounty/reagent/chef))
			if(CIV_JOB_SEC)
				if(prob(75))
					chosen_type = /datum/bounty/patrol
				else
					chosen_type = /datum/bounty/item/contraband
			if(CIV_JOB_DRINK)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/simple_drink
				else
					chosen_type = /datum/bounty/reagent/complex_drink
			if(CIV_JOB_CHEM)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/chemical_simple
				else
					chosen_type = /datum/bounty/reagent/chemical_complex
			if(CIV_JOB_VIRO)
				chosen_type = pick(subtypesof(/datum/bounty/virus))
			if(CIV_JOB_SCI)
				if(prob(50))
					chosen_type = pick(subtypesof(/datum/bounty/item/science))
				else
					chosen_type = pick(subtypesof(/datum/bounty/item/slime))
			if(CIV_JOB_ENG)
				chosen_type = pick(subtypesof(/datum/bounty/item/engineering))
			if(CIV_JOB_MINE)
				chosen_type = pick(subtypesof(/datum/bounty/item/mining))
			if(CIV_JOB_MED)
				chosen_type = pick(subtypesof(/datum/bounty/item/medical))
			if(CIV_JOB_GROW)
				chosen_type = pick(subtypesof(/datum/bounty/item/botany))
			if(CIV_JOB_ATMOS)
				chosen_type = pick(subtypesof(/datum/bounty/item/atmospherics))
			if(CIV_JOB_BITRUN)
				chosen_type = pick(subtypesof(/datum/bounty/item/bitrunning))
		bounty_ref = new chosen_type
		if(bounty_ref.can_get())
			bounty_succeeded = TRUE
		else
			qdel(bounty_ref)
	return bounty_ref
