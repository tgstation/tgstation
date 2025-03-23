/// Caused by dirty food. Makes you burp out Tritium, sometimes burning hot!
/datum/disease/gastritium
	name = "Gastritium"
	desc = "If left untreated, may manifest in severe Tritium heartburn."
	form = "Infection"
	agent = "Atmobacter Polyri"
	cure_text = "Milk"
	cures = list(/datum/reagent/consumable/milk)
	viable_mobtypes = list(/mob/living/carbon/human)
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	severity = DISEASE_SEVERITY_HARMFUL
	max_stages = 5
	required_organ = ORGAN_SLOT_STOMACH
	/// The chance of burped out tritium to be hot during max stage
	var/tritium_burp_hot_chance = 10

/datum/disease/gastritium/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("burp")
		if(3)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("Your stomach makes turbine noises..."))
			else if(SPT_PROB(1, seconds_per_tick))
				affected_mob.emote("burp")
		if(4)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("You're starting to feel like a burn chamber..."))
			else if(SPT_PROB(1, seconds_per_tick))
				tritium_burp()
		if(5)
			if(SPT_PROB(1, seconds_per_tick) && affected_mob.stat == CONSCIOUS)
				to_chat(affected_mob, span_warning("You feel like you're about to delam..."))
			else if(SPT_PROB(1, seconds_per_tick))
				tritium_burp(hot_chance = TRUE)
	var/change_limit = max(affected_mob.get_body_temp_heat_damage_limit() - 5 - affected_mob.get_body_temp_normal(apply_change=FALSE), 0)
	affected_mob.add_body_temperature_change("gastritium", min(15 * stage, change_limit))

/datum/disease/gastritium/proc/tritium_burp(hot_chance = FALSE)
	var/datum/gas_mixture/burp = new
	ADD_GAS(/datum/gas/tritium, burp.gases)
	burp.gases[/datum/gas/tritium][MOLES] = MOLES_GAS_VISIBLE
	burp.temperature = affected_mob.bodytemperature
	if(hot_chance && prob(tritium_burp_hot_chance))
		burp.temperature = TRITIUM_MINIMUM_BURN_TEMPERATURE
		if(affected_mob.stat == CONSCIOUS)
			to_chat(affected_mob, span_warning("Your throat feels hot!"))
	affected_mob.visible_message("burps out green gas.", visible_message_flags = EMOTE_MESSAGE)
	affected_mob.loc.assume_air(burp)
