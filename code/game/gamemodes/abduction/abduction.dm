/datum/game_mode
	var/list/datum/mind/abductors = list()

/datum/game_mode/abduction
	name = "Abduction"
	config_tag = "abduction"
	antag_flag = BE_ABDUCTOR
	recommended_enemies = 2
	required_players = 15
	var/max_teams = 4
	var/teams = 1
	var/list/datum/mind/scientists = list()
	var/list/datum/mind/agents = list()
	var/list/datum/objective/team_objectives = list()
	var/list/team_names = list()
	var/finished = 0

/datum/game_mode/abduction/announce()
	world << "<B>The current game mode is - Abduction!</B>"

/datum/game_mode/abduction/pre_setup()
	teams = max(1, min(max_teams,round(num_players()/config.abductor_scaling_coeff)))
	var/possible_teams = max(1,round(antag_candidates.len / 2))
	teams = min(teams,possible_teams)

	abductors.len = 2*teams
	scientists.len = teams
	agents.len = teams
	team_objectives.len = teams
	team_names.len = teams

	for(var/i=1,i<=teams,i++)
		if(!make_abductor_team(i))
			return 0

	return 1

/datum/game_mode/abduction/proc/make_abductor_team(var/team_number,var/preset_agent=null,var/preset_scientist=null)
	//Team Name
	team_names[team_number] = "Mothership [pick(possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
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


	scientist.assigned_role = "MODE"
	scientist.special_role = "Abductor"
	log_game("[scientist.key] (ckey) has been selected as an abductor team [team_number] scientist.")

	agent.assigned_role = "MODE"
	agent.special_role = "Abductor"
	log_game("[agent.key] (ckey) has been selected as an abductor team [team_number] agent.")

	abductors |= agent
	abductors |= scientist
	scientists[team_number] = scientist
	agents[team_number] = agent
	return 1

/datum/game_mode/abduction/post_setup()
	//Spawn Team
	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/team_name
	var/mob/living/carbon/human/H
	var/datum/species/abductor/S
	for(var/team_number=1,team_number<=teams,team_number++)
		team_name = team_names[team_number]
		agent = agents[team_number]
		H = agent.current
		L = agent_landmarks[team_number]
		H.loc = L.loc
		hardset_dna(H, null, null, null, null, /datum/species/abductor)
		S = H.dna.species
		S.agent = 1
		S.team = team_number
		H.real_name = team_name + " Agent"
		equip_common(H,team_number)
		equip_agent(H,team_number)
		greet_agent(agent,team_number)
		H.regenerate_icons()

		scientist = scientists[team_number]
		H = scientist.current
		L = scientist_landmarks[team_number]
		H.loc = L.loc
		hardset_dna(H, null, null, null, null, /datum/species/abductor)
		S = H.dna.species
		S.scientist = 1
		S.team = team_number
		H.real_name = team_name + " Scientist"
		equip_common(H,team_number)
		equip_scientist(H,team_number)
		greet_scientist(scientist,team_number)
		H.regenerate_icons()
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(var/team_number)
	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/team_name
	var/mob/living/carbon/human/H
	var/datum/species/abductor/S

	team_name = team_names[team_number]
	agent = agents[team_number]
	H = agent.current
	L = agent_landmarks[team_number]
	H.loc = L.loc
	hardset_dna(H, null, null, null, null, /datum/species/abductor)
	S = H.dna.species
	S.agent = 1
	S.team = team_number
	H.real_name = team_name + " Agent"
	equip_common(H,team_number)
	equip_agent(H,team_number)
	greet_agent(agent,team_number)
	H.regenerate_icons()

	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.loc = L.loc
	hardset_dna(H, null, null, null, null, /datum/species/abductor)
	S = H.dna.species
	S.scientist = 1
	S.team = team_number
	H.real_name = team_name + " Scientist"
	equip_common(H,team_number)
	equip_scientist(H,team_number)
	greet_scientist(scientist,team_number)
	H.regenerate_icons()


/datum/game_mode/abduction/proc/greet_agent(var/datum/mind/abductor,var/team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	abductor.current << "<span class='notice'>You are an Abductor Agent of [team_name]!</span>"
	abductor.current << "<span class='notice'>With the help of your teammate kidnap and experiment on station members!</span>"
	abductor.current << "<span class='notice'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>"

	var/obj_count = 1
	for(var/datum/objective/objective in abductor.objectives)
		abductor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/abduction/proc/greet_scientist(var/datum/mind/abductor,var/team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	abductor.current << "<span class='notice'>You are an Abductor Scientist of [team_name]!</span>"
	abductor.current << "<span class='notice'>With the help of your teammate kidnap and experiment on station members!</span>"
	abductor.current << "<span class='notice'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>"

	var/obj_count = 1
	for(var/datum/objective/objective in abductor.objectives)
		abductor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/abduction/proc/equip_common(var/mob/living/carbon/human/agent,var/team_number)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
	R.set_frequency(radio_freq)
	agent.equip_to_slot_or_del(R, slot_ears)
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(agent), slot_shoes)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), slot_w_uniform) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), slot_back)

/datum/game_mode/abduction/proc/get_team_console(var/team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in machines)
		if(c.team == team)
			console = c
			break
	return console

/datum/game_mode/abduction/proc/equip_agent(var/mob/living/carbon/human/agent,var/team_number)
	if(!team_number)
		var/datum/species/abductor/S = agent.dna.species
		team_number = S.team

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(agent)
	if(console!=null)
		console.vest = V
		V.flags |= NODROP
	agent.equip_to_slot_or_del(V, slot_wear_suit)
	agent.equip_to_slot_or_del(new /obj/item/weapon/abductor_baton(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/decloner/alien(agent), slot_belt)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), slot_head)


/datum/game_mode/abduction/proc/equip_scientist(var/mob/living/carbon/human/scientist,var/team_number)
	if(!team_number)
		var/datum/species/abductor/S = scientist.dna.species
		team_number = S.team

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(scientist)
	if(console!=null)
		console.gizmo = G
		G.console = console
	scientist.equip_to_slot_or_del(G, slot_in_backpack)

	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(scientist)
	beamplant.imp_in = scientist
	beamplant.implanted = 1
	beamplant.implanted(scientist)
	beamplant.home = console.pad


/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number=1,team_number<=teams,team_number++)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if (con.experiment.points > objective.target_amount)
				SSshuttle.emergency.request(null, 0.5)
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	world << "<br><font size=3><b>The Abductors were:</b></font>"
	for(var/team_number=1,team_number<=teams,team_number++)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		var/datum/mind/amind = agents[team_number]
		var/datum/mind/smind = scientists[team_number]
		var/mob/living/carbon/human/agent = amind.current
		var/mob/living/carbon/human/scientist = smind.current
		if (console.experiment.points > objective.target_amount)
			world << "<font size = 3 color='green'><b>[team_name] team fullfilled its mission! </b></font>"
			world << "<b>Team Members : [agent.name]([agent.ckey]),[scientist.name]([scientist.ckey])</b>"
		else
			world << "<font size = 3 color='red'><b>[team_name] team failed its mission! </b></font>"
			world << "<b>Team Members</b>: [agent.name]([agent.ckey])<br>[scientist.name]([scientist.ckey])"

		world <<  "<br><font size=2><b>The Abductees were:</b></font>"
		display_abductees(console)

	..()
	return 1

/datum/game_mode/abduction/proc/display_abductees(var/obj/machinery/abductor/console/console)
	var/list/mob/living/abductees = console.experiment.history
	for(var/mob/living/abductee in abductees)
		if(!abductee.mind)
			continue
		world << printplayer(abductee.mind)
		world << printobjectives(abductee.mind)

/datum/game_mode/proc/auto_declare_completion_abduction()
	if(abductors.len && ticker.mode.config_tag != "abduction") // no repeating for the gamemode
		world << "<br><font size=3><b>The Abductors were:</b></font>"
		for(var/datum/mind/M in abductors)
			world << "<font size = 2><b>Abductor [M.current ? M.current.name : "Abductor"]([M.key])</b></font>"
			world << printobjectives(M)
		world << "<br><font size=3><b>The Abductees were:</b></font>"
		var/list/full_history = list()
		for(var/obj/machinery/abductor/console/C in machines)
			full_history |= C.experiment.history
		for(var/mob/living/abductee in full_history)
			if(!abductee.mind)
				continue
			world << printplayer(abductee.mind)
			world << printobjectives(abductee.mind)
	return

//Landmarks
// TODO: Split into seperate landmarks for prettier ships
/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/console/New()
	var/obj/machinery/abductor/console/c = new /obj/machinery/abductor/console(src.loc)
	c.team = team

	spawn(5) // I'd do this properly when i got some time, temporary hack for mappers
		c.Initialize()
	qdel(src)


/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
/datum/objective/experiment
	dangerrating = 10
	target_amount = 6
	var/team

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans"

/datum/objective/experiment/check_completion()
	if(!owner.current || !ishuman(owner.current))
		return 0
	var/mob/living/carbon/human/H = owner.current
	if(!H.dna || !H.dna.species || !(H.dna.species.id == "abductor"))
		return 0
	var/datum/species/abductor/S = H.dna.species
	var/ab_team = S.team
	for(var/obj/machinery/abductor/experiment/E in machines)
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return 1
			else
				return 0
	return 0

/datum/objective/abductee
	dangerrating = 5
	completed = 1

/datum/objective/abductee/steal
	explanation_text = "Steal all"

/datum/objective/abductee/steal/New()
	var/target = pick(list("Pets","Lights","Monkeys","Fruits","Shoes","Soap Bars"))
	explanation_text+=" [target]"

/datum/objective/abductee/capture
	explanation_text = "Capture"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjob.occupations
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " \a [target.title]."
	else
		explanation_text += " someone."

/datum/objective/abductee/shuttle
	explanation_text = "You must escape the station! Get the shuttle called!"

/datum/objective/abductee/noclone
	explanation_text = "Don't allow anyone to be cloned."