//power cell that gets its power from GLOB.clock_power
/obj/item/stock_parts/cell/clock
	name = "Wound Power Cell"
	desc = "A bronze colored power cell. Is that a winding crank on the side?" //might make a real wind up powercell at some point for a joke item
	color = rgb(190, 135, 0) //currently only used for mechs so im calling this good enough

/obj/item/stock_parts/cell/clock/Initialize(mapload, override_maxcharge)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF) //no EMP
	UnregisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED) //just to be safe
	START_PROCESSING(SSfastprocess, src) //janky, but the only way I can think of to get this to work is with a refactor to clock power, which im not doing for the visuals of one thing

/obj/item/stock_parts/cell/clock/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/stock_parts/cell/clock/process(seconds_per_tick)
	charge = GLOB.clock_power
	maxcharge = GLOB.max_clock_power

//technically this means these cant be rigged with plasma
/obj/item/stock_parts/cell/clock/use(used, force)
	if(istype(loc, /obj/machinery/power/apc) || GLOB.clock_power < used)
		return FALSE
	SSblackbox.record_feedback("tally", "cell_used", 1, type)
	GLOB.clock_power = max(GLOB.clock_power - used, 0)
	return TRUE

/obj/item/stock_parts/cell/clock/percent()
	return 100 * GLOB.clock_power / GLOB.max_clock_power

/obj/item/stock_parts/cell/clock/give(amount) //no
	return FALSE

//these are just for flavor
/obj/item/stock_parts/scanning_module/triphasic/clock
	name = "Ticking Scanning Module"
	desc = "A bronze colored scanning module, you hear a faint ticking from inside."
	color = rgb(190, 135, 0)

/datum/stock_part/scanning_module/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/scanning_module/triphasic/clock

/obj/item/stock_parts/capacitor/quadratic/clock
	name = "Clicking Capacitor"
	desc = "A bronze colored scanning module with a slow clicking within."
	color = rgb(190, 135, 0)

/datum/stock_part/capacitor/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/capacitor/quadratic/clock

/obj/item/stock_parts/matter_bin/bluespace/clock
	name = "Glowing Matter Bin"
	desc = "It has a faint glow emitting from within."
	color = rgb(190, 135, 0)

/datum/stock_part/matter_bin/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/matter_bin/bluespace/clock

/obj/item/stock_parts/manipulator/femto/clock
	name = "Powered Manipulator"
	desc = "Changes the energy flow around an object to manipulate it."
	color = rgb(190, 135, 0)

/datum/stock_part/manipulator/clock
	tier = 4
	physical_object_type = /obj/item/stock_parts/manipulator/femto/clock
