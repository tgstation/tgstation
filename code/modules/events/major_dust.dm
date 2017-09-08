/datum/round_event_control/meteor_wave/major_dust
	name = "Major Space Dust"
	typepath = /datum/round_event/meteor_wave/major_dust
	weight = 8

/datum/round_event/meteor_wave/major_dust
	wave_name = "space dust"

/datum/round_event/meteor_wave/major_dust/announce()
	var/reason = SSrng.pick_from_list(
		"The station is passing through a debris cloud, expect minor damage \
		to external fittings and fixtures.",
		"Nanotrasen Superweapons Division is testing a new prototype \
		[SSrng.pick_from_list("field","projection","nova","super-colliding","reactive")] \
		[SSrng.pick_from_list("cannon","artillery","tank","cruiser","\[REDACTED\]")], \
		some mild debris is expected.",
		"A neighbouring station is throwing rocks at you. (Perhaps they've \
		grown tired of your messages.)")
	priority_announce(SSrng.pick_from_list(reason), "Collision Alert")
