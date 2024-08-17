///Plays a sound when walked into, lower sounding if the person walking into it has light stepping.
/datum/element/squish_sound
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The sound to play when something holding this element is entered.
	var/sound_to_play

/datum/element/squish_sound/Attach(
	datum/target,
	sound = 'sound/effects/footstep/gib_step.ogg',
)
	. = ..()
	sound_to_play = sound
	RegisterSignal(target, COMSIG_MOVABLE_CROSS, PROC_REF(on_cross))

///Plays the set sound upon being entered, as long as the person walking into it can actually walk.
/datum/element/squish_sound/proc/on_cross(atom/movable/source, atom/movable/crossed)
	SIGNAL_HANDLER

	if(!isliving(crossed) || (crossed.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || crossed.throwing)
		return
	playsound(
		source = source,
		soundin = sound_to_play,
		vol = HAS_TRAIT(crossed, TRAIT_LIGHT_STEP) ? 20 : 50,
		vary = TRUE,
	)
