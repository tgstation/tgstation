/datum/event/radiation
	Lifetime = 10
	Announce()
		command_alert("The station is now travelling through a radiation belt", "Medical Alert")

	Tick()
		for(var/mob/living/carbon/L in world)
			L.apply_effect(rand(1,7), IRRADIATE)

	Die()
		command_alert("The station has cleared the radiation belt", "Medical Alert")
