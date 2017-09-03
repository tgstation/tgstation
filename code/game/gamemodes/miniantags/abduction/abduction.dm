/datum/game_mode
	var/abductor_teams = 0
	var/list/datum/mind/abductors = list()
	var/list/datum/mind/abductees = list()

/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	antag_flag = ROLE_ABDUCTOR
	recommended_enemies = 2
	required_players = 15
	maximum_players = 50
	var/max_teams = 4
	abductor_teams = 1
	var/list/datum/mind/scientists = list()
	var/list/datum/mind/agents = list()
	var/list/datum/objective/team_objectives = list()
	var/list/team_names = list()
	var/finished = 0

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	abductor_teams = max(1, min(max_teams,round(num_players()/config.abductor_scaling_coeff)))
	var/possible_teams = max(1,round(antag_candidates.len / 2))
	abductor_teams = min(abductor_teams,possible_teams)

	abductors.len = 2*abductor_teams
	scientists.len = abductor_teams
	agents.len = abductor_teams
	team_objectives.len = abductor_teams
	team_names.len = abductor_teams

	for(var/i=1,i<=abductor_teams,i++)
		if(!make_abductor_team(i))
			return 0

	return 1

/datum/game_mode/abduction/proc/make_abductor_team(team_number,preset_agent=null,preset_scientist=null)
	//Team Name
	team_names[team_number] = "Mothership [pick(GLOB.possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	//Team Objective
	var/datum/objective/experiment/team_objective = new
	team_objective.team = team_number
	team_objectives[team_number] = team_objective
	//Team Members

	if(!preset_agent || !preset_scientist)
		if(antag_candidates.len <=2)
			return 0

	var/datum/mind/scientist
	var/datum/mind/agent

	if(!preset_scientist)
		scientist = pick(antag_candidates)
		antag_candidates -= scientist
	else
		scientist = preset_scientist

	if(!preset_agent)
		agent = pick(antag_candidates)
		antag_candidates -= agent
	else
		agent = preset_agent


	scientist.assigned_role = "abductor scientist"
	scientist.special_role = "abductor scientist"
	log_game("[scientist.key] (ckey) has been selected as an abductor team [team_number] scientist.")

	agent.assigned_role = "abductor agent"
	agent.special_role = "abductor agent"
	log_game("[agent.key] (ckey) has been selected as an abductor team [team_number] agent.")

	abductors |= agent
	abductors |= scientist
	scientists[team_number] = scientist
	agents[team_number] = agent
	return 1

/datum/game_mode/abduction/post_setup()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		post_setup_team(team_number)
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(team_number)
	var/list/obj/effect/landmark/abductor/agent_landmarks = list()
	var/list/obj/effect/landmark/abductor/scientist_landmarks = list()
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A, /obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A, /obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/team_name = team_names[team_number]

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/mob/living/carbon/human/H
	var/datum/species/abductor/S

	agent = agents[team_number]
	H = agent.current
	L = agent_landmarks[team_number]
	H.forceMove(L.loc)
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.team = team_number
	H.real_name = team_name + " Agent"
	H.equipOutfit(/datum/outfit/abductor/agent)
	greet_agent(agent,team_number)


	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.forceMove(L.loc)
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.scientist = TRUE
	S.team = team_number
	H.real_name = team_name + " Scientist"
	H.equipOutfit(/datum/outfit/abductor/scientist)
	greet_scientist(scientist,team_number)



/datum/game_mode/abduction/proc/greet_agent(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	to_chat(abductor.current, "<span class='notice'>You are an agent of [team_name]!</span>")
	to_chat(abductor.current, "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='notice'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/greet_scientist(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	to_chat(abductor.current, "<span class='notice'>You are a scientist of [team_name]!</span>")
	to_chat(abductor.current, "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='notice'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.team == team_number)
			return C

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number=1,team_number<=abductor_teams,team_number++)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if (con.experiment.points >= objective.target_amount)
				SSshuttle.emergency.request(null, set_coefficient = 0.5)
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		if(console.experiment.points >= objective.target_amount)
			to_chat(world, "<span class='greenannounce'>[team_name] team fulfilled its mission!</span>")
		else
			to_chat(world, "<span class='boldannounce'>[team_name] team failed its mission.</span>")
	..()
	return 1

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

//Landmarks
// TODO: Split into separate landmarks for prettier ships
/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
/datum/objective/experiment
	target_amount = 6
	var/team

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	var/ab_team = team
	if(owner)
		if(!owner.current || !ishuman(owner.current))
			return 0
		var/mob/living/carbon/human/H = owner.current
		if(H.dna.species.id != "abductor")
			return 0
		var/datum/species/abductor/S = H.dna.species
		ab_team = S.team
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return 1
			else
				return 0
	return 0

/datum/game_mode/proc/update_abductor_icons_added(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, ((alien_mind in abductors) ? "abductor" : "abductee"))

/datum/game_mode/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)
