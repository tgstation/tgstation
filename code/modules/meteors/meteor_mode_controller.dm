/// Global that controls meteor mode
GLOBAL_DATUM(meteor_mode, /datum/meteor_mode_controller)

/// All this datum does is regularly spawn meteors until the round ends.
/datum/meteor_mode_controller
	/// Delay before meteors start falling
	var/meteordelay = 5 MINUTES
	/// Every [x] minutes, more meteors will spawn
	var/rampupdelta = 5

/datum/meteor_mode_controller/proc/start_meteor()
	if(datum_flags & DF_ISPROCESSING)
		return
	START_PROCESSING(SSprocessing, src)

/datum/meteor_mode_controller/process(seconds_per_tick)
	if(meteordelay > world.time - SSticker.round_start_time)
		return

	var/list/wavetype = GLOB.meteors_normal
	var/meteorminutes = (world.time - SSticker.round_start_time - meteordelay) / 10 / 60

	if (prob(meteorminutes))
		wavetype = GLOB.meteors_threatening

	if (prob(meteorminutes/2))
		wavetype = GLOB.meteors_catastrophic

	var/ramp_up_final = clamp(round(meteorminutes / rampupdelta), 1, 10)

	spawn_meteors(ramp_up_final, wavetype)
