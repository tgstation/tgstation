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
		to_chat(owner, span_cult("Strange air is taking control of you..."))
		to_chat(owner, span_cult("Pain... Anger... KILL..."))
		to_chat(owner, span_cult("Goal: kill all!"))
		owner.announce_objectives()

/datum/antagonist/cult_of_suffering/apostate/on_gain()
		. = ..()


		RegisterSignal(owner.current, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack))
		// adding obj to kill
		var/datum/objective/berserk/kill_objective = new
		kill_objective.owner = owner
		objectives += kill_objective

		// timer for auto delete
		removal_timer = addtimer(CALLBACK(src, PROC_REF(remove_berserker)), duration, TIMER_STOPPABLE)

// 		// visual effect - glowing eyes
// 		add_berserker_effects()
// 		// timer for auto delete
// 		removal_timer = addtimer(CALLBACK(src, PROC_REF(remove_berserker)), duration, TIMER_STOPPABLE)


/datum/antagonist/cult_of_suffering/apostate/on_removal()
		. = ..()
		if(removal_timer)
				deltimer(removal_timer)


// /datum/antagonist/cult_of_suffering/apostate/proc/add_berserker_effects()

// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			// eyes
// 			H.add_overlay(mutable_appearance('icons/effects/cult_of_suffering.dmi', "berserker_eyes"))
// 			// effect of angry
// 			H.add_mood_event("berserk", /datum/mood_event/berserk)

// /datum/antagonist/cult_of_suffering/apostate/proc/remove_berserker_effects()
// 		var/mob/living/carbon/human/H = owner.current
// 		if(istype(H))
// 			H.cut_overlay(mutable_appearance('icons/effects/cult_of_suffering.dmi', "berserker_eyes"))
// 			H.clear_mood_event("berserk")

/datum/antagonist/cult_of_suffering/apostate/proc/remove_berserker()
		if(owner?.current)
				to_chat(owner.current, span_notice("Anger is leaving your body... сonsciousness wakes up."))
		owner.remove_antag_datum(type)

/datum/antagonist/cult_of_suffering/apostate/proc/on_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER

	// minimal check - hit
	if(!isliving(target) || target == source)
		return

	// convert to cult of suffering
	owner.remove_antag_datum(type)
	owner.add_antag_datum(/datum/antagonist/cult_of_suffering/cultist)
	to_chat(owner.current, span_cult("КРОВЬЮ СТРАДАНИЯ ТЫ ПРИНЯТ В КУЛЬТ!"))
