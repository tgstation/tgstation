/datum/objective_team/abductor_team
	member_name = "abductor" 
	var/list/objectives = list()
	var/team_number

/datum/objective_team/abductor_team/is_solo()
	return FALSE

/datum/objective_team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/game_mode
	var/list/datum/mind/abductors = list()
	var/list/datum/mind/abductees = list()

/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	antag_flag = ROLE_ABDUCTOR
	false_report_weight = 1
	recommended_enemies = 2
	required_players = 15
	maximum_players = 50
	var/max_teams = 4
	var/list/datum/objective_team/abductor_team/abductor_teams = list()
	var/finished = FALSE
	var/static/team_count = 0

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	var/num_teams = max(1, min(max_teams, round(num_players() / CONFIG_GET(number/abductor_scaling_coeff))))
	var/possible_teams = max(1, round(antag_candidates.len / 2))
	num_teams = min(num_teams, possible_teams)

	for(var/i = 1 to num_teams)
		if(!make_abductor_team())
			return FALSE
	return TRUE

/datum/game_mode/abduction/proc/make_abductor_team(datum/mind/agent, datum/mind/scientist)
	team_count++ //TODO: Fix the edge case of abductor game mode rolling twice+ and failing to setup on first time.
	var/team_number = team_count

	if(team_number > max_teams)
		return //or should it try to stuff them in anway ?

	var/datum/objective_team/abductor_team/team = new
	team.team_number = team_number
	team.name = "Mothership [pick(GLOB.possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	team.add_objective(new/datum/objective/experiment)

	if(antag_candidates.len < (!agent + !scientist))
		return

	if(!scientist)
		scientist = pick(antag_candidates)
	antag_candidates -= scientist
	team.members |= scientist
	scientist.assigned_role = "Abductor Scientist"
	scientist.special_role = "Abductor Scientist"
	log_game("[scientist.key] (ckey) has been selected as [team.name] abductor scientist.")

	if(!agent)
		agent = pick(antag_candidates)
	antag_candidates -= agent
	team.members |= agent
	agent.assigned_role = "Abductor Agent"
	agent.special_role = "Abductor Agent"
	log_game("[agent.key] (ckey) has been selected as [team.name] abductor agent.")

	abductor_teams += team
	return team

/datum/game_mode/abduction/post_setup()
	for(var/datum/objective_team/abductor_team/team in abductor_teams)
		post_setup_team(team)
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(datum/objective_team/abductor_team/team)
	for(var/datum/mind/M in team.members)
		if(M.assigned_role == "Abductor Scientist")
			M.add_antag_datum(ANTAG_DATUM_ABDUCTOR_SCIENTIST, team)
		else
			M.add_antag_datum(ANTAG_DATUM_ABDUCTOR_AGENT, team)

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/datum/objective_team/abductor_team/team in abductor_teams)
			for(var/datum/objective/O in team.objectives)
				if(O.check_completion())
					SSshuttle.emergency.request(null, set_coefficient = 0.5)
					finished = TRUE
					return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/datum/objective_team/abductor_team/team in abductor_teams)
		var/won = TRUE
		for(var/datum/objective/O in team.objectives)
			if(!O.check_completion())
				won = FALSE
		if(won)
			to_chat(world, "<span class='greenannounce'>[team.name] team fulfilled its mission!</span>")
		else
			to_chat(world, "<span class='boldannounce'>[team.name] team failed its mission.</span>")
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_abduction()
	var/text = ""
	if(abductors.len)
		text += "<br><span class='big'><b>The abductors were:</b></span>"
		for(var/datum/mind/abductor_mind in abductors)
			text += printplayer(abductor_mind)
			text += printobjectives(abductor_mind)
		text += "<br>"
		if(abductees.len)
			text += "<br><span class='big'><b>The abductees were:</b></span>"
			for(var/datum/mind/abductee_mind in abductees)
				text += printplayer(abductee_mind)
				text += printobjectives(abductee_mind)
	text += "<br>"
	to_chat(world, text)

// LANDMARKS
/obj/effect/landmark/abductor
	var/team_number = 1

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist

// OBJECTIVES
/datum/objective/experiment
	target_amount = 6

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(!istype(team, /datum/objective_team/abductor_team))
			return FALSE
		var/datum/objective_team/abductor_team/T = team
		if(E.team_number == T.team_number)
			return E.points >= target_amount
	return FALSE

/datum/game_mode/proc/update_abductor_icons_added(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, ((alien_mind in abductors) ? "abductor" : "abductee"))

/datum/game_mode/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)

/datum/game_mode/abduction/generate_report()
	return "Nearby spaceships report crewmembers having been [pick("kidnapped", "abducted", "captured")] and [pick("tortured", "experimented on", "probed", "implanted")] by mysterious \
			grey humanoids, before being sent back.  Be advised that the kidnapped crewmembers behave strangely upon return to duties."
