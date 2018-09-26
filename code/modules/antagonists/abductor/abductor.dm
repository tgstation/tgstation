#define ABDUCTOR_MAX_TEAMS 4

/datum/antagonist/abductor
	name = "Abductor"
	roundend_category = "abductors"
	antagpanel_category = "Abductor"
	job_rank = ROLE_ABDUCTOR
	show_in_antagpanel = FALSE //should only show subtypes
	var/datum/team/abductor_team/team
	var/sub_role
	var/outfit
	var/landmark_type
	var/greet_text


/datum/antagonist/abductor/agent
	name = "Abductor Agent"
	sub_role = "Agent"
	outfit = /datum/outfit/abductor/agent
	landmark_type = /obj/effect/landmark/abductor/agent
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."
	show_in_antagpanel = TRUE

/datum/antagonist/abductor/scientist
	name = "Abductor Scientist"
	sub_role = "Scientist"
	outfit = /datum/outfit/abductor/scientist
	landmark_type = /obj/effect/landmark/abductor/scientist
	greet_text = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."
	show_in_antagpanel = TRUE

/datum/antagonist/abductor/create_team(datum/team/abductor_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/abductor/get_team()
	return team

/datum/antagonist/abductor/on_gain()
	owner.special_role = "[name] [sub_role]"
	owner.assigned_role = "[name] [sub_role]"
	objectives += team.objectives
	finalize_abductor()
	return ..()

/datum/antagonist/abductor/on_removal()
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

	update_abductor_icons_added(owner,"abductor")

/datum/antagonist/abductor/scientist/finalize_abductor()
	..()
	var/mob/living/carbon/human/H = owner.current
	var/datum/species/abductor/A = H.dna.species
	A.scientist = TRUE

/datum/antagonist/abductor/admin_add(datum/mind/new_owner,mob/admin)
	var/list/current_teams = list()
	for(var/datum/team/abductor_team/T in get_all_teams(/datum/team/abductor_team))
		current_teams[T.name] = T
	var/choice = input(admin,"Add to which team ?") as null|anything in (current_teams + "new team")
	if (choice == "new team")
		team = new
	else if(choice in current_teams)
		team = current_teams[choice]
	else
		return
	new_owner.add_antag_datum(src)
	log_admin("[key_name(usr)] made [key_name(new_owner.current)] [name] on [choice]!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(new_owner.current)] [name] on [choice] !")

/datum/antagonist/abductor/get_admin_commands()
	. = ..()
	.["Equip"] = CALLBACK(src,.proc/admin_equip)

/datum/antagonist/abductor/proc/admin_equip(mob/admin)
	if(!ishuman(owner.current))
		to_chat(admin, "<span class='warning'>This only works on humans!</span>")
		return
	var/mob/living/carbon/human/H = owner.current
	var/gear = alert(admin,"Agent or Scientist Gear","Gear","Agent","Scientist")
	if(gear)
		if(gear=="Agent")
			H.equipOutfit(/datum/outfit/abductor/agent)
		else
			H.equipOutfit(/datum/outfit/abductor/scientist)

/datum/team/abductor_team
	member_name = "abductor"
	var/team_number
	var/list/datum/mind/abductees = list()
	var/static/team_count = 1

/datum/team/abductor_team/New()
	..()
	team_number = team_count++
	name = "Mothership [pick(GLOB.possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	add_objective(new/datum/objective/experiment)

/datum/team/abductor_team/is_solo()
	return FALSE

/datum/team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/team/abductor_team/roundend_report()
	var/list/result = list()

	var/won = TRUE
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			won = FALSE
	if(won)
		result += "<span class='greentext big'>[name] team fulfilled its mission!</span>"
	else
		result += "<span class='redtext big'>[name] team failed its mission.</span>"

	result += "<span class='header'>The abductors of [name] were:</span>"
	for(var/datum/mind/abductor_mind in members)
		result += printplayer(abductor_mind)
	result += printobjectives(objectives)

	return "<div class='panel redborder'>[result.Join("<br>")]</div>"

/datum/antagonist/abductee
	name = "Abductee"
	roundend_category = "abductees"
	antagpanel_category = "Abductee"

/datum/antagonist/abductee/on_gain()
	give_objective()
	. = ..()

/datum/antagonist/abductee/greet()
	to_chat(owner, "<span class='warning'><b>Your mind snaps!</b></span>")
	to_chat(owner, "<big><span class='warning'><b>You can't remember how you got here...</b></span></big>")
	owner.announce_objectives()

/datum/antagonist/abductee/proc/give_objective()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
	var/objtype = (prob(75) ? /datum/objective/abductee/random : pick(subtypesof(/datum/objective/abductee/) - /datum/objective/abductee/random))
	var/datum/objective/abductee/O = new objtype()
	objectives += O

/datum/antagonist/abductee/apply_innate_effects(mob/living/mob_override)
	update_abductor_icons_added(mob_override ? mob_override.mind : owner,"abductee")

/datum/antagonist/abductee/remove_innate_effects(mob/living/mob_override)
	update_abductor_icons_removed(mob_override ? mob_override.mind : owner)


// LANDMARKS
/obj/effect/landmark/abductor
	var/team_number = 1

/obj/effect/landmark/abductor/agent
	icon_state = "abductor_agent"
/obj/effect/landmark/abductor/scientist
	icon_state = "abductor"

// OBJECTIVES
/datum/objective/experiment
	target_amount = 6

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	for(var/obj/machinery/abductor/experiment/E in GLOB.machines)
		if(!istype(team, /datum/team/abductor_team))
			return FALSE
		var/datum/team/abductor_team/T = team
		if(E.team_number == T.team_number)
			return E.points >= target_amount
	return FALSE

/datum/antagonist/proc/update_abductor_icons_added(datum/mind/alien_mind,hud_type)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.join_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, hud_type)

/datum/antagonist/proc/update_abductor_icons_removed(datum/mind/alien_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
	hud.leave_hud(alien_mind.current)
	set_antag_hud(alien_mind.current, null)