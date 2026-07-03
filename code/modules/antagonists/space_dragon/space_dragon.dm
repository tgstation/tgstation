/datum/antagonist/space_dragon
	name = "\improper Space Dragon"
	roundend_category = "Космические драконы"
	antagpanel_category = ANTAG_GROUP_LEVIATHANS
	pref_flag = ROLE_SPACE_DRAGON
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// All space carps created by this antagonist space dragon
	var/list/datum/mind/carp = list()
	/// The innate ability to summon rifts
	var/datum/action/innate/summon_rift/rift_ability
	/// The innate ability to find where rift locations are
	var/datum/action/innate/locate_rift/locate_rift_ability
	/// Current time since the the last rift was activated.  If set to -1, does not increment.
	var/riftTimer = 0
	/// Maximum amount of time which can pass without a rift before Space Dragon despawns.
	var/maxRiftTimer = 300
	/// A list of all of the rifts created by Space Dragon.  Used for setting them all to infinite carp spawn when Space Dragon wins, and removing them when Space Dragon dies.
	var/list/obj/structure/carp_rift/rift_list = list()
	/// How many rifts have been successfully charged
	var/rifts_charged = 0
	/// Whether or not Space Dragon has completed their objective, and thus triggered the ending sequence.
	var/objective_complete = FALSE
	/// What mob to spawn from ghosts using this dragon's rifts
	var/minion_to_spawn = /mob/living/basic/carp/advanced
	/// What AI mobs to spawn from this dragon's rifts
	var/ai_to_spawn = /mob/living/basic/carp
	/// Wavespeak mind linker, to allow telepathy between dragon and carps
	var/datum/component/mind_linker/wavespeak
	/// What areas are we allowed to place rifts in?
	var/list/chosen_rift_areas = list()

/datum/antagonist/space_dragon/greet()
	. = ..()
	to_chat(owner, "<b>Мы движемся сквозь время и пространство, не смотря на их величину. Мы не помним, откуда мы явились; мы не знаем, куда мы пойдем. Весь космос принадлежит нам.\n\
					Мы являемся высшими хищниками в бездонной пустоте, и мало кто может осмелиться занять этот титул.\n\
					Но сейчас, мы лицезреем нарушителей, что борются против наших клыков с помощью немыслимой магии; их логова мелькают в глубине космоса, как маленькие огоньки.\n\
					Сегодня, мы потушим один из этих огоньков.</b>")
	to_chat(owner, span_boldwarning("У вас имеется пять минут, чтобы найти безопасное место для открытия первого разрыва. Если не успеете, вас вернет в бездну, из которой вы прибыли."))
	owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'sound/effects/magic/demon_attack1.ogg', 80)

/datum/antagonist/space_dragon/forge_objectives()
	var/static/list/area/allowed_areas
	if(!allowed_areas)
		// Areas that will prove a challeng for the dragon and are provocative to the crew.
		allowed_areas = typecacheof(list(
			/area/station/command,
			/area/station/engineering,
			/area/station/science,
			/area/station/security,
		))

	var/list/possible_areas = typecache_filter_list(get_sorted_areas(), allowed_areas)
	for(var/area/possible_area as anything in possible_areas)
		if(initial(possible_area.outdoors) || !(possible_area.area_flags & VALID_TERRITORY))
			possible_areas -= possible_area

	for(var/i in 1 to 5)
		chosen_rift_areas += pick_n_take(possible_areas)

	var/datum/objective/summon_carp/summon = new
	objectives += summon
	summon.owner = owner
	summon.update_explanation_text()

/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	rift_ability = new()
	locate_rift_ability = new()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/space_dragon))
	return ..()

/datum/antagonist/space_dragon/on_removal()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))
	return ..()

/datum/antagonist/space_dragon/apply_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	RegisterSignal(antag, COMSIG_LIVING_LIFE, PROC_REF(rift_checks))
	RegisterSignal(antag, COMSIG_LIVING_DEATH, PROC_REF(destroy_rifts))
	antag.add_faction(FACTION_CARP)
	// Give the ability over if we have one
	rift_ability?.Grant(antag)
	locate_rift_ability?.Grant(antag)
	wavespeak = antag.AddComponent( \
		/datum/component/mind_linker, \
		network_name = "Wavespeak", \
		chat_color = "#635BAF", \
		signals_which_destroy_us = list(COMSIG_LIVING_DEATH), \
		speech_action_icon = 'icons/mob/actions/actions_space_dragon.dmi', \
		speech_action_icon_state = "wavespeak", \
	)
	RegisterSignal(wavespeak, COMSIG_QDELETING, PROC_REF(clear_wavespeak))

/datum/antagonist/space_dragon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/antag = mob_override || owner.current
	UnregisterSignal(antag, COMSIG_LIVING_LIFE)
	UnregisterSignal(antag, COMSIG_LIVING_DEATH)
	antag.remove_faction(FACTION_CARP)
	rift_ability?.Remove(antag)
	locate_rift_ability?.Remove(antag)
	QDEL_NULL(wavespeak)

/datum/antagonist/space_dragon/Destroy()
	rift_list = null
	carp = null
	QDEL_NULL(rift_ability)
	QDEL_NULL(locate_rift_ability)
	QDEL_NULL(wavespeak)
	chosen_rift_areas.Cut()
	return ..()

/datum/antagonist/space_dragon/get_preview_icon()
	var/datum/universal_icon/icon = uni_icon('icons/mob/nonhuman-player/spacedragon.dmi', "spacedragon")

	icon.blend_color(COLOR_STRONG_VIOLET, ICON_MULTIPLY)
	icon.blend_icon(uni_icon('icons/mob/nonhuman-player/spacedragon.dmi', "spacedragon_overlay_base"), ICON_OVERLAY)

	icon.crop(10, 9, 54, 53)
	icon.scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/datum/antagonist/space_dragon/proc/clear_wavespeak()
	SIGNAL_HANDLER
	wavespeak = null

/**
 * Checks to see if we need to do anything with the current state of the dragon's rifts.
 *
 * A simple update check which sees if we need to do anything based on the current state of the dragon's rifts.
 *
 */
/datum/antagonist/space_dragon/proc/rift_checks()
	if((rifts_charged == 3 || (SSshuttle.emergency.mode == SHUTTLE_DOCKED && rifts_charged > 0)) && !objective_complete)
		victory()
		return
	if(riftTimer == -1)
		return
	riftTimer = min(riftTimer + 1, maxRiftTimer + 1)
	if(riftTimer == (maxRiftTimer - 60))
		to_chat(owner.current, span_boldwarning("У вас осталась минута, чтобы открыть разрыв! Скорее!"))
		return
	if(riftTimer >= maxRiftTimer)
		to_chat(owner.current, span_boldwarning("Вы не успели огкрыть разрыв! Бездна затягивает вас обратно!"))
		destroy_rifts()
		SEND_SOUND(owner.current, sound('sound/effects/magic/demon_dies.ogg'))
		owner.current.death(/* gibbed = */ TRUE)
		QDEL_NULL(owner.current)

/**
 * Destroys all of Space Dragon's current rifts.
 *
 * QDeletes all the current rifts after removing their references to other objects.
 * Currently, the only reference they have is to the Dragon which created them, so we clear that before deleting them.
 * Currently used when Space Dragon dies or one of his rifts is destroyed.
 */
/datum/antagonist/space_dragon/proc/destroy_rifts()
	if(objective_complete)
		return
	rifts_charged = 0
	ADD_TRAIT(owner.current, TRAIT_RIFT_FAILURE, REF(src))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_depression)
	riftTimer = -1
	SEND_SOUND(owner.current, sound('sound/vehicles/rocketlaunch.ogg'))
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.dragon = null
		rift_list -= rift
		if(!QDELETED(rift))
			QDEL_NULL(rift)

/**
 * Sets up Space Dragon's victory for completing the objectives.
 *
 * Triggers when Space Dragon completes his objective.
 * Calls the shuttle with a coefficient of 3, making it impossible to recall.
 * Sets all of his rifts to allow for infinite sentient carp spawns
 * Also plays appropriate sounds and CENTCOM messages.
 */
/datum/antagonist/space_dragon/proc/victory()
	objective_complete = TRUE
	permanant_empower()
	var/datum/objective/summon_carp/main_objective = locate() in objectives
	main_objective?.completed = TRUE
	priority_announce("Огромное количество форм жизни надвигается в сторону [station_name()] с невероятной скоростью. \
		Оставшемуся экипажу необходимо эвакуироваться как можно скорее.", "[command_name()]: Отдел Изучения Дикой Природы", has_important_message = TRUE)
	sound_to_playing_players('sound/mobs/non-humanoids/space_dragon/space_dragon_roar.ogg', volume = 75)
	for(var/obj/structure/carp_rift/rift as anything in rift_list)
		rift.carp_stored = 999999
		rift.time_charged = rift.max_charge

/**
 * Gives Space Dragon their the rift speed buff permanently and fully heals the user.
 *
 * Gives Space Dragon the enraged speed buff from charging rifts permanently.
 * Only happens in circumstances where Space Dragon completes their objective.
 * Also gives them a full heal.
 */
/datum/antagonist/space_dragon/proc/permanant_empower()
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = COLOR_CARP_RIFT_RED, "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/**
 * Handles Space Dragon's temporary empowerment after boosting a rift.
 *
 * Empowers and depowers Space Dragon after a successful rift charge.
 * Empowered, Space Dragon regains all his health and becomes temporarily faster for 30 seconds, along with being tinted red.
 */
/datum/antagonist/space_dragon/proc/rift_empower()
	owner.current.fully_heal()
	owner.current.add_filter("anger_glow", 3, list("type" = "outline", "color" = COLOR_CARP_RIFT_RED, "size" = 5))
	owner.current.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	addtimer(CALLBACK(src, PROC_REF(rift_depower)), 30 SECONDS)

/**
 * Removes Space Dragon's rift speed buff.
 *
 * Removes Space Dragon's speed buff from charging a rift.  This is only called
 * in rift_empower, which uses a timer to call this after 30 seconds.  Also
 * removes the red glow from Space Dragon which is synonymous with the speed buff.
 */
/datum/antagonist/space_dragon/proc/rift_depower()
	owner.current.remove_filter("anger_glow")
	owner.current.remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/datum/objective/summon_carp
	explanation_text = "Откройте 3 разлома, чтобы заполнить всю станцию карпами."

/datum/objective/summon_carp/update_explanation_text()
	var/datum/antagonist/space_dragon/dragon_owner = owner.has_antag_datum(/datum/antagonist/space_dragon)
	if(isnull(dragon_owner))
		return

	var/list/converted_names = list()
	for(var/area/possible_area as anything in dragon_owner.chosen_rift_areas)
		converted_names += possible_area.get_original_area_name()

	explanation_text = initial(explanation_text)
	explanation_text += " Возможные места для разломов: [english_list(converted_names)]"

/datum/antagonist/space_dragon/roundend_report()
	var/list/parts = list()
	var/datum/objective/summon_carp/S = locate() in objectives
	if(S.check_completion())
		parts += "<span class='redtext big'>[name] - успех! Космические карпы вернули контроль над территорией расположения станции!</span>"
	parts += printplayer(owner)
	var/objectives_complete = TRUE
	if(objectives.len)
		parts += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(objectives_complete)
		parts += "<span class='greentext big'>[name] преуспел!</span>"
	else
		parts += "<span class='redtext big'>[name] провалился!</span>"

	if(length(carp))
		parts += span_header("<br>Помощники [name]:")
		parts += "<ul class='playerlist'>"
		var/list/players_to_carp_taken = list()
		for(var/datum/mind/carpy as anything in carp)
			players_to_carp_taken[carpy.key] += 1
		var/list = ""
		for(var/carp_user in players_to_carp_taken)
			list += "<li><b>[carp_user]</b>, был космическим карпом <b>[players_to_carp_taken[carp_user]]</b> раз.</li>"
		parts += list
		parts += "</ul>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
