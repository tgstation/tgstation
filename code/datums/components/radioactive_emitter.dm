/**
 * # Radioactive Emitter
 *
 * Simple component that you can attach to something to make it emit radiation pulses over time.
 *
 * Additionally allows you to pass one or multiple signals to clean up the component when a certain sig is sent.
 */
/datum/component/radioactive_emitter
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// The actual cooldown between rad pulses
	COOLDOWN_DECLARE(rad_pulse_cooldown)

	/// The length of the cooldown between radiation pulses
	var/cooldown_time = 5 SECONDS
	/// How far the radiation pulses aggregate with other radiation pulses (see: [proc/radiation_pulse])
	var/range = 1
	/// How much radiation protection threshold is passed to the radiation pulse (see: [proc/radiation_pulse])
	var/threshold = RAD_MEDIUM_INSULATION
	/// Optional - What is shown on examine of the parent? If not set, no signal will register
	var/examine_text

/datum/component/radioactive_emitter/Initialize(
	cooldown_time = 5 SECONDS,
	range = 1,
	threshold = RAD_MEDIUM_INSULATION,
	examine_text,
)

	if(!isturf(parent) && !ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.cooldown_time = max(cooldown_time, 0.25 SECONDS) // We'll cap it at every 4th of a second, we use fastprocess after all
	src.range = range
	src.threshold = threshold
	src.examine_text = examine_text

	// We process on fastprocess even though we're on a cooldown system, just so we're sure that we catch the next cooldown
	START_PROCESSING(SSfastprocess, src)

/datum/component/radioactive_emitter/Destroy(force, silent)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/component/radioactive_emitter/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/radioactive_emitter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/datum/component/radioactive_emitter/InheritComponent(
	datum/component/new_comp,
	i_am_original,
	cooldown_time = 5 SECONDS,
	range = 1,
	threshold = RAD_NO_INSULATION,
	examine_text,
)

	// Only care about modifying our rad wave argument
	// Don't touch examine text or whatever else
	src.cooldown_time = cooldown_time
	src.range = range
	src.threshold = threshold

/datum/component/radioactive_emitter/process(delta_time)
	if(!COOLDOWN_FINISHED(src, rad_pulse_cooldown))
		return

	COOLDOWN_START(src, rad_pulse_cooldown, cooldown_time)
	radiation_pulse(parent, range, threshold)

/datum/component/radioactive_emitter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!examine_text)
		return

	examine_list += examine_text
