/datum/twitch_event/skinny
	event_name = "Thinned Out Mode"
	event_duration = 5 MINUTES
	event_flags = TWITCH_AFFECTS_ALL
	id_tag = "skinny-5"

/datum/twitch_event/skinny/run_event()
	. = ..()
	for(var/mob/living/target in targets)
		target.apply_displacement_icon(/obj/effect/distortion/skinny)

/datum/twitch_event/skinny/end_event()
	for(var/mob/living/target in targets)
		var/obj/effect/distortion/skinny/located = locate() in target.vis_contents
		qdel(located)
		target.clear_filters()
