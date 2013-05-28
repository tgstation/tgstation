/datum/event/radiation_storm
	announceWhen	= 1
	oneShot			= 1


/datum/event/radiation_storm/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/radiation_storm/start()
	spawn()
		world << sound('sound/AI/radiation.ogg')
		command_alert("High levels of radiation detected near the station. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert")

		sleep(600)

		command_alert("The station has entered the radiation belt. Please remain in a sheltered area until we have passed the radiation belt.", "Anomaly Alert")
		for(var/i = 0, i < 10, i++)
			for(var/mob/living/carbon/human/H in living_mob_list)
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != 1)
					continue
				if(istype(T.loc, /area/maintenance) || istype(T.loc, /area/crew_quarters))
					continue
				if(istype(H,/mob/living/carbon/human))
					H.apply_effect((rand(2,15)),IRRADIATE,0)
					if(prob(5))
						H.apply_effect((rand(10,30)),IRRADIATE,0)
						if (prob(75))
							randmutb(H)
							domutcheck(H,null,1)
						else
							randmutg(H)
							domutcheck(H,null,1)
			for(var/mob/living/carbon/monkey/M in living_mob_list)
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z != 1)
					continue
				M.apply_effect((rand(5,25)),IRRADIATE,0)
			sleep(100)


		command_alert("The station has passed the radiation belt. Please report to medbay if you experience any unusual symptoms.", "Anomaly Alert")
