// idea inspired by vgstation, original pr on github vgstation-coders/vgstation13#4555

/obj/machinery/power/smes/connector
	name = "power connector"
	desc = "A user-safe high-current contact port, used for connecting and interfacing with portable power storage units. Practically useless without one."
	icon_state = "battery_port"
	circuit = /obj/item/circuitboard/machine/smes/connector
	density = FALSE
	input_attempt = FALSE
	output_attempt = FALSE
	show_display_lights = FALSE

	///The smes this connector is connected with
	var/obj/machinery/smesbank/connected_smes

/obj/machinery/power/smes/connector/Destroy()
	connected_smes?.disconnect_port() // in the unlikely but possible case a SMES is connected and this explodes
	return ..()

/obj/machinery/power/smes/connector/update_appearance(updates)
	. = ..()
	connected_smes?.update_appearance(updates)

/obj/machinery/power/smes/connector/update_overlays()
	. = ..()
	if(!connected_smes)
		return

	if(inputting)
		. += "bp-c"
	else
		if(total_charge() > 0)
			. += "bp-o"
		else
			. += "bp-d"

/obj/machinery/power/smes/connector/RefreshParts()
	. = ..()

	//happens if the terminal gets rped without a bank attached. No division by zero error
	if(!total_capacity)
		total_capacity = 1

/obj/machinery/power/smes/connector/wrench_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/smes/connector/screwdriver_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/smes/connector/crowbar_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/// checks if the connector is free; if not, alerts a user and returns FALSE
/obj/machinery/power/smes/connector/proc/connector_free(mob/living/user)
	PRIVATE_PROC(TRUE)

	if(connected_smes)
		balloon_alert(user, "disconnect SMES first!")
		return FALSE
	return TRUE

/**
 * Connects the power bank to the smes
 * Arguments
 *
 * * obj/machinery/power/smesbank/bank - the bank to connect
 */
/obj/machinery/power/smes/connector/proc/connect_smes(obj/machinery/smesbank/bank)
	SHOULD_NOT_OVERRIDE(TRUE)

	connected_smes = bank
	if(connected_smes)
		total_capacity = 0
		for(var/obj/item/stock_parts/power_store/power_cell in connected_smes.component_parts)
			component_parts += power_cell
			total_capacity += power_cell.max_charge()
	else
		inputting = FALSE
		outputting = FALSE
		total_capacity = 1
		for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
			component_parts -= power_cell
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/smes/connector/ui_act(action, params)
	// prevent UI interactions if there's no SMES
	if(!connected_smes)
		balloon_alert(usr, "needs a connected SMES!")
		return FALSE
	return ..()

/// The actual portable part of the portable SMES system. Pretty useless without an actual connector.
/obj/machinery/smesbank
	name = "portable power storage unit"
	desc = "A portable, high-capacity superconducting magnetic energy storage (SMES) unit. Requires a separate power connector port to actually interface with power networks."
	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "port_smes"
	circuit = /obj/item/circuitboard/machine/smesbank
	use_power = NO_POWER_USE // well, technically
	density = TRUE
	anchored = FALSE

	/// The initial charge of this smes charge.
	var/charge = 0
	/// The port this is connected to.
	var/obj/machinery/power/smes/connector/connected_port

/obj/machinery/smesbank/Initialize(mapload)
	. = ..()

	///Initial connection for mapload, We attempt to locate the connector but only connect to it after it has initialized
	if(mapload)
		connected_port = locate() in loc

	///Initial charge
	if(charge)
		for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
			power_cell.use(power_cell.charge())
			if(charge)
				charge -= power_cell.give(charge)
		charge = 0

	register_context()

/obj/machinery/smesbank/post_machine_initialize()
	. = ..()

	//we somehow located an deleted port or no port at all. clear out
	if(QDELETED(connected_port))
		connected_port = null
		return

	//connect to the port located during mapload
	var/obj/machinery/power/smes/connector/possible_connector = connected_port
	connected_port = null
	if(!connect_port(possible_connector))
		return
	connected_port.input_attempt = TRUE
	connected_port.output_attempt = TRUE

/obj/machinery/smesbank/on_construction(mob/user)
	set_anchored(FALSE)

/obj/machinery/smesbank/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[connected_port ? "Disconnect" : "Connect"]"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open && !connected_port)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/smesbank/examine(user)
	. = ..()
	. += span_notice("its maintenance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(connected_port)
		. += span_notice("You need to [EXAMINE_HINT("unwrench")] from the port before deconstructing.")
	else
		if(panel_open)
			. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")
		. += span_notice("It should be [EXAMINE_HINT("wrenched")] onto a connector port to operate.")

/obj/machinery/smesbank/Destroy()
	disconnect_port()
	return ..()

/obj/machinery/smesbank/update_overlays()
	. = ..()
	if(panel_open || !is_operational)
		return

	if(connected_port)
		. += "smes-op[connected_port.outputting ? 1 : 0]"
		. += "smes-oc[connected_port.inputting ? 1 : 0]"
		var/clevel = connected_port.chargedisplay()
		if(clevel > 0)
			. += "smes-og[clevel]"

/obj/machinery/smesbank/interact(mob/user)
	. = ..()
	connected_port?.interact(user)

// adapted from portable atmos connection code
/obj/machinery/smesbank/wrench_act(mob/living/user, obj/item/wrench)
	if(connected_port)
		wrench.play_tool_sound(src)
		if(!wrench.use_tool(src, user, 8 SECONDS))
			return ITEM_INTERACT_BLOCKING
		user.visible_message( \
			"[user] disconnects [src].", \
			span_notice("You unfasten [src] from [connected_port]."), \
			span_hear("You hear a ratchet."))
		investigate_log("was disconnected from [connected_port] by [key_name(user)].", INVESTIGATE_ENGINE)
		disconnect_port()
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

	var/obj/machinery/power/smes/connector/possible_connector = locate(/obj/machinery/power/smes/connector) in loc
	if(!possible_connector)
		to_chat(user, span_notice("There's no power connector to connect to."))
		return ITEM_INTERACT_BLOCKING
	wrench.play_tool_sound(src)
	if(!wrench.use_tool(src, user, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	if(!connect_port(possible_connector))
		to_chat(user, span_notice("[src] failed to connect to [possible_connector]."))
		return ITEM_INTERACT_BLOCKING
	user.visible_message( \
		"[user] connects [src].", \
		span_notice("You fasten [src] to [possible_connector]."), \
		span_hear("You hear a ratchet."))
	update_appearance(UPDATE_OVERLAYS)
	investigate_log("was connected to [possible_connector] by [key_name(user)].", INVESTIGATE_ENGINE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/smesbank/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_FAILURE
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/smesbank/default_deconstruction_crowbar(obj/item/crowbar/crowbar)
	if(istype(crowbar) && connected_port)
		balloon_alert(usr, "disconnect from [connected_port] first!")
		return ITEM_INTERACT_FAILURE
	return ..()

/**
 * Attempt to connect the portable SMES to a given connector. Adapted from portable atmos connection code.
 *
 * Arguments
 * * obj/machinery/power/smes/connector/possible_connector - the connector we are trying to link with
 */
/obj/machinery/smesbank/proc/connect_port(obj/machinery/power/smes/connector/possible_connector)
	PRIVATE_PROC(TRUE)

	//Make sure not already connected to something else
	if(connected_port || !possible_connector || possible_connector.connected_smes || possible_connector.panel_open)
		return FALSE

	//Make sure are close enough for a valid connection
	if(possible_connector.loc != get_turf(src))
		return FALSE

	//Perform the connection
	connected_port = possible_connector
	connected_port.connect_smes(src)
	set_anchored(TRUE)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Disconnects the portable SMES from its assigned connector, if it has any. Also adapted from portable atmos connection code.
/obj/machinery/smesbank/proc/disconnect_port()
	SHOULD_NOT_OVERRIDE(TRUE)

	if(!connected_port)
		return

	connected_port.connect_smes(null)
	connected_port = null
	set_anchored(FALSE)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/smesbank/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	///Drain the charge
	var/charge_adjust = STANDARD_BATTERY_CHARGE / severity
	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		charge_adjust -= power_cell.use(charge_adjust, TRUE)
		if(!charge_adjust)
			break

/obj/machinery/smesbank/super
	name = "super capacity power storage unit"
	desc = "A portable, super-capacity, superconducting magnetic energy storage (SMES) unit. Relatively rare, and typically installed in long-range outposts where minimal maintenance is expected."
	circuit = /obj/item/circuitboard/machine/smesbank/super

/obj/machinery/smesbank/super/full
	charge = 100 * STANDARD_BATTERY_CHARGE
