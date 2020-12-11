/datum/antagonist/ninja
	name = "Space Ninja"
	antagpanel_category = "Space Ninja"
	job_rank = ROLE_NINJA
	antag_hud_type = ANTAG_HUD_NINJA
	antag_hud_name = "space_ninja"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	///Whether or not this ninja will obtain objectives
	var/give_objectives = TRUE
	///Whether or not this ninja receives the standard equipment
	var/give_equipment = TRUE

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/ninja = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, ninja)

/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/ninja = mob_override || owner.current
	remove_antag_hud(antag_hud_type, ninja)

/**
 * Proc that equips the space ninja outfit on a given individual.  By default this is the owner of the antagonist datum.
 *
 * Proc that equips the space ninja outfit on a given individual.  By default this is the owner of the antagonist datum.
 * Arguments:
 * * ninja - The human to receive the gear
 * * Returns a proc call on the given human which will equip them with all the gear.
 */
/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/ninja = owner.current)
	return ninja.equipOutfit(/datum/outfit/ninja)

/**
 * Proc that adds the proper memories to the antag datum
 *
 * Proc that adds the ninja starting memories to the owner of the antagonist datum.
 */
/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite mercenary of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>"
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by clicking the initialize UI button, to use abilities like stealth)!<br>"

/datum/objective/cyborg_hijack
	explanation_text = "Use your gloves to convert at least one cyborg to aide you in sabotaging the station."

/datum/objective/door_jack
	///How many doors that need to be opened using the gloves to pass the objective
	var/doors_required = 0

/datum/objective/plant_explosive
	var/area/detonation_location

/datum/objective/security_scramble
	explanation_text = "Use your gloves on a security console to set everyone to arrest at least once.  Note that the AI will be alerted once you begin!"

/datum/objective/terror_message
	explanation_text = "Use your gloves on a communication console in order to bring another threat to the station.  Note that the AI will be alerted once you begin!"

/**
 * Proc that adds all the ninja's objectives to the antag datum.
 *
 * Proc that adds all the ninja's objectives to the antag datum.  Called when the datum is gained.
 */
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

	owner.current.mind.assigned_role = ROLE_NINJA
	owner.current.mind.special_role = ROLE_NINJA
	return ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_NINJA
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'ed [key_name(new_owner)].")
