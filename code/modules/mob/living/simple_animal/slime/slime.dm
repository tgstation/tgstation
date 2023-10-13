#define SLIME_CARES_ABOUT(to_check) (to_check && (to_check == Target || to_check == Leader || (to_check in Friends)))
/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/simple/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	harm_intent_damage = 5
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	mob_biotypes = MOB_SLIME
	melee_damage_lower = 5
	melee_damage_upper = 25

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	///The current mood of the slime, set randomly or through emotes (if sentient).
	var/current_mood

	var/AIproc = 0 // determines if the AI loop is activated
	var/Atkcool = 0 // attack cooldown
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable

	var/is_adult = 0
	var/docile = 0

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime
	var/force_stasis = FALSE

	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	///////////TIME FOR SUBSPECIES

	var/colour = SLIME_TYPE_GREY
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/static/list/slime_colours = list(
		SLIME_TYPE_ADAMANTINE,
		SLIME_TYPE_BLACK,
		SLIME_TYPE_BLUE,
		SLIME_TYPE_BLUESPACE,
		SLIME_TYPE_CERULEAN,
		SLIME_TYPE_DARK_BLUE,
		SLIME_TYPE_DARK_PURPLE,
		SLIME_TYPE_GOLD,
		SLIME_TYPE_GREEN,
		SLIME_TYPE_GREY,
		SLIME_TYPE_LIGHT_PINK,
		SLIME_TYPE_METAL,
		SLIME_TYPE_OIL,
		SLIME_TYPE_ORANGE,
		SLIME_TYPE_PINK,
		SLIME_TYPE_PURPLE,
		SLIME_TYPE_PYRITE,
		SLIME_TYPE_RAINBOW,
		SLIME_TYPE_RED,
		SLIME_TYPE_SEPIA,
		SLIME_TYPE_SILVER,
		SLIME_TYPE_YELLOW,
	)

	var/static/list/slime_colours_to_rgb = list(
		SLIME_TYPE_ADAMANTINE = COLOR_SLIME_ADAMANTINE,
		SLIME_TYPE_BLACK = COLOR_SLIME_BLACK,
		SLIME_TYPE_BLUE = COLOR_SLIME_BLUE,
		SLIME_TYPE_BLUESPACE = COLOR_SLIME_BLUESPACE,
		SLIME_TYPE_CERULEAN = COLOR_SLIME_CERULEAN,
		SLIME_TYPE_DARK_BLUE = COLOR_SLIME_DARK_BLUE,
		SLIME_TYPE_DARK_PURPLE = COLOR_SLIME_DARK_PURPLE,
		SLIME_TYPE_GOLD = COLOR_SLIME_GOLD,
		SLIME_TYPE_GREEN = COLOR_SLIME_GREEN,
		SLIME_TYPE_GREY = COLOR_SLIME_GREY,
		SLIME_TYPE_LIGHT_PINK = COLOR_SLIME_LIGHT_PINK,
		SLIME_TYPE_METAL = COLOR_SLIME_METAL,
		SLIME_TYPE_OIL = COLOR_SLIME_OIL,
		SLIME_TYPE_ORANGE = COLOR_SLIME_ORANGE,
		SLIME_TYPE_PINK = COLOR_SLIME_PINK,
		SLIME_TYPE_PURPLE = COLOR_SLIME_PURPLE,
		SLIME_TYPE_PYRITE = COLOR_SLIME_PYRITE,
		SLIME_TYPE_RAINBOW = COLOR_SLIME_RAINBOW,
		SLIME_TYPE_RED = COLOR_SLIME_RED,
		SLIME_TYPE_SEPIA = COLOR_SLIME_SEPIA,
		SLIME_TYPE_SILVER = COLOR_SLIME_SILVER,
		SLIME_TYPE_YELLOW = COLOR_SLIME_YELLOW,
	)

	///////////CORE-CROSSING CODE

	var/effectmod //What core modification is being used.
	var/applied = 0 //How many extracts of the modtype have been applied.

#define TRAIT_SLIME_WATER_IMMUNE "gingus"

/mob/living/simple_animal/slime/Initialize(mapload, new_colour=colour, new_is_adult=FALSE)
	var/datum/action/innate/slime/feed/F = new
	F.Grant(src)
	ADD_TRAIT(src, TRAIT_CANT_RIDE, INNATE_TRAIT)

	is_adult = new_is_adult

	if(is_adult)
		var/datum/action/innate/slime/reproduce/R = new
		R.Grant(src)
		health = 200
		maxHealth = 200
	else
		var/datum/action/innate/slime/evolve/E = new
		E.Grant(src)
	create_reagents(100)
	set_colour(new_colour)
	. = ..()
	set_nutrition(700)
	add_cell_sample()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	AddElement(/datum/element/soft_landing)

/mob/living/simple_animal/slime/Destroy()
	for (var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	set_target(null)
	set_leader(null)
	clear_friends()
	return ..()

/mob/living/simple_animal/slime/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_DEL_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/// Handles removing signal hooks incase someone is crazy enough to reset the reagents datum.
/mob/living/simple_animal/slime/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_QDELETING))
	return NONE

/mob/living/simple_animal/slime/proc/set_colour(new_colour)
	colour = new_colour
	update_name()
	slime_mutation = mutation_table(colour)
	var/sanitizedcolour = replacetext(colour, " ", "")
	coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	regenerate_icons()

/mob/living/simple_animal/slime/update_name()
	if(slime_name_regex.Find(name))
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		real_name = name
	return ..()

/mob/living/simple_animal/slime/proc/random_colour()
	set_colour(pick(slime_colours))

/mob/living/simple_animal/slime/regenerate_icons(force_mood)
	if(force_mood)
		current_mood = force_mood
	cut_overlays()
	var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(current_mood && !stat)
			add_overlay("aslime-[current_mood]")
	else
		icon_state = icon_dead
	..()

/**
 * Snowflake handling of reagent movespeed modifiers
 *
 * Should be moved to the reagents at some point in the future. As it is I'm in a hurry.
 */
/mob/living/simple_animal/slime/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	remove_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod)
	var/amount = 0
	if(reagents.has_reagent(/datum/reagent/medicine/morphine)) // morphine slows slimes down
		amount = 2
	if(reagents.has_reagent(/datum/reagent/consumable/frostoil)) // Frostoil also makes them move VEEERRYYYYY slow
		amount = 5
	if(amount)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod, multiplicative_slowdown = amount)
	return NONE

/mob/living/simple_animal/slime/updatehealth()
	. = ..()
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/adjust_bodytemperature()
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1 // slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_tempmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)
				probab = 20
			if(3 to 4)
				probab = 30
			if(5 to 6)
				probab = 40
			if(7 to 8)
				probab = 60
			if(9)
				probab = 70
			if(10)
				probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(nutrition <= get_hunger_nutrition() && !Atkcool)
					if (is_adult || prob(5))
						O.attack_slime(src)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 2

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

	// BZ Sends the slime into a state of happy stupor that makes them utterly and completely harmless for the status effects' duration.
	if(air?.gases[/datum/gas/bz])
		current_gas_pp = air.get_breath_partial_pressure(air.gases[/datum/gas/bz][MOLES])
		if(current_gas_pp > 0.1)
			bz_expose(current_gas_pp, air)

	// Pluoxium is skipped. It's just cool oxygen and slimes don't care about oxygen.

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
	add_nutrition((0.11 * current_gas_pp * 0.5)) // SSair ticks every 0.5 apparently. idfk.
	absorb_gas(air, /datum/gas/plasma, 1 * current_gas_pp)
	air.temperature += 0.5 * (current_gas_pp * 0.25)
	regenerate_icons(force_mood = ":3") //they love it!

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
			visible_message(span_notice("[src] seems less placid."))
		else if(Friends)
			clear_friends()
			visible_message(span_notice("[src]'s mischevious smile takes on a malicious shade!"))
		else
			rabid = TRUE
			visible_message(span_notice("[src]'s smile turns manic!"))
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
	regenerate_icons(force_mood = ":33") //they REALLY love it!

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
		/datum/component/ghost_direct_control,\
		poll_candidates = TRUE,\
		poll_length = 30 SECONDS,\
		role_name = "Anti-Noblium Slime",\
		assumed_control_message = "You are a common slime infused into true life by Anti-Noblium. While a creature may have brought you to life, you may follow your own whims. You have no masters, but no enemies.",\
		poll_ignore_key = POLL_IGNORE_SENTIENCE_POTION,\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)

/mob/living/simple_animal/slime/proc/became_player_controlled()
	mind.special_role = "Sentient Slime"

/**
 * Reduce the amount of gas in the air by this amount.
 */
/mob/living/simple_animal/slime/proc/absorb_gas(datum/gas_mixture/air, gas_absorbed_type, absorbed_amount)
	air.gases[gas_absorbed_type][MOLES] -= min(absorbed_amount, air.gases[gas_absorbed_type][MOLES])

/mob/living/simple_animal/slime/get_status_tab_items()
	. = ..()
	if(!docile)
		. += "Nutrition: [nutrition]/[get_max_nutrition()]"
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		if(is_adult)
			. += "You can reproduce!"
		else
			. += "You can evolve!"

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			. += "You are knocked out!"
		else
			. += "Power Level: [powerlevel]"


/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	attacked += 10
	if((Proj.damage_type == BURN))
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src, 0, piercing_hit)
	else
		. = ..(Proj)
	. = . || BULLET_ACT_BLOCK

/mob/living/simple_animal/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/movable/A as mob|obj)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(CanFeedon(Food))
			Feedon(Food)
	return ..()

/mob/living/simple_animal/slime/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot, params)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(buckled)
			Feedstop(silent = TRUE)
			visible_message(span_danger("[M] pulls [src] off!"), \
				span_danger("You pull [src] off!"))
			return
		attacked += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + (40 * M.is_adult)))
			M.add_nutrition(50 + (40 * M.is_adult))
		if(health > 0)
			M.adjustBruteLoss(-10 + (-10 * M.is_adult))
			M.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	if(.)
		attacked += 10


/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..()) //successful monkey bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(..()) //successful larva bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	discipline_slime(user)

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(buckled)
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(buckled == user)
			if(prob(60))
				user.visible_message(span_warning("[user] attempts to wrestle \the [name] off!"), \
					span_danger("You attempt to wrestle \the [name] off!"))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				user.visible_message(span_warning("[user] manages to wrestle \the [name] off!"), \
					span_notice("You manage to wrestle \the [name] off!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(user)

		else
			if(prob(30))
				buckled.visible_message(span_warning("[user] attempts to wrestle \the [name] off of [buckled]!"), \
					span_warning("[user] attempts to wrestle \the [name] off of you!"))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				buckled.visible_message(span_warning("[user] manages to wrestle \the [name] off of [buckled]!"), \
					span_notice("[user] manage to wrestle \the [name] off of you!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(user)
	else
		if(stat == DEAD && surgeries.len)
			if(!user.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
				for(var/datum/surgery/operations as anything in surgeries)
					if(operations.next_step(user, modifiers))
						return TRUE
		if(..()) //successful attack
			attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	if(..()) //if harm or disarm intent.
		attacked += 10
		discipline_slime(user)


/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		var/list/modifiers = params2list(params)
		if(!user.combat_mode || (LAZYACCESS(modifiers, RIGHT_CLICK)))
			for(var/datum/surgery/operations as anything in surgeries)
				if(operations.next_step(user, modifiers))
					return TRUE
	if(istype(W, /obj/item/stack/sheet/mineral/plasma) && !stat) //Let's you feed slimes plasma.
		add_friendship(user, 1)
		to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	if(W.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_danger("[W] passes right through [src]!"))
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(is_adult)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)
	if(istype(W, /obj/item/storage/bag/xeno))
		var/obj/item/storage/P = W
		if(!effectmod)
			to_chat(user, span_warning("The slime is not currently being mutated."))
			return
		var/hasOutput = FALSE //Have we outputted text?
		var/hasFound = FALSE //Have we found an extract to be added?
		for(var/obj/item/slime_extract/S in P.contents)
			if(S.effectmod == effectmod)
				P.atom_storage.attempt_remove(S, get_turf(src), silent = TRUE)
				qdel(S)
				applied++
				hasFound = TRUE
			if(applied >= SLIME_EXTRACT_CROSSING_REQUIRED)
				to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
				spawn_corecross()
				hasOutput = TRUE
				break
		if(!hasOutput)
			if(!hasFound)
				to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
			else
				to_chat(user, span_notice("You feed the slime some extracts from the bag."))
				playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
		return
	..()

/mob/living/simple_animal/slime/proc/spawn_corecross()
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/crosspath
	for(var/X in crossbreeds)
		var/obj/item/slimecross/S = X
		if(initial(S.colour) == colour && initial(S.effect) == effectmod)
			crosspath = S
			break
	if(crosspath)
		new crosspath(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

/mob/living/simple_animal/slime/proc/apply_water()
	if(HAS_TRAIT(src, TRAIT_SLIME_WATER_IMMUNE))
		return
	adjustBruteLoss(rand(15,20))
	if(!client)
		if(Target) // Like cats
			set_target(null)
			++Discipline
	return

/mob/living/simple_animal/slime/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if (stat == DEAD)
		. += span_deadsay("It is limp and unresponsive.")
	else
		if (stat == UNCONSCIOUS || stat == HARD_CRIT) // Slime stasis
			. += span_deadsay("It appears to be alive but unresponsive.")
		if (getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += span_warning("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += span_warning("<B>It is radiating with massive levels of electrical activity!</B>")

	. += "</span>"

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		Discipline++

		if(!is_adult)
			if(Discipline == 1)
				attacked = 0

	set_target(null)
	if(buckled)
		Feedstop(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	SStun = world.time + rand(20,60)

	Stun(3)
	if(user)
		step_away(src,user,15)

	addtimer(CALLBACK(src, PROC_REF(slime_move), user), 0.3 SECONDS)


/mob/living/simple_animal/slime/proc/slime_move(mob/user)
	if(user)
		step_away(src,user,15)


/mob/living/simple_animal/slime/pet
	docile = 1

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick(slime_colours), prob(50))

/mob/living/simple_animal/slime/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLIME, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/slime/proc/set_target(new_target)
	var/old_target = Target
	Target = new_target
	if(old_target && !SLIME_CARES_ABOUT(old_target))
		UnregisterSignal(old_target, COMSIG_QDELETING)
	if(Target)
		RegisterSignal(Target, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/set_leader(new_leader)
	var/old_leader = Leader
	Leader = new_leader
	if(old_leader && !SLIME_CARES_ABOUT(old_leader))
		UnregisterSignal(old_leader, COMSIG_QDELETING)
	if(Leader)
		RegisterSignal(Leader, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/add_friendship(new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/set_friendship(new_friend, amount = 1)
	Friends[new_friend] = amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/remove_friend(friend)
	Friends -= friend
	if(friend && !SLIME_CARES_ABOUT(friend))
		UnregisterSignal(friend, COMSIG_QDELETING)

/mob/living/simple_animal/slime/proc/set_friends(new_buds)
	clear_friends()
	for(var/mob/friend as anything in new_buds)
		set_friendship(friend, new_buds[friend])

/mob/living/simple_animal/slime/proc/clear_friends()
	for(var/mob/friend as anything in Friends)
		remove_friend(friend)

/mob/living/simple_animal/slime/proc/clear_memories_of(datum/source)
	SIGNAL_HANDLER
	if(source == Target)
		set_target(null)
	if(source == Leader)
		set_leader(null)
	remove_friend(source)

#undef SLIME_CARES_ABOUT
