/// Transforms a carbon mob into a new DNA for a set amount of time,
/// then turns them back to how they were before transformation.
/datum/status_effect/temporary_transformation
	id = "temp_dna_transformation"
	tick_interval = STATUS_EFFECT_NO_TICK
	duration = 1 MINUTES // set in on creation, this just needs to be any value to process
	alert_type = null
	/// A reference to a COPY of the DNA that the mob will be transformed into.
	var/datum/dna/new_dna
	/// A reference to a COPY of the DNA of the mob prior to transformation.
	var/datum/dna/old_dna

/datum/status_effect/temporary_transformation/Destroy()
	. = ..() // parent must be called first, so we clear DNA refs AFTER transforming back... yeah i know
	QDEL_NULL(new_dna)
	QDEL_NULL(old_dna)

/datum/status_effect/temporary_transformation/on_creation(mob/living/new_owner, new_duration = 1 MINUTES, datum/dna/dna_to_copy)
	src.duration = new_duration
	src.new_dna = new()
	src.old_dna = new()
	dna_to_copy.copy_dna(new_dna)
	return ..()

/datum/status_effect/temporary_transformation/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/mob/living/carbon/transforming = owner
	if(!transforming.has_dna())
		return FALSE

	// Save the old DNA
	transforming.dna.copy_dna(old_dna)
	// Makes them into the new DNA
	new_dna.copy_dna(transforming.dna, COPY_DNA_SPECIES)
	transforming.real_name = new_dna.real_name
	transforming.name = transforming.get_visible_name()
	transforming.updateappearance(mutcolor_update = TRUE)
	transforming.domutcheck()
	return TRUE

/datum/status_effect/temporary_transformation/on_remove()
	var/mob/living/carbon/transforming = owner

	if(!QDELING(owner)) // Don't really need to do appearance stuff if we're being deleted
		old_dna.copy_dna(transforming.dna, COPY_DNA_SPECIES)
		transforming.updateappearance(mutcolor_update = TRUE)
		transforming.domutcheck()

	transforming.real_name = old_dna.real_name // Name is fine though
	transforming.name = transforming.get_visible_name()

/datum/status_effect/temporary_transformation/trans_sting
	/// Tracks the time left on the effect when the owner last died. Used to pause the effect.
	var/time_before_pause = -1
	/// Signals which we react to to determine if we should pause the effect.
	var/static/list/update_on_signals = list(
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_STASIS),
		SIGNAL_REMOVETRAIT(TRAIT_STASIS),
		SIGNAL_ADDTRAIT(TRAIT_DEATHCOMA),
		SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA),
	)

/datum/status_effect/temporary_transformation/trans_sting/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignals(owner, update_on_signals, PROC_REF(pause_effect))
	pause_effect(owner) // for if we sting a dead guy

/datum/status_effect/temporary_transformation/trans_sting/on_remove()
	. = ..()
	UnregisterSignal(owner, update_on_signals)

/datum/status_effect/temporary_transformation/trans_sting/proc/pause_effect(mob/living/source)
	SIGNAL_HANDLER

	// Pause if we're dead, appear dead, or in stasis
	if(source.stat == DEAD || HAS_TRAIT(source, TRAIT_DEATHCOMA) || HAS_TRAIT(source, TRAIT_STASIS))
		if(duration == STATUS_EFFECT_PERMANENT)
			return // Already paused

		time_before_pause = duration - world.time
		duration = STATUS_EFFECT_PERMANENT

	// Resume if we're none of the above and also were paused
	else if(time_before_pause != -1)
		duration = time_before_pause + world.time
		time_before_pause = -1
