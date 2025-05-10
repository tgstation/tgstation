// the SMES
// stores power


//Cache defines
#define SMES_CLEVEL_1 1
#define SMES_CLEVEL_2 2
#define SMES_CLEVEL_3 3
#define SMES_CLEVEL_4 4
#define SMES_CLEVEL_5 5
#define SMES_OUTPUTTING 6
#define SMES_NOT_OUTPUTTING 7
#define SMES_INPUTTING 8
#define SMES_INPUT_ATTEMPT 9

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/smes
	can_change_cable_layer = TRUE

	/// The charge capacity.
	var/capacity = 50 * STANDARD_BATTERY_CHARGE // The board defaults with 5 high capacity batteries.
	/// The current charge.
	var/charge = 0

	var/input_attempt = TRUE // TRUE = attempting to charge, FALSE = not attempting to charge
	var/inputting = TRUE // TRUE = actually inputting, FALSE = not inputting
	var/input_level = 50 KILO WATTS // amount of power the SMES attempts to charge by
	var/input_level_max = 200 KILO WATTS // cap on input_level
	var/input_available = 0 // amount of charge available from input last tick

	var/output_attempt = TRUE // TRUE = attempting to output, FALSE = not attempting to output
	var/outputting = TRUE // TRUE = actually outputting, FALSE = not outputting
	var/output_level = 50 KILO WATTS // amount of power the SMES attempts to output
	var/output_level_max = 200 KILO WATTS // cap on output_level
	var/output_used = 0 // amount of power actually outputted. may be less than output_level if the powernet returns excess power

	/// does this SMES show its input/output lights?
	var/show_display_lights = TRUE

	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/examine(user)
	. = ..()
	if(!terminal)
		. += span_warning("This [src] has no power terminal!")

/obj/machinery/power/smes/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, capacity)
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)
	return .

/obj/machinery/power/smes/Initialize(mapload)
	. = ..()
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
	update_appearance()

/obj/machinery/power/smes/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	var/power_coefficient = 0
	var/max_charge = 0
	var/new_charge = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		power_coefficient += capacitor.tier
	input_level_max = initial(input_level_max) * power_coefficient
	output_level_max = initial(output_level_max) * power_coefficient
	for(var/obj/item/stock_parts/power_store/power_cell in component_parts)
		max_charge += power_cell.maxcharge
		new_charge += power_cell.charge
	capacity = max_charge
	if(!initial(charge) && !charge)
		charge = new_charge

/obj/machinery/power/smes/should_have_node()
	return TRUE

// adapted from APC item interacts for cable act handling
/obj/machinery/power/smes/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(istype(tool, /obj/item/stack/cable_coil))
		. = cable_act(user, tool, LAZYACCESS(modifiers, RIGHT_CLICK))
	if(.)
		return .
	return .

/obj/machinery/power/smes/cable_layer_act(mob/living/user, obj/item/tool)
	if(!QDELETED(terminal))
		balloon_alert(user, "cut the terminal first!")
		return ITEM_INTERACT_BLOCKING
	return ..()

//opening using screwdriver
/obj/machinery/power/smes/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), tool))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

//changing direction using wrench
/obj/machinery/power/smes/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_change_direction_wrench(user, tool))
		terminal = null
		var/turf/turf = get_step(src, dir)
		for(var/obj/machinery/power/terminal/term in turf)
			if(term && term.dir == REVERSE_DIR(dir))
				terminal = term
				terminal.master = src
				to_chat(user, span_notice("Terminal found."))
				break
		if(!terminal)
			to_chat(user, span_alert("No power terminal found."))
			return ITEM_INTERACT_SUCCESS
		set_machine_stat(machine_stat & ~BROKEN)
		update_appearance()
		return ITEM_INTERACT_SUCCESS

//building and linking a terminal
/obj/machinery/power/smes/proc/cable_act(mob/living/user, obj/item/stack/cable_coil/installing_cable, is_right_clicking)
	. = ITEM_INTERACT_BLOCKING
	if(!can_place_terminal(user, installing_cable, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	var/terminal_cable_layer
	if(is_right_clicking)
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
	make_terminal(turf, terminal_cable_layer)
	terminal.connect_to_network()
	return ITEM_INTERACT_SUCCESS

//crowbarring it!
/obj/machinery/power/smes/crowbar_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return
	var/turf/turf = get_turf(src)
	if(default_deconstruction_crowbar(tool))
		message_admins("[src] has been deconstructed by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(turf)].")
		user.log_message("deconstructed [src]", LOG_GAME)
		investigate_log("deconstructed by [key_name(user)] at [AREACOORD(src)].", INVESTIGATE_ENGINE)
		return

/// Checks if we're in a valid state to place a terminal
/obj/machinery/power/smes/proc/can_place_terminal(mob/living/user, obj/item/stack/cable_coil/installing_cable, silent = TRUE)
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

/obj/machinery/power/smes/wirecutter_act(mob/living/user, obj/item/item)
	//disassembling the terminal
	. = ..()
	if(terminal && panel_open)
		terminal.dismantle(user, item)
		return TRUE


/obj/machinery/power/smes/default_deconstruction_crowbar(obj/item/crowbar/crowbar)
	if(istype(crowbar) && terminal)
		balloon_alert(usr, "remove the power terminal!")
		return FALSE

	return ..()

/obj/machinery/power/smes/on_deconstruction(disassembled)
	for(var/obj/item/stock_parts/power_store/cell in component_parts)
		cell.charge = (charge / capacity) * cell.maxcharge

/obj/machinery/power/smes/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/turf = get_turf(src)
		message_admins("[src] deleted at [ADMIN_VERBOSEJMP(turf)]")
		log_game("[src] deleted at [AREACOORD(turf)]")
		investigate_log("deleted at [AREACOORD(turf)]", INVESTIGATE_ENGINE)
	if(terminal)
		disconnect_terminal()
	return ..()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/smes/proc/make_terminal(turf/turf, terminal_cable_layer = cable_layer)
	terminal = new/obj/machinery/power/terminal(turf)
	terminal.cable_layer = terminal_cable_layer
	terminal.setDir(get_dir(turf,src))
	terminal.master = src
	set_machine_stat(machine_stat & ~BROKEN)

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		atom_break()

/// is this SMES in a suitable state to display overlays?
/obj/machinery/power/smes/proc/display_ready()
	if(machine_stat & BROKEN)
		return FALSE
	if(panel_open)
		return FALSE
	return TRUE

/obj/machinery/power/smes/update_overlays()
	. = ..()
	if(!display_ready())
		return

	if(show_display_lights)
		. += "smes-op[outputting ? 1 : 0]"
		. += "smes-oc[inputting ? 1 : 0]"

		var/clevel = chargedisplay()
		if(clevel > 0)
			. += "smes-og[clevel]"


/obj/machinery/power/smes/proc/chargedisplay()
	if(capacity <= 0)
		return 0
	return clamp(round(5.5*charge/capacity),0,5)

/obj/machinery/power/smes/process(seconds_per_tick)
	if(machine_stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting
	var/input_energy = power_to_energy(input_level)
	var/output_energy = power_to_energy(output_level)

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min(charge, output_energy) //limit output to that stored

			if (add_avail(output_used)) // add output to powernet if it exists (smes side)
				adjust_charge(-output_used) // reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.1) // either from no charge or set to 0
				outputting = FALSE
				investigate_log("lost power and turned off", INVESTIGATE_ENGINE)
		else if(output_attempt && charge > output_energy && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	//inputting
	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0) // if there's power available, try to charge

				var/load = min((capacity-charge), input_energy, input_available) // charge at set rate, limited to spare capacity

				adjust_charge(load) // increase the charge

				terminal.add_load(load) // add the load to the terminal side network

			else // if not enough capcity
				inputting = FALSE // stop inputting

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_appearance()

/// Adjusts the charge in this SMES, used instead of directly adjusting the charge value. Mainly for the benefit of the power connector/portable SMES system.
/obj/machinery/power/smes/proc/adjust_charge(charge_adjust)
	charge += charge_adjust

/// Sets the charge in this SMES, used instead of directly adjusting the charge value. Mainly for the benefit of the power connector/portable SMES system.
/obj/machinery/power/smes/proc/set_charge(charge_set)
	charge = charge_set

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(machine_stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess // this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess) // clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge), excess) // for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	adjust_charge(excess) // restore unused power
	powernet.netexcess -= excess // remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay() ) //if needed updates the icons overlay
		update_appearance()
	return


/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/ui_data()
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = display_power(input_level, convert = FALSE),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = energy_to_power(input_available),
		"outputAttempt" = output_attempt,
		"outputting" = energy_to_power(outputting),
		"outputLevel" = output_level,
		"outputLevel_text" = display_power(output_level, convert = FALSE),
		"outputLevelMax" = output_level_max,
		"outputUsed" = energy_to_power(output_used),
	)
	return data

/obj/machinery/power/smes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			log_smes(usr)
			update_appearance()
			. = TRUE
		if("tryoutput")
			output_attempt = !output_attempt
			log_smes(usr)
			update_appearance()
			. = TRUE
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
				log_smes(usr)
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
				log_smes(usr)

/obj/machinery/power/smes/proc/log_smes(mob/user)
	investigate_log("Input/Output: [input_level]/[output_level] | Charge: [charge] | Output-mode: [output_attempt?"ON":"OFF"] | Input-mode: [input_attempt?"AUTO":"OFF"] by [user ? key_name(user) : "outside forces"]", INVESTIGATE_ENGINE)

/obj/machinery/power/smes/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	input_attempt = rand(0,1)
	inputting = input_attempt
	output_attempt = rand(0,1)
	outputting = output_attempt
	output_level = rand(0, output_level_max)
	input_level = rand(0, input_level_max)
	adjust_charge(-STANDARD_BATTERY_CHARGE/severity)
	if (charge < 0)
		set_charge(0)
	update_appearance()
	log_smes()

// Variant of SMES that starts with super power cells for higher longevity
/obj/machinery/power/smes/super
	name = "super capacity power storage unit"
	desc = "A super-capacity superconducting magnetic energy storage (SMES) unit. Relatively rare, and typically installed in long-range outposts where minimal maintenance is expected."
	circuit = /obj/item/circuitboard/machine/smes/super
	capacity = 100 * STANDARD_BATTERY_CHARGE

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

/obj/machinery/power/smes/magical/process()
	capacity = INFINITY
	charge = INFINITY
	..()

#undef SMES_CLEVEL_1
#undef SMES_CLEVEL_2
#undef SMES_CLEVEL_3
#undef SMES_CLEVEL_4
#undef SMES_CLEVEL_5
#undef SMES_OUTPUTTING
#undef SMES_NOT_OUTPUTTING
#undef SMES_INPUTTING
#undef SMES_INPUT_ATTEMPT
