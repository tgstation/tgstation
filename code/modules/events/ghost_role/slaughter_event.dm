/datum/round_event_control/slaughter
	name = "Spawn Slaughter Demon"
	typepath = /datum/round_event/ghost_role/slaughter
	weight = 1 //Very rare
	max_occurrences = 1
	earliest_start = 1 HOURS
	min_players = 20
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "Spawns a slaughter demon, to hunt by travelling through pools of blood."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

/datum/round_event/ghost_role/slaughter
	minimum_required = 1
	role_name = "slaughter demon"

/datum/round_event/ghost_role/slaughter/spawn_role()
	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_ALIEN, role = ROLE_ALIEN, alert_pic = /mob/living/basic/demon/slaughter, role_name_text = role_name, amount_to_pick = 1)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/player_mind = new /datum/mind(chosen_one.key)
	player_mind.active = TRUE

	var/spawn_location = find_space_spawn()
	if(!spawn_location)
		return MAP_ERROR //This sends an error message further up.
	var/mob/living/basic/demon/slaughter/spawned = new(spawn_location)
	new /obj/effect/dummy/phased_mob(spawn_location, spawned)

	player_mind.transfer_to(spawned)

	message_admins("[ADMIN_LOOKUPFLW(spawned)] has been made into a slaughter demon by an event.")
	spawned.log_message("was spawned as a slaughter demon by an event.", LOG_GAME)
	spawned_mobs += spawned
	return SUCCESSFUL_SPAWN
