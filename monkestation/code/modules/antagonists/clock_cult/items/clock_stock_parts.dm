//power cell that gets its power from GLOB.clock_power DOES NOT CURRENTLY WORK, NEED TO REFACTOR CLOCK POWER INTO AN SS
/obj/item/stock_parts/cell/clock
	name = "Wound Power Cell"
	desc = "A bronze colored power cell. Is that a winding crank on the side?" //might make a real wind up powercell at some point for a joke item
	color = rgb(190, 135, 0) //currently only used for mechs so im calling this good enough

/obj/item/stock_parts/cell/clock/Initialize(mapload, override_maxcharge)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF) //no EMP
	UnregisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED) //just to be safe

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

//these are just for flavor, also only for mechs
/obj/item/stock_parts/scanning_module/triphasic/clock
	name = "Ticking Scanning Module"
	desc = "A bronze colored scanning module, you hear a faint ticking from inside."
	color = rgb(190, 135, 0)

/obj/item/stock_parts/capacitor/quadratic/clock
	name = "Clicking Capacitor"
	desc = "A bronze colored scanning module with a slow clicking within."
	color = rgb(190, 135, 0)
