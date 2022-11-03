/obj/machinery/modular_computer/console
	name = "console"
	desc = "A stationary computer."

	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	icon_state_powered = "console"
	icon_state_unpowered = "console-off"
	hardware_flag = PROGRAM_CONSOLE
	density = TRUE
	base_idle_power_usage = 100
	base_active_power_usage = 500
	max_hardware_size = 4
	steel_sheet_cost = 10
	light_strength = 2
	max_integrity = 300
	integrity_failure = 0.5
	///Used in New() to set network tag according to our area.
	var/console_department = ""

/obj/machinery/modular_computer/console/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/battery/battery_module = cpu.all_components[MC_CELL]
	if(battery_module)
		qdel(battery_module)

	if(cpu)
		cpu.screen_on = TRUE
	update_appearance()
