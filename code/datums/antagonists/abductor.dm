/datum/antagonist/abductor
	name = "Abductor"
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
