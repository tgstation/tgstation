/datum/event/radiation_storm
	announceWhen	= 1
	var/safe_zones = list(
		/area/maintenance,
		/area/crew_quarters/sleep,
		/area/security/prison,
		/area/security/gas_chamber,
		/area/security/brig,
		/area/shuttle,
		/area/vox_station,
		/area/syndicate_station
	)


/datum/event/radiation_storm/announce()
	// Don't do anything, we want to pack the announcement with the actual event

/datum/event/radiation_storm/proc/is_safe_zone(var/area/A)
	for(var/szt in safe_zones)
		if(istype(A, szt))
			return 1
	return 0

/datum/event/radiation_storm/start()
	spawn()
		to_chat(world, sound('sound/AI/radiation.ogg'))
		command_alert("High levels of radiation detected near the station, ETA in 30 seconds.. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert")

		for(var/area/A in areas)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.radiation_alert()

		make_maint_all_access()


		sleep(30 SECONDS)


		command_alert("The station has entered the radiation belt. Please remain in a sheltered area until we have passed the radiation belt.", "Anomaly Alert")

		for(var/i = 0, i < 15, i++)
			var/irradiationThisBurst = rand(15,25) //everybody gets the same rads this radiation burst
			var/randomMutation = prob(50)
			var/badMutation = prob(50)
			for(var/mob/living/carbon/human/H in living_mob_list)
				if(istype(H.loc, /obj/spacepod))
					continue
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != 1 || is_safe_zone(T.loc))
					continue

				var/applied_rads = (H.apply_effect(irradiationThisBurst,IRRADIATE,0) > (irradiationThisBurst/4))
				if(randomMutation && applied_rads)
					if (badMutation)
						//H.apply_effect((rand(25,50)),IRRADIATE,0)
						randmutb(H) // Applies bad mutation
						domutcheck(H,null,MUTCHK_FORCED)
					else
						randmutg(H) // Applies good mutation
						domutcheck(H,null,MUTCHK_FORCED)

			sleep(25)


		command_alert("The station has passed the radiation belt. Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "Anomaly Alert")

		for(var/area/A in areas)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.reset_radiation_alert()


		sleep(600) // Want to give them time to get out of maintenance.


		revoke_maint_all_access()
