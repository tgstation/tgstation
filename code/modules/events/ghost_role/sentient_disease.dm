/datum/round_event_control/sentient_disease
	name = "Spawn Sentient Disease"
	typepath = /datum/round_event/ghost_role/sentient_disease
	weight = 7
	max_occurrences = 0 //monkestation edit: from 1 to 0
	min_players = 25
	earliest_start = 60 MINUTES //monke edit: 25 to 60
	category = EVENT_CATEGORY_HEALTH
	description = "Spawns a sentient disease, who wants to infect as many people as possible."
	min_wizard_trigger_potency = 4
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/sentient_disease
	role_name = "sentient disease"

/datum/round_event/ghost_role/sentient_disease/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_SENTIENT_DISEASE, role = ROLE_SENTIENT_DISEASE, alert_pic = /obj/structure/sign/warning/biohazard, role_name_text = role_name)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/selected = pick_n_take(candidates)

	var/mob/camera/disease/virus = new /mob/camera/disease(SSmapping.get_station_center())
	virus.key = selected.key
	INVOKE_ASYNC(virus, TYPE_PROC_REF(/mob/camera/disease, pick_name))
	message_admins("[ADMIN_LOOKUPFLW(virus)] has been made into a sentient disease by an event.")
	virus.log_message("was spawned as a sentient disease by an event.", LOG_GAME)
	spawned_mobs += virus
	return SUCCESSFUL_SPAWN
