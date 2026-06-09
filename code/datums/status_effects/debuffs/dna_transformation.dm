/// Transforms a carbon mob into a new DNA for a set amount of time,
/// then turns them back to how they were before transformation.
/datum/status_effect/temporary_transformation
	id = "temp_dna_transformation"
	tick_interval = STATUS_EFFECT_NO_TICK
	duration = 1 MINUTES // set in on creation, this just needs to be any value to process
	alert_type = null
	/// Flags used to determine what all we're copying over
	VAR_PROTECTED/copy_dna_flags = COPY_DNA_SPECIES
	/// A reference to a COPY of the DNA that the mob will be transformed into.
	VAR_PRIVATE/datum/dna/new_dna
	/// A reference to a COPY of the DNA of the mob prior to transformation.
	VAR_PRIVATE/datum/dna/old_dna

/datum/status_effect/temporary_transformation/Destroy()
	. = ..() // parent must be called first, so we clear DNA refs AFTER transforming back... yeah i know
	QDEL_NULL(new_dna)
	QDEL_NULL(old_dna)

/datum/status_effect/temporary_transformation/on_creation(mob/living/new_owner, new_duration = 1 MINUTES, datum/dna/dna_to_copy)
	if(!iscarbon(new_owner) || isnull(dna_to_copy))
		qdel(src)
		return

	src.duration = new_duration
	src.new_dna = new()
	src.old_dna = new()
	init_dna(new_owner, dna_to_copy)
	return ..()

/datum/status_effect/temporary_transformation/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/mob/living/carbon/transforming = owner
	if(!transforming.has_dna())
		return FALSE

	save_dna()
	apply_dna()
	return TRUE

/datum/status_effect/temporary_transformation/on_remove()
	var/mob/living/carbon/transforming = owner

	if(!QDELING(owner)) // Don't really need to do appearance stuff if we're being deleted
		old_dna.copy_dna(transforming.dna, copy_dna_flags)
		transforming.updateappearance(mutcolor_update = TRUE)
		transforming.domutcheck()

	transforming.real_name = old_dna.real_name // Name is fine though
	transforming.name = transforming.get_visible_name()

/// Called when initializing the DNA that the mob is transforming into
/datum/status_effect/temporary_transformation/proc/init_dna(mob/living/carbon/new_owner, datum/dna/dna_to_copy)
	dna_to_copy.copy_dna(new_dna, copy_dna_flags)

/// Called when saving the mob's DNA before transformation
/datum/status_effect/temporary_transformation/proc/save_dna()
	var/mob/living/carbon/transforming = owner
	transforming.dna.copy_dna(old_dna, copy_dna_flags)

/// Applies the DNA to the mob
/datum/status_effect/temporary_transformation/proc/apply_dna()
	var/mob/living/carbon/transforming = owner
	new_dna.copy_dna(transforming.dna, copy_dna_flags)
	transforming.real_name = new_dna.real_name
	transforming.name = transforming.get_visible_name()
	transforming.updateappearance(mutcolor_update = TRUE)
	transforming.domutcheck()

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

		time_before_pause = duration
		duration = STATUS_EFFECT_PERMANENT

	// Resume if we're none of the above and also were paused
	else if(time_before_pause != -1)
		duration = time_before_pause
		time_before_pause = -1

/datum/status_effect/temporary_transformation/dna_injector
	id = "temp_dna_injector_transformation"
	status_type = STATUS_EFFECT_MULTIPLE
	copy_dna_flags = NONE // no touching species or mutations

// when initting dna, any unset fields are copied from the mob's dna (so nothing changes effectively)
/datum/status_effect/temporary_transformation/dna_injector/init_dna(mob/living/carbon/new_owner, datum/dna/dna_to_copy)
	. = ..()
	new_dna.real_name ||= new_owner.dna.real_name
	new_dna.unique_enzymes ||= new_owner.dna.unique_enzymes
	new_dna.unique_features ||= new_owner.dna.unique_features
	new_dna.unique_identity ||= new_owner.dna.unique_identity
	new_dna.blood_type ||= new_owner.dna.blood_type
	// just to put something there, it'll get updated if UF does anyways
	new_dna.features = new_owner.dna.features.Copy()

// ensure secondary transformation make a copy of the original dna (to prevent latter effects that expire earlier from returning to the wrong dna)
/datum/status_effect/temporary_transformation/dna_injector/save_dna()
	for(var/datum/status_effect/temporary_transformation/dna_injector/other_effect in owner.status_effects)
		other_effect.old_dna.copy_dna(src.old_dna, copy_dna_flags)
		return

	return ..()

// when the effect ends, see if there's any other active effects, and re-apply them if necessary
/datum/status_effect/temporary_transformation/dna_injector/on_remove()
	. = ..()
	if(QDELING(owner))
		return
	for(var/datum/status_effect/temporary_transformation/dna_injector/other_effect in owner.status_effects)
		other_effect.apply_dna()
