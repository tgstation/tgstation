//a unique subtype of particle spewer that only runs on equip
/datum/component/particle_spewer/movement
	processes = FALSE
	var/mob/attached_signal

/datum/component/particle_spewer/movement/Destroy(force, silent)
	UnregisterSignal(source_object, COMSIG_MOVABLE_PRE_MOVE)
	. = ..()
	UnregisterSignal(attached_signal, COMSIG_MOVABLE_PRE_MOVE)
	attached_signal = null

/datum/component/particle_spewer/movement/Initialize(duration, spawn_interval, offset_x, offset_y, icon_file, particle_state, equipped_offset, burst_amount, lifetime, random_bursts)
	. = ..()
	RegisterSignal(source_object, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(spawn_particles))

/datum/component/particle_spewer/movement/handle_equip_offsets(datum/source, mob/equipper, slot)
	. = ..()
	if(attached_signal)
		UnregisterSignal(attached_signal, COMSIG_MOVABLE_PRE_MOVE)
		attached_signal = null

	attached_signal = equipper
	RegisterSignal(equipper, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(spawn_particles))

/datum/component/particle_spewer/movement/reset_offsets()
	. = ..()
	if(attached_signal)
		UnregisterSignal(attached_signal, COMSIG_MOVABLE_PRE_MOVE)
		attached_signal = null
