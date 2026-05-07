// Effects given by the spacer quirk

/datum/status_effect/spacer
	id = "spacer_gravity_effects"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Essentially, tracks whether this is a planetary map.
	/// It'd be pretty miserable if you're playing a planetary map and getting the worse of all effects, so we handwave it a bit.
	VAR_FINAL/nerfed_effects_because_planetary = FALSE

/datum/status_effect/spacer/on_apply()
	return iscarbon(owner)

/datum/status_effect/spacer/on_creation(mob/living/new_owner, ...)
	. = ..()
	nerfed_effects_because_planetary = SSmapping.is_planetary()

// The good side (being in space)
/datum/status_effect/spacer/gravity_wellness
	alert_type = null
	tick_interval = 1 SECONDS
	/// How much disgust to heal per tick
	var/disgust_healing_per_second = 1
	/// How much of stamina damage to heal per tick when we've been in nograv for a while.
	var/stamina_heal_per_second = 4
	/// How many seconds of stuns to reduce per tick when we've been in nograv for a while
	var/stun_heal_per_second = 2 SECONDS
	/// How much to reduce incoming knockdown effects while in nograv for a while
	var/knockdown_multiplier = 0.8
	/// Tracks how long we've been in no gravity
	VAR_FINAL/seconds_in_nograv = 0 SECONDS
	/// Tracks if we've applied knockdown modifier reduction to the mob
	VAR_FINAL/knockdown_mod_applied = FALSE

/datum/status_effect/spacer/gravity_wellness/tick(seconds_between_ticks)
	var/in_nograv = !owner.has_gravity()
	var/nograv_mod = in_nograv ? 1 : 0.5
	owner.adjust_disgust(-1 * nograv_mod * disgust_healing_per_second * seconds_between_ticks)

	if(!in_nograv)
		seconds_in_nograv = 0 SECONDS
		if(knockdown_mod_applied)
			remove_knockdown_mod()
		return

	seconds_in_nograv += (seconds_between_ticks * 0.1)

	if(seconds_in_nograv >= 2 MINUTES)
		// With 5 stamina healing per second you'd get out of stamcrit in 5 seconds instead of the usual 10
		owner.adjust_stamina_loss(-1 * stamina_heal_per_second * seconds_between_ticks)
	if(seconds_in_nograv >= 20 SECONDS)
		owner.AdjustAllImmobility(-1 * stun_heal_per_second * seconds_between_ticks)
		if(!knockdown_mod_applied)
			apply_knockdown_mod()

/datum/status_effect/spacer/gravity_wellness/on_remove()
	. = ..()
	remove_knockdown_mod()

/datum/status_effect/spacer/gravity_wellness/proc/apply_knockdown_mod()
	if(knockdown_mod_applied || !ishuman(owner))
		return
	var/mob/living/carbon/human/the_spacer = owner
	the_spacer.physiology.knockdown_mod *= knockdown_multiplier
	knockdown_mod_applied = TRUE

/datum/status_effect/spacer/gravity_wellness/proc/remove_knockdown_mod()
	if(!knockdown_mod_applied || !ishuman(owner))
		return
	var/mob/living/carbon/human/the_spacer = owner
	the_spacer.physiology.knockdown_mod /= knockdown_multiplier
	knockdown_mod_applied = FALSE

// The bad side (being on a planet)
/datum/status_effect/spacer/gravity_sickness
	alert_type = /atom/movable/screen/alert/status_effect/gravity_sickness
	tick_interval = 1 SECONDS
	/// How much disgust to gain per tick
	var/disgust_per_tick = 1
	/// The cap to which we can apply disgust
	var/max_disgust = DISGUST_LEVEL_GROSS + 5
	/// Tracks how many seconds this has been active
	VAR_FINAL/seconds_active = 0 SECONDS

/datum/status_effect/spacer/gravity_sickness/tick(seconds_between_ticks)
	if(owner.mob_negates_gravity())
		// Might seem redundant but we can totally be on a planet but have an anti-gravity effect like gravitum
		return

	seconds_active += (seconds_between_ticks * 0.1)

	var/mob/living/carbon/the_spacer = owner
	the_spacer.adjust_disgust(disgust_per_tick, max = max_disgust + 5)

	if(nerfed_effects_because_planetary)
		return
	if(seconds_active < 2 MINUTES)
		return

	var/minutes_active = round(seconds_active / (1 MINUTES))
	// Sit at a passive amount of stamina damage depending on how long it's been
	if(!the_spacer.get_stamina_loss())
		the_spacer.adjust_stamina_loss(min(25, 5 * minutes_active))
	// Max disgust increases over time as well
	max_disgust = min(DISGUST_LEVEL_VERYGROSS + 5, initial(max_disgust) + 5 * minutes_active)
	// And your lungs can't really handle it good
	if(!the_spacer.internal && seconds_active % 10 == 0)
		the_spacer.losebreath = min(the_spacer.losebreath++, minutes_active, 8)

/atom/movable/screen/alert/status_effect/gravity_sickness
	name = "Gravity Sickness"
	desc = "The gravity of the planet around you is making you feel sick and tired."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "paralysis"

/datum/mood_event/spacer

/datum/mood_event/spacer/in_space
	description = "Space is long and dark and empty, but it's my home."

/datum/mood_event/spacer/on_planet
	description = "I'm on a planet. The gravity here makes me uncomfortable."
	mood_change = -2

/datum/mood_event/spacer/on_planet/too_long
	description = "I've been on this planet for too long. I need to get back to space."
	mood_change = -4

/datum/mood_event/spacer/on_planet/nerfed
	description = "I'm stationed on a planet. I'd love to be back in space."
	mood_change = -3

/datum/mood_event/spacer/on_planet/low_grav
	description = "This feels like I'm back home!"
	mood_change = 3

/datum/mood_event/spacer/on_planet/low_grav/add_effects(...)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(lower_mood_bonus)), 5 MINUTES, TIMER_DELETE_ME)

/datum/mood_event/spacer/on_planet/low_grav/proc/lower_mood_bonus()
	mood_change -= 1
	owner.mob_mood.update_mood()
	if(mood_change > 1)
		addtimer(CALLBACK(src, PROC_REF(lower_mood_bonus)), 5 MINUTES, TIMER_DELETE_ME)

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

/datum/movespeed_modifier/spacer/on_planet/nerfed
	multiplicative_slowdown = 0.15
