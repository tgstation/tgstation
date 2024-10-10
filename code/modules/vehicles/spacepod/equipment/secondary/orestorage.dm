/obj/item/pod_equipment/orestorage
	name = "pod ore scoop"
	desc = "Picks up and stores ore this pod moves over. Handy!"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "brassbox" //placeholder
	slot = POD_SLOT_SECONDARY
	interface_id = "OreHold"

/obj/item/pod_equipment/orestorage/on_attach(mob/user)
	. = ..()
	RegisterSignal(pod, COMSIG_MOVABLE_MOVED, PROC_REF(ore_pickup))

/obj/item/pod_equipment/orestorage/on_detach(mob/user)
	. = ..()
	UnregisterSignal(pod, COMSIG_MOVABLE_MOVED)
	if(!QDELETED(pod) && !isnull(user))
		dump_contents()

/obj/item/pod_equipment/orestorage/get_overlay()
	return "top_cover" //no unique overlay yet

/obj/item/pod_equipment/orestorage/dump_contents()
	var/turf/turf_ahead = get_step(pod, pod.dir)
	var/turf/target = turf_ahead.is_blocked_turf_ignore_climbable() ? pod.drop_location() : turf_ahead
	for(var/atom/movable/content as anything in contents)
		content.forceMove(target)

/obj/item/pod_equipment/orestorage/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	for(var/obj/item/stack/ore/ore in get_turf(pod))
		INVOKE_ASYNC(src, PROC_REF(move_ore), ore)
		playsound(src, SFX_RUSTLE, 50, TRUE)

/obj/item/pod_equipment/orestorage/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/stored_ore as anything in contents)
		if(!ore.can_merge(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
		break
	ore.forceMove(src)

/obj/item/pod_equipment/orestorage/ui_data(mob/user)
	. = list()
	.["ores"] = list()
	for(var/obj/item/stack/ore/ore as anything in contents)
		var/ore_data = list(
			"name" = ore.name,
			"count" = ore.amount,
		)
		.["ores"] += list(ore_data)

/obj/item/pod_equipment/orestorage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			dump_contents()
			return TRUE
