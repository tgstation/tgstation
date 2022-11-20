// Held by /obj/machinery/modular_computer to reduce amount of copy-pasted code.
//TODO: REFACTOR THIS SPAGHETTI CODE, MAKE IT A COMPUTER_HARDWARE COMPONENT OR REMOVE IT
/obj/item/modular_computer/processor
	name = "processing unit"
	desc = "An advanced computer." //modular PCs examine us
	icon = null
	icon_state = null
	icon_state_unpowered = null
	icon_state_menu = null
	hardware_flag = 0
	max_bays = 4

	///The modular computer MACHINE that hosts us.
	var/obj/machinery/modular_computer/machinery_computer

/obj/item/modular_computer/processor/UpdateDisplay()
	. = ..()
	//update the name with us
	machinery_computer.name = name

/obj/item/modular_computer/processor/Initialize(mapload)
	if(!istype(loc, /obj/machinery/modular_computer))
		CRASH("A non '/obj/machinery/modular_computer' had a [src] initialized in it!")

	// Obtain reference to machinery computer
	machinery_computer = loc
	machinery_computer.cpu = src
	internal_cell = machinery_computer.internal_cell
	hardware_flag = machinery_computer.hardware_flag
	max_hardware_size = machinery_computer.max_hardware_size
	steel_sheet_cost = machinery_computer.steel_sheet_cost
	max_idle_programs = machinery_computer.max_idle_programs
	update_integrity(machinery_computer.get_integrity())
	max_integrity = machinery_computer.max_integrity
	integrity_failure = machinery_computer.integrity_failure
	base_active_power_usage = machinery_computer.base_active_power_usage
	base_idle_power_usage = machinery_computer.base_idle_power_usage
	machinery_computer.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, /obj/machinery/modular_computer/proc/relay_icon_update) //when we update_icon, also update the computer
	return ..()

/obj/item/modular_computer/processor/Destroy(force)
	if(machinery_computer && (machinery_computer.cpu == src))
		machinery_computer.cpu = null
		machinery_computer.UnregisterSignal(src, COMSIG_ATOM_UPDATED_ICON)
	machinery_computer = null
	return ..()

/obj/item/modular_computer/processor/relay_qdel()
	qdel(machinery_computer)
