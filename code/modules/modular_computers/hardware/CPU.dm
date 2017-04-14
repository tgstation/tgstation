// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/weapon/computer_hardware/processor_unit
	name = "processor board"
	desc = "A standard CPU board used in most computers. It can run up to three programs simultaneously."
	icon_state = "cpuboard"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 50
	critical = 1
	malfunction_probability = 1
	origin_tech = "programming=3;engineering=2"
	var/max_idle_programs = 2 // 2 idle, + 1 active = 3 as said in description.
	device_type = MC_CPU

/obj/item/weapon/computer_hardware/processor_unit/on_remove(obj/item/device/modular_computer/MC, mob/user)
	MC.shutdown_computer()

/obj/item/weapon/computer_hardware/processor_unit/small
	name = "microprocessor"
	desc = "A miniaturised CPU used in portable devices. It can run up to two programs simultaneously."
	icon_state = "cpu"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 25
	max_idle_programs = 1
	origin_tech = "programming=2;engineering=2"

/obj/item/weapon/computer_hardware/processor_unit/photonic
	name = "photonic processor board"
	desc = "An advanced experimental CPU board that uses photonic core instead of regular circuitry. It can run up to five programs simultaneously, but uses a lot of power."
	icon_state = "cpuboard_super"
	w_class = WEIGHT_CLASS_SMALL
	power_usage = 250
	max_idle_programs = 4
	origin_tech = "programming=5;engineering=4"

/obj/item/weapon/computer_hardware/processor_unit/photonic/small
	name = "photonic microprocessor"
	desc = "An advanced miniaturised CPU for use in portable devices. It uses photonic core instead of regular circuitry. It can run up to three programs simultaneously."
	icon_state = "cpu_super"
	w_class = WEIGHT_CLASS_TINY
	power_usage = 75
	max_idle_programs = 2
	origin_tech = "programming=4;engineering=3"