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
	var/list/active_gizmodes = list()
	/// Guaranted operating modes/gizpulses types. use GIZMO_PICK_ONE with an associated list for more bespoke guaranteed picking
	var/list/guaranteed_active_gizmodes = list()

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

/// Pick the paths to generate and instantiate them
/datum/gizmodes/proc/generate_modes(list/trigger_callbacks, datum/gizmo_interface/interface)
	interface = src.interface

	var/list/modes_to_spawn = list()

	for(var/path in guaranteed_active_gizmodes)
		if(path == GIZMO_PICK_ONE)
			var/list/nested_list = guaranteed_active_gizmodes[path]
			modes_to_spawn += pick_weight(nested_list)
		else
			modes_to_spawn += path

	for(var/i in 1 to rand(min_modes, max_modes))
		var/path = pick_weight_take(possible_active_modes)
		if(!path)
			break
		modes_to_spawn += path

	for(var/path in modes_to_spawn)
		active_gizmodes += new path ()

	current_active = pick(active_gizmodes)

	var/mode_path = pick(mode_pulses)
	mode_pulse = new mode_path()
	mode_pulse.setup_mode_controle(src, active_gizmodes, trigger_callbacks)

/// Activate this gizmode which in turn activates the active gizpulse (you following me here?)
/datum/gizmodes/proc/activate(atom/movable/holder)
	if(current_active.affect_timer)
		if(!COOLDOWN_FINISHED(src, cooldown_timer))
			return

		COOLDOWN_START(src, cooldown_timer, cooldown_time)
	current_active.activate(holder, src, interface)

/// Holds some functionaly that is activated and selected by the /gizmodes
/datum/gizpulse
	/// If TRUE, put the gizmode into cooldown
	var/affect_timer = TRUE

/// Activate it do so stuff
/datum/gizpulse/proc/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	return

/// Changes the currently activate gizpulse and adds a way to activate gizpulses
/datum/gizpulse/mode_controle
	affect_timer = FALSE

/// Select how activating the pulzes interacts with the gizpulses
/datum/gizpulse/mode_controle/proc/setup_mode_controle(datum/gizmodes/master, list/active_gizmodes, list/trigger_callbacks)
	return

/// Adds a puzzle for every possible made to select it, and a single wire to activate the selected mode
/datum/gizpulse/mode_controle/select_mode/setup_mode_controle(datum/gizmodes/master, list/active_gizmodes, list/trigger_callbacks)
	for(var/active in active_gizmodes)
		trigger_callbacks += VARSET_CALLBACK(master, current_active, active)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/// Adds a puzzle to cycle to the next gizpulse, and a puzzle to activate the currently active mode
/datum/gizpulse/mode_controle/cycle_mode/setup_mode_controle(datum/gizmodes/master, list/active_gizmodes, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)
	trigger_callbacks += CALLBACK(master, PROC_REF(activate))

/datum/gizpulse/mode_controle/cycle_mode/proc/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	// Move to the next mode in the list (and loop back to 1 if needed)
	master.current_active = master.active_gizmodes[((master.active_gizmodes.Find(master.current_active)) % (master.active_gizmodes.len)) + 1]

/// Adds a puzzle for every gizpulse that just immediately activates that gizpulse
/datum/gizpulse/mode_controle/direct_activate/setup_mode_controle(datum/gizmodes/master, list/active_gizmodes, list/trigger_callbacks)
	for(var/active in active_gizmodes)
		trigger_callbacks += CALLBACK(src, PROC_REF(switch_and_activate), master, active)

/datum/gizpulse/mode_controle/direct_activate/proc/switch_and_activate(datum/gizmodes/master, datum/gizpulse/active, atom/movable/holder)
	master.current_active = active
	master.activate(holder)

/// Adds a single wire, that cycles and then activates
/datum/gizpulse/mode_controle/cycle_mode/activate/setup_mode_controle(datum/gizmodes/master, list/active_gizmodes, list/trigger_callbacks)
	trigger_callbacks += CALLBACK(src, PROC_REF(cycle_mode), master)

/datum/gizpulse/mode_controle/cycle_mode/activate/cycle_mode(datum/gizmodes/master, atom/movable/holder)
	..()
	master.activate(holder)
