// Double the OD treshold, no brain damage
/datum/reagent/drug/methamphetamine/borer_version
	name = "Unknown Methamphetamine Isomer"
	overdose_threshold = 40

/datum/reagent/drug/methamphetamine/borer_version/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[high_message]"))
	affected_mob.add_mood_event("tweaking", /datum/mood_event/stimulant_medium, name)
	affected_mob.AdjustStun(-40 * REM * seconds_per_tick)
	affected_mob.AdjustKnockdown(-40 * REM * seconds_per_tick)
	affected_mob.AdjustUnconscious(-40 * REM * seconds_per_tick)
	affected_mob.AdjustParalyzed(-40 * REM * seconds_per_tick)
	affected_mob.AdjustImmobilized(-40 * REM * seconds_per_tick)
	affected_mob.stamina.adjust(2 * REM * seconds_per_tick, TRUE)
	affected_mob.set_jitter_if_lower(4 SECONDS * REM * seconds_per_tick)
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.emote(pick("twitch", "shiver"))
	..()
	. = TRUE
