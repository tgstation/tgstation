/datum/gizmo_interface
    /// The gizmo master ultra mega controller
    var/datum/gizmo_controller/controller
    /// The puzzle that connects the interface to the activation callbacks
    var/datum/gizmo_puzzle_handler/puzzle = /datum/gizmo_puzzle_handler

    /// List (or list define) for the gizmodes to pick
    var/list/effects = GIZMO_COMMON_MODES
    /// Guaranteed active combinations
    var/list/guaranteed_active_gizmodes = list()
    /// The combination instances
    var/list/active_gizmodes = list()
    /// The current combination to be triggered
    var/datum/gizmo_effect_combination/current_active

    /// Min modes to select from effects
    var/min_modes = 1
    /// Max modes to select from effects
    var/max_modes = 2

/datum/gizmo_interface/New(datum/gizmo_controller/controller)
    . = ..()
    src.controller = controller

/// Instantiate the active modes, tell them to pass their callbacks to the puzzle maker
/datum/gizmo_interface/proc/generate_interface(atom/movable/holder)
    var/list/trigger_callbacks = list()
    var/list/modes_to_spawn = list() + guaranteed_active_gizmodes

    for(var/i in 1 to rand(min_modes, max_modes))
        var/path = pick_weight_take(effects)
        if(!path)
            break
        modes_to_spawn += path

    trigger_callbacks[src] = CALLBACK(src, PROC_REF(execute_active), holder)

    for(var/path in modes_to_spawn)
        var/datum/gizmo_effect_combination/mode = new path()
        mode.interface = src
        active_gizmodes += mode

        trigger_callbacks[mode] = CALLBACK(src, PROC_REF(select_mode), mode)

    puzzle = new puzzle()
    puzzle.generate_code_sequences(trigger_callbacks)

/datum/gizmo_interface/proc/select_mode(datum/gizmo_effect_combination/mode)
    current_active = mode

/datum/gizmo_interface/proc/execute_active(atom/movable/holder)
    if(!current_active)
        return
    current_active.activate(holder)

/datum/gizmo_interface/beyblade
    guaranteed_active_gizmodes = list(/datum/gizmo_effect_combination/mover)
    min_modes = 0
    max_modes = 1

/datum/gizmo_interface/toggle
    guaranteed_active_gizmodes = list(/datum/gizmo_effect_combination/lights)

/datum/gizmo_interface/voice_unlock
    guaranteed_active_gizmodes = list(/datum/gizmo_effect_combination/voice)
    min_modes = 0
    max_modes = 0

/datum/gizmo_interface/voice
    puzzle = /datum/gizmo_puzzle_handler/voice

/datum/gizmo_interface/cursed
    effects = list(/datum/gizmo_effect_combination/dangerous = 1)
    max_modes = 1
