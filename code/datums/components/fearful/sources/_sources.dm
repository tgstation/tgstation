// Terror source handlers
/// Simple source which passively increases terror based on a single condition and can do something when its added/removed
/datum/terror_handler/simple_source
	handler_type = TERROR_HANDLER_SOURCE
	/// Have we already applied our effects?
	var/active = FALSE

/datum/terror_handler/simple_source/tick(seconds_per_tick, terror_buildup)
	. = ..()
	var/temporarily_immune = HAS_TRAIT(owner, TRAIT_FEARLESS) || HAS_TRAIT(owner, TRAIT_MIND_TEMPORARILY_GONE) || IS_UNCONSCIOUS(owner)
	var/buildup_per_second = temporarily_immune ? 0 : check_condition(seconds_per_tick, terror_buildup)
	if (buildup_per_second > 0 && terror_buildup < TERROR_BUILDUP_PASSIVE_MAXIMUM)
		if (!active)
			active = TRUE
			on_activation(terror_buildup)
		. += min(buildup_per_second * seconds_per_tick, TERROR_BUILDUP_PASSIVE_MAXIMUM - terror_buildup)

	else if (active)
		active = FALSE
		on_deactivation(terror_buildup)

/**
 * Checks how much terror to build up this tick
 *
 * * seconds_per_tick - How many seconds are in each tick, static
 * * terror_buildup - How much terror the owner currently has
 *
 * Return a number, which is the amount of terror to build up this tick.
 * Return 0 for no buildup.
 */
/datum/terror_handler/simple_source/proc/check_condition(seconds_per_tick, terror_buildup)
	return 0

/// Proc that's called when the effect is first applied, for moodlets and alike
/datum/terror_handler/simple_source/proc/on_activation(terror_buildup)
	return

/// Proc that's called when the effect stops working, for moodlets and alike
/datum/terror_handler/simple_source/proc/on_deactivation(terror_buildup)
	return

/// Makes the owner terrified of darkness
/datum/terror_handler/simple_source/nyctophobia
	/// Are we counteracted by mesons?
	var/meson_negated = TRUE

/datum/terror_handler/simple_source/nyctophobia/Destroy(force)
	owner.clear_mood_event("nyctophobia")
	return ..()

/datum/terror_handler/simple_source/nyctophobia/check_condition(seconds_per_tick, terror_buildup)
	if (ishuman(owner))
		var/mob/living/carbon/human/as_human = owner
		if(as_human.dna?.species.id in list(SPECIES_SHADOW, SPECIES_NIGHTMARE))
			return 0

	if (meson_negated && (owner.sight & SEE_TURFS))
		return 0

	var/lit_tiles = 0
	var/unlit_tiles = 0

	for (var/turf/open/turf_to_check in range(1, owner))
		if (turf_to_check.check_lumcount_above(LIGHTING_TILE_IS_DARK))
			lit_tiles++
		else
			unlit_tiles++

	return lit_tiles < unlit_tiles ? 5 : 0

/datum/terror_handler/simple_source/nyctophobia/on_activation(terror_buildup)
	owner.add_mood_event("nyctophobia", /datum/mood_event/nyctophobia)

/datum/terror_handler/simple_source/nyctophobia/on_deactivation(terror_buildup)
	owner.clear_mood_event("nyctophobia")

/// Nightmare spell version with quicker buildup that shadows the quirk one, also handles removing the status upon reaching 0 terror
/datum/terror_handler/simple_source/nyctophobia/terrified
	// Overrides the base type with slower buildup
	overrides = list(/datum/terror_handler/simple_source/nyctophobia)
	meson_negated = FALSE

/datum/terror_handler/simple_source/nyctophobia/terrified/tick(seconds_per_tick, terror_buildup)
	. = ..() * 3
	if (terror_buildup == 0 && . <= 0)
		owner.RemoveComponentSource("terrified", /datum/component/fearful)

/// Makes the owner afraid of being stuck in closets, crates, mechs, etc
/datum/terror_handler/simple_source/claustrophobia
	COOLDOWN_DECLARE(message_cd)

/datum/terror_handler/simple_source/claustrophobia/Destroy(force)
	owner.clear_mood_event("claustrophobia")
	return ..()

/datum/terror_handler/simple_source/claustrophobia/check_condition(seconds_per_tick, terror_buildup)
	if (isturf(owner.loc))
		return 0

	if (COOLDOWN_FINISHED(src, message_cd) && SPT_PROB(15, seconds_per_tick))
		to_chat(owner, span_warning("You feel trapped! Must escape... can't breathe..."))
		COOLDOWN_START(src, message_cd, TERROR_MESSAGE_CD)

	return 15

/datum/terror_handler/simple_source/claustrophobia/on_activation(terror_buildup)
	owner.add_mood_event("claustrophobia", /datum/mood_event/claustrophobia)

/datum/terror_handler/simple_source/claustrophobia/on_deactivation(terror_buildup)
	owner.clear_mood_event("claustrophobia")

/// Makes the owner afraid of certain jolly figures
/datum/terror_handler/simple_source/clausophobia
	COOLDOWN_DECLARE(message_cd)

/datum/terror_handler/simple_source/clausophobia/check_condition(seconds_per_tick, terror_buildup)
	var/certified_jolly = FALSE

	for (var/mob/living/carbon/human/possible_claus in view(5, owner))
		if (possible_claus == owner)
			continue  // imagine being scared of your own existence

		if (!istype(possible_claus.wear_suit, /obj/item/clothing/suit/space/santa))
			continue

		if (istype(possible_claus.back, /obj/item/storage/backpack/santabag))
			certified_jolly = TRUE
			break

		if (istype(possible_claus.head, /obj/item/clothing/head/costume/santa) || istype(possible_claus.head, /obj/item/clothing/head/helmet/space/santahat))
			certified_jolly = TRUE
			break

	if (!certified_jolly)
		return 0

	if (COOLDOWN_FINISHED(src, message_cd) && SPT_PROB(15, seconds_per_tick))
		to_chat(owner, span_warning("Santa Claus is here! I gotta get out of here!"))
		COOLDOWN_START(src, message_cd, TERROR_MESSAGE_CD)

	return 15

/// Makes the owner afraid of being alone
/datum/terror_handler/simple_source/monophobia
	COOLDOWN_DECLARE(message_cd)

/datum/terror_handler/simple_source/monophobia/check_condition(seconds_per_tick, terror_buildup)
	var/check_radius = 7
	if (owner.is_blind())
		check_radius = 1

	for (var/mob/living/friend in view(check_radius, owner))
		if (friend == owner)
			continue

		if (istype(friend, /mob/living/basic/pet) || friend.ckey)
			return 0

	if (COOLDOWN_FINISHED(src, message_cd) && SPT_PROB(10, seconds_per_tick))
		to_chat(owner, span_warning("You feel terribly lonely..."))
		COOLDOWN_START(src, message_cd, TERROR_MESSAGE_CD)

	return 2.5 // Pretty low, ~4 minutes to reach passive cap

/// Afraid of being on fire or being near open flames (even flames such as candles or fireplaces)
/datum/terror_handler/simple_source/pyrophobia
	/// Tracks the last fire size to avoid spamming mood events
	VAR_PRIVATE/last_fire_size = -1
	/// Weakref to active fire hallucinations
	VAR_PRIVATE/datum/weakref/fire_hallucination_weakref

/datum/terror_handler/simple_source/pyrophobia/New(mob/living/new_owner, datum/component/fearful/new_component)
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_HALLUCINATING, PROC_REF(on_hallucination))

/datum/terror_handler/simple_source/pyrophobia/Destroy(force)
	UnregisterSignal(owner, COMSIG_LIVING_HALLUCINATING)
	return ..()

/datum/terror_handler/simple_source/pyrophobia/check_condition(seconds_per_tick, terror_buildup)
	var/datum/hallucination/fire/fire_hallucination = fire_hallucination_weakref?.resolve()
	if(owner.on_fire || !QDELETED(fire_hallucination))
		owner.clear_mood_event("pyrophobia") // they have the "ON FIRE" moodlet
		return max(owner.fire_stacks, fire_hallucination.fake_firestacks) * 2

	var/fire_size = owner.count_nearby_fire_sources()
	if(fire_size != last_fire_size)
		if(fire_size >= 1)
			owner.add_mood_event("pyrophobia", /datum/mood_event/pyrophobia, round(fire_size))
		else
			owner.clear_mood_event("pyrophobia")
	last_fire_size = fire_size
	// 40 -> 15 seconds to reach passive cap
	return min(round(fire_size * 3, 0.1), 40)

/datum/terror_handler/simple_source/pyrophobia/proc/on_hallucination(datum/source, datum/hallucination/hallucination)
	SIGNAL_HANDLER

	if(istype(hallucination, /datum/hallucination/fire))
		fire_hallucination_weakref = WEAKREF(hallucination)

/// While stop drop and rolling you lose a tiny bit of terror
/datum/terror_handler/is_stop_drop_rolling

/datum/terror_handler/is_stop_drop_rolling/tick(seconds_per_tick, terror_buildup)
	if (owner.has_status_effect(/datum/status_effect/stop_drop_roll))
		return -0.2 * TERROR_BUILDUP_PASSIVE_DECREASE * seconds_per_tick // reduces terror a bit because you think it's helping!
	return 0
