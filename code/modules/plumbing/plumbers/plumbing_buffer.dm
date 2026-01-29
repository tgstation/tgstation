/obj/machinery/plumbing/buffer
	name = "automatic buffer"
	desc = "A chemical holding tank that waits for neighbouring automatic buffers to complete before allowing a withdrawal. Connect/reset by screwdrivering"
	icon_state = "buffer"
	pass_flags_self = PASSMACHINE | LETPASSTHROW // It looks short enough.
	buffer = 200

	///List of all buffers we are connected to
	var/list/obj/machinery/plumbing/buffer/connections
	///Volume of reagents at which which this buffer is ready to send
	var/activation_volume = 100
	///The state of this machine see defines
	var/mode = AB_UNREADY

/obj/machinery/plumbing/buffer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/buffer, layer)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))

///Removes this buffer from the list of connected buffers
/obj/machinery/plumbing/buffer/proc/disconnect()
	PRIVATE_PROC(TRUE)
	if(!connections)
		return

	connections -= src
	for(var/obj/machinery/plumbing/buffer/node as anything in connections)
		node.on_reagent_change()
	connections = null

/obj/machinery/plumbing/buffer/Destroy(force)
	disconnect()
	return ..()

/obj/machinery/plumbing/buffer/examine(mob/user)
	. = ..()
	. += span_notice("It activates at a threshold of [activation_volume]u of reagents")
	switch(mode)
		if(AB_UNREADY)
			. += span_notice("It is filling up on reagents.")
		if(AB_IDLE)
			. += span_notice("It is waiting on other buffers to activate.")
		if(AB_READY)
			. += span_notice("It is sending reagents.")
	. += span_notice("Its activation threshold can be changed with by [EXAMINE_HINT("hand")].")
	. += span_notice("Its connections can be changed with a [EXAMINE_HINT("screwdriver")].")

/obj/machinery/plumbing/buffer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Set threshold"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Reset connections"
		return CONTEXTUAL_SCREENTIP_SET

	return ..()

/obj/machinery/plumbing/buffer/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	if(!anchored || !is_operational)
		return

	switch(mode)
		if(AB_UNREADY)
			icon_state += "_red"
		if(AB_IDLE)
			icon_state += "_yellow"
		if(AB_READY)
			icon_state += "_green"

/obj/machinery/plumbing/buffer/proc/on_reagent_change()
	SIGNAL_HANDLER

	if(mode == AB_UNREADY)
		if(reagents.total_volume >= activation_volume)
			mode = AB_IDLE
			update_appearance(UPDATE_ICON_STATE)

	if(mode == AB_IDLE)
		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			if(node.mode == AB_UNREADY)
				return

		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			node.mode = AB_READY
			node.update_appearance(UPDATE_ICON_STATE)

	if(mode == AB_READY)
		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			if(node.reagents.total_volume)
				return

		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			node.mode = AB_UNREADY
			node.update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/buffer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS

	//clear existing connections and ourself to it for other machines
	LAZYCLEARLIST(connections)
	LAZYADD(connections, src)

	//Discover new connections
	var/list/obj/machinery/plumbing/buffer/queue = list(src)
	var/list/obj/machinery/plumbing/buffer/visited = list(src = TRUE)
	while(queue.len)
		var/obj/machinery/plumbing/buffer/node = popleft(queue)
		for(var/direction in GLOB.cardinals)
			for(var/obj/machinery/plumbing/buffer/sub_node in get_step(node, direction))
				if(visited[sub_node])
					continue
				visited[sub_node] = TRUE

				sub_node.activation_volume = activation_volume
				sub_node.connections = connections
				LAZYADD(connections, sub_node)

				queue += sub_node

	//Ping the alert to the player
	for(var/obj/machinery/plumbing/buffer/node as anything in connections)
		node.is_operational = FALSE
		node.update_appearance(UPDATE_ICON_STATE)
		node.add_overlay(icon_state + "_alert")
		addtimer(CALLBACK(node, TYPE_PROC_REF(/atom/, cut_overlay), icon_state + "_alert"), 2 SECONDS)
		node.is_operational = TRUE
		node.mode = AB_UNREADY
		node.on_reagent_change()
		addtimer(CALLBACK(node, TYPE_PROC_REF(/atom/, update_appearance), UPDATE_ICON_STATE), 2.5 SECONDS)

/obj/machinery/plumbing/buffer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		disconnect()
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/buffer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/new_volume = tgui_input_number(user, "Enter new activation threshold", "Beepityboop", activation_volume, buffer)
	if(!new_volume || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	activation_volume = new_volume
