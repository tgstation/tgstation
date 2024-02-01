/datum/twitch_event/australia_mode
	event_name = "Australia Mode"
	event_duration = 15 MINUTES //effect is very minor so it lasts for a while
	event_flags = TWITCH_AFFECTS_ALL | CLEAR_TARGETS_ON_END_EVENT
	id_tag = T_EVENT_AUSTRALIA_MODE
	token_cost = 500

/datum/twitch_event/australia_mode/apply_effects()
	for(var/mob/living/target in targets)
		var/matrix/m180 = matrix(target.transform)
		m180.Turn(180)
		animate(target, transform = m180, time = 3)

/datum/twitch_event/australia_mode/end_event()
	for(var/mob/living/target in targets) //I would like to figure out a way to make this check first but this should work for now
		var/matrix/m180 = matrix(target.transform)
		m180.Turn(180)
		animate(target, transform = m180, time = 3)
	return ..()
