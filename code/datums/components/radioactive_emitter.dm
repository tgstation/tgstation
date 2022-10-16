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
	/// Optional - a list of signals which, if caught, will result in the component terminating
	var/list/signals_which_delete_us
	/// Optional - If we have a list of signals, what do we return from them?
	var/sigreturn = NONE
	/// Optional - a callback invoked when one of the above signals is caught, so you can call behavior to determine whether it actually gets deleted
	var/datum/callback/on_signal_callback

/datum/component/radioactive_emitter/Initialize(
	cooldown_time = 5 SECONDS,
	range = 1,
	threshold = RAD_MEDIUM_INSULATION,
	examine_text,
	list/signals_which_delete_us,
	sigreturn = NONE,
	datum/callback/on_signal_callback,
)

	if(!isturf(parent) && !ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.cooldown_time = max(cooldown_time, 0.25 SECONDS) // We'll cap it at every 4th of a second, we use fastprocess after all
	src.range = range
	src.threshold = threshold
	src.examine_text = examine_text
	src.signals_which_delete_us = signals_which_delete_us
	src.sigreturn = sigreturn
	src.on_signal_callback = on_signal_callback

	// We process on fastprocess even though we're on a cooldown system, just so we're sure that we catch the next cooldown
	START_PROCESSING(SSfastprocess, src)

/datum/component/radioactive_emitter/Destroy(force, silent)
	STOP_PROCESSING(SSfastprocess, src)
	QDEL_NULL(on_signal_callback)
	return ..()

/datum/component/radioactive_emitter/RegisterWithParent()
	if(length(signals_which_delete_us))
		RegisterSignal(parent, signals_which_delete_us, .proc/delete_us)

	if(examine_text)
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/radioactive_emitter/UnregisterFromParent()
	if(length(signals_which_delete_us))
		UnregisterSignal(parent, signals_which_delete_us)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/datum/component/radioactive_emitter/InheritComponent(
	datum/component/new_comp,
	i_am_original,
	processing_subsystem = SSprocessing,
	cooldown_time = 5 SECONDS,
	range = 1,
	threshold = RAD_NO_INSULATION,
	examine_text,
	list/signals_which_delete_us,
	sigreturn,
	datum/callback/on_signal_callback,
)

	// Only care about modifying our rad arguments
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

	examine_list += examine_text

/datum/component/radioactive_emitter/proc/delete_us(datum/source, ...)
	SIGNAL_HANDLER

	if(on_signal_callback)
		INVOKE_ASYNC(src, .proc/aync_delete_us, args)
	else
		qdel(src)

	return sigreturn

/datum/component/radioactive_emitter/proc/aync_delete_us(list/sig_args)
	if(!on_signal_callback.Invoke(arglist(sig_args)))
		return

	qdel(src)
