
/datum/proximity_monitor/advanced/dominator_forcefield
	name = "\improper Dominator Protection Field"
	setup_field_turfs = TRUE
	setup_edge_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	var/obj/machinery/dominator/controller
	var/datum/gang/team
	use_host_turf = TRUE

/datum/proximity_monitor/advanced/dominator_forcefield/New()
	START_PROCESSING(SSfields, src)
	..()

/datum/proximity_monitor/advanced/dominator_forcefield/proc/teamcheck(mob/living/L)
	if(!team || team.name == "ERROR")
		return TRUE
	if(!is_in_gang(L, team.name))
		return FALSE
	return TRUE

/datum/proximity_monitor/advanced/dominator_forcefield/setup_field_turf(turf/T)
	..()
	for(var/mob/living/L in T)
		if(!teamcheck(L))
			L.forceMove(pick(edge_turfs))

/datum/proximity_monitor/advanced/dominator_forcefield/initialize_effects()
	generic_edge = mutable_appearance('icons/effects/fields.dmi', icon_state = "dominator_field_generic")

/datum/proximity_monitor/advanced/dominator_forcefield/field_turf_explosion_block()
	return 100

/datum/proximity_monitor/advanced/dominator_forcefield/field_edge_block_air()
	return TRUE

/datum/proximity_monitor/advanced/dominator_forcefield/field_turf_crossed(atom/movable/thing)
	if(isliving(thing) && !teamcheck(thing))
		thing.forceMove(pick(edge_turfs))
	return TRUE

/datum/proximity_monitor/advanced/dominator_forcefield/field_edge_canpass(atom/movable/thing, obj/effect/abstract/proximity_checker/advanced/ADV)
	if(isliving(thing))
		return teamcheck(thing)
	else if(istype(thing, /obj/item/projectile))
		var/obj/item/projectile/P = thing
		P.Bump(ADV, TRUE)
		return FALSE
	else if(thing.throwing)
		var/datum/thrownthing/TT = thing.throwing
		TT.finalize()
	return TRUE

