/// You can imagine a /datum/gizmodes as remote and a TV
/// The mode_controles is the remote. Maybe there's 9 buttons for 1-9, and pressing the buttons just goes to that channel!
/// Maybe there's 10 buttons, 1-9 for selecting a channel and an extra for going to the selected channel
/// Or maybe there's two buttons, one that cycles to the next number and one that then goes to that channel]
/// The giz_pulse is essentually the TV. Generally the functioning of the TV is themed, happy image :) or sad image :(
/datum/gizmodes
	/// Our paarent gizmo interface
	var/datum/gizmo_interface/interface
	/// The currently selected gizpulse
	var/datum/gizpulse/current_active

	/// Instantiated active operating modes/gizpulses
	var/list/active_gizpulses = list()
	/// Guaranted operating modes/gizpulses types
	var/list/guaranteed_active_gizpulses = list()

	/// Random gizpulses we can have. PICKWEIGHTED SO GIVE IT A VALUE (/datum/gizpulse/milk_person = 1)
	var/list/possible_active_modes = list()
	/// Min modes from possible_active_modes
	var/min_modes = 1
	/// Max modes from possible_active_modes
	var/max_modes = 2

	/// Mode controles add signals that decide how gizpulses are activated
	/// Such as cycle to the next gizpulse, directly activate a gizpulse, or select a specific gizpulse
	/// Select mode, for example, adds a callback for every gizpulse + 1 for activating that
	/// Cycle mode activate adds only one callback, which cycles to the next one and then activates it
	var/list/mode_pulses = list(
		/datum/gizpulse/mode_controle/select_mode,
		/datum/gizpulse/mode_controle/cycle_mode,
		/datum/gizpulse/mode_controle/direct_activate,
		/datum/gizpulse/mode_controle/cycle_mode/activate,
	)
	/// The selected mode controle
	var/datum/gizpulse/mode_controle/mode_pulse
	/// Time between pulses
	var/cooldown_time = 1 SECONDS
	COOLDOWN_DECLARE(cooldown_timer)

/datum/gizmodes/proc/generate_modes(list/trigger_callbacks, datum/gizmo_interface/_interface)
	interface = _interface

	var/list/modes_to_spawn = list() + guaranteed_active_gizpulses

	for(var/i in 1 to (min_modes + rand(min_modes, max_modes)))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		active_gizpulses += new path ()

	current_active = pick(active_gizpulses)

	var/mode_path = pick(mode_pulses)
	mode_pulse = new mode_path()
	mode_pulse.setup_mode_controle(src, active_gizpulses, trigger_callbacks)

/// Activate this gizmode which in turn activates the active gizpulse (you following me here?)
/datum/gizmodes/proc/activate(atom/movable/holder)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return

	COOLDOWN_START(src, cooldown_timer, cooldown_time)
	current_active.activate(holder, src, interface)

/datum/gizpulse/proc/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	return

/datum/gizpulse/mode_controle/proc/setup_mode_controle(datum/gizmodes/master, list/active_gizpulses, list/trigger_callbacks)
	return

/datum/gizpulse/mode_controle/select_mode/setup_mode_controle(datum/gizmodes/master, list/active_gizpulses, list/trigger_callbacks)
	for(var/active in active_gizpulses)
		trigger_callbacks += VARSET_CALLBACK(master, current_active, active)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/datum/gizpulse/mode_controle/cycle_mode/setup_mode_controle(datum/gizmodes/master, list/active_gizpulses, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/datum/gizpulse/mode_controle/cycle_mode/proc/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	// Move to the next mode in the list (and loop back to 1 if needed)
	master.current_active = master.active_gizpulses[((master.active_gizpulses.Find(master.current_active)) % (master.active_gizpulses.len)) + 1]

/datum/gizpulse/mode_controle/direct_activate/setup_mode_controle(datum/gizmodes/master, list/active_gizpulses, list/trigger_callbacks)
	for(var/active in active_gizpulses)
		trigger_callbacks += CALLBACK(src, PROC_REF(switch_and_activate), master, active)

/datum/gizpulse/mode_controle/direct_activate/proc/switch_and_activate(datum/gizmodes/master, datum/gizpulse/active, atom/movable/holder)
	master.current_active = active
	master.activate(holder)

/datum/gizpulse/mode_controle/cycle_mode/activate/setup_mode_controle(datum/gizmodes/master, list/active_gizpulses, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)

/datum/gizpulse/mode_controle/cycle_mode/activate/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	..()
	master.activate(holder)

////////////////////////////////////////////////////
//////////// COOL FEATURE TYPES WEEEEEE/////////////
////////////////////////////////////////////////////

/datum/gizmodes/mood_pulser
	guaranteed_active_gizpulses = list(/datum/gizpulse/mood_pulser/positive, /datum/gizpulse/mood_pulser/negative)

/// Send out a mood pulse
/datum/gizpulse/mood_pulser
	/// Mood event to give out
	var/datum/mood_event/mood
	/// Color of the ring effect (god i love the ring effect)
	var/ring_color
	/// Range of the mood pulse
	var/range = 14

/datum/gizpulse/mood_pulser/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	mood_pulse(holder)

/// Send a mood pulse to a range
/datum/gizpulse/mood_pulser/proc/mood_pulse(atom/movable/holder)
	new /obj/effect/temp_visual/circle_wave(get_turf(holder), ring_color)
	for(var/mob/living/carbon/human/human in orange(range, holder))
		human.add_mood_event("gizmo_mood_pulse", mood)

/// Make a positive mood pulse
/datum/gizpulse/mood_pulser/positive
	mood = /datum/mood_event/gizmo_positive
	ring_color = COLOR_GREEN

/// Make a negative mood pulse
/datum/gizpulse/mood_pulser/negative
	mood = /datum/mood_event/gizmo_negative
	ring_color = COLOR_RED

/// Make the holder move by adding a movement element. Signal is for aestethic interactions mostly
/datum/gizmodes/mover
	guaranteed_active_gizpulses = list(/datum/gizpulse/start_moving = 1, /datum/gizpulse/stop_moving = 1)

/datum/gizpulse/start_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.AddElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_START_MOVING)

/datum/gizpulse/stop_moving/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.RemoveElement(/datum/element/moving_randomly)
	SEND_SIGNAL(holder, COMSIG_GIZMO_STOP_MOVING)

/datum/gizmodes/lights
	guaranteed_active_gizpulses = list(/datum/gizpulse/lights_on, /datum/gizpulse/lights_off)
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
	guaranteed_active_gizpulses = list(/datum/gizpulse/voice_hint, /datum/gizpulse/language_change)
	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)

/datum/gizpulse/voice_hint/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/component/gizmo_voice/voice = holder.GetComponent(/datum/component/gizmo_voice)

	holder.say(voice.active_words.Join(" "))

/datum/gizpulse/language_change/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.grant_random_uncommon_language("gizmo")

/// Gizmo mode that regenerates, cycles and expells reagents in different functions
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

	/// Reagents that can be selected
	var/list/reagents = list(
		/datum/reagent/water,
		/datum/reagent/toxin/acid,
		/datum/reagent/consumable/salt,
		/datum/reagent/uranium/radium,
	)
	/// Reference to the reagent holder. Preferably access it from the holder instead, but some procs dont like that (process())
	var/datum/reagents/reagent_holder
	/// Reagent that is being generated right now
	var/active_reagent = /datum/reagent/water
	/// Max volume of the reagent holder we hand out
	var/max_volume = 50
	/// Amount of reagents we regenerate per second
	var/regeneration_speed = 2
	/// How many reagents we grab from get_random_reagent_id
	var/random_reagents_to_add = 1
	/// Flags to pass to the reagent holder
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

/// Get the tiles to wet
/datum/gizpulse/wet_tiles/proc/get_tiles(atom/movable/holder)
	return

/// Dump reagents in a circle
/datum/gizpulse/wet_tiles/fluid_circle
	/// Size, in a circle, around the holder for wetting
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
	holder.reagents.clear_reagents()
	master.active_reagent = pick(master.reagents - master.active_reagent) //maybe also add a cycle one instead of random

/// Teleports itself and/or others
/datum/gizmodes/teleporter
	possible_active_modes = list(
		/datum/gizpulse/teleport/self = 1,
		/datum/gizpulse/teleport/other = 1,
		/datum/gizpulse/teleport/other/and_self = 1,

	)

	min_modes = 2
	max_modes = 3

/datum/gizpulse/teleport
	/// Min distance to teleport
	var/offset_min = 5
	/// Max distance to teleport
	var/offset_max = 15

/datum/gizpulse/teleport/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/list/targets = get_teleport_targets(holder)
	var/range = rand(offset_min, offset_max)
	var/dir = pick(GLOB.alldirs)

	for(var/atom/movable/target as anything in targets)
		var/turf/new_turf = get_ranged_target_turf(target, dir, range)
		do_teleport(target, new_turf, asoundin = 'sound/effects/cartoon_sfx/cartoon_pop.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/gizpulse/teleport/proc/get_teleport_targets(atom/movable/holder)
	return list()

/datum/gizpulse/teleport/self/get_teleport_targets(atom/movable/holder)
	return list(holder)

/datum/gizpulse/teleport/other/get_teleport_targets(atom/movable/holder)
	. = list()
	for(var/mob/living/liver in view(2, holder))
		. += liver

/datum/gizpulse/teleport/other/and_self/get_teleport_targets(atom/movable/holder)
	. = ..() + holder

