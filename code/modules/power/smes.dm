// the SMES
// stores power

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/smes
	can_change_cable_layer = TRUE

	/// The initial charge of this smes.
	var/charge = 0
	/// Max capacity of all cells in this smes
	VAR_PROTECTED/total_capacity = 0

	/// TRUE = attempting to charge, FALSE = not attempting to charge
	var/input_attempt = TRUE
	/// TRUE = actually inputting, FALSE = not inputting
	var/inputting = TRUE
	/// amount of power the SMES attempts to charge by
	var/input_level = 50 KILO WATTS
	/// cap on input_level
	var/input_level_max = 200 KILO WATTS
	/// amount of charge available from input last tick
	var/input_available = 0

	/// TRUE = attempting to output, FALSE = not attempting to output
	var/output_attempt = TRUE
	/// TRUE = actually outputting, FALSE = not outputting
	var/outputting = TRUE
	/// amount of power the SMES attempts to output
	var/output_level = 50 KILO WATTS
	/// cap on output_level
	var/output_level_max = 200 KILO WATTS
	/// amount of power actually outputted. may be less than output_level if the powernet returns excess power
	var/output_used = 0

	///Should we show display lights
	var/show_display_lights = TRUE
	/// Terminal for charging this smes
	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/Initialize(mapload)
	. = ..()

	//screentips
	register_context()

	///initial charge
	if(charge)
		for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
			power_cell.use(power_cell.charge())
			if(charge)
				charge -= power_cell.give(charge)
		charge = 0

	//locate terminal
	dir_loop:
		for(var/direction in GLOB.cardinals)
			var/turf/turf = get_step(src, direction)
			for(var/obj/machinery/power/terminal/term in turf)
				if(term && term.dir == REVERSE_DIR(direction))
					terminal = term
					break dir_loop
	if(!terminal)
		atom_break()
		return
	terminal.master = src
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/smes/on_construction(mob/user)
	var/obj/structure/cable/C = locate() in loc
	if(!QDELETED(C))
		cable_layer = C.cable_layer
		connect_to_network()

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		atom_break()

/obj/machinery/power/smes/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/turf = get_turf(src)
		message_admins("[src] deleted at [ADMIN_VERBOSEJMP(turf)]")
		log_game("[src] deleted at [AREACOORD(turf)]")
		investigate_log("deleted at [AREACOORD(turf)]", INVESTIGATE_ENGINE)
	disconnect_terminal()
	return ..()

/obj/machinery/power/smes/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(istype(held_item, /obj/item/stack/cable_coil) && !terminal && can_place_terminal(user, held_item, silent = TRUE))
		context[SCREENTIP_CONTEXT_LMB] = "Install terminal"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_WRENCH && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Rotate"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_WIRECUTTER && terminal && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Cut terminal"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && !terminal && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/power/smes/examine(user)
	. = ..()

	. += span_notice("it's maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "opened"]")
	if(panel_open)
		if(!terminal)
			. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")
		. += span_notice("It can [EXAMINE_HINT("wrenched")] to rotate.")

	if(!terminal)
		. += span_warning("A terminal that requires [EXAMINE_HINT("10 cable pieces")] needs to be installed!.")
	else if(panel_open)
		. += span_notice("The terminal can be [EXAMINE_HINT("cut")] apart.")

/obj/machinery/power/smes/update_overlays()
	. = ..()
	if(panel_open || !is_operational)
		return

	if(show_display_lights)
		. += "smes-op[outputting ? 1 : 0]"
		. += "smes-oc[inputting ? 1 : 0]"

		var/clevel = chargedisplay()
		if(clevel > 0)
			. += "smes-og[clevel]"

/obj/machinery/power/smes/get_save_vars()
	. = ..()
	charge = total_charge()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)

/// Returns the total charge of this smes
/obj/machinery/power/smes/proc/total_charge()
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_BE_PURE(TRUE)

	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		. += power_cell.charge()

/**
 * Adjusts the total charge of this smes
 * Arguments
 *
 * * charge_adjust - the amount of give/take from this smes
 */
/obj/machinery/power/smes/proc/adjust_charge(charge_adjust)
	var/give = charge_adjust > 0
	charge_adjust = abs(charge_adjust)
	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		var/amount_adjusted
		if(give)
			amount_adjusted = power_cell.give(charge_adjust)
		else
			amount_adjusted = power_cell.use(charge_adjust, TRUE)

		. += amount_adjusted
		charge_adjust -= amount_adjusted
		if(!charge_adjust)
			return

/obj/machinery/power/smes/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)

	var/power_coefficient = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		power_coefficient += capacitor.tier
	input_level_max = initial(input_level_max) * power_coefficient
	output_level_max = initial(output_level_max) * power_coefficient

	total_capacity = 0
	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		total_capacity += power_cell.max_charge()

	update_static_data_for_all_viewers()

/obj/machinery/power/smes/should_have_node()
	return TRUE

/**
 * Can we place the terminal based on the players position
 *
 * Arguments
 * * mob/living/user - the player attempting to install the cable
 * * obj/item/stack/cable_coil/installing_cable - the cable coil used to install the terminal
 * * silent - should we display error messages
*/
/obj/machinery/power/smes/proc/can_place_terminal(mob/living/user, obj/item/stack/cable_coil/installing_cable, silent = TRUE)
	PRIVATE_PROC(TRUE)

	var/set_dir = get_dir(user, src)
	if(set_dir & (set_dir - 1))//we don't want diagonal click
		return FALSE

	var/turf/terminal_turf = get_turf(user)
	if(!panel_open)
		if(!silent && user)
			balloon_alert(user, "open the maintenance panel!")
		return FALSE
	if(terminal_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		if(!silent && user)
			balloon_alert(user, "remove the floor plating!")
		return FALSE
	if(terminal)
		if(!silent && user)
			balloon_alert(user, "already wired!")
		return FALSE
	if(installing_cable.get_amount() < 10)
		if(!silent && user)
			balloon_alert(user, "need ten lengths of cable!")
		return FALSE
	return TRUE

// adapted from APC item interacts for cable act handling
/obj/machinery/power/smes/item_interaction(mob/living/user, obj/item/stack/cable_coil/installing_cable, list/modifiers)
	. = NONE
	if(istype(installing_cable))
		. = ITEM_INTERACT_BLOCKING
		if(!can_place_terminal(user, installing_cable, silent = FALSE))
			return ITEM_INTERACT_BLOCKING

		//select cable layer
		var/terminal_cable_layer
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			var/choice = tgui_input_list(user, "Select Power Input Cable Layer", "Select Cable Layer", GLOB.cable_name_to_layer)
			if(isnull(choice) \
				|| !user.is_holding(installing_cable) \
				|| !user.Adjacent(src) \
				|| user.incapacitated \
				|| !can_place_terminal(user, installing_cable, silent = TRUE) \
			)
				return ITEM_INTERACT_BLOCKING
			terminal_cable_layer = GLOB.cable_name_to_layer[choice]
		user.visible_message(span_notice("[user.name] starts adding cables to [src]."))
		balloon_alert(user, "adding cables...")
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)

		//use cable
		if(!do_after(user, 2 SECONDS, target = src))
			return ITEM_INTERACT_BLOCKING
		if(!can_place_terminal(user, installing_cable, silent = TRUE))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/stack/cable_coil/cable = installing_cable
		var/turf/turf = get_turf(user)
		var/obj/structure/cable/connected_cable = turf.get_cable_node(terminal_cable_layer) //get the connecting node cable, if there's one
		if (prob(50) && electrocute_mob(user, connected_cable, connected_cable, 1, TRUE)) //animate the electrocution if uncautious and unlucky
			do_sparks(5, TRUE, src)
			return ITEM_INTERACT_BLOCKING
		cable.use(10)
		user.visible_message(span_notice("[user.name] adds cables to [src]."))
		balloon_alert(user, "cables added")

		//build the terminal and link it to the network
		terminal = new(turf)
		terminal.master = src
		terminal.cable_layer = terminal_cable_layer
		terminal.setDir(get_dir(turf, src))
		terminal.connect_to_network()
		set_machine_stat(machine_stat & ~BROKEN)
		return ITEM_INTERACT_SUCCESS

//opening using screwdriver
/obj/machinery/power/smes/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/power/smes/wirecutter_act(mob/living/user, obj/item/item)
	. = ITEM_INTERACT_FAILURE
	if(terminal && panel_open)
		terminal.dismantle(user, item)
		return ITEM_INTERACT_SUCCESS

//crowbarring it!
/obj/machinery/power/smes/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_FAILURE
	if(terminal)
		balloon_alert(user, "remove the power terminal!")
		return

	if(default_deconstruction_crowbar(tool))
		var/turf/ground = get_turf(src)
		message_admins("[src] has been deconstructed by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(ground)].")
		user.log_message("deconstructed [src]", LOG_GAME)
		investigate_log("deconstructed by [key_name(user)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)
		return ITEM_INTERACT_SUCCESS

//changing direction using wrench
/obj/machinery/power/smes/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_FAILURE
	if(default_change_direction_wrench(user, tool))
		disconnect_terminal()
		for(var/obj/machinery/power/terminal/term in get_step(src, dir))
			if(term && term.dir == REVERSE_DIR(dir))
				terminal = term
				terminal.master = src
				to_chat(user, span_notice("Terminal found."))
				set_machine_stat(machine_stat & ~BROKEN)
				update_appearance(UPDATE_OVERLAYS)
				return ITEM_INTERACT_SUCCESS
		to_chat(user, span_alert("No power terminal found."))

/obj/machinery/power/smes/cable_layer_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open panel first!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/smes/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		connect_to_network()

///Returns the charge level this smes is at 0->5 for display purposes
/obj/machinery/power/smes/proc/chargedisplay()
	SHOULD_BE_PURE(TRUE)

	return clamp(round(5 * (total_charge() / total_capacity)), 0, 5)

/obj/machinery/power/smes/process(seconds_per_tick)
	if(!is_operational)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//outputting
	if(output_attempt && powernet)
		var/output_energy = power_to_energy(output_level)

		output_used = 0
		if(output_energy <= 0)
			outputting = FALSE
		else
			outputting = TRUE

			// reduce the storage (may be recovered in /restore() if excessive)
			output_used = adjust_charge(-output_energy)
			if(output_used)
				add_avail(output_used)

				// either from no charge or set to 0
				if(output_used < 0.1)
					outputting = FALSE
					investigate_log("lost power and turned off", INVESTIGATE_ENGINE)
			else
				outputting = FALSE
	else
		outputting = FALSE

	//inputting
	if(input_attempt && terminal)
		var/input_energy = power_to_energy(input_level)

		input_available = terminal.surplus()
		if(input_energy <= 0)
			inputting = FALSE
		else
			inputting = TRUE

			// increase the charge
			var/load = adjust_charge(min(input_energy, input_available))
			if(load)
				terminal.add_load(load) // add the load to the terminal side network
			else
				inputting = FALSE
	else
		inputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_appearance(UPDATE_OVERLAYS)

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(!is_operational)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = min(output_used, powernet.netexcess) // clamp it to how much was actually output by this SMES last ptick

	// now recharge this amount
	var/clev = chargedisplay()

	excess = adjust_charge(excess) // restore unused power
	powernet.netexcess -= excess // remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay()) //if needed updates the icons overlay
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/ui_static_data(mob/user)
	. = list(
		"capacity" = total_capacity,
		"inputLevelMax" = input_level_max,
		"outputLevelMax" = output_level_max,
	)

/obj/machinery/power/smes/ui_data()
	. = list(
		"charge" = total_charge(),
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputAvailable" = energy_to_power(input_available),
		"outputAttempt" = output_attempt,
		"outputLevel" = output_level,
		"outputUsed" = energy_to_power(output_used),
		"outputting" = outputting,
	)

/obj/machinery/power/smes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			log_smes(ui.user)
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if("tryoutput")
			output_attempt = !output_attempt
			log_smes(ui.user)
			update_appearance(UPDATE_OVERLAYS)
			return TRUE

		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = clamp(target, 0, input_level_max)
				log_smes(ui.user)
				return

		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = clamp(target, 0, output_level_max)
				log_smes(ui.user)

///Logs the current state of this smes
/obj/machinery/power/smes/proc/log_smes(mob/user)
	PRIVATE_PROC(TRUE)

	investigate_log("Input/Output: [input_level]/[output_level] | Charge: [total_charge()] | Output-mode: [output_attempt?"ON":"OFF"] | Input-mode: [input_attempt?"AUTO":"OFF"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_ENGINE)

/obj/machinery/power/smes/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	input_attempt = rand(0, 1)
	inputting = input_attempt
	output_attempt = rand(0, 1)
	outputting = output_attempt
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	adjust_charge(-STANDARD_BATTERY_CHARGE / severity)
	update_appearance(UPDATE_OVERLAYS)
	log_smes()

// Variant of SMES that starts with super power cells for higher longevity
/obj/machinery/power/smes/super
	name = "super capacity power storage unit"
	desc = "A super-capacity superconducting magnetic energy storage (SMES) unit. Relatively rare, and typically installed in long-range outposts where minimal maintenance is expected."
	circuit = /obj/item/circuitboard/machine/smes/super

/obj/machinery/power/smes/super/full
	charge = 100 * STANDARD_BATTERY_CHARGE

/obj/machinery/power/smes/full
	charge = 50 * STANDARD_BATTERY_CHARGE

/obj/machinery/power/smes/ship
	charge = 20 * STANDARD_BATTERY_CHARGE

/obj/machinery/power/smes/engineering
	charge = 50 * STANDARD_BATTERY_CHARGE // Engineering starts with some charge for singulo //sorry little one, singulo as engine is gone
	output_level = 90 KILO WATTS

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

/obj/machinery/power/smes/magical/adjust_charge(charge_adjust)
	//give charge without consuming anything
	if(charge_adjust < 0)
		return abs(charge_adjust)
	//no point charging this already infinite smes
	return 0
