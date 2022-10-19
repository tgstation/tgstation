/// This mob leaves a trail of shadows behind them as they walk.
/datum/element/shadow_trail

/datum/element/shadow_trail/Attach(datum/target)
	. = ..()
	// Technically it can work with anything but we only have human shadow sprites,
	// so any other kind of mob using it will just look bad. Someone can easily change this later though
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/element/shadow_trail/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/// Signal proc for [COMSIG_MOVABLE_MOVED].
/datum/element/shadow_trail/proc/on_moved(mob/living/carbon/human/source, old_loc, movement_dir, forced, old_locs, momentum_change)
	SIGNAL_HANDLER

	if(!isturf(source.loc))
		return

	new /obj/effect/temp_visual/dir_setting/ninja/shadow(old_loc, source.dir)
