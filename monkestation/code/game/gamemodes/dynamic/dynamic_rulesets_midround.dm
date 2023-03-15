//////////////////////////////////////////////
//                                          //
//           MIMICS (GHOST)                 //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/mimic
	name = "Mimic"
	antag_datum = /datum/antagonist/mimic
	antag_flag = "Mimic"
	antag_flag_override = ROLE_ALIEN
	enemy_roles = list("Security Officer", "Detective", "Warden", "Head of Security", "Captain")
	required_enemies = list(2,2,2,2,2,2,2,1,1,0)
	required_candidates = 2
	weight = 3
	cost = 15
	minimum_players = 30
	requirements = list(101,101,101,30,30,30,30,30,10,10)
	repeatable = FALSE
	var/spawn_location

/datum/dynamic_ruleset/midround/from_ghosts/mimic/execute()
	if(!GLOB.xeno_spawn.len)
		log_admin("Cannot accept Mimic ruleset. Couldn't find any xeno spawn points.")
		message_admins("Cannot accept Mimic ruleset. Couldn't find any xeno spawn points.")
		return FALSE
	spawn_location = pick(GLOB.xeno_spawn)
	. = ..()

/datum/dynamic_ruleset/midround/from_ghosts/mimic/generate_ruleset_body(mob/applicant)
	if(!spawn_location) //You never know
		spawn_location = pick(GLOB.xeno_spawn)
	var/mob/living/simple_animal/hostile/alien_mimic/spawned_mimic = new(spawn_location)
	var/datum/mind/player_mind = new(applicant.key)
	player_mind.assigned_role = "Mimic"
	player_mind.special_role = "Mimic"
	player_mind.active = TRUE
	player_mind.transfer_to(spawned_mimic)
	var/datum/antagonist/mimic/mimic_datum = player_mind.add_antag_datum(/datum/antagonist/mimic)

	mimic_datum.mimic_team.mimics |= spawned_mimic
	mimic_datum.mimic_team.original_members |= player_mind
	spawned_mimic.mimic_team = mimic_datum.mimic_team

	//Give them a special name in the hivemind for being the first one
	if(mimic_datum.mimic_team.mimics.len <= 1)
		spawned_mimic.real_name = pick("Mimic Leader","Mimic [pick("King","Queen","Monarch")]","The Broodmother","The Original","Mimic Prime")
	else
		spawned_mimic.real_name = pick("Mimic Commander","Mimic Centurion","Mimic General","Mimic Lord","Mimic Legionnaire","Mimic Elder") + " [mimic_datum.mimic_team.mimics.len - 1]" //Unless multiple spawned, then any others get their own names

	message_admins("[ADMIN_LOOKUPFLW(spawned_mimic)] has been made into a Mimic by the midround ruleset.")
	log_game("DYNAMIC: [key_name(spawned_mimic)] was spawned as a Mimic by the midround ruleset.")
	return spawned_mimic



