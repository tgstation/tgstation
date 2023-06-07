/datum/twitch_event/buff
	event_name = "Bodybuilder Mode"
	event_duration = 5 MINUTES
	event_flags = TWITCH_AFFECTS_ALL
	id_tag = "buff-5"

/datum/twitch_event/buff/run_event()
	. = ..()
	for(var/mob/living/target in targets)
		target.apply_displacement_icon(/obj/effect/distortion/buff)

/datum/twitch_event/buff/end_event()
	for(var/mob/living/target in targets)
		var/obj/effect/distortion/buff/located = locate() in target.vis_contents
		qdel(located)
		target.clear_filters()
