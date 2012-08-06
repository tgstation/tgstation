/datum/event/radiation
	var/current_iteration = 0

	// 50 - 20 (grace period) seconds lifetime
	Lifetime = 50
	Announce()
		command_alert("The station is now travelling through a radiation belt. Take shelter in the maintenance tunnels, or in the crew quarters!", "Medical Alert")

	Tick()
		current_iteration++

		// start radiating after 20 seconds grace period
		if(current_iteration > 20)
			for(var/mob/living/carbon/L in world)
				// check whether they're in a safe place
				// if they are, do not radiate
				var/turf/T = get_turf(L)
				if(T && ( istype(T.loc, /area/maintenance) || istype(T.loc, /area/crew_quarters) ))
					continue

				if (istype(L, /mob/living/carbon/monkey)) // So as to stop monkeys from dying in their pens
					L.apply_effect(rand(3,4), IRRADIATE)
				else
					L.apply_effect(rand(4,10), IRRADIATE)

	Die()
		command_alert("The station has cleared the radiation belt", "Medical Alert")
