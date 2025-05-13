GLOBAL_LIST_EMPTY(teleporter_maze_nodes)

/obj/bitrunning/teleporter
	name = "teleporter"
	desc = "Step on this to try to map out the maze!"
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "teleporter"
	icon_state = "teleporter"
	density = FALSE
	anchored = TRUE
	flags_1 = INDESTRUCTIBLE
	var/current_id
	var/target_id
	var/teleporting = FALSE

/obj/bitrunning/teleporter/Initialize(mapload)
	. = ..()
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	GLOB.teleporter_maze_nodes += src

/obj/bitrunning/teleporter/Destroy(force)
	GLOB.teleporter_maze_nodes -= src
	UnregisterSignal(get_turf(src), COMSIG_ATOM_ENTERED)
	. = ..()

/obj/bitrunning/teleporter/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!ishuman(arrived))
		return
	if(!teleporting)
		var/obj/bitrunning/teleporter/target
		for(var/obj/bitrunning/teleporter/checked_porter in GLOB.teleporter_maze_nodes)
			if(checked_porter.current_id == target_id)
				target = checked_porter
				break
		if(!target)
			CRASH("Couldn't find target teleporter [target_id]!")
		teleporting = TRUE
		target.teleporting = TRUE
		do_teleport(arrived, get_turf(target), 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
		teleporting = FALSE
		target.teleporting = FALSE
