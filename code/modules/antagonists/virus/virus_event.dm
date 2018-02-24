
/datum/round_event_control/sentient_virus
	name = "Spawn Sentient Virus"
	typepath = /datum/round_event/ghost_role/sentient_virus
	weight = 7
	max_occurrences = 1
	min_players = 5


/datum/round_event/ghost_role/sentient_virus
	role_name = "sentient virus"

/datum/round_event/ghost_role/sentient_virus/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/selected = pick_n_take(candidates)

	var/mob/camera/virus/virus = new /mob/camera/virus(locate(1, 1, 1))
	if(!virus.infect_patient_zero())
		message_admins("Event attempted to spawn a sentient virus, but infection of patient zero failed.")
		qdel(virus)
		return WAITING_FOR_SOMETHING
	virus.key = selected.key
	message_admins("[key_name_admin(virus)] has been made into a sentient virus by an event.")
	log_game("[key_name(virus)] was spawned as a sentient virus by an event.")
	spawned_mobs += virus
	return SUCCESSFUL_SPAWN
