/datum/gizmodes
	var/datum/gizpulse/current_active
	var/list/active_modes = list()
	var/list/possible_active_modes = list()

	var/list/mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
	)

	var/datum/gizpulse/mode_controle/mode_pulse

/datum/gizmodes/proc/generate_modes(list/trigger_callbacks)
	for(var/path in possible_active_modes)
		active_modes += new path ()

	current_active = pick(active_modes)

	var/mode_path = pick(mode_pulses)
	mode_pulse = new mode_path()
	mode_pulse.setup_mode_controle(src, active_modes, trigger_callbacks)

/datum/gizmodes/proc/activate(atom/movable/holder)
	current_active.activate(holder)

/datum/gizpulse/proc/activate(atom/movable/holder)

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

