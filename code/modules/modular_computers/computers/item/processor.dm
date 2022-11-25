// Held by /obj/machinery/modular_computer to reduce amount of copy-pasted code.
//TODO: REFACTOR THIS SPAGHETTI CODE
/obj/item/modular_computer/processor
	name = "processing unit"
	desc = "An advanced computer." //modular PCs examine us
	icon = null
	icon_state = null
	icon_state_unpowered = null
	icon_state_menu = null
	hardware_flag = 0

	///The modular computer MACHINE that hosts us.
	var/obj/machinery/modular_computer/machinery_computer

/obj/item/modular_computer/processor/UpdateDisplay()
	. = ..()
	//update our name to match the computer's
	name = machinery_computer.name

/obj/item/modular_computer/processor/Initialize(mapload)
	if(!istype(loc, /obj/machinery/modular_computer))
		CRASH("A non '/obj/machinery/modular_computer' had a [src] initialized in it!")

	// Obtain reference to machinery computer
	machinery_computer = loc
	machinery_computer.cpu = src
	internal_cell = machinery_computer.internal_cell
	hardware_flag = machinery_computer.hardware_flag
	steel_sheet_cost = machinery_computer.steel_sheet_cost
	max_idle_programs = machinery_computer.max_idle_programs
	update_integrity(machinery_computer.get_integrity())
	max_integrity = machinery_computer.max_integrity
	integrity_failure = machinery_computer.integrity_failure
	base_active_power_usage = machinery_computer.base_active_power_usage
	base_idle_power_usage = machinery_computer.base_idle_power_usage
	machinery_computer.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, TYPE_PROC_REF(/obj/machinery/modular_computer, relay_icon_update)) //when we update_icon, also update the computer
	return ..()

/obj/item/modular_computer/processor/Destroy(force)
	if(machinery_computer && (machinery_computer.cpu == src))
		machinery_computer.cpu = null
		machinery_computer.UnregisterSignal(src, COMSIG_ATOM_UPDATED_ICON)
	machinery_computer = null
	return ..()

/obj/item/modular_computer/processor/relay_qdel()
	qdel(machinery_computer)
