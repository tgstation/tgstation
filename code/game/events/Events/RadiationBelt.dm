/datum/event/radiation
	Lifetime = 10
	Announce()
		command_alert("The station is now travelling through a radiation belt", "Medical Alert")

	Tick()
		for(var/mob/living/L in world)
			L.radiation += rand(1,7)
			if (L && prob(4))
				if (prob(75))
					randmutb(L)
					domutcheck(L,null,1)
				else
					randmutg(L)
					domutcheck(L,null,1)

	Die()
		command_alert("The station has cleared the radiation belt", "Medical Alert")