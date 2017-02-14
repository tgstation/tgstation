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
	world << "<B>The current game mode is - Abduction!</B>"
	world << "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!"
	world << "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones."
	world << "<b>Crew</b> - don't get abducted and stop the abductors."

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
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		team_name = team_names[team_number]
		agent = agents[team_number]
		H = agent.current
		L = agent_landmarks[team_number]
		H.loc = L.loc
		H.set_species(/datum/species/abductor)
		S = H.dna.species
		S.agent = 1
		S.team = team_number
		H.real_name = team_name + " Agent"
		equip_common(H,team_number)
		equip_agent(H,team_number)
		greet_agent(agent,team_number)

		scientist = scientists[team_number]
		H = scientist.current
		L = scientist_landmarks[team_number]
		H.loc = L.loc
		H.set_species(/datum/species/abductor)
		S = H.dna.species
		S.scientist = 1
		S.team = team_number
		H.real_name = team_name + " Scientist"
		equip_common(H,team_number)
		equip_scientist(H,team_number)
		greet_scientist(scientist,team_number)
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(team_number)
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
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.agent = 1
	S.team = team_number
	H.real_name = team_name + " Agent"
	equip_common(H,team_number)
	equip_agent(H,team_number)
	greet_agent(agent,team_number)


	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.loc = L.loc
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.scientist = 1
	S.team = team_number
	H.real_name = team_name + " Scientist"
	equip_common(H,team_number)
	equip_scientist(H,team_number)
	greet_scientist(scientist,team_number)



/datum/game_mode/abduction/proc/greet_agent(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	abductor.current << "<span class='notice'>You are an agent of [team_name]!</span>"
	abductor.current << "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>"
	abductor.current << "<span class='notice'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>"

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/greet_scientist(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	abductor.current << "<span class='notice'>You are a scientist of [team_name]!</span>"
	abductor.current << "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>"
	abductor.current << "<span class='notice'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>"

	abductor.announce_objectives()

/datum/game_mode/abduction/proc/equip_common(mob/living/carbon/human/agent,team_number)
	var/radio_freq = SYND_FREQ

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
	R.set_frequency(radio_freq)
	agent.equip_to_slot_or_del(R, slot_ears)
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(agent), slot_shoes)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), slot_w_uniform) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), slot_back)

/datum/game_mode/abduction/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in machines)
		if(c.team == team)
			console = c
			break
	return console

/datum/game_mode/abduction/proc/equip_agent(mob/living/carbon/human/agent,team_number)
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
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/alien(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), slot_head)
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/military/abductor/full(agent), slot_belt)


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
	beamplant.implant(scientist)


/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number=1,team_number<=abductor_teams,team_number++)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if (con.experiment.points >= objective.target_amount)
				SSshuttle.emergency.request(null, 0.5)
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		if(console.experiment.points >= objective.target_amount)
			world << "<span class='greenannounce'>[team_name] team fulfilled its mission!</span>"
		else
			world << "<span class='boldannounce'>[team_name] team failed its mission.</span>"
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
	world << text

//Landmarks
// TODO: Split into seperate landmarks for prettier ships
/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/console/New()
	var/obj/machinery/abductor/console/c = new /obj/machinery/abductor/console(src.loc)
	c.team = team

	spawn(5) // I'd do this properly when i got some time, temporary hack for mappers
		c.Setup()
	qdel(src)


/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
/datum/objective/experiment
	dangerrating = 10
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
	for(var/obj/machinery/abductor/experiment/E in machines)
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return 1
			else
				return 0
	return 0

/datum/game_mode/proc/update_abductor_icons_added(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, ((alien_mind in abductors) ? "abductor" : "abductee"))

/datum/game_mode/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)

/datum/objective/abductee
	dangerrating = 5
	completed = 1

/datum/objective/abductee/steal
	explanation_text = "Steal all"

/datum/objective/abductee/steal/New()
	var/target = pick(list("pets","lights","monkeys","fruits","shoes","bars of soap"))
	explanation_text+=" [target]."

/datum/objective/abductee/capture
	explanation_text = "Capture"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjob.occupations.Copy()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title]."
	else
		explanation_text += " someone."

/datum/objective/abductee/shuttle
	explanation_text = "You must escape the station! Get the shuttle called!"

/datum/objective/abductee/noclone
	explanation_text = "Don't allow anyone to be cloned."

/datum/objective/abductee/oxygen
	explanation_text = "The oxygen is killing them all and they don't even know it. Make sure no oxygen is on the station."

/datum/objective/abductee/blazeit
	explanation_text = "Your body must be improved. Ingest as many drugs as you can."

/datum/objective/abductee/yumyum
	explanation_text = "You are hungry. Eat as much food as you can find."

/datum/objective/abductee/insane
	explanation_text = "You see you see what they cannot you see the open door you seeE you SEeEe you SEe yOU seEee SHOW THEM ALL"

/datum/objective/abductee/cannotmove
	explanation_text = "Convince the crew that you are a paraplegic."

/datum/objective/abductee/deadbodies
	explanation_text = "Start a collection of corpses. Don't kill people to get these corpses."

/datum/objective/abductee/floors
	explanation_text = "Replace all the floor tiles with carpeting, wooden boards, or grass."

/datum/objective/abductee/POWERUNLIMITED
	explanation_text = "Flood the station's powernet with as much electricity as you can."

/datum/objective/abductee/pristine
	explanation_text = "Ensure the station is in absolutely pristine condition."

/datum/objective/abductee/window
	explanation_text = "Replace all normal windows with reinforced windows."

/datum/objective/abductee/nations
	explanation_text = "Ensure your department prospers over all else."

/datum/objective/abductee/abductception
	explanation_text = "You have been changed forever. Find the ones that did this to you and give them a taste of their own medicine."

/datum/objective/abductee/ghosts
	explanation_text = "Conduct a seance with the spirits of the afterlife."

/datum/objective/abductee/summon
	explanation_text = "Conduct a ritual to summon an elder god."

/datum/objective/abductee/machine
	explanation_text = "You are secretly an android. Interface with as many machines as you can to boost your own power."

/datum/objective/abductee/prevent
	explanation_text = "You have been enlightened. This knowledge must not escape. Ensure nobody else can become enlightened."

/datum/objective/abductee/calling
	explanation_text = "Call forth a spirit from the other side."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(D)
		explanation_text = "You know that [D] has perished. Call them from the spirit realm."

/datum/objective/abductee/social_experiment
	explanation_text = "This is a secret social experiment conducted by Nanotrasen. Convince the crew that this is the truth."

/datum/objective/abductee/vr
	explanation_text = "It's all an entirely virtual simulation within an underground vault. Convince the crew to escape the shackles of VR."

/datum/objective/abductee/pets
	explanation_text = "Nanotrasen is abusing the animals! Save as many as you can!"

/datum/objective/abductee/defect
	explanation_text = "Defect from your employer."

/datum/objective/abductee/promote
	explanation_text = "Climb the corporate ladder all the way to the top!"

/datum/objective/abductee/science
	explanation_text = "So much lies undiscovered. Look deeper into the machinations of the universe."

/datum/objective/abductee/build
	explanation_text = "Expand the station."

/datum/objective/abductee/pragnant
	explanation_text = "You are pregnant and soon due. Find a safe place to deliver your baby."

/datum/objective/abductee/engine
	explanation_text = "Go have a good conversation with the Singularity/Tesla/Supermatter crystal. Bonus points if it responds."
	
/datum/objective/abductee/teamredisbetterthangreen
	explanation_text = "Tell the AI (or a borg/pAI/drone if there is no AI) some corny technology jokes until it cries for help."
	
/datum/objective/abductee/time
	explanation_text = "Go bug a bronze worshipper to give you a clock."
		
/datum/objective/abductee/licky
	explanation_text = "You must lick anything that you find interesting."
	
/datum/objective/abductee/music
	explanation_text = "Start playing music, you're the best musician ever. If anyone hates it, beat them on the head with your instrument!"
	
