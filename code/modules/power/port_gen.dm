//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0_0"
	base_icon_state = "portgen0"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1
	var/consumption = 0
	var/datum/looping_sound/generator/soundloop

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

/obj/machinery/power/port_gen/Initialize(mapload)
	. = ..()
	soundloop = new(src, active)

/obj/machinery/power/port_gen/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/port_gen/should_have_node()
	return anchored

/obj/machinery/power/port_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return TRUE

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/proc/TogglePower()
	if(active)
		active = FALSE
		update_appearance()
		soundloop.stop()
	else if(HasFuel())
		active = TRUE
		START_PROCESSING(SSmachines, src)
		update_appearance()
		soundloop.start()

/obj/machinery/power/port_gen/update_icon_state()
	icon_state = "[base_icon_state]_[active]"
	return ..()

/obj/machinery/power/port_gen/process()
	if(active)
		if(!HasFuel() || !anchored)
			TogglePower()
			return
		if(powernet)
			add_avail(power_gen * power_output)
		UseFuel()
	else
		handleInactive()

/obj/machinery/power/port_gen/examine(mob/user)
	. = ..()
	. += "It is[!active?"n't":""] running."

/////////////////
// P.A.C.M.A.N //
/////////////////
/obj/machinery/power/port_gen/pacman
	name = "\improper P.A.C.M.A.N.-type portable generator"
	circuit = /obj/item/circuitboard/machine/pacman
	power_gen = 5000
	var/sheets = 0
	var/max_sheets = 50
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 60
	var/current_heat = 0

/obj/machinery/power/port_gen/pacman/Initialize(mapload)
	. = ..()
	if(anchored)
		connect_to_network()

	var/obj/S = sheet_path
	sheet_name = initial(S.name)

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/on_construction(mob/user)
	var/obj/item/circuitboard/machine/pacman/our_board = circuit
	if(our_board.high_production_profile)
		icon_state = "portgen1_0"
		base_icon_state = "portgen1"
		max_sheets = 20
		time_per_sheet = 20
		power_gen = 15000
		sheet_path = /obj/item/stack/sheet/mineral/uranium

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	. = ..()
	. += span_notice("The generator has [sheets] units of [sheet_name] fuel left, producing [display_power(power_gen)] per cycle.")
	if(anchored)
		. += span_notice("It is anchored to the ground.")

/obj/machinery/power/port_gen/pacman/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		new sheet_path(drop_location(), sheets)
		sheets = 0

/obj/machinery/power/port_gen/pacman/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if (sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

	var/lower_limit = 56 + power_output * 10
	var/upper_limit = 76 + power_output * 10
	var/bias = 0
	if (power_output > 4)
		upper_limit = 400
		bias = power_output - 3
	if (current_heat < lower_limit)
		current_heat += 3
	else
		current_heat += rand(-7 + bias, 7 + bias)
		if (current_heat < lower_limit)
			current_heat = lower_limit
		if (current_heat > upper_limit)
			current_heat = upper_limit

	if (current_heat > 300)
		overheat()
		qdel(src)

/obj/machinery/power/port_gen/pacman/handleInactive()
	current_heat = max(current_heat - 2, 0)
	if(current_heat == 0)
		STOP_PROCESSING(SSmachines, src)

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src, devastation_range = 2, heavy_impact_range = 5, light_impact_range = 2, flash_range = -1)

/obj/machinery/power/port_gen/pacman/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/port_gen/pacman/attackby(obj/item/O, mob/user, params)
	if(istype(O, sheet_path))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, span_notice("The [src.name] is full!"))
			return
		to_chat(user, span_notice("You add [amount] sheets to the [src.name]."))
		sheets += amount
		addstack.use(amount)
		return
	else if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			if(!anchored && !isinspace())
				set_anchored(TRUE)
				to_chat(user, span_notice("You secure the generator to the floor."))
			else if(anchored)
				set_anchored(FALSE)
				to_chat(user, span_notice("You unsecure the generator from the floor."))

			playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
			return
		else if(O.tool_behaviour == TOOL_SCREWDRIVER)
			toggle_panel_open()
			O.play_tool_sound(src)
			if(panel_open)
				to_chat(user, span_notice("You open the access panel."))
			else
				to_chat(user, span_notice("You close the access panel."))
			return
		else if(default_deconstruction_crowbar(O))
			return
	return ..()

/obj/machinery/power/port_gen/pacman/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You hear a hefty clunk from inside the generator."))
	emp_act(EMP_HEAVY)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/port_gen/pacman/attack_paw(mob/user, list/modifiers)
	interact(user)

/obj/machinery/power/port_gen/pacman/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableGenerator", name)
		ui.open()

/obj/machinery/power/port_gen/pacman/ui_data()
	var/data = list()

	data["active"] = active
	data["sheet_name"] = capitalize(sheet_name)
	data["sheets"] = sheets
	data["stack_percent"] = round(sheet_left * 100, 0.1)

	data["anchored"] = anchored
	data["connected"] = (powernet == null ? 0 : 1)
	data["ready_to_boot"] = anchored && HasFuel()
	data["power_generated"] = display_power(power_gen)
	data["power_output"] = display_power(power_gen * power_output)
	data["power_available"] = (powernet == null ? 0 : display_power(avail()))
	data["current_heat"] = current_heat
	. = data

/obj/machinery/power/port_gen/pacman/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_power")
			TogglePower()
			. = TRUE

		if("eject")
			if(!active)
				DropFuel()
				. = TRUE

		if("lower_power")
			if (power_output > 1)
				power_output--
				. = TRUE

		if("higher_power")
			if (power_output < 4 || (obj_flags & EMAGGED))
				power_output++
				. = TRUE

/obj/machinery/power/port_gen/pacman/super
	icon_state = "portgen1_0"
	base_icon_state = "portgen1"
	max_sheets = 20
	time_per_sheet = 20
	power_gen = 15000
	sheet_path = /obj/item/stack/sheet/mineral/uranium

/obj/machinery/power/port_gen/pacman/pre_loaded
	sheets = 15
