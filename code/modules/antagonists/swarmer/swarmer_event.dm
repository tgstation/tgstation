/datum/round_event_control/spawn_swarmer
	name = "Spawn Swarmer Shell"
	typepath = /datum/round_event/spawn_swarmer
	weight = 8
	max_occurrences = 1 //Only once okay fam
	earliest_start = 30 MINUTES
	min_players = 15

/datum/round_event/spawn_swarmer/announce(fake)
	priority_announce("Our long-range sensors have detected an odd signal emanating from your station's gateway. We recommend immediate investigation of your gateway, as something may have come through.", "<span class='big bold'>[command_name()] High-Priority Update</span>")

/datum/round_event/spawn_swarmer
	announceWhen = 50

/datum/round_event/spawn_swarmer/start()
	if(!GLOB.the_gateway)
		return 0
	new /obj/effect/mob_spawn/swarmer(get_turf(GLOB.the_gateway))
