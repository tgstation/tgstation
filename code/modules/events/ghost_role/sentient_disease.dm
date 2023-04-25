/datum/round_event_control/sentient_disease
	name = "Spawn Sentient Disease"
	typepath = /datum/round_event/ghost_role/sentient_disease
	weight = 7
	max_occurrences = 1
	min_players = 25
	category = EVENT_CATEGORY_HEALTH
	description = "Spawns a sentient disease, who wants to infect as many people as possible."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event_control/sentient_disease/can_spawn_event(players_amt, allow_magic)
	. = ..()
	if(!.)
		return .

	var/host_counter = 0 //Counts how many potential hosts we have

	//If 75% of the crew are potential hosts, we send in a sentient disease.
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		if(candidate.stat == DEAD)
			continue
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER)) //We're only checking crew here.
			continue
		if(length(candidate.diseases))
			continue
		host_counter++

	if(((host_counter / length(GLOB.player_list)) * 100) < 75) //If under 75% of the crew is infected with something or ineligible, maybe it's not the best time to introduce a sentient disease.
		return FALSE

/datum/round_event/ghost_role/sentient_disease
	role_name = "sentient disease"

/datum/round_event/ghost_role/sentient_disease/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/selected = pick_n_take(candidates)

	var/mob/camera/disease/virus = new /mob/camera/disease(SSmapping.get_station_center())
	virus.key = selected.key
	INVOKE_ASYNC(virus, TYPE_PROC_REF(/mob/camera/disease, pick_name))
	message_admins("[ADMIN_LOOKUPFLW(virus)] has been made into a sentient disease by an event.")
	virus.log_message("was spawned as a sentient disease by an event.", LOG_GAME)
	spawned_mobs += virus
	return SUCCESSFUL_SPAWN
