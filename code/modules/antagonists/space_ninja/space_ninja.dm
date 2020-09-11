/datum/antagonist/ninja
	name = "Space Ninja"
	antagpanel_category = "Space Ninja"
	job_rank = ROLE_NINJA
	antag_hud_type = ANTAG_HUD_NINJA
	antag_hud_name = "space_ninja"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	var/give_objectives = TRUE
	var/give_equipment = TRUE

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/ninja = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, ninja)

/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/ninja = mob_override || owner.current
	remove_antag_hud(antag_hud_type, ninja)

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/ninja = owner.current)
	return ninja.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite mercenary of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>"
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by clicking the initialize UI button, to use abilities like stealth)!<br>"

/datum/objective/cyborg_hijack
	explanation_text = "Use your gloves to convert a cyborg to aide you in sabotaging the station."
	
/datum/objective/door_jack
	var/doors_required = 0

/datum/objective/plant_explosive
	var/area/detonation_location = null

/datum/objective/security_scramble
	explanation_text = "Use your gloves on a security console to set everyone to arrest.  Note that the AI will be alerted once you begin!"
	
/datum/objective/terror_message
	explanation_text = "Use your gloves on a communication console to announce a fake warning from Centcom."

/datum/antagonist/ninja/proc/addObjectives()
	//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
	var/datum/objective/hijack = new /datum/objective/cyborg_hijack()
	objectives += hijack
	
	//Research stealing
	var/datum/objective/download/research = new /datum/objective/download()
	research.owner = owner
	research.gen_amount_goal()
	objectives += research
	
	//Door jacks, flag will be set to complete on when the last door is hijacked
	var/datum/objective/door_jack/doorobjective = new /datum/objective/door_jack()
	doorobjective.doors_required = rand(15,40)
	doorobjective.explanation_text = "Use your gloves to doorjack [doorobjective.doors_required] airlocks on the station."
	objectives += doorobjective
	
	//Explosive plant, the bomb will register its completion on priming
	var/datum/objective/plant_explosive/bombobjective = new /datum/objective/plant_explosive()
	for(var/sanity in 1 to 100) // 100 checks at most.
		var/area/selected_area = pick(GLOB.sortedAreas)
		if(!is_station_level(selected_area.z) || !(selected_area.area_flags & VALID_TERRITORY))
			continue
		bombobjective.detonation_location = selected_area
		break
	if(bombobjective.detonation_location)
		bombobjective.explanation_text = "Detonate your starter bomb in [bombobjective.detonation_location].  Note that the bomb will not work anywhere else!"
		objectives += bombobjective

	//Security Scramble, set to complete upon using your gloves on a security console
	var/datum/objective/securityobjective = new /datum/objective/security_scramble()
	objectives += securityobjective

	//Message of Terror, set to complete upon using your gloves a communication console
	var/datum/objective/communicationobjective = new /datum/objective/terror_message()
	objectives += communicationobjective

	//Survival until end
	var/datum/objective/survival = new /datum/objective/survive()
	survival.owner = owner
	objectives += survival

/proc/remove_ninja(mob/living/ninja)
	if(!ninja || !ninja.mind)
		return FALSE
	var/datum/antagonist/datum = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	datum.on_removal()
	return TRUE

/proc/is_ninja(mob/living/possible_ninja)
	return possible_ninja && possible_ninja.mind && possible_ninja.mind.has_antag_datum(/datum/antagonist/ninja)

/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	owner.announce_objectives()

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
	if(give_equipment)
		equip_space_ninja(owner.current)
	return ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_NINJA
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'ed [key_name(new_owner)].")
