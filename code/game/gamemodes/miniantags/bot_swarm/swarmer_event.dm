/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Shell"
	typepath = /datum/round_event/spawn_swarmer
	weight = 7
	max_occurrences = 1 //Only once okay fam
	earliest_start = 18000 //30 minutes
	min_players = 15


/datum/round_event/spawn_swarmer


/datum/round_event/spawn_swarmer/start()
	if(find_swarmer())
		return 0
	if(!GLOB.the_gateway)
		return 0
	new /obj/item/device/unactivated_swarmer(get_turf(GLOB.the_gateway))
	if(prob(25)) //25% chance to announce it to the crew
		var/swarmer_report = "<font size=3><b>[command_name()] High-Priority Update</b></span>"
		swarmer_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station's gateway. We recommend immediate investigation of your gateway, as something may have come through."
		print_command_report(swarmer_report, announce=TRUE)


/datum/round_event/spawn_swarmer/proc/find_swarmer()
	for(var/mob/living/M in GLOB.mob_list)
		if(istype(M, /mob/living/simple_animal/hostile/swarmer) && M.client) //If there is a swarmer with an active client, we've found our swarmer
			return 1
	return 0
