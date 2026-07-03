/datum/antagonist/ninja
	name = "\proper Космический Ниндзя"
	antagpanel_category = ANTAG_GROUP_NINJAS
	pref_flag = ROLE_NINJA
	antag_hud_name = "ninja"
	hijack_speed = 1
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "ЗА КЛАН ПАУКА!!"
	preview_outfit = /datum/outfit/ninja_preview
	can_assign_self_objectives = TRUE
	ui_name = "AntagInfoNinja"
	default_custom_objective = "Уничтожьте жизненно важную инфраструктуру станции, оставаясь незамеченным."
	desensitized_modifier = DESENSITIZED_THRESHOLD
	///Whether or not this ninja will obtain objectives
	var/give_objectives = TRUE

/**
 * Proc that equips the space ninja outfit on a given individual.  By default this is the owner of the antagonist datum.
 *
 * Proc that equips the space ninja outfit on a given individual.  By default this is the owner of the antagonist datum.
 * Arguments:
 * * ninja - The human to receive the gear
 * * Returns a proc call on the given human which will equip them with all the gear.
 */
/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/ninja = owner.current)
	return ninja.equip_species_outfit(/datum/outfit/ninja)

/**
 * Proc that adds the proper memories to the antag datum
 *
 * Proc that adds the ninja starting memories to the owner of the antagonist datum.
 */
/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "Я - элитный наёмник из могущественного клана Паука. <font color='red'><B>КОСМИЧЕСКИЙ НИНДЗЯ</B></font>!<br>"
	antag_memory += "Неожиданность - мое оружие. Тень - моя броня. Без них, Я - ничто.<br>"

/datum/objective/cyborg_hijack
	explanation_text = "Используйте свои перчатки, чтобы конвертировать хотя бы одного киборга, для оказания помощи в ваших задачах."

/datum/objective/door_jack
	///How many doors that need to be opened using the gloves to pass the objective
	var/doors_required = 0

/datum/objective/plant_explosive
	var/area/detonation_location

/datum/objective/security_scramble
	explanation_text = "Используйте перчатки на консоли безопасности хотя бы один раз, чтобы установить арест на всех. Помните, что ИИ будет предупрежден, как только вы начнете!"

/datum/objective/terror_message
	explanation_text = "Используйте свои перчатки на консоли коммуникации, чтобы навлечь на станцию еще одну угрозу. Помните, что ИИ будет предупрежден, как только вы начнете!"

/datum/objective/research_secrets
	explanation_text = "Используйте свои перчатки на сервере РНД, чтобы саботировать исследовательские проекты. Помните, что ИИ будет предупрежден, как только вы начнете!"

/**
 * Proc that adds all the ninja's objectives to the antag datum.
 *
 * Proc that adds all the ninja's objectives to the antag datum.  Called when the datum is gained.
 */
/datum/antagonist/ninja/proc/addObjectives()
	//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
	var/datum/objective/hijack = new /datum/objective/cyborg_hijack()
	objectives += hijack

	// Break into science and mess up their research. Only add this objective if the similar steal objective is possible.
	var/datum/objective/research_secrets/sabotage_research = new /datum/objective/research_secrets()
	objectives += sabotage_research

	//Door jacks, flag will be set to complete on when the last door is hijacked
	var/datum/objective/door_jack/doorobjective = new /datum/objective/door_jack()
	doorobjective.doors_required = rand(15,40)
	doorobjective.explanation_text = "Используйте свои перчатки, чтобы взломать [doorobjective.doors_required] шлюзов на станции."
	objectives += doorobjective

	//Explosive plant, the bomb will register its completion on priming
	var/datum/objective/plant_explosive/bombobjective = new /datum/objective/plant_explosive()
	for(var/sanity in 1 to 100) // 100 checks at most.
		var/area/selected_area = pick(GLOB.areas)
		if(!is_station_level(selected_area.z) || !(selected_area.area_flags & VALID_TERRITORY))
			continue
		bombobjective.detonation_location = selected_area
		break
	if(bombobjective.detonation_location)
		bombobjective.explanation_text = "Взорвите выданную вам бомбу в [bombobjective.detonation_location].  Учтите, что бомба не будет работать в любом другом месте!"
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
	. = ..()
	SEND_SOUND(owner.current, sound('sound/music/antag/ninja_greeting.ogg'))
	to_chat(owner.current, span_danger("Я элитный наёмник из могущественного клана Паука!"))
	to_chat(owner.current, span_warning("Неожиданность - мое оружие. Тень - моя броня. Без них, Я - ничто."))
	to_chat(owner.current, span_notice("Станция находится в [dir2text(get_dir(owner.current, locate(world.maxx/2, world.maxy/2, owner.current.z)))]. Брошенный сюрикен станет отличным способом попасть туда."))
	owner.announce_objectives()

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
	equip_space_ninja(owner.current)
	owner.current.add_quirk(/datum/quirk/freerunning, announce = FALSE)
	owner.current.add_quirk(/datum/quirk/light_step, announce = FALSE)
	owner.current.mind.set_assigned_role(SSjob.get_job_type(/datum/job/space_ninja))
	return ..()

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.set_assigned_role(SSjob.get_job_type(/datum/job/space_ninja))
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has ninja'ed [key_name(new_owner)].")

/datum/antagonist/ninja/on_respawn(mob/new_character)
	equip_space_ninja()
	var/turf/spawnpoint = find_space_spawn()
	if(spawnpoint)
		new_character.forceMove(spawnpoint)
	return TRUE
