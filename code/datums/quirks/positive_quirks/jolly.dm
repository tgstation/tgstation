/datum/quirk/jolly
	name = "Jolly"
	desc = "Иногда вы просто чувствуете себя счастливым без всякой причины."
	icon = FA_ICON_GRIN
	value = 4
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES|QUIRK_TRAUMALIKE
	medical_record_text = "Пациент демонстрирует постоянную эутимию независимо от обстоятельств. Это уже слишком, если честно."
	medical_symptom_text = "Exhibits persistent feelings of happiness and elevated mood, which may lead to unrealistic optimism and risk-taking behaviors."
	mail_goodies = list(/obj/item/clothing/mask/joy)

/datum/quirk/jolly/process(seconds_per_tick)
	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(SPT_PROB(0.416, seconds_per_tick))
		quirk_holder.add_mood_event("jolly", /datum/mood_event/jolly)

/datum/quirk/jolly/remove()
	quirk_holder.clear_mood_event("jolly")
