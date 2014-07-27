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
		world << sound('sound/AI/radiation.ogg')
		command_alert("High levels of radiation detected near the station. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert")

		for(var/area/A in world)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.radiation_alert()

		make_maint_all_access()


		sleep(600)


		command_alert("The station has entered the radiation belt. Please remain in a sheltered area until we have passed the radiation belt.", "Anomaly Alert")

		for(var/i = 0, i < 10, i++)
			for(var/mob/living/carbon/human/H in living_mob_list)
				var/turf/T = get_turf(H)
				if(!T)
					continue
				if(T.z != 1 || is_safe_zone(T.loc))
					continue

				if(istype(H,/mob/living/carbon/human))
					H.apply_effect((rand(15,35)),IRRADIATE,0)
					if(prob(5))
						H.apply_effect((rand(40,70)),IRRADIATE,0)
						if (prob(75))
							randmutb(H) // Applies bad mutation
							domutcheck(H,null,MUTCHK_FORCED)
						else
							randmutg(H) // Applies good mutation
							domutcheck(H,null,MUTCHK_FORCED)


			for(var/mob/living/carbon/monkey/M in living_mob_list)
				var/turf/T = get_turf(M)
				if(!T)
					continue
				if(T.z != 1)
					continue
				M.apply_effect((rand(5,25)),IRRADIATE,0)
			sleep(100)


		command_alert("The station has passed the radiation belt. Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "Anomaly Alert")

		for(var/area/A in world)
			if(A.z != 1 || is_safe_zone(A))
				continue
			var/area/ma = get_area_master(A)
			ma.reset_radiation_alert()


		sleep(600) // Want to give them time to get out of maintenance.


		revoke_maint_all_access()
