/datum/round_event_control/meteor_wave/oreo
	name = "Meteor Wave: Oreo"
	typepath = /datum/round_event/meteor_wave/oreo
	weight = 7
	min_players = 30
	max_occurrences = 1
	earliest_start = 900 MINUTES

/datum/round_event/meteor_wave/oreo
	wave_name = "oreo"

/datum/round_event/meteor_wave/oreo/announce(fake)
	priority_announce("You guys have oreos...right?", "Can I have some oreos?",'sound/effects/oreoannouncement.ogg')
