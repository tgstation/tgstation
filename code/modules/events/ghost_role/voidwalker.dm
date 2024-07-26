/datum/round_event_control/voidwalker
	name = "Spawn Void Walker"
	typepath = /datum/round_event/ghost_role/void_walker
	max_occurrences = 1
	weight = 2
	min_players = 40
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_ENTITIES
	description = "A Void Walker that rips people out of the station and into the abyss"
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7

// Only run on station maps.
/datum/round_event_control/ghost_role/voidwalker/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	var/space_check = find_space_spawn()
	if(!space_check)
		return FALSE
	return TRUE

/datum/round_event/ghost_role/void_walker
	minimum_required = 40
	fakeable = FALSE
	role_name = "void walker"

/datum/round_event/ghost_role/void_walker/spawn_role()
	var/spawn_location = find_space_spawn()
	if(isnull(spawn_location))
		return MAP_ERROR

	var/mob/chosen_one = SSpolling.poll_ghost_candidates(check_jobban = ROLE_VOIDWALKER, role = ROLE_VOIDWALKER, alert_pic = /obj/item/cosmic_skull, jump_target = spawn_location, role_name_text = "Void Walker", amount_to_pick = 1)
	if(isnull(chosen_one))
		return NOT_ENOUGH_PLAYERS

	var/datum/mind/player_mind = new /datum/mind(chosen_one.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/walker = new (spawn_location)
	player_mind.transfer_to(walker)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/voidwalker))
	player_mind.add_antag_datum(/datum/antagonist/voidwalker)
	walker.set_species(/datum/species/voidwalker)
	playsound(walker, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(walker)] has been made into a Voidwalker by the midround event.")
	walker.log_message("[key_name(walker)] was spawned as a Voidwalker by an event.", LOG_GAME)
	spawned_mobs += walker
	return SUCCESSFUL_SPAWN
