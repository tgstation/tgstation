/datum/round_event_control/refugees
	name = "Spawn Fugitives"
	typepath = /datum/round_event/ghost_role/refugees
	max_occurrences = 1
	min_players = 20
	earliest_start = 30 MINUTES //deadchat sink, lets not even consider it early on.

/datum/round_event/ghost_role/refugees
	minimum_required = 1
	role_name = "fugitive"
	fakeable = FALSE

/datum/round_event/ghost_role/refugees/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN) //hehe "alien"
	if(candidates.len < 4)
		return NOT_ENOUGH_PLAYERS

	var/backstory = pick(list("prisoner"))

	var/turf/landing_turf = pick(GLOB.xeno_spawn)
	if(!landing_turf)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	for(var/i in 1 to 4)
		var/mob/dead/selected = pick(candidates)

		var/datum/mind/player_mind = new /datum/mind(selected.key)
		player_mind.active = TRUE

		var/mob/living/carbon/human/S = new (landing_turf)
		player_mind.transfer_to(S)
		player_mind.assigned_role = "Fugitive"
		player_mind.special_role = "Fugitive"
		player_mind.add_antag_datum(/datum/antagonist/fugitive) //they are not antagonists, but will show up roundend to see how they fared (and their origin)
		//clothes - WIP
		//outfit.uniform = /obj/item/clothing/under/rank/prisoner
		//outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
		//outfit.back = /obj/item/storage/backpack
		message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Fugitive by an event.")
		log_game("[key_name(S)] was spawned as a Fugitive by an event.")
		spawned_mobs += S

//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	//code for the security team add timer proc
	return SUCCESSFUL_SPAWN


//security team gets called in after 5 minutes of prep to find the refugees
