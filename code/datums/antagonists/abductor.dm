/datum/antagonist/abductor
	name = "Abductor"
	roundend_category = "abductors"
	job_rank = ROLE_ABDUCTOR
	var/datum/objective_team/abductor_team/team
	var/sub_role
	var/outfit
	var/landmark_type
	var/greet_text

/datum/antagonist/abductor/agent
	sub_role = "Agent"
	outfit = /datum/outfit/abductor/agent
	landmark_type = /obj/effect/landmark/abductor/agent
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."

/datum/antagonist/abductor/scientist
	sub_role = "Scientist"
	outfit = /datum/outfit/abductor/scientist
	landmark_type = /obj/effect/landmark/abductor/scientist
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."

/datum/antagonist/abductor/create_team(datum/objective_team/abductor_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/abductor/get_team()
	return team

/datum/antagonist/abductor/on_gain()
	SSticker.mode.abductors += owner
	owner.special_role = "[name] [sub_role]"
	owner.objectives += team.objectives
	finalize_abductor()
	return ..()

/datum/antagonist/abductor/on_removal()
	SSticker.mode.abductors -= owner
	owner.objectives -= team.objectives
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>You are no longer the [owner.special_role]!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/abductor/greet()
	to_chat(owner.current, "<span class='notice'>You are the [owner.special_role]!</span>")
	to_chat(owner.current, "<span class='notice'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(owner.current, "<span class='notice'>[greet_text]</span>")
	owner.announce_objectives()

/datum/antagonist/abductor/proc/finalize_abductor()
	//Equip
	var/mob/living/carbon/human/H = owner.current
	H.set_species(/datum/species/abductor)
	H.real_name = "[team.name] [sub_role]"
	H.equipOutfit(outfit)

	//Teleport to ship
	for(var/obj/effect/landmark/abductor/LM in GLOB.landmarks_list)
		if(istype(LM, landmark_type) && LM.team_number == team.team_number)
			H.forceMove(LM.loc)
			break

	SSticker.mode.update_abductor_icons_added(owner)

/datum/antagonist/abductor/scientist/finalize_abductor()
	..()
	var/mob/living/carbon/human/H = owner.current
	var/datum/species/abductor/A = H.dna.species
	A.scientist = TRUE


/datum/objective_team/abductor_team
	member_name = "abductor" 
	var/team_number
	var/list/datum/mind/abductees = list()

/datum/objective_team/abductor_team/is_solo()
	return FALSE

/datum/objective_team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/objective_team/abductor_team/roundend_report()
	var/list/result = list()

	var/won = TRUE
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			won = FALSE
	if(won)
		result += "<span class='greenannounce'>[name] team fulfilled its mission!</span>"
	else
		result += "<span class='boldannounce'>[name] team failed its mission.</span>"

	result += "<span class='big'><b>The abductors of [name] were:</b></span>"
	for(var/datum/mind/abductor_mind in members)
		result += printplayer(abductor_mind)
		result += printobjectives(abductor_mind)
	if(abductees.len) //TODO: Make these proper antag datums instead
		result += "<span class='big'><b>The abductees were:</b></span>"
		for(var/datum/mind/abductee_mind in abductees)
			result += printplayer(abductee_mind)
			result += printobjectives(abductee_mind)

	return result.Join("<br>")