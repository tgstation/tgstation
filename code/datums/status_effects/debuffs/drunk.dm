// Defines for the ballmer peak.
#define BALLMER_PEAK_LOW_END 12.9
#define BALLMER_PEAK_HIGH_END 13.8
#define BALLMER_PEAK_WINDOWS_ME 26

/**
 * The drunk status effect.
 *
 * Slowly decreases in drunk_value over time,
 * causing effects based on that value.
 *
 * Whenever drunk_value is lower than 6, is replaced with "tipsy".
 */
/datum/status_effect/drunk
	id = "drunk"
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/drunk
	examine_requires_alive = TRUE
	/// The level of drunkness we are currently at.
	var/drunk_value = 0

/datum/status_effect/drunk/on_creation(mob/living/new_owner, drunk_value)
	. = ..()
	src.drunk_value = drunk_value

/datum/status_effect/drunk/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, .proc/on_heal)
	owner.sound_environment_override = SOUND_ENVIRONMENT_PSYCHOTIC
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, id, /datum/mood_event/drunk)
	return TRUE

/datum/status_effect/drunk/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, id)
	owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/datum/status_effect/drunk/get_examine_text()
	var/t_He = owner.p_they(TRUE)
	var/t_is = owner.p_are()

	// .01s are used in case the drunk value ends up to be a small decimal.
	switch(drunk_value)
		if(11 to 21)
			return "[t_He] [t_is] slightly flushed."
		if(21.01 to 41)
			return "[t_He] [t_is] flushed."
		if(41.01 to 51)
			return "[t_He] [t_is] quite flushed and [source.p_their()] breath smells of alcohol."
		if(51.01 to 61)
			return "[t_He] [t_is] very flushed and [source.p_their()] movements jerky, with breath reeking of alcohol."
		if(61.01 to 91)
			return "[t_He] look[p_s()] like a drunken mess."
		if(91.01 to INFINITY)
			return "[t_He] [t_is] a shitfaced, slobbering wreck."

	return null

/datum/status_effect/drunk/proc/on_heal(mob/living/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/drunk/tick()
	drunk_value = drunk_value - (2 * (0.005 + (drunk_value * 0.02)))
	if(drunk_value <= 0)
		qdel(src)
		return

	on_tick_effects()

/datum/status_effect/drunk/proc/on_tick_effects()
	// Return to "tipsyness" when we're below 6.
	if(drunk_value < 6)
		owner.apply_status_effect(/datum/status_effect/drunk/tipsy, drunk_value)
		return

	// Handle the Ballmer Peak.
	// If our owner is a scientist (has the trait "TRAIT_BALLMER_SCIENTIST"), there's a 5% chance
	// that they'll say one of the special "ballmer message" lines, depending their drunk-ness level.
	if(HAS_TRAIT(owner, TRAIT_BALLMER_SCIENTIST) && prob(5))
		if(drunk_value >= BALLMER_PEAK_LOW_END && drunk_value <= BALLMER_PEAK_HIGH_END)
			say(pick_list_replacements(VISTA_FILE, "ballmer_good_msg"), forced = "ballmer")

		if(drunk_value > BALLMER_PEAK_WINDOWS_ME) // by this point you're into windows ME territory
			say(pick_list_replacements(VISTA_FILE, "ballmer_windows_me_msg"), forced = "ballmer")

	// There's always a 30% chance to gain some drunken slurring
	if(prob(30))
		owner.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/speech/slurring/drunk)

	// And drunk people will always lose jitteriness
	jitteriness = max(jitteriness - (1.5 * delta_time), 0)

	// Over 11, we will constantly gain slurring up to 10 seconds of slurring.
	if(drunk_value >= 11)
		var/datum/status_effect/speech/slurring/drunk/already_slurring = owner.has_status_effect(/datum/status_effect/speech/slurring/drunk)
		if(!already_slurring || (already_slurring.duration - world.time) <= 10 SECONDS)
			owner.adjust_timed_status_effect(2.4 SECONDS, /datum/status_effect/speech/slurring/drunk)

	// Over 41, we have a 30% chance to gain confusion, and we will always have 20 seconds of dizziness.
	if(drunk_value >= 41)
		if(prob(30))
			owner.add_confusion(2)
		owner.set_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

	// Over 51, we have a 3% chance to gain a lot of confusion and vomit, and we will always have 50 seconds of dizziness
	if(drunk_value >= 51)
		if(prob(3))
			owner.add_confusion(15)
			owner.vomit() // Vomiting clears toxloss - consider this a blessing
		owner.set_timed_status_effect(50 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)

	// Over 71, we will constantly have blurry eyes
	if(drunk_value >= 71)
		owner.blur_eyes(5)

	// Over 81, we will gain constant toxloss
	if(drunk_value >= 81)
		owner.adjustToxLoss(1)
		if(stat == CONSCIOUS && prob(5))
			to_chat(owner, span_warning("Maybe you should lie down for a bit..."))

	// Over 91, we gain even more toxloss, brain damage, and have a chance of dropping into a long sleep
	if(drunk_value >= 91)
		owner.adjustToxLoss(1)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.4)
		if(prob(20) && stat == CONSCIOUS)
			// Don't put us in a deep sleep if the shuttle's here. QoL, mainly.
			if(SSshuttle.emergency.mode == SHUTTLE_DOCKED && is_station_level(owner.z))
				to_chat(owner, span_warning("You're so tired... but you can't miss that shuttle..."))

			else
				to_chat(owner, span_warning("Just a quick nap..."))
				owner.Sleeping(90 SECONDS)

	// And finally, over 100 - let's be honest, you shouldn't be alive by now.
	if(drunk_value >= 101)
		owner.adjustToxLoss(2)

/**
 * Applied at drunk values between 0 and 6.
 * Basically is the "drunk but no effects" effect.
 */
/datum/status_effect/drunk/tipsy
	alert_type = null

/datum/status_effect/drunk/tipsy/on_tick_effects()
	if(drunk_value < 6)
		return

	// If we go above 6, we become fully drunk.
	owner.apply_status_effect(/datum/status_effect/drunk, drunk_value)
