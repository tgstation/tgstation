#define ELECTROLYZER_MODE_STANDBY "standby"
#define ELECTROLYZER_MODE_WORKING "working"

/obj/machinery/electrolyzer
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "electrolyzer-off"
	name = "space electrolyzer"
	desc = "Thanks to the fast and dynamic response of our electrolyzers, on-site hydrogen production is guaranteed. Warranty void if used by clowns"
	max_integrity = 250
	armor_type = /datum/armor/machinery_electrolyzer
	circuit = /obj/item/circuitboard/machine/electrolyzer
	/// We don't use area power, we always use the cell
	use_power = NO_POWER_USE
	///used to check if there is a cell in the machine
	var/obj/item/stock_parts/cell/cell
	///check if the machine is on or off
	var/on = FALSE
	///check what mode the machine should be (WORKING, STANDBY)
	var/mode = ELECTROLYZER_MODE_STANDBY
	///Increase the amount of moles worked on, changed by upgrading the manipulator tier
	var/working_power = 1
	///Decrease the amount of power usage, changed by upgrading the capacitor tier
	var/efficiency = 0.5

/datum/armor/machinery_electrolyzer
	fire = 80
	acid = 10

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	SSair.start_processing_machine(src)
	update_appearance()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		rmb_text = "Toggle power", \
	)

	var/static/list/tool_behaviors = list(
		TOOL_SCREWDRIVER = list(
			SCREENTIP_CONTEXT_LMB = "Open hatch",
		),

		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Anchor",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/machinery/electrolyzer/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/machinery/electrolyzer/on_deconstruction()
	if(cell)
		LAZYADD(component_parts, cell)
		cell = null
	return ..()

/obj/machinery/electrolyzer/examine(mob/user)
	. = ..()
	. += "\The [src] is [on ? "on" : "off"], and the hatch is [panel_open ? "open" : "closed"]."

	if(cell)
		. += "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "There is no power cell installed."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("<b>Right-click</b> to toggle [on ? "off" : "on"].")
	. += span_notice("It will drain power from the [anchored ? "area's APC" : "internal power cell"].")


/obj/machinery/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? "[mode]" : "off"]"
	return ..()

/obj/machinery/electrolyzer/update_overlays()
	. = ..()
	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/electrolyzer/process_atmos()

	if(!is_operational && on)
		on = FALSE
	if(!on)
		return PROCESS_KILL

	if((!cell || cell.charge <= 0) && !anchored)
		on = FALSE
		update_appearance()
		return PROCESS_KILL

	var/turf/our_turf = loc
	if(!istype(our_turf))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_appearance()
		return

	var/new_mode = on ? ELECTROLYZER_MODE_WORKING : ELECTROLYZER_MODE_STANDBY //change the mode to working if the machine is on

	if(mode != new_mode) //check if the mode is set correctly
		mode = new_mode
		update_appearance()

	if(mode == ELECTROLYZER_MODE_STANDBY)
		return

	var/datum/gas_mixture/env = our_turf.return_air() //get air from the turf

	if(!env)
		return

	call_reactions(env)

	air_update_turf(FALSE, FALSE)

	var/power_to_use = (5 * (3 * working_power) * working_power) / (efficiency + working_power)
	if(anchored)
		use_power(power_to_use)
	else
		cell.use(power_to_use)

/obj/machinery/electrolyzer/proc/call_reactions(datum/gas_mixture/env)
	for(var/reaction in GLOB.electrolyzer_reactions)
		var/datum/electrolyzer_reaction/current_reaction = GLOB.electrolyzer_reactions[reaction]

		if(!current_reaction.reaction_check(env))
			continue

		current_reaction.react(loc, env, working_power)

	env.garbage_collect()

/obj/machinery/electrolyzer/RefreshParts()
	. = ..()
	var/power = 0
	var/cap = 0
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		power += manipulator.tier
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		cap += capacitor.tier

	working_power = power //used in the amount of moles processed

	efficiency = (cap + 1) * 0.5 //used in the amount of charge in power cell uses

/obj/machinery/electrolyzer/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	toggle_panel_open()
	user.visible_message(span_notice("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src]."), span_notice("You [panel_open ? "open" : "close"] the hatch on \the [src]."))
	update_appearance()
	return TRUE

/obj/machinery/electrolyzer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/electrolyzer/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/stock_parts/cell))
		if(!panel_open)
			to_chat(user, span_warning("The hatch must be open to insert a power cell!"))
			return
		if(cell)
			to_chat(user, span_warning("There is already a power cell inside!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		I.add_fingerprint(usr)

		user.visible_message(span_notice("\The [user] inserts a power cell into \the [src]."), span_notice("You insert the power cell into \the [src]."))
		SStgui.update_uis(src)

		return
	return ..()

/obj/machinery/electrolyzer/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_interact(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_power(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/electrolyzer/proc/toggle_power(user)
	on = !on
	mode = ELECTROLYZER_MODE_STANDBY
	if(!isnull(user))
		balloon_alert(user, "turned [on ? "on" : "off"]")
	update_appearance()
	if(on)
		SSair.start_processing_machine(src)

/obj/machinery/electrolyzer/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/electrolyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electrolyzer", name)
		ui.open()

/obj/machinery/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["hasPowercell"] = !isnull(cell)
	data["anchored"] = anchored
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	return data

/obj/machinery/electrolyzer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			toggle_power()
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
