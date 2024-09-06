/datum/dynamic_ruleset/midround/from_ghosts/sapper_gang
	name = "Sapper Gang"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/sapper
	antag_flag = ROLE_SPACE_SAPPER
	ruleset_category = parent_type::ruleset_category |  RULESET_CATEGORY_NO_WITTING_CREW_ANTAGONISTS
	signup_item_path = /obj/item/wrench/bolter
	minimum_players = 20
	delay = 1 HOURS
	requirements = list(14,10,7,7,7,7,7,7,7,7)
	enemy_roles = list(
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_STATION_ENGINEER,
		JOB_CHIEF_ENGINEER,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CAPTAIN,
	)
	required_enemies = list(4,4,2,2,2,2,2,0,0,0)
	required_candidates = 2
	required_applicants = 2
	weight = 4
	cost = 7
	// where the antag will begin (its in their ship)
	var/list/spawn_locs = list()

/datum/dynamic_ruleset/midround/from_ghosts/sapper_gang/acceptable(population=0, threat_level=0)
	if (SSmapping.is_planetary())
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/sapper_gang/ready(forced = FALSE)
	if (required_candidates > (length(dead_players) + length(list_observers)))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/sapper_gang/finish_setup(mob/new_character, index)
	// spawn the ship once
	if (index == 1)
		var/datum/map_template/shuttle/pirate/sapper/ship = SSmapping.shuttle_templates["pirate_sapper"]
		var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
		var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
		var/z = SSmapping.empty_space.z_value
		var/turf/turf = locate(x,y,z)
		if(!turf)
			CRASH("Sapper event found no turf to load in")
		if(!ship.load(turf))
			CRASH("Loading sapper ship failed!")
		// get spawn locs
		for(var/turf/area_turf as anything in ship.get_affected_turfs(turf))
			for(var/obj/structure/chair/comfy/shuttle/chair in area_turf)
				spawn_locs += get_turf(chair)

	var/datum/team/sapper/gang = new

	new_character.forceMove(pick_n_take(spawn_locs))
	new_character.mind.set_assigned_role(SSjob.GetJobType(/datum/job/space_sapper))
	new_character.mind.special_role = ROLE_SPACE_SAPPER
	new_character.mind.add_antag_datum(/datum/antagonist/sapper, gang)
	new_character.mind.active = TRUE

////
// Trigger Events Panel
/datum/round_event_control/sappers
	name = "Space Sappers"
	typepath = /datum/round_event/ghost_role/sappers
	occurrences = 0
	dynamic_should_hijack = TRUE
	category = EVENT_CATEGORY_INVASION
	description = "A gang of outlaws are sapping the powernet with their credit-miners."
	map_flags = EVENT_SPACE_ONLY

/datum/round_event_control/sappers/preRunEvent()
	if (SSmapping.is_planetary())
		return EVENT_CANT_RUN

/datum/round_event/ghost_role/sappers
	fakeable = FALSE
	role_name = "Space Sapper"
	minimum_required = 2

/datum/round_event/ghost_role/sappers/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates("Do you wish to be considered to join the [span_notice("Space Sappers?")]", check_jobban = ROLE_TRAITOR, alert_pic = /obj/item/wrench/bolter, role_name_text = "sapper gang")
	if(minimum_required > length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/datum/map_template/shuttle/pirate/sapper/ship = SSmapping.shuttle_templates["pirate_sapper"]
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/turf = locate(x,y,z)
	if(!turf)
		CRASH("Sapper event found no turf to load in")

	if(!ship.load(turf))
		CRASH("Loading sapper ship failed!")

	var/list/spawn_locs = list()
	for(var/turf/area_turf as anything in ship.get_affected_turfs(turf))
		for(var/obj/structure/chair/comfy/shuttle/chair in area_turf)
			spawn_locs += get_turf(chair)
	if(!length(spawn_locs))
		return MAP_ERROR

	var/datum/team/sapper/gang = new

	var/mob/dead/candidate_one = pick_n_take(candidates)
	candidates -= candidate_one
	var/mob/dead/candidate_two = pick_n_take(candidates)
	candidates -= candidate_two

	var/datum/mind/mind_one = new /datum/mind(candidate_one.key)
	var/datum/mind/mind_two = new /datum/mind(candidate_two.key)
	var/mob/living/carbon/human/sapper_one = new(pick_n_take(spawn_locs))
	var/mob/living/carbon/human/sapper_two = new(pick_n_take(spawn_locs))

	candidate_one.client?.prefs?.apply_prefs_to(sapper_one)
	candidate_two.client?.prefs?.apply_prefs_to(sapper_two)
	sapper_one.dna.update_dna_identity()
	sapper_two.dna.update_dna_identity()

	var/list/mind_list = list(mind_one, mind_two)
	for(var/datum/mind/minds as anything in mind_list)
		minds.set_assigned_role(SSjob.GetJobType(/datum/job/space_sapper))
		minds.special_role = ROLE_SPACE_SAPPER
		minds.active = TRUE

	mind_one.transfer_to(sapper_one)
	mind_two.transfer_to(sapper_two)
	mind_one.add_antag_datum(/datum/antagonist/sapper, gang)
	mind_two.add_antag_datum(/datum/antagonist/sapper, gang)

	spawned_mobs += list(sapper_one, sapper_two)

	message_admins("[ADMIN_LOOKUPFLW(sapper_one)] and [ADMIN_LOOKUPFLW(sapper_two)] have been made into [src] by an event.")
	log_game("[key_name(sapper_one)] and[key_name(sapper_two)] were spawned as a [src] by an event.")
	return SUCCESSFUL_SPAWN
