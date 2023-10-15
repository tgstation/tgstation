/mob/living/simple_animal/slime/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return TRUE

/mob/living/simple_animal/slime/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	// No need for the rest yet
	ASSERT_GAS(/datum/gas/hypernoblium, air)

	var/current_gas_pp

	// Hyper-noblium 'reacts' extremely easily with slimes. Any amount at all and they become immune to fire extinguishers and lose all mutation chances.
	if(air?.gases[/datum/gas/hypernoblium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/hypernoblium][MOLES])
		if(current_gas_pp)
			hypernoblium_expose(current_gas_pp, air)

	air.assert_gases(/datum/gas/plasma, /datum/gas/tritium, /datum/gas/bz, /datum/gas/nitrium, /datum/gas/proto_nitrate, /datum/gas/healium, /datum/gas/zauker, /datum/gas/antinoblium)

	// Plasma nutrientives slimes.
	if(air?.gases[/datum/gas/plasma])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/plasma][MOLES])
		if(current_gas_pp)
			plasma_expose(current_gas_pp, air)

	// Tritium is a slime's equivalent of bath salts.
	if(air?.gases[/datum/gas/tritium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/tritium][MOLES])
		if(current_gas_pp > 10)
			tritium_expose(current_gas_pp, air)

	// Pluoxium Sends the slime into a state of happy stupor that makes them utterly and completely harmless for the status effects' duration.
	if(air?.gases[/datum/gas/pluoxium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/pluoxium][MOLES])
		if(current_gas_pp > 0.1)
			pluoxium_expose(current_gas_pp, air)

	// BZ puts slimes in stasis and makes them harmless.
	if(air?.gases[/datum/gas/bz])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/bz][MOLES])
		if(current_gas_pp > 0.05)
			bz_expose(current_gas_pp, air)

	// Slimes become supercharged and hyper-active on Nitrium.
	if(air?.gases[/datum/gas/nitrium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/nitrium][MOLES])
		if(current_gas_pp > 15)
			nitrium_expose(current_gas_pp, air)

	// Proto-Nitrate boosts core drops, up to a maximum of 10.
	// It also passively increases mutation chance and can change colors at a high enough value, as a less-risky but harder alternative to Tritium.

	if(air?.gases[/datum/gas/proto_nitrate])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/proto_nitrate][MOLES])
		if(current_gas_pp > 5)
			proto_nitrate_expose(current_gas_pp, air)

	// Healium.... heals-'em.
	if(air?.gases[/datum/gas/healium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/healium][MOLES])
		healium_expose(current_gas_pp, air)

	// Zauker feeds and heals them incredibly fast, they love it.
	if(air?.gases[/datum/gas/zauker])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/zauker][MOLES])
		zauker_expose(current_gas_pp, air)

	// Slimes consume 50 moles of antinoblium to become sentient!!
	if(air?.gases[/datum/gas/antinoblium])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/antinoblium][MOLES])
		if(current_gas_pp >= 50)
			antinoblium_expose(current_gas_pp, air)

/**
 * Hypernoblium-exposed slimes (any amount at all) gain a status effect that protects them from water, but slows them down.
 */
/mob/living/simple_animal/slime/proc/hypernoblium_expose(current_gas_pp, datum/gas_mixture/air)
	apply_status_effect(/datum/status_effect/slime/hypernob_protection, 10 SECONDS)
	absorb_gas(air, /datum/gas/hypernoblium, 0.01)

/**
 * Plasma-exposed slimes gain a healthy amount of nutrition, but also heat up the air.
 * Probably shouldn't have an oxidizer in the pen at the same time.
 * On average, they should get around ~11 nutrition per second at 100% plasma, roughly the same as monkey absorption nutrition.
 */
/mob/living/simple_animal/slime/proc/plasma_expose(current_gas_pp, datum/gas_mixture/air)
	add_nutrition((0.11 * current_gas_pp * SSair.wait_time))
	absorb_gas(air, /datum/gas/plasma, 1 * current_gas_pp)
	air.temperature += 0.5 * (current_gas_pp * 0.25)
	force_mood_change(force_mood = ":3") //they love it!

/**
 * Tritium-exposed slimes randomly and wildly mutate until they become green.
 * If the pp is *slightly* higher, they can still mutate, but if it gets too high again...
 * Above 15 pp they become frenzied. They begin emitting nuclear particles, become radioactive, and turn rabid.
 */
/mob/living/simple_animal/slime/proc/tritium_expose(current_gas_pp, datum/gas_mixture/air)
	// In low concentrations, mutates their color wildly.
	if(current_gas_pp > 10 && prob(10))
		// However, it stops mutating whenever it reaches the color green. You'd need to get ballsy and up the amount of tritium if you want a reroll.
		// That's hard when tritrating a slime does its own color flipping as well!
		if(colour != COLOR_SLIME_GREEN && !(current_gas_pp > 12.5))
			set_colour(pick(slime_colours))
		absorb_gas(air, /datum/gas/tritium, 10)
	// Slightly higher, and they flip out and become frenzied and radioactive to boot. You need to be careful!
	if(current_gas_pp > 15 && prob(10))
		apply_status_effect(/datum/status_effect/slime/tritrated, 5 SECONDS)
		docile = FALSE
		rabid = TRUE
		Discipline = 0
		clear_friends()
		absorb_gas(air, /datum/gas/tritium, 5)
/**
 * BZ-exposed slimes gain a temporary status effect that makes them pacifist, docile, and be friends with everyone they see.
 * They also slowly lose charge over time.
 */
/mob/living/simple_animal/slime/proc/bz_expose(current_gas_pp, datum/gas_mixture/air)
	if(current_gas_pp > 0.1 && prob(15)) // small. cast friendliness!
		apply_status_effect(/datum/status_effect/slime/stupor, 10 SECONDS)
		absorb_gas(air, /datum/gas/bz, 0.1)

/**
 * Nitrium-exposed slimes become very fast, gain charge over time, and ignore damage slowdown.
 * If the Nitrium amount is too high, they will slowly lose tameness and go crazy (rabid)
 */
/mob/living/simple_animal/slime/proc/nitrium_expose(current_gas_pp, datum/gas_mixture/air)
	if(current_gas_pp > 5 && prob(15))
		apply_status_effect(/datum/status_effect/slime/nitrated, 10 SECONDS)
		absorb_gas(air, /datum/gas/nitrium, 5)
	// They can overdose on it tho.
	if(current_gas_pp > 15 && prob(10))
		powerlevel += 2
		if(docile)
			docile = FALSE
			balloon_alert_to_viewers("[src] seems less placid.")
		else if(Friends)
			clear_friends()
			balloon_alert_to_viewers("[src]'s mischevious smile takes on a malicious shade!")
		else
			rabid = TRUE
			balloon_alert_to_viewers("[src]'s smile turns manic!")
		absorb_gas(air, /datum/gas/nitrium, 10)

/**
 * Proto-Nitrate is a powerful mutation enhancer.
 * Additionally, it adds one core to the slime per 5 pp of nitrate, up to a maximum of 10.
 * If it's heavily concentrated it will randomly change the color, for a more safe but slower method fo color randomizing.
 */
/mob/living/simple_animal/slime/proc/proto_nitrate_expose(current_gas_pp, datum/gas_mixture/air)
	cores = clamp(current_gas_pp * 5, cores, 10)
	mutation_chance += 5
	absorb_gas(air, /datum/gas/proto_nitrate, 2 * current_gas_pp)
	if(current_gas_pp > 25)
		set_colour(pick(slime_colours))
		absorb_gas(air, /datum/gas/proto_nitrate, 25)

/**
 * Healium heals'em.
 */
/mob/living/simple_animal/slime/proc/healium_expose(current_gas_pp, datum/gas_mixture/air)
	adjustBruteLoss(-1 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	adjustFireLoss(-1 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	adjustToxLoss(-1 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	absorb_gas(air, /datum/gas/proto_nitrate, min(current_gas_pp * 0.1, 1.5))

/**
 * Zauker-infused slimes regenerate health exceedingly quickly, and gain a LOT of nutrition.
 */
/mob/living/simple_animal/slime/proc/zauker_expose(current_gas_pp, datum/gas_mixture/air)
	add_nutrition((0.55 * current_gas_pp * 0.5)) // SSair ticks every 0.5 apparently!! idfk!!!
	adjustBruteLoss(-5 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	adjustFireLoss(-5 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	adjustToxLoss(-5 * min(current_gas_pp, 15), updating_health = TRUE, forced = TRUE)
	absorb_gas(air, /datum/gas/zauker, min(current_gas_pp * 0.1, 1.5))
	force_mood_change(force_mood = ":33") //they REALLY love it!

/**
 * Antinoblium can turn slimes sentient if there's enough in the air.
 */
/mob/living/simple_animal/slime/proc/antinoblium_expose(current_gas_pp, datum/gas_mixture/air)
	var/antinoblium_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/antinoblium][MOLES])
	if(client)
		if(prob(5))
			to_chat(src, span_notice("You have a strange feeling for a moment, and then it passes."))
		return
	if(antinoblium_pp < 50)
		return
	absorb_gas(air, /datum/gas/antinoblium, 50)
	INVOKE_ASYNC(src, PROC_REF(become_sentient))

/mob/living/simple_animal/slime/proc/become_sentient()
	AddComponent(\
		/datum/component/ghost_direct_control, \
		poll_candidates = TRUE, \
		poll_length = 30 SECONDS, \
		role_name = "Anti-Noblium Slime", \
		assumed_control_message = "You are a common slime infused into true life by Anti-Noblium. While a creature may have brought you to life, you may follow your own whims. You have no masters, but no enemies.",\
		poll_ignore_key = POLL_IGNORE_SENTIENCE_POTION, \
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)), \
	)

/mob/living/simple_animal/slime/proc/became_player_controlled()
	mind.special_role = "Sentient Slime"

/**
 * Reduce the amount of gas in the air by this amount.
 */
/mob/living/simple_animal/slime/proc/absorb_gas(datum/gas_mixture/air, gas_absorbed_type, absorbed_amount)
	air.gases[gas_absorbed_type][MOLES] -= min(absorbed_amount, air.gases[gas_absorbed_type][MOLES])
