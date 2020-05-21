/datum/game_mode/ecult
	name = "eldritch cultist"
	config_tag = "eldritch cultist"
	report_type = "eldritch cultist"
	antag_flag = ROLE_ECULT
	false_report_weight = 5
	protected_jobs = list("Prisoner","Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_jobs = list("AI", "Cyborg","Chaplain")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "An eldritch cultist has been spotted on the station!\n\
	<span class='danger'>Cultist</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the madman succeed!"

	var/ecult_possible = 4 //hard limit on culties if scaling is turned off
	var/num_ecult = 1
	var/list/culties = list()

/datum/game_mode/ecult/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/esc = CONFIG_GET(number/ecult_scaling_coeff)
	if(esc)
		num_ecult = max(1, min(round(num_players() / (esc * 2)) + 2, round(num_players() / esc)))
	else
		num_ecult = max(1, min(num_players(), ecult_possible))

	for(var/i = 0, i < num_ecult, i++)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultie = antag_pick(antag_candidates)
		antag_candidates -= cultie
		cultie.special_role = ROLE_ECULTIST
		cultie.restricted_roles = restricted_jobs
		culties += cultie

	var/enough_tators = culties.len > 0

	if(!enough_tators)
		setup_error = "Not enough cult candidates"
		return FALSE
	else
		for(var/antag in culties)
			GLOB.pre_setup_antags += antag
		return TRUE

/datum/game_mode/ecult/post_setup()
	new /datum/reality_smash_tracker()
	GLOB.reality_smash_track.Generate(num_ecult)
	for(var/datum/mind/cultie in culties)
		log_game("[key_name(cultie)] has been selected as an eldritch cultist!")
		var/datum/antagonist/ecult/new_antag = new()
		cultie.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= cultie
	. =..()

/datum/game_mode/ecult/generate_report()
	return "Cybersun Industries has announced that they have successfully raided a high-security library. The library contained a very dangerous book that was \
	shown to posses anomalous properties. We suspect that the book has been delivered onto your station. Stay vigilant!"
