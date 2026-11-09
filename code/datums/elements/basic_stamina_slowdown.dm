/// Applies a simple scaling slowdown as a mob's stamina is depleted
/datum/element/basic_stamina_slowdown
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// How much stamina damage need we take before we start moving slower?
	var/minium_stamina_threshold
	/// How much stamina damage can we have at maximum?
	var/maximum_stamina
	/// How slow do we move with the maximum stamina damage?
	var/maximum_slowdown

/datum/element/basic_stamina_slowdown/Attach(datum/target, minium_stamina_threshold = 40, maximum_stamina = 120, maximum_slowdown = 12)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.minium_stamina_threshold = minium_stamina_threshold
	src.maximum_stamina = maximum_stamina
	src.maximum_slowdown = maximum_slowdown
	RegisterSignal(target, COMSIG_LIVING_STAMINA_UPDATE, PROC_REF(on_stamina_changed))

/datum/element/basic_stamina_slowdown/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_STAMINA_UPDATE)

/// When our stamina changes check how slow we should be
/datum/element/basic_stamina_slowdown/proc/on_stamina_changed(mob/living/source)
	SIGNAL_HANDLER
	if (source.staminaloss >= minium_stamina_threshold)
		var/current_slowdown = (source.staminaloss / maximum_stamina) * maximum_slowdown
		source.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/basic_stamina_slowdown, TRUE, multiplicative_slowdown = current_slowdown)
	else
		source.remove_movespeed_modifier(/datum/movespeed_modifier/basic_stamina_slowdown)
