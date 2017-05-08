/datum/game_mode/devil
	name = "devil"
	config_tag = "devil"
	antag_flag = ROLE_DEVIL
	protected_jobs = list("Lawyer", "Curator", "Chaplain", "Head of Security", "Captain", "AI")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0

	var/traitors_possible = 4 //hard limit on devils if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/objective_count = 2
	var/minimum_devils = 1

	announce_text = "There are devils onboard the station!\n\
		+	<span class='danger'>Devils</span>: Purchase souls and tempt the crew to sin!\n\
		+	<span class='notice'>Crew</span>: Resist the lure of sin and remain pure!"

/datum/game_mode/devil/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/num_devils = 1

	if(config.traitor_scaling_coeff)
		num_devils = max(minimum_devils, min( round(num_players()/(config.traitor_scaling_coeff*3))+ 2 + num_modifier, round(num_players()/(config.traitor_scaling_coeff*1.5)) + num_modifier ))
	else
		num_devils = max(minimum_devils, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_devils, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/devil = pick(antag_candidates)
		devils += devil
		devil.special_role = traitor_name
		devil.restricted_roles = restricted_jobs

		log_game("[devil.key] (ckey) has been selected as a [traitor_name]")
		antag_candidates.Remove(devil)

	if(devils.len < required_enemies)
		return 0
	return 1


/datum/game_mode/devil/post_setup()
	for(var/datum/mind/devil in devils)
		post_setup_finalize(devil)
	modePlayer += devils
	..()
	return 1

/datum/game_mode/devil/proc/post_setup_finalize(datum/mind/devil)
	set waitfor = FALSE
	sleep(rand(10,100))
	finalize_devil(devil, TRUE)
	sleep(100)
	add_devil_objectives(devil, objective_count) //This has to be in a separate loop, as we need devil names to be generated before we give objectives in devil agent.
	devil.announceDevilLaws()
	devil.announce_objectives()