/datum/hallucination/malf_apc
	random_hallucination_weight = 5
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// APC icon to use for the hallucination
	var/apc_icon = 'icons/obj/machines/wallmounts.dmi'
	/// APC icon state to use for the hallucination
	var/apc_icon_state = "apcemag"

	/// The hacked APC image shown to the hallucinating mob
	VAR_PRIVATE/image/hacked_image

/datum/hallucination/malf_apc/start()
	if(!hallucinator.client)
		return FALSE

	var/num_ais = 0
	for(var/mob/living/silicon/ai/ai in GLOB.silicon_mobs)
		if(is_valid_z_level(get_turf(hallucinator), get_turf(ai)))
			num_ais += 1

	// less likely to see apcs if there are few to no ais around, but no guarantees.
	if(!prob(clamp(45 * num_ais, 10, 90)))
		return FALSE

	var/list/nearby_apcs = list()
	for(var/obj/machinery/power/apc/apc in view(hallucinator))
		if(!apc.is_operational || !apc.area || !apc.area.requires_power || apc.opened != APC_COVER_CLOSED)
			continue
		nearby_apcs += apc

	if(!length(nearby_apcs))
		return FALSE

	var/obj/machinery/power/apc/selected_apc = pick(nearby_apcs)
	hacked_image = image(
		icon = apc_icon,
		icon_state = apc_icon_state,
		layer = FLOAT_LAYER,
		loc = selected_apc,
	)
	hallucinator.client.images |= hacked_image
	QDEL_IN(src, 1 SECONDS)
	return TRUE

/datum/hallucination/malf_apc/Destroy()
	hallucinator.client?.images -= hacked_image
	hacked_image = null
	return ..()
