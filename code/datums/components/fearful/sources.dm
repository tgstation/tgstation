// Terror source handlers
/// Simple source which passively increases terror based on a single condition and can do something when its added/removed
/datum/terror_handler/simple_source
	handler_type = TERROR_HANDLER_SOURCE
	/// How much terror is added per second
	var/buildup_per_second = 10
	/// Have we already applied our effects?
	var/active = FALSE

/datum/terror_handler/simple_source/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (check_condition(seconds_per_tick, terror_buildup) && terror_buildup < TERROR_BUILDUP_PASSIVE_MAXIMUM)
		if (!active)
			on_activation(terror_buildup)
		. += min(buildup_per_second * seconds_per_tick, TERROR_BUILDUP_PASSIVE_MAXIMUM - terror_buildup)
	else if (active)
		on_deactivation(terror_buildup)

/// Proc that children should override with their conditions
/datum/terror_handler/simple_source/proc/check_condition(seconds_per_tick, terror_buildup)
	return !HAS_TRAIT(owner, TRAIT_FEARLESS) && !HAS_TRAIT(owner, TRAIT_MIND_TEMPORARILY_GONE) && owner.stat < UNCONSCIOUS

/// Proc that's called when the effect is first applied, for moodlets and alike
/datum/terror_handler/simple_source/proc/on_activation(terror_buildup)
	active = TRUE

/// Proc that's called when the effect stops working, for moodlets and alike
/datum/terror_handler/simple_source/proc/on_deactivation(terror_buildup)
	active = FALSE

/// Makes the owner terrified of darkness
/datum/terror_handler/simple_source/nyctophobia
	buildup_per_second = 5 // Takes about two minutes to reach maximum
	/// Are we counteracted by mesons?
	var/meson_negated = TRUE

/datum/terror_handler/simple_source/nyctophobia/Destroy(force)
	owner.clear_mood_event("nyctophobia")
	return ..()

/datum/terror_handler/simple_source/nyctophobia/check_condition(seconds_per_tick, terror_buildup)
	. = ..()
	if (!.)
		return

	if (ishuman(owner))
		var/mob/living/carbon/human/as_human = owner
		if(as_human.dna?.species.id in list(SPECIES_SHADOW, SPECIES_NIGHTMARE))
			return FALSE

	if (meson_negated && (owner.sight & SEE_TURFS))
		return FALSE

	var/lit_tiles = 0
	var/unlit_tiles = 0

	for (var/turf/open/turf_to_check in range(1, owner))
		var/light_amount = turf_to_check.get_lumcount()
		if (light_amount > LIGHTING_TILE_IS_DARK)
			lit_tiles++
		else
			unlit_tiles++

	return lit_tiles < unlit_tiles

/datum/terror_handler/simple_source/nyctophobia/on_activation(terror_buildup)
	. = ..()
	owner.add_mood_event("nyctophobia", /datum/mood_event/nyctophobia)

/datum/terror_handler/simple_source/nyctophobia/on_deactivation(terror_buildup)
	. = ..()
	owner.clear_mood_event("nyctophobia")

// Nightmare spell version with quicker buildup that shadows the quirk one, also handles removing the status upon reaching 0 terror
/datum/terror_handler/simple_source/nyctophobia/terrified
	// Takes about 30 seconds to reach maximum if you include 100 from casting the spell
	buildup_per_second = 15
	// Overrides the base type with slower buildup
	overrides = list(/datum/terror_handler/simple_source/nyctophobia)
	meson_negated = FALSE

/datum/terror_handler/simple_source/nyctophobia/terrified/tick(seconds_per_tick, terror_buildup)
	. = ..()
	if (terror_buildup == 0 && !.)
		owner.RemoveComponentSource("terrified", /datum/component/fearful)

/// Makes the owner afraid of being stuck in closets, crates, mechs, etc
/datum/terror_handler/simple_source/claustrophobia
	buildup_per_second = 15

/datum/terror_handler/simple_source/claustrophobia/Destroy(force)
	owner.clear_mood_event("claustrophobia")
	return ..()

/datum/terror_handler/simple_source/claustrophobia/check_condition(seconds_per_tick, terror_buildup)
	. = ..()
	if (!.)
		return

	if (isturf(owner.loc))
		return FALSE

	if (SPT_PROB(15, seconds_per_tick))
		to_chat(owner, span_warning("You feel trapped! Must escape... can't breathe..."))

	return TRUE

/datum/terror_handler/simple_source/claustrophobia/on_activation(terror_buildup)
	. = ..()
	owner.add_mood_event("claustrophobia", /datum/mood_event/claustrophobia)

/datum/terror_handler/simple_source/claustrophobia/on_deactivation(terror_buildup)
	. = ..()
	owner.clear_mood_event("claustrophobia")

/// Makes the owner afraid of certain jolly figures
/datum/terror_handler/simple_source/clausophobia
	buildup_per_second = 20

/datum/terror_handler/simple_source/clausophobia/check_condition(seconds_per_tick, terror_buildup)
	. = ..()
	if (!.)
		return

	var/certified_jolly = FALSE

	for(var/mob/living/carbon/human/possible_claus in view(5, owner))
		if(istype(possible_claus.back, /obj/item/storage/backpack/santabag))
			certified_jolly = TRUE
			break

		if(istype(possible_claus.head, /obj/item/clothing/head/costume/santa) || istype(possible_claus.head, /obj/item/clothing/head/helmet/space/santahat))
			certified_jolly = TRUE
			break

		if(istype(possible_claus.wear_suit, /obj/item/clothing/suit/space/santa))
			certified_jolly = TRUE
			break

	if (!certified_jolly)
		return FALSE

	if (SPT_PROB(15, seconds_per_tick))
		to_chat(owner, span_warning("Santa Claus is here! I gotta get out of here!"))

	return TRUE

/// Makes the owner afraid of being alone
/datum/terror_handler/simple_source/monophobia
	buildup_per_second = 2.5 // Pretty low, ~4 minutes to reach passive cap

/datum/terror_handler/simple_source/monophobia/check_condition(seconds_per_tick, terror_buildup)
	. = ..()
	if (!.)
		return

	var/check_radius = 7
	if (owner.is_blind())
		check_radius = 1

	for (var/mob/living/friend in view(check_radius, owner))
		if (friend == owner)
			continue

		if (istype(friend, /mob/living/basic/pet) || friend.ckey)
			return FALSE

	return TRUE
