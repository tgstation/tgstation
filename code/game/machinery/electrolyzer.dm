#define ELECTROLYZER_MODE_STANDBY "standby"
#define ELECTROLYZER_MODE_WORKING "working"

/obj/machinery/electrolyzer
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer-off"
	name = "space electrolyzer"
	desc = "Thanks to the fast and dynamic response of our electrolyzers, on-site hydrogen production is guaranteed. Warranty void if used by clowns"
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 80, ACID = 10)
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
	var/workingPower = 1
	///Decrease the amount of power usage, changed by upgrading the capacitor tier
	var/efficiency = 0.5

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	update_appearance()

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

/obj/machinery/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? "[mode]" : "off"]"
	return ..()

/obj/machinery/electrolyzer/update_overlays()
	. = ..()
	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/electrolyzer/process(delta_time)
	if(!is_operational && on)
		on = FALSE
	if(!on)
		return PROCESS_KILL

	if(!cell || cell.charge <= 0)
		on = FALSE
		update_appearance()
		return PROCESS_KILL

	var/turf/L = loc
	if(!istype(L))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_appearance()
		return

	var/newMode = on ? ELECTROLYZER_MODE_WORKING : ELECTROLYZER_MODE_STANDBY //change the mode to working if the machine is on

	if(mode != newMode) //check if the mode is set correctly
		mode = newMode
		update_appearance()

	if(mode == ELECTROLYZER_MODE_STANDBY)
		return

	var/datum/gas_mixture/env = L.return_air() //get air from the turf
	var/datum/gas_mixture/removed = env.remove_ratio(0.1)

	if(!removed)
		return

	removed.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen, /datum/gas/hydrogen)
	var/proportion = min(removed.gases[/datum/gas/water_vapor][MOLES], (1.5 * delta_time * workingPower))//Works to max 12 moles at a time.
	removed.gases[/datum/gas/water_vapor][MOLES] -= proportion * 2 * workingPower
	removed.gases[/datum/gas/oxygen][MOLES] += proportion * workingPower
	removed.gases[/datum/gas/hydrogen][MOLES] += proportion * 2 * workingPower
	env.merge(removed) //put back the new gases in the turf
	air_update_turf(FALSE, FALSE)
	cell.use((5 * proportion * workingPower) / (efficiency + workingPower))

/obj/machinery/electrolyzer/RefreshParts()
	var/manipulator = 0
	var/cap = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manipulator += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	workingPower = manipulator //used in the amount of moles processed

	efficiency = (cap + 1) * 0.5 //used in the amount of charge in power cell uses

/obj/machinery/electrolyzer/screwdriver_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	panel_open = !panel_open
	user.visible_message(span_notice("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src]."), span_notice("You [panel_open ? "open" : "close"] the hatch on \the [src]."))
	update_appearance()
	return TRUE

/obj/machinery/electrolyzer/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
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
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	return data

/obj/machinery/electrolyzer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			mode = ELECTROLYZER_MODE_STANDBY
			usr.visible_message(span_notice("[usr] switches [on ? "on" : "off"] \the [src]."), span_notice("You switch [on ? "on" : "off"] \the [src]."))
			update_appearance()
			if (on)
				START_PROCESSING(SSmachines, src)
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
