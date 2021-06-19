#define UNREADY 0
#define IDLE 1
#define READY 2

/obj/machinery/plumbing/buffer
	name = "automatic buffer"
	desc = "A chemical holding tank that waits for neighbouring automatic buffers to complete before allowing a withdrawal. Connect/reset by screwdrivering"
	icon_state = "buffer"
	buffer = 200

	var/datum/buffer_net/buffer_net
	var/activation_volume = 100
	var/mode

/obj/machinery/plumbing/buffer/Initialize(mapload, bolt)
	. = ..()

	AddComponent(/datum/component/plumbing/buffer, bolt)

/obj/machinery/plumbing/buffer/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/buffer/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_PARENT_QDELETING))
	return NONE

/obj/machinery/plumbing/buffer/proc/on_reagent_change()
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
	addtimer(CALLBACK(src, /atom/.proc/cut_overlay, icon_state + "_alert"), 20)

/obj/machinery/plumbing/buffer/attack_hand_secondary(mob/user, modifiers)
	. = ..()

	var/new_volume = input(user, "Enter new activation threshold", "Beepityboop", activation_volume) as num|null
	if(!new_volume)
		return

	activation_volume = round(clamp(new_volume, 0, buffer))
	to_chat(user, "<span class='notice'>New activation threshold is now [activation_volume].</span>")

/obj/machinery/plumbing/buffer/attackby(obj/item/item, mob/user, params)
	if(item.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>You reset the automatic buffer.</span>")

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
