#define DELUSION_VIEW_RANGE 15

/// Delusion status effect. How most delusions end up happening.
/datum/status_effect/delusion
	id = "delusion"
	alert_type = null
	tick_interval = 5 SECONDS
	remove_on_fullheal = TRUE
	/// Biotypes which cannot hallucinate.
	var/barred_biotypes = NO_HALLUCINATION_BIOTYPES
	/// A list of all images we've made
	var/list/image/delusions

/datum/status_effect/delusion/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/delusion/on_apply()
	if(owner.mob_biotypes & barred_biotypes)
		return FALSE

	RegisterSignal(owner, COMSIG_LIVING_HEALTHSCAN,  PROC_REF(on_health_scan))
	tick() // start our delusions immediately
	return TRUE

/datum/status_effect/delusion/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_HEALTHSCAN))

	if(!QDELETED(owner) && LAZYLEN(delusions))
		owner.client?.images -= delusions
		LAZYNULL(delusions)

/// Signal proc for [COMSIG_LIVING_HEALTHSCAN]. Show we're hallucinating to (advanced) scanners.
/datum/status_effect/delusion/proc/on_health_scan(datum/source, list/render_list, advanced, mob/user, mode)
	SIGNAL_HANDLER

	if(!advanced)
		return

	render_list += "<span class='info ml-1'>Subject is hallucinating.</span>\n"

/datum/status_effect/delusion/tick(seconds_between_ticks)
	if(owner.stat == DEAD || !owner.client)
		return

	if(LAZYLEN(delusions))
		owner.client.images -= delusions
		LAZYNULL(delusions)

	var/list/mob/living/funny_looking_mobs = list()

	for(var/mob/living/nearby_mob in get_hearers_in_view(DELUSION_VIEW_RANGE, owner))
		if(nearby_mob == owner)
			continue
		funny_looking_mobs |= nearby_mob

	for(var/mob/living/found_mob in funny_looking_mobs)
		var/datum/hallucination/delusion/random_delusion
		while(!random_delusion)
			random_delusion = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
			if(initial(random_delusion.dynamic_icon))
				random_delusion = null // try again

		var/image/funny_image = image(initial(random_delusion.delusion_icon_file), found_mob, initial(random_delusion.delusion_icon_state))
		funny_image.name = initial(random_delusion.delusion_name)
		funny_image.override = TRUE

		LAZYADD(delusions, funny_image)
		owner.client.images |= funny_image

	return TRUE

#undef DELUSION_VIEW_RANGE
