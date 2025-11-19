/// Used for tracking mobs that have had synthetic blood injected into them.
/// The higher the synth content, the more nerfed the blood is for blood worms.
/// This decays over time while the mob is alive.
/datum/component/synth_blood
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// 0-1 of how synthetic this mobs blood is right now.
	var/current_synth_content = 0

/datum/component/synth_blood/Initialize(added_synth_content = 0)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if (current_synth_content + added_synth_content <= 0)
		return COMPONENT_REDUNDANT

	current_synth_content = clamp(current_synth_content + added_synth_content, 0, 1)

	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/synth_blood/Destroy(force)
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)
	return ..()

/datum/component/synth_blood/proc/on_life(mob/living/living_parent, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if (current_synth_content <= 0)
		qdel(src)
	else if (living_parent.stat != DEAD)
		// Five minutes (or 300 seconds) to fully clear synth content from one to zero.
		current_synth_content = max(current_synth_content - (1/300) * seconds_per_tick, 0)
