/datum/gizmodes
	var/datum/gizpulse/current_active
	var/list/active_modes = list()
	var/list/possible_active_modes = list()

	var/list/mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

	var/datum/gizpulse/mode_controle/mode_pulse

	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/datum/gizmodes/proc/generate_modes(list/trigger_callbacks)
	for(var/path in possible_active_modes)
		active_modes += new path ()

	current_active = pick(active_modes)

	var/mode_path = pick(mode_pulses)
	mode_pulse = new mode_path()
	mode_pulse.setup_mode_controle(src, active_modes, trigger_callbacks)

/datum/gizmodes/proc/activate(atom/movable/holder)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return

	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	current_active.activate(holder)

/datum/gizpulse/proc/activate(atom/movable/holder)
	return

/datum/gizpulse/mode_controle/proc/setup_mode_controle(datum/gizmodes/master, list/active_modes, list/trigger_callbacks)
	return

/datum/gizpulse/mode_controle/select_mode/setup_mode_controle(datum/gizmodes/master, list/active_modes, list/trigger_callbacks)
	for(var/active in active_modes)
		trigger_callbacks += VARSET_CALLBACK(master, current_active, active)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/datum/gizpulse/mode_controle/cycle_mode/setup_mode_controle(datum/gizmodes/master, list/active_modes, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/datum/gizpulse/mode_controle/cycle_mode/proc/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	// Move to the next mode in the list (and loop back to 1 if needed)
	master.current_active = master.active_modes[((master.active_modes.Find(master.current_active)) % (master.active_modes.len)) + 1]

/datum/gizpulse/mode_controle/direct_activate/setup_mode_controle(datum/gizmodes/master, list/active_modes, list/trigger_callbacks)
	for(var/active in active_modes)
		trigger_callbacks += CALLBACK(src, PROC_REF(switch_and_activate), master, active)

/datum/gizpulse/mode_controle/direct_activate/proc/switch_and_activate(datum/gizmodes/master, datum/gizpulse/active, atom/movable/holder)
	master.current_active = active
	master.activate(holder)

/datum/gizpulse/mode_controle/cycle_mode/activate/setup_mode_controle(datum/gizmodes/master, list/active_modes, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)

/datum/gizpulse/mode_controle/cycle_mode/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	..()
	master.activate(holder)

/datum/gizmodes/mood_pulser
	possible_active_modes = list(/datum/gizpulse/mood_pulser/positive, /datum/gizpulse/mood_pulser/negative)

/datum/gizpulse/mood_pulser
	var/datum/mood_event/mood
	var/ring_color
	var/range = 14

/datum/gizpulse/mood_pulser/activate(atom/movable/holder)
	mood_pulse(holder)

/datum/gizpulse/mood_pulser/proc/mood_pulse(atom/movable/holder)
	new /obj/effect/temp_visual/circle_wave(get_turf(holder), ring_color)
	for(var/mob/living/carbon/human/human in orange(range, holder))
		human.add_mood_event("gizmo_mood_pulse", mood)

/datum/gizpulse/mood_pulser/positive
	mood = /datum/mood_event/gizmo_positive
	ring_color = COLOR_GREEN

/datum/gizpulse/mood_pulser/negative
	mood = /datum/mood_event/gizmo_negative
	ring_color = COLOR_RED

/datum/gizmodes/mover
	possible_active_modes = list(/datum/gizpulse/start_moving, /datum/gizpulse/stop_moving)

/datum/gizpulse/start_moving/activate(atom/movable/holder)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING)

/datum/gizpulse/stop_moving/activate(atom/movable/holder)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING)

/datum/gizmodes/lights
	possible_active_modes = list(/datum/gizpulse/lights_on, /datum/gizpulse/lights_off)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

/datum/gizpulse/lights_on/activate(atom/movable/holder)
	SEND_SIGNAL(holder, COMSIG_GIZMO_ON_STATE)
	holder.light_power = 2
	holder.light_range = 3
	holder.light_color = LIGHT_COLOR_INTENSE_RED
	holder.light_on = TRUE

/datum/gizpulse/lights_off/activate(atom/movable/holder)
	SEND_SIGNAL(holder, COMSIG_GIZMO_OFF_STATE)
	holder.light_on = FALSE
