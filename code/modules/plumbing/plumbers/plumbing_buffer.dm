#define UNREADY 0
#define IDLE 1
#define READY 2

/obj/machinery/plumbing/buffer
	name = "automatic buffer"
	desc = "A chemical holding tank that waits for neighbouring automatic buffers to complete before allowing a withdrawal. Connect/reset by screwdrivering"
	icon_state = "buffer"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // It looks short enough.
	buffer = 200

	var/datum/buffer_net/buffer_net
	var/activation_volume = 100
	var/mode

/obj/machinery/plumbing/buffer/Initialize(mapload, bolt, layer)
	. = ..()

	AddComponent(/datum/component/plumbing/buffer, bolt, layer)

/obj/machinery/plumbing/buffer/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

/obj/machinery/plumbing/buffer/proc/on_reagent_change()
	SIGNAL_HANDLER
	if(!buffer_net)
		return
	if(reagents.total_volume >= activation_volume && mode == UNREADY)
		mode = IDLE
		buffer_net.check_active()

	else if(reagents.total_volume < activation_volume && mode != UNREADY)
		mode = UNREADY
		buffer_net.check_active()

/obj/machinery/plumbing/buffer/update_icon()
	. = ..()
	icon_state = initial(icon_state)
	if(buffer_net)
		switch(mode)
			if(UNREADY)
				icon_state += "_red"
			if(IDLE)
				icon_state += "_yellow"
			if(READY)
				icon_state += "_green"

/obj/machinery/plumbing/buffer/proc/attempt_connect()

	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		for(var/atom/movable/movable in T)
			if(istype(movable, /obj/machinery/plumbing/buffer))
				var/obj/machinery/plumbing/buffer/neighbour = movable
				if(neighbour.buffer_net != buffer_net)
					neighbour.buffer_net?.destruct()
					//we could put this on a proc, but its so simple I dont think its worth the overhead
					buffer_net.buffer_list += neighbour
					neighbour.buffer_net = buffer_net
					neighbour.attempt_connect() //technically this would runtime if you made about 200~ buffers

	add_overlay(icon_state + "_alert")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, cut_overlay), icon_state + "_alert"), 2 SECONDS)

/obj/machinery/plumbing/buffer/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/new_volume = tgui_input_number(user, "Enter new activation threshold", "Beepityboop", activation_volume, buffer)
	if(!new_volume || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	activation_volume = new_volume
	to_chat(user, span_notice("New activation threshold is now [activation_volume]."))
	return

/obj/machinery/plumbing/buffer/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, span_notice("You reset the automatic buffer."))

		//reset the net
		buffer_net?.destruct()
		buffer_net = new()
		LAZYADD(buffer_net.buffer_list, src)

		attempt_connect()
	else
		return . = ..()

/obj/machinery/plumbing/buffer/doMove(destination)
	. = ..()
	buffer_net?.destruct()

/datum/buffer_net
	var/list/obj/machinery/plumbing/buffer/buffer_list

/datum/buffer_net/proc/destruct()
	for(var/obj/machinery/plumbing/buffer/buffer in buffer_list)
		buffer.buffer_net = null
	buffer_list.Cut()
	qdel(src)

/datum/buffer_net/proc/check_active()
	var/ready = TRUE
	for(var/obj/machinery/plumbing/buffer/buffer in buffer_list)
		if(buffer.mode == UNREADY)
			ready = FALSE
			break
	for(var/obj/machinery/plumbing/buffer/buffer in buffer_list)
		if(buffer.mode == READY && !ready)
			buffer.mode = IDLE
		else if(buffer.mode == IDLE && ready)
			buffer.mode = READY
		buffer.update_icon()

#undef UNREADY
#undef IDLE
#undef READY
