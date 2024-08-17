/datum/action/changeling/adrenaline
	name = "Repurposed Glands"
	desc = "We shift almost all available muscle mass from the arms to the legs, disabling the former but making us unable to be downed for 20 seconds. Costs 25 chemicals."
	helptext = "Disables your arms and retracts bioweaponry, but regenerates your legs, grants you speed, and wakes you up from any stun."
	button_icon_state = "adrenaline"
	chemical_cost = 25 // similar cost to biodegrade, as they serve similar purposes
	dna_cost = 2
	req_human = FALSE
	req_stat = CONSCIOUS
	disabled_by_fire = FALSE

/datum/action/changeling/adrenaline/can_sting(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT_FROM(user, TRAIT_PARALYSIS_L_ARM, CHANGELING_TRAIT) || HAS_TRAIT_FROM(user, TRAIT_PARALYSIS_R_ARM, CHANGELING_TRAIT))
		user.balloon_alert(user, "already boosted!")
		return FALSE

	return .

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/carbon/user)
	..()
	to_chat(user, span_changeling("Our arms feel weak, but our legs become unstoppable!"))

	for(var/datum/action/changeling/weapon/weapon_ability in user.actions)
		weapon_ability.unequip_held(user)

	// Destroy legcuffs with our IMMENSE LEG STRENGTH.
	if(istype(user.legcuffed))
		user.visible_message(
			span_warning("[user]'s legs suddenly rip [user.legcuffed] apart!"),
			span_warning("We rip apart our leg restraints!"),
		)
		qdel(user.legcuffed)

	// Regenerate our legs only.
	var/our_leg_zones = (GLOB.all_body_zones - GLOB.leg_zones)
	user.regenerate_limbs(excluded_zones = our_leg_zones) // why is this exclusive rather than inclusive

	user.add_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
	user.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)

	// Revert above mob changes.
	addtimer(CALLBACK(src, PROC_REF(unsting_action), user), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	// Get us standing up.
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	user.set_resting(FALSE, instant = TRUE)

	// Add fast reagents to go fast.
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds

	return TRUE

/datum/action/changeling/adrenaline/proc/unsting_action(mob/living/user)
	to_chat(user, span_changeling("The muscles in our limbs shift back to their usual places."))
	user.remove_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM), CHANGELING_TRAIT)
	user.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown)
