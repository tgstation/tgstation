// Effects given by the spacer quirk

/datum/status_effect/spacer
	id = "spacer_gravity_effects"
	status_type = STATUS_EFFECT_REPLACE
	/// Essentially, tracks whether this is a planetary map.
	/// It'd be pretty miserable if you're playing a planetary map and getting the worse of all effects, so we handwave it a bit.
	var/nerfed_effects_because_planetary = FALSE

/datum/status_effect/spacer/on_apply()
	return iscarbon(owner)

/datum/status_effect/spacer/on_creation(mob/living/new_owner, ...)
	. = ..()
	nerfed_effects_because_planetary = SSmapping.config.planetary

// The good side (being in space)
/datum/status_effect/spacer/gravity_wellness
	alert_type = null
	/// How much disgust to heal per tick
	var/disgust_healing_per_tick = 1.2
	/// How much of stamina damage and stuns to heal per tick when we've been in nograv for a while
	var/stamina_heal_per_tick = 2
	/// How many seconds of stuns to reduce per tick when we've been in nograv for a while
	var/stun_heal_per_tick = 1 SECONDS
	/// Tracks how long we've been in no gravity
	var/seconds_in_nograv = 0

/datum/status_effect/spacer/gravity_wellness/tick(seconds_per_tick, times_fired)
	var/in_nograv = !owner.has_gravity()
	var/nograv_mod = in_nograv ? 1 : 0.5
	owner.adjust_disgust(-1 * disgust_healing_per_tick * nograv_mod)

	if(!in_nograv)
		seconds_in_nograv = 0
		return

	seconds_in_nograv += (initial(tick_interval) * 0.1)

	if(seconds_in_nograv >= 1 MINUTES)
		// This has some interesting side effects with gravitum or similar negating effects that may be worth nothing
		owner.adjustStaminaLoss(-1 * stamina_heal_per_tick * initial(tick_interval) * 0.1)
		owner.AdjustAllImmobility(-1 * stun_heal_per_tick * initial(tick_interval) * 0.1)

// The bad side (being on a planet)
/datum/status_effect/spacer/gravity_sickness
	alert_type = /atom/movable/screen/alert/status_effect/gravity_sickness
	/// How much disgust to gain per tick
	var/disgust_per_tick = 1
	/// The cap to which we can apply disgust
	var/max_disgust = DISGUST_LEVEL_GROSS + 5
	/// Tracks how many seconds this has been active
	var/seconds_active = 0

/datum/status_effect/spacer/gravity_sickness/tick(seconds_per_tick, times_fired)
	if(owner.mob_negates_gravity())
		// Might seem redundant but we can totally be on a planet but have an anti-gravity effect like gravitum
		return

	seconds_active += (initial(tick_interval) * 0.1)

	var/mob/living/carbon/the_spacer = owner
	the_spacer.adjust_disgust(disgust_per_tick * initial(tick_interval) * 0.1, max = max_disgust + 5)

	if(nerfed_effects_because_planetary)
		return
	if(seconds_active < 1 MINUTES)
		return

	var/minutes_active = round(seconds_active / (1 MINUTES))
	// Sit at a passive amount of stamina damage depending on how long it's been
	if(!the_spacer.getStaminaLoss())
		the_spacer.adjustStaminaLoss(min(25, 5 * minutes_active))
	// Max disgust increases over time as well
	max_disgust = min(DISGUST_LEVEL_VERYGROSS + 5, initial(max_disgust) + 5 * minutes_active)
	// And your lungs can't really handle it good
	if(!the_spacer.internal && seconds_active % 10 == 0)
		the_spacer.losebreath = min(the_spacer.losebreath++, minutes_active, 8)

/atom/movable/screen/alert/status_effect/gravity_sickness
	name = "Gravity Sickness"
	desc = "The gravity of the planet around you is making you feel sick and tired."
	icon_state = "paralysis"

/datum/mood_event/spacer
	category = "spacer"

/datum/mood_event/spacer/in_space
	description = "Space is long and dark and empty, but it's my home."

/datum/mood_event/spacer/on_planet
	description = "I'm on a planet. The gravity here makes me uncomfotable."
	mood_change = -2

/datum/mood_event/spacer/on_planet/too_long
	description = "I've been on this planet for too long. I need to get back to space."
	mood_change = -4

/datum/movespeed_modifier/spacer
	id = "spacer"

/datum/movespeed_modifier/spacer/in_space
	movetypes = FLOATING
	blacklisted_movetypes = FLYING
	multiplicative_slowdown = -0.15

/datum/movespeed_modifier/spacer/on_planet
	movetypes = GROUND|FLYING
	blacklisted_movetypes = FLOATING
	multiplicative_slowdown = 0.2

/datum/movespeed_modifier/spacer/on_planet/too_long
	multiplicative_slowdown = 0.5
