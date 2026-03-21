/datum/gizmodes
	var/datum/gizmo_interface/interface
	var/datum/gizpulse/current_active

	var/list/active_modes = list()
	var/list/guaranteed_active_modes = list()

	var/list/possible_active_modes = list()
	var/min_modes = 1
	var/max_modes = 2

	var/list/mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

	var/datum/gizpulse/mode_controle/mode_pulse

	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/datum/gizmodes/proc/generate_modes(list/trigger_callbacks, datum/gizmo_interface/_interface)
	interface = _interface

	var/list/modes_to_spawn = list() + guaranteed_active_modes

	for(var/i in 1 to (min_modes + rand(min_modes, max_modes)))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		active_modes += new path ()

	current_active = pick(active_modes)

	var/mode_path = pick(mode_pulses)
	mode_pulse = new mode_path()
	mode_pulse.setup_mode_controle(src, active_modes, trigger_callbacks)

/datum/gizmodes/proc/activate(atom/movable/holder)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return

	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	current_active.activate(holder, src, interface)

/datum/gizpulse/proc/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
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

////////////////////////////////////////////////////
//////////// COOL FEATURE TYPES WEEEEEE/////////////
////////////////////////////////////////////////////

/datum/gizmodes/mood_pulser
	guaranteed_active_modes = list(/datum/gizpulse/mood_pulser/positive, /datum/gizpulse/mood_pulser/negative)

/datum/gizpulse/mood_pulser
	var/datum/mood_event/mood
	var/ring_color
	var/range = 14

/datum/gizpulse/mood_pulser/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
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
	guaranteed_active_modes = list(/datum/gizpulse/start_moving = 1, /datum/gizpulse/stop_moving = 1)

/datum/gizpulse/start_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING)

/datum/gizpulse/stop_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING)

/datum/gizmodes/lights
	guaranteed_active_modes = list(/datum/gizpulse/lights_on, /datum/gizpulse/lights_off)
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
	guaranteed_active_modes = list(/datum/gizpulse/voice_hint, /datum/gizpulse/language_change)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)

/datum/gizpulse/voice_hint/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/component/gizmo_voice/voice = holder.GetComponent(/datum/component/gizmo_voice)

	holder.say(voice.active_words.Join(" "))

/datum/gizpulse/language_change/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.grant_random_uncommon_language("gizmo")

/datum/gizmodes/mopper
	possible_active_modes = list(
		/datum/gizpulse/wet_tiles/fluid_circle/small = 1,
		/datum/gizpulse/wet_tiles/fluid_circle/medium = 1,
		/datum/gizpulse/wet_tiles/fluid_circle/large = 1,
		/datum/gizpulse/fluid_smoke = 1,
		/datum/gizpulse/swap_reagent = 1,
		)

	min_modes = 3
	max_modes = 5

	mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)

	var/list/reagents = list(
		/datum/reagent/water,
		/datum/reagent/toxin/acid,
		/datum/reagent/consumable/salt,
		/datum/reagent/uranium/radium,
	)
	/// Reference to the reagent holder. Preferably access it from the holder instead, but some procs dont like that (process())
	var/datum/reagents/reagent_holder

	var/active_reagent = /datum/reagent/water

	var/max_volume = 50

	var/regeneration_speed = 2

	var/random_reagents_to_add = 1

	var/reagent_flags = AMOUNT_VISIBLE

/datum/gizmodes/mopper/New()
	. = ..()

	for(var/i in 1 to random_reagents_to_add)
		reagents += get_random_reagent_id()

/datum/gizmodes/mopper/activate(atom/movable/holder)
	if(!holder.reagents)
		holder.create_reagents(max_volume, reagent_flags)
		holder.reagents.add_reagent(active_reagent, max_volume)
		reagent_holder = holder.reagents
		START_PROCESSING(SSdcs, src)
	. = ..()

/datum/gizmodes/mopper/process(seconds_per_tick)
	reagent_holder.add_reagent(active_reagent, regeneration_speed * seconds_per_tick)

/datum/gizpulse/wet_tiles/activate(atom/movable/holder, datum/gizmodes/mopper/master, datum/gizmo_interface/interface)
	var/list/tiles = get_tiles(holder)
	for(var/turf/open/tile in tiles)
		tile.expose_reagents(holder.reagents.reagent_list, holder.reagents)

		holder.reagents.expose(tile, TOUCH, 1, master.max_volume / tiles.len)
		holder.reagents.remove_reagent(master.active_reagent, master.max_volume / tiles.len)

/datum/gizpulse/wet_tiles/proc/get_tiles(atom/movable/holder)
	return

/datum/gizpulse/wet_tiles/fluid_circle
	var/size = 0

/datum/gizpulse/wet_tiles/fluid_circle/get_tiles(atom/movable/holder)
	return range(size, holder)

/datum/gizpulse/wet_tiles/fluid_circle/small
	size = 1

/datum/gizpulse/wet_tiles/fluid_circle/medium
	size = 2

/datum/gizpulse/wet_tiles/fluid_circle/large
	size = 3

/datum/gizpulse/fluid_smoke/activate(atom/movable/holder, datum/gizmo_interface/interface)
	do_chem_smoke(3, holder, get_turf(holder), carry = holder.reagents)
	holder.reagents.clear_reagents()

/datum/gizpulse/swap_reagent/activate(atom/movable/holder, datum/gizmodes/mopper/master, datum/gizmo_interface/interface)
	master.active_reagent = pick(master.reagents - master.active_reagent) //maybe also add a cycle one instead of random

