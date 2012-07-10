/datum/event/radiation
	var/current_iteration = 0

	// 1 minute lifetime
	Lifetime = 60
	Announce()
		command_alert("The station is now travelling through a radiation belt", "Medical Alert")

	Tick()
		current_iteration++

		// start radiating after 20 seconds grace period
		if(current_iteration > 20)
			for(var/mob/living/carbon/L in world)
				// check whether they're in a safe place
				// if they are, do not radiate
				var/turf/T = get_turf(L)
				if(T && istype(T.loc, /area/maintenance))
					continue

				L.apply_effect(rand(4,10), IRRADIATE)

	Die()
		command_alert("The station has cleared the radiation belt", "Medical Alert")
