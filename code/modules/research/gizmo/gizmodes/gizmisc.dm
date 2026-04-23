/// Make the holder move by adding a movement element. Signal is for aestethic interactions mostly
/datum/gizmodes/mover
	guaranteed_active_gizmodes = list(/datum/gizpulse/start_moving = 1, /datum/gizpulse/stop_moving = 1)

/datum/gizpulse/start_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.AddElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING)

/datum/gizpulse/stop_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.RemoveElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING)

/// Start glowing
/datum/gizmodes/lights
	guaranteed_active_gizmodes = list(/datum/gizpulse/lights_on, /datum/gizpulse/lights_off)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

/datum/gizpulse/lights_on/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_ON_STATE)
	holder.light_power = 2
	holder.light_range = 3
	holder.light_color = LIGHT_COLOR_INTENSE_RED

	holder.set_light_on(TRUE)

/datum/gizpulse/lights_off/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_OFF_STATE)
	holder.set_light_on(FALSE)

/// Gives a voice hint or changes the voices language for use with a voice interface (i mean you give this to a wire interface or other but it then gives you
/// the info to use a voice interface)
/datum/gizmodes/voice
	guaranteed_active_gizmodes = list(/datum/gizpulse/voice_hint, /datum/gizpulse/language_change)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)

/// Spit out a hint for using the voice interface
/datum/gizpulse/voice_hint/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/component/gizmo_voice/voice = holder.GetComponent(/datum/component/gizmo_voice)

	holder.say(voice.active_words.Join(" "))

/// Pick a different language
/datum/gizpulse/language_change/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.grant_random_uncommon_language("gizmo")
