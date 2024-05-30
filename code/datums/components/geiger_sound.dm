/// Atoms with this component will play sounds depending on nearby radiation
/datum/component/geiger_sound
	var/datum/looping_sound/geiger/sound

	var/last_parent = null

/datum/component/geiger_sound/Initialize(...)
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/geiger_sound/Destroy(force)
	QDEL_NULL(sound)

	if (!isnull(last_parent))
		UnregisterSignal(last_parent, COMSIG_IN_RANGE_OF_IRRADIATION)

	last_parent = null

	return ..()

/datum/component/geiger_sound/RegisterWithParent()
	sound = new(parent)

	RegisterSignal(parent, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))

	ADD_TRAIT(parent, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))

	if (isitem(parent))
		var/atom/atom_parent = parent
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
		register_to_loc(atom_parent.loc)

/datum/component/geiger_sound/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_IN_RANGE_OF_IRRADIATION,
	))

	REMOVE_TRAIT(parent, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))

/datum/component/geiger_sound/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	sound.last_insulation_to_target = insulation_to_target
	sound.last_radiation_pulse = pulse_information
	sound.start()

	addtimer(CALLBACK(sound, TYPE_PROC_REF(/datum/looping_sound,stop)), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/geiger_sound/proc/on_moved(atom/source)
	SIGNAL_HANDLER
	register_to_loc(source.loc)

/datum/component/geiger_sound/proc/register_to_loc(new_loc)
	if (last_parent == new_loc)
		return

	if (!isnull(last_parent))
		UnregisterSignal(last_parent, COMSIG_IN_RANGE_OF_IRRADIATION)

	last_parent = new_loc

	if (!isnull(new_loc))
		RegisterSignal(new_loc, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))

/datum/looping_sound/geiger
	mid_sounds = list(
		list('sound/items/geiger/low1.ogg'=1, 'sound/items/geiger/low2.ogg'=1, 'sound/items/geiger/low3.ogg'=1, 'sound/items/geiger/low4.ogg'=1),
		list('sound/items/geiger/med1.ogg'=1, 'sound/items/geiger/med2.ogg'=1, 'sound/items/geiger/med3.ogg'=1, 'sound/items/geiger/med4.ogg'=1),
		list('sound/items/geiger/high1.ogg'=1, 'sound/items/geiger/high2.ogg'=1, 'sound/items/geiger/high3.ogg'=1, 'sound/items/geiger/high4.ogg'=1),
		list('sound/items/geiger/ext1.ogg'=1, 'sound/items/geiger/ext2.ogg'=1, 'sound/items/geiger/ext3.ogg'=1, 'sound/items/geiger/ext4.ogg'=1)
	)
	mid_length = 2
	volume = 25

	var/datum/radiation_pulse_information/last_radiation_pulse
	var/last_insulation_to_target

/datum/looping_sound/geiger/Destroy()
	last_radiation_pulse = null
	return ..()

/datum/looping_sound/geiger/get_sound()
	if (isnull(last_radiation_pulse))
		return null

	return ..(mid_sounds[get_perceived_radiation_danger(last_radiation_pulse, last_insulation_to_target)])

/datum/looping_sound/geiger/stop(null_parent = FALSE)
	. = ..()

	last_radiation_pulse = null
