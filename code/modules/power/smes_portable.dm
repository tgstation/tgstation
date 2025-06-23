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

	capacity = 1 // solely to avoid div by zero
	charge = 0
	var/obj/machinery/power/smesbank/connected_smes

/obj/machinery/power/smes/connector/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	var/power_coefficient = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		power_coefficient += capacitor.tier
	input_level_max = initial(input_level_max) * power_coefficient
	output_level_max = initial(output_level_max) * power_coefficient

/obj/machinery/power/smes/connector/ui_act(action, params)
	// prevent UI interactions if there's no SMES
	if(!connected_smes)
		balloon_alert(usr, "needs a connected SMES!")
		return FALSE
	return ..()

/obj/machinery/power/smes/connector/display_ready()
	if(!connected_smes)
		return FALSE
	return ..()

/obj/machinery/power/smes/connector/update_appearance(updates)
	. = ..()
	connected_smes?.update_appearance(updates)

/obj/machinery/power/smes/connector/update_overlays()
	. = ..()
	if(connected_smes && inputting)
		. += "bp-c"
	else
		if(connected_smes)
			if(charge > 0)
				. += "bp-o"
			else
				. += "bp-d"
	connected_smes?.update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/smes/connector/crowbar_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/smes/connector/wrench_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/smes/connector/screwdriver_act(mob/living/user, obj/item/tool)
	if(!connector_free(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/// checks if the connector is free; if not, alerts a user and returns FALSE
/obj/machinery/power/smes/connector/proc/connector_free(mob/living/user)
	if(connected_smes)
		balloon_alert(user, "disconnect SMES first!")
		return FALSE
	return TRUE

/// connects the actual portable SMES once it's assigned, adjusting charge/maxcharge
/obj/machinery/power/smes/connector/proc/on_connect_smes()
	charge = connected_smes.charge
	capacity = connected_smes.capacity
	update_appearance()

/// disconnects the portable SMES, resetting internal charge + capacity
/obj/machinery/power/smes/connector/proc/on_disconnect_smes()
	input_attempt = FALSE
	output_attempt = FALSE
	charge = initial(charge)
	capacity = initial(capacity)
	update_appearance()

// we really should only be adjusting charge when there's a connected SMES bank.
/obj/machinery/power/smes/connector/adjust_charge(charge_adjust)
	. = ..()
	connected_smes?.charge += charge_adjust

// same as above - if we have to set charge, affect the connected SMES bank as well
/obj/machinery/power/smes/connector/set_charge(charge_set)
	. = ..()
	connected_smes?.charge = charge_set

/obj/machinery/power/smes/connector/Destroy()
	connected_smes?.disconnect_port() // in the unlikely but possible case a SMES is connected and this explodes
	return ..()

/// The actual portable part of the portable SMES system. Pretty useless without an actual connector.
/obj/machinery/power/smesbank
	name = "portable power storage unit"
	desc = "A portable, high-capacity superconducting magnetic energy storage (SMES) unit. Requires a separate power connector port to actually interface with power networks."
	icon_state = "port_smes"
	circuit = /obj/item/circuitboard/machine/smesbank
	use_power = NO_POWER_USE // well, technically
	density = TRUE
	anchored = FALSE
	can_change_cable_layer = FALSE // cable layering is handled via connector port
	/// The charge capacity.
	var/capacity = 50 * STANDARD_BATTERY_CHARGE // The board defaults with 5 high capacity batteries.
	/// The current charge.
	var/charge = 0
	/// The port this is connected to.
	var/obj/machinery/power/smes/connector/connected_port

/obj/machinery/power/smesbank/on_construction(mob/user, from_flatpack = FALSE)
	. = ..()
	set_anchored(FALSE)

/obj/machinery/power/smesbank/Initialize(mapload)
	. = ..()
	if(mapload)
		mapped_setup()

/obj/machinery/power/smesbank/interact(mob/user)
	. = ..()
	connected_port?.interact(user)

/obj/machinery/power/smesbank/examine(user)
	. = ..()
	if(!connected_port)
		. += span_warning("This SMES has no connector port!")

//opening using screwdriver
/obj/machinery/power/smesbank/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/power/smesbank/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	var/max_charge = 0
	var/new_charge = 0
	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		max_charge += power_cell.maxcharge
		new_charge += power_cell.charge
	capacity = max_charge
	if(!initial(charge) && !charge)
		charge = new_charge

/obj/machinery/power/smesbank/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		return

	if(panel_open)
		return

	. += "smes-op[connected_port?.outputting ? 1 : 0]"
	. += "smes-oc[connected_port?.inputting ? 1 : 0]"
	var/clevel = chargedisplay()
	if(clevel > 0)
		. += "smes-og[clevel]"

/obj/machinery/power/smesbank/proc/chargedisplay()
	return clamp(round(5.5*charge/capacity),0,5)

/obj/machinery/power/smesbank/default_deconstruction_crowbar(obj/item/crowbar/crowbar)
	if(istype(crowbar) && connected_port)
		balloon_alert(usr, "disconnect from [connected_port] first!")
		return FALSE
	return ..()

// adapted from portable atmos connection code
/obj/machinery/power/smesbank/wrench_act(mob/living/user, obj/item/wrench)
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
		update_appearance()
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
	update_appearance()
	investigate_log("was connected to [possible_connector] by [key_name(user)].", INVESTIGATE_ENGINE)
	return ITEM_INTERACT_SUCCESS

/// Attempt to connect the portable SMES to a given connector. Adapted from portable atmos connection code.
/obj/machinery/power/smesbank/proc/connect_port(obj/machinery/power/smes/connector/possible_connector)
	//Make sure not already connected to something else
	if(connected_port || !possible_connector || possible_connector.connected_smes || possible_connector.panel_open)
		return FALSE

	//Make sure are close enough for a valid connection
	if(possible_connector.loc != get_turf(src))
		return FALSE

	//Perform the connection
	connected_port = possible_connector
	connected_port.connected_smes = src
	possible_connector.on_connect_smes()
	set_anchored(TRUE) //Prevent movement
	connected_port.update_appearance()
	update_appearance()
	return TRUE

/// Disconnects the portable SMES from its assigned connector, if it has any. Also adapted from portable atmos connection code.
/obj/machinery/power/smesbank/proc/disconnect_port()
	if(!connected_port)
		return
	connected_port.on_disconnect_smes()
	connected_port.connected_smes = null
	connected_port = null
	set_anchored(FALSE)
	update_appearance()

/obj/machinery/power/smesbank/Destroy()
	disconnect_port()
	return ..()

/// Adjusts the charge of the portable SMES. See SMES code.
/obj/machinery/power/smesbank/proc/adjust_charge(charge_adjust)
	charge += charge_adjust

/// Sets the charge of the portable SMES. See SMES code.
/obj/machinery/power/smesbank/proc/set_charge(charge_set)
	charge = charge_set

/obj/machinery/power/smesbank/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	adjust_charge(-STANDARD_BATTERY_CHARGE/severity) // EMP'd banks double-dip on draining if connected. too bad, i guess
	if (charge < 0)
		set_charge(0)
	update_appearance()

/// Attempt to locate, connect to, and activate a portable connector, for pre-mapped portable SMESes.
/obj/machinery/power/smesbank/proc/mapped_setup()
	var/obj/machinery/power/smes/connector/possible_connector = locate(/obj/machinery/power/smes/connector) in loc
	if(!possible_connector)
		return
	if(!connect_port(possible_connector))
		return
	possible_connector.input_attempt = TRUE
	possible_connector.output_attempt = TRUE

/obj/machinery/power/smesbank/super
	name = "super capacity power storage unit"
	desc = "A portable, super-capacity, superconducting magnetic energy storage (SMES) unit. Relatively rare, and typically installed in long-range outposts where minimal maintenance is expected."
	circuit = /obj/item/circuitboard/machine/smesbank/super
	capacity = 100 * STANDARD_BATTERY_CHARGE

/obj/machinery/power/smesbank/super/full
	charge = 100 * STANDARD_BATTERY_CHARGE
