/datum/action/changeling/adrenaline
	name = "Repurposed Glands"
	desc = "We shift almost all available muscle mass from the arms to the legs, disabling the former but making us unable to be downed for 15 seconds. Costs 10 chemicals."
	helptext = "Disables your arms and retracts bioweaponry, but regenerates your legs, grants you speed, and wakes you up from any stun."
	button_icon_state = "adrenaline"
	chemical_cost = 10
	dna_cost = 1
	req_human = FALSE
	req_stat = CONSCIOUS

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()
	to_chat(user, span_changeling("Our arms feel weak, but our legs become unstoppable!"))

	for(var/datum/action/changeling/weapon/weapon_ability in user.actions)
		weapon_ability.unequip_held(user)

	// Destroy legcuffs with our IMMENSE LEG STRENGTH.
	if(user.legcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(O))
			return FALSE
		qdel(O)
		user.visible_message(span_warning("[user]'s legs suddenly rip [O] apart!"), \
			span_warning("We rip apart our leg restraints!"))

	// Regenerate our legs only.
	var/our_leg_zones = (GLOB.all_body_zones - GLOB.leg_zones)
	user.regenerate_limbs(excluded_zones = our_leg_zones) // why is this exclusive rather than inclusive

	user.add_traits(list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)

	// Revert above mob changes.
	addtimer(CALLBACK(src, PROC_REF(unsting_action), user), 20 SECONDS)

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	// Add fast reagents to go fast.
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds

	return TRUE

/datum/action/changeling/adrenaline/proc/unsting_action(mob/living/user)
	to_chat(user, span_changeling("The muscles in our limbs shift back to their usual places."))
	user.remove_traits(list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
	return
