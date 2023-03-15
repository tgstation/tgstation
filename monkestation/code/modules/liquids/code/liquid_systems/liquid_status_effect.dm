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
	owner.add_movespeed_modifier("water_slow", TRUE, 100, multiplicative_slowdown = slowdown_amount)

/datum/status_effect/water_affected/tick()
	var/turf/T = get_turf(owner)
	if(!T || !T.liquids || T.liquids.liquid_group.group_overlay_state == LIQUID_STATE_PUDDLE)
		qdel(src)
		return
	calculate_water_slow()
	//Make the reagents touch the person

	var/fraction = SUBMERGEMENT_PERCENT(owner, T.liquids)
	T.liquids.liquid_group.expose_members_turf(T.liquids)
	T.liquids.liquid_group.transfer_to_atom(T.liquids, ((SUBMERGEMENT_REAGENTS_TOUCH_AMOUNT*fraction/20)), owner)

	return ..()

/datum/status_effect/water_affected/on_remove()
	owner.remove_movespeed_modifier("water_slow")

