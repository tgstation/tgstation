/datum/game_mode
	var/list/datum/mind/vampires = list()

/mob/living/carbon/human/Stat()
	. = ..()
	var/datum/antagonist/vampire/vamp = mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
	if(vamp && statpanel("Status"))
		stat("Total Blood", vamp.total_blood)
		stat("Usable Blood", vamp.usable_blood)

/mob/living/carbon/human/Life()
	. = ..()
	if(is_vampire(src))
		var/datum/antagonist/vampire/vamp = mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
		vamp.vampire_life()


/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	antag_flag = ROLE_VAMPIRE
	false_report_weight = 1
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Head of Security", "Captain", "Security Officer", "Chaplain", "Detective", "Warden")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3
	enemy_minimum_age = 0

	announce_text = "There are vampires onboard the station!\n\
		+	<span class='danger'>Vampires</span>: Suck the blood of the crew and complete your objectives!\n\
		+	<span class='notice'>Crew</span>: Kill the unholy vampires!"

	var/vampires_possible = 4 //hard limit on vampires if scaling is turned off
	var/num_modifier = 0


/datum/game_mode/vampire/pre_setup()
	var/vampires_num = 1

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	if(config.traitor_scaling_coeff)
		vampires_num = max(required_enemies, min( round(num_players()/(config.traitor_scaling_coeff*3))+ 2 + num_modifier, round(num_players()/(config.traitor_scaling_coeff*1.5)) + num_modifier ))
	else
		vampires_num = max(required_enemies, min(num_players(), vampires_possible))

	for(var/j = 0, j < vampires_num, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/vamp = pick(antag_candidates)
		vampires += vamp
		vamp.special_role = traitor_name
		vamp.restricted_roles = restricted_jobs

		log_game("[vamp.key] (ckey) has been selected as a Vampire")
		antag_candidates.Remove(vamp)

	if(vampires.len < required_enemies)
		return FALSE
	return TRUE


/datum/game_mode/devil/post_setup()
	for(var/datum/mind/devil in devils)
		add_vampire(devil)
	modePlayer += devils
	..()
	return TRUE


/proc/add_vampire(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/vampire/vamp = L.mind.add_antag_datum(ANTAG_DATUM_VAMPIRE)
	return vamp

/proc/remove_vampire(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/vamp = L.mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
	vamp.on_removal()
	return TRUE

/proc/is_vampire(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)