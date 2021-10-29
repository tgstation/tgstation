/datum/reagent/medicine/c2/libital/borer_version
	name = "Unknown Libital Isomer"
	impure_chem = null

/datum/reagent/medicine/c2/lenturi/borer_version
	name = "Unknown Lenturi Isomer"
	impure_chem = null

/datum/reagent/drug/methamphetamine/borer_version
	name = "Unknown Methamphetamine Isomer"
	overdose_threshold = 40

/datum/reagent/drug/methamphetamine/borer_version/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(DT_PROB(2.5, delta_time))
		to_chat(M, span_notice("[high_message]"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-40 * REM * delta_time)
	M.AdjustKnockdown(-40 * REM * delta_time)
	M.AdjustUnconscious(-40 * REM * delta_time)
	M.AdjustParalyzed(-40 * REM * delta_time)
	M.AdjustImmobilized(-40 * REM * delta_time)
	M.adjustStaminaLoss(-2 * REM * delta_time, 0)
	M.Jitter(2 * REM * delta_time)
	if(DT_PROB(2.5, delta_time))
		M.emote(pick("twitch", "shiver"))
	..()
	. = TRUE
