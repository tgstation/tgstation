/datum/antagonist/cult_of_suffering/apostate
	name = "Apostate"
	roundend_category = "cult of suffering"
	antagpanel_category = "Cult of Suffering"
	antag_hud_name = "cult_of_suffering_apostate"
	show_to_ghosts = TRUE

	/// Длительность эффекта в секундах
	var/duration = 2 MINUTES
	/// Таймер для автоматического удаления
	var/removal_timer

/datum/antagonist/cult_of_suffering/apostate/greet()
		to_chat(owner, span_cult("ГАЗ АДИУМ ЗАХВАТЫВАЕТ ТВОЙ РАЗУМ!"))
		to_chat(owner, span_cult("Боль... Гнев... УБИВАТЬ..."))
		to_chat(owner, span_cult("Цель: Убивать всех, кто не под влиянием газа!"))
		owner.announce_objectives()

/datum/antagonist/cult_of_suffering/apostate/on_gain()
		. = ..()
		// Добавляем цель убийства
		var/datum/objective/berserk/kill_objective = new
		kill_objective.owner = owner
		objectives += kill_objective

		// Таймер для автоматического удаления
		removal_timer = addtimer(CALLBACK(src, PROC_REF(remove_berserker)), duration, TIMER_STOPPABLE)

// 		// Визуальные эффекты: светящиеся глаза
// 		add_berserker_effects()
// 		// Таймер для автоматического удаления
// 		removal_timer = addtimer(CALLBACK(src, PROC_REF(remove_berserker)), duration, TIMER_STOPPABLE)


/datum/antagonist/cult_of_suffering/apostate/on_removal()
		. = ..()
		if(removal_timer)
				deltimer(removal_timer)


// /datum/antagonist/cult_of_suffering/apostate/proc/add_berserker_effects()

// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// Светящиеся глаза (эффект)
// 			H.add_overlay(mutable_appearance('icons/effects/cult_of_suffering.dmi', "berserker_eyes"))
// 			// Эффект дрожи/агрессии
// 			H.add_mood_event("berserk", /datum/mood_event/berserk)

// /datum/antagonist/cult_of_suffering/apostate/proc/remove_berserker_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			H.cut_overlay(mutable_appearance('icons/effects/cult_of_suffering.dmi', "berserker_eyes"))
// 			H.clear_mood_event("berserk")

/datum/antagonist/cult_of_suffering/apostate/proc/remove_berserker()
		if(owner?.current)
				to_chat(owner.current, span_notice("Эффект газа Адиум ослабевает... сознание проясняется."))
		owner.remove_antag_datum(type)
