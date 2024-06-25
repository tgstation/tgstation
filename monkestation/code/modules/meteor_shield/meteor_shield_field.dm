GLOBAL_LIST_EMPTY_TYPED(meteor_shield_fields, /datum/proximity_monitor/advanced/meteor_shield)

/// A proximity monitor field that marks openspace turfs within as being covered by a meteor shield.
/datum/proximity_monitor/advanced/meteor_shield
	edge_is_a_field = TRUE
	var/obj/machinery/satellite/meteor_shield/proxied_host

/datum/proximity_monitor/advanced/meteor_shield/New(atom/_host, range, _ignore_if_not_on_turf, proxied_host)
	GLOB.meteor_shield_fields += src
	if(proxied_host)
		src.proxied_host = proxied_host
	return ..()

/datum/proximity_monitor/advanced/meteor_shield/Destroy()
	GLOB.meteor_shield_fields -= src
	proxied_host = null
	return ..()

/datum/proximity_monitor/advanced/meteor_shield/setup_field_turf(turf/open/target)
	if(!isgroundlessturf(target))
		return
	var/obj/machinery/satellite/meteor_shield/host_sat = proxied_host || host
	if(host_sat.check_los(get_turf(host_sat), target))
		ADD_TRAIT(target, TRAIT_COVERED_BY_METEOR_SHIELD, REF(src))
		target.AddElement(/datum/element/meteor_shield_coverage)

/datum/proximity_monitor/advanced/meteor_shield/cleanup_field_turf(turf/target)
	REMOVE_TRAIT(target, TRAIT_COVERED_BY_METEOR_SHIELD, REF(src))

/datum/proximity_monitor/advanced/meteor_shield/set_range(range, force_rebuild)
	. = ..()
	if(.)
		recalculate_field(full_recalc = TRUE)
