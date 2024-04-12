/datum/status_effect/water_affected
	id = "wateraffected"
	alert_type = null
	duration = -1

/datum/status_effect/water_affected/on_apply()
	//We should be inside a liquid turf if this is applied
	calculate_water_slow()
	return TRUE

/datum/status_effect/water_affected/proc/calculate_water_slow()
	//Factor in swimming skill here?
	var/turf/T = get_turf(owner)
	var/slowdown_amount = T.liquids.liquid_group.group_overlay_state * 0.5
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/liquids, multiplicative_slowdown = slowdown_amount)

/datum/status_effect/water_affected/tick()
	var/turf/owner_turf = get_turf(owner)
	if(QDELETED(owner_turf) || QDELETED(owner_turf.liquids) || owner_turf.liquids.liquid_group.group_overlay_state == LIQUID_STATE_PUDDLE)
		qdel(src)
		return
	calculate_water_slow()
	//Make the reagents touch the person

	var/fraction = SUBMERGEMENT_PERCENT(owner, owner_turf.liquids)
	owner_turf.liquids.liquid_group.expose_members_turf(owner_turf.liquids)
	owner_turf.liquids.liquid_group.transfer_to_atom(owner_turf.liquids, ((SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT * fraction / 20)), owner)

	return ..()

/datum/status_effect/water_affected/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/liquids)

/datum/movespeed_modifier/liquids
	variable = TRUE
	blacklisted_movetypes = FLOATING | FLYING

/datum/status_effect/ocean_affected
	alert_type = null
	duration = -1

/datum/status_effect/ocean_affected/tick()
	var/turf/ocean_turf = get_turf(owner)
	if(!istype(ocean_turf, /turf/open/floor/plating/ocean))
		qdel(src)

	if(ishuman(owner))
		var/mob/living/carbon/human/arrived = owner
		if(is_species(owner, /datum/species/ipc) && !(arrived.wear_suit?.clothing_flags & STOPSPRESSUREDAMAGE))
			arrived.adjustFireLoss(5)
