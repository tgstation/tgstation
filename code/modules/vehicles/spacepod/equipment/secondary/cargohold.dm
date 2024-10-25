/obj/item/pod_equipment/cargo_hold
	name = "cargo hold"
	desc = "Advanced spatial management tech in the form of a trunk. Wow."
	icon_state = "trunk"
	interface_id = "CargoHold"
	slot = POD_SLOT_SECONDARY
	/// what items can we hold inside
	var/static/list/cargo_whitelist = typecacheof(list(
		/obj/machinery/portable_atmospherics,
		/obj/structure/reagent_dispensers,
		/obj/machinery/nuclearbomb,
		/obj/structure/closet,
	))

/obj/item/pod_equipment/cargo_hold/examine(mob/user)
	. = ..()
	. += span_notice("Click-drag the pod to an adjacent position to remove something from it, or drag something onto the pod to add something.")
	. += span_notice("It may hold portable atmospherics devices, large reagent tanks, closets, crates or a <b>nuclear bomb</b>.")

/obj/item/pod_equipment/cargo_hold/on_attach(mob/user)
	. = ..()
	RegisterSignal(pod, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(dragged_onto_pod))
	RegisterSignal(pod, COMSIG_MOUSEDROP_ONTO, PROC_REF(dragged_elsewhere))
	RegisterSignal(pod, COMSIG_ATOM_DESTRUCTION, PROC_REF(dump_contents))

/obj/item/pod_equipment/cargo_hold/on_detach(mob/user)
	. = ..()
	UnregisterSignal(pod, list(COMSIG_MOUSEDROPPED_ONTO, COMSIG_MOUSEDROP_ONTO, COMSIG_ATOM_DESTRUCTION))
	if(!QDELING(src))
		dump_contents()

/obj/item/pod_equipment/cargo_hold/get_overlay()
	return "top_cover" //no unique overlay yet

/obj/item/pod_equipment/cargo_hold/dump_contents()
	for(var/atom/movable/content as anything in contents)
		content.forceMove(pod.drop_location())

/obj/item/pod_equipment/cargo_hold/proc/dragged_elsewhere(datum/source, atom/onto, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(dragged_elsewhere_async), onto, user)

/obj/item/pod_equipment/cargo_hold/proc/dragged_elsewhere_async(atom/onto, mob/user)
	if(!length(contents))
		return // pointless
	if(!user.can_perform_action(pod, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return
	if(!onto.Adjacent(pod))
		pod.balloon_alert(user, "too far!")
		return
	var/turf/target_turf = get_turf(onto)
	if(target_turf.is_blocked_turf_ignore_climbable())
		pod.balloon_alert(user, "destination blocked!")
		return
	if(!pod.does_lock_permit_it(user))
		return
	var/atom/movable/picked = length(contents) == 1 ? contents[1] : tgui_input_list(user, "What to remove?", "Remove what from cargo hold?", contents)
	if(!picked)
		return
	picked.Move(get_turf(onto))
	pod.visible_message(span_notice("[user] unloads [picked] from [pod]."))

/obj/item/pod_equipment/cargo_hold/proc/dragged_onto_pod(datum/source, obj/dropped_atom, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(dragged_onto_pod_async), dropped_atom, user)

/obj/item/pod_equipment/cargo_hold/proc/dragged_onto_pod_async(obj/dropped_atom, mob/user)
	if(!user.can_perform_action(pod, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return
	if(!istype(dropped_atom))
		return // no mobs sorry
	if(!dropped_atom.Adjacent(pod))
		return
	if(dropped_atom.anchored)
		pod.balloon_alert(user, "must not be anchored!")
		return
	if(length(contents))
		pod.balloon_alert(user, "full!")
		return
	if(!is_type_in_typecache(dropped_atom, cargo_whitelist))
		pod.balloon_alert(user, "cannot fit this in!")
		return
	if(!do_after(user, 1 SECONDS, pod))
		return
	dropped_atom.Move(src)
	pod.visible_message(span_notice("[user] loads [dropped_atom] into [pod]."))

/obj/item/pod_equipment/cargo_hold/ui_data(mob/user)
	. = list()
	if(length(contents))
		var/atom/stored = contents[1]
		.["storedName"] = stored.name

/obj/item/pod_equipment/cargo_hold/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			if(!length(contents))
				return
			var/atom/movable/to_drop = contents[1]
			to_drop.Move(get_step(pod, pod.dir))
