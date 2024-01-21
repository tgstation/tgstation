/datum/twitch_event/skinny
	event_name = "Thinned Out Mode"
	event_duration = 5 MINUTES
	event_flags = TWITCH_AFFECTS_ALL | CLEAR_TARGETS_ON_END_EVENT
	id_tag = T_EVENT_SKINNY_5
	token_cost = 500

/datum/twitch_event/skinny/apply_effects()
	for(var/mob/living/target in targets)
		target.apply_displacement_icon(/obj/effect/distortion/skinny)

/datum/twitch_event/skinny/end_event()
	for(var/mob/living/target in targets)
		var/obj/effect/distortion/skinny/located = locate() in target.vis_contents
		qdel(located)
		target.clear_filters()
	return ..()
