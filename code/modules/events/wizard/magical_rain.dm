/datum/round_event_control/wizard/magical_rain
	name = "Magical Rain"
	weight = 3
	typepath = /datum/round_event/wizard/magical_rain
	max_occurrences = 5
	earliest_start = 0 MINUTES
	description = "A magical thunderstorm rains down below, drenching anyone caught in it with mysterious rain."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 7

/datum/round_event/wizard/magical_rain
	end_when = 0
	var/started = FALSE

/datum/round_event/wizard/magical_rain/start()
	for(var/mob/living/wizard in GLOB.alive_mob_list)
		// give it to all wizards even if there are multiple
		if(IS_WIZARD(wizard) && !HAS_TRAIT_FROM(wizard, TRAIT_RAINSTORM_IMMUNE, MAGIC_TRAIT))
			ADD_TRAIT(wizard, TRAIT_RAINSTORM_IMMUNE, MAGIC_TRAIT)
			to_chat(wizard, span_reallybig(span_hypnophrase("You feel a magical force giving you resistance to rain!")))

	if(!started)
		started = TRUE
		SSweather.run_weather(/datum/weather/rain_storm/wizard)

/datum/round_event/wizard/magical_rain/end()
	for(var/mob/living/wizard in GLOB.alive_mob_list)
		if(IS_WIZARD(wizard) && HAS_TRAIT_FROM(wizard, TRAIT_RAINSTORM_IMMUNE, MAGIC_TRAIT))
			REMOVE_TRAIT(wizard, TRAIT_RAINSTORM_IMMUNE, MAGIC_TRAIT)
			to_chat(wizard, span_notice("You feel your magical resistance to rain fade!"))
