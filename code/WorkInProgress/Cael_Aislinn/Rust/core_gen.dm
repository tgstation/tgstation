//the core [tokamaka generator] big funky solenoid, it generates an EM field

/*
when the core is turned on, it generates [creates] an electromagnetic field
the em field attracts plasma, and suspends it in a controlled torus (doughnut) shape, oscillating around the core

the field strength is directly controllable by the user
field strength = sqrt(energy used by the field generator)

the size of the EM field = field strength / k
(k is an arbitrary constant to make the calculated size into tilewidths)

1 tilewidth = below 5T
3 tilewidth = between 5T and 12T
5 tilewidth = between 10T and 25T
7 tilewidth = between 20T and 50T
(can't go higher than 40T)

energy is added by a gyrotron, and lost when plasma escapes
energy transferred from the gyrotron beams is reduced by how different the frequencies are (closer frequencies = more energy transferred)

frequency = field strength * (stored energy / stored moles of plasma) * x
(where x is an arbitrary constant to make the frequency something realistic)
the gyrotron beams' frequency and energy are hardcapped low enough that they won't heat the plasma much

energy is generated in considerable amounts by fusion reactions from injected particles
fusion reactions only occur when the existing energy is above a certain level, and it's near the max operating level of the gyrotron. higher energy reactions only occur at higher energy levels
a small amount of energy constantly bleeds off in the form of radiation

the field is constantly pulling in plasma from the surrounding [local] atmosphere
at random intervals, the field releases a random percentage of stored plasma in addition to a percentage of energy as intense radiation

the amount of plasma is a percentage of the field strength, increased by frequency
*/

/*
- VALUES -

max volume of plasma storeable by the field = the total volume of a number of tiles equal to the (field tilewidth)^2

*/

#define MAX_FIELD_FREQ 1000
#define MIN_FIELD_FREQ 1
#define MAX_FIELD_STR 1000
#define MIN_FIELD_STR 1
#define RUST_CORE_STR_COST 5

/obj/machinery/power/rust_core
	name = "R-UST Mk 7 Tokamak core"
	desc = "An enormous solenoid for generating extremely high power electromagnetic fields"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "core0"
	density = 1
	light_power_on = 2
	light_range_on = 3
	light_color = LIGHT_COLOR_BLUE

	var/obj/effect/rust_em_field/owned_field
	var/field_strength = 1//0.01
	var/field_frequency = 1
	var/id_tag

	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500	//multiplied by field strength
	anchored = 0

	machine_flags = WRENCHMOVE | FIXED2WORK | WELD_FIXED | EMAGGABLE | MULTITOOL_MENU

/obj/machinery/power/rust_core/New()
	. = ..()
	if(ticker)
		initialize()

/obj/machinery/power/rust_core/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

/obj/machinery/power/rust_core/process()
	if(stat & BROKEN || !powernet)
		Shutdown()

/obj/machinery/power/rust_core/weldToFloor(var/obj/item/weapon/weldingtool/WT, mob/user)
	if(owned_field)
		to_chat(user, user << "<span class='warning'>Turn \the [src] off first!</span>")
		return -1

	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

/obj/machinery/power/rust_core/Topic(href, href_list)
	if(..()) return 1
	if(href_list["str"])
		var/dif = text2num(href_list["str"])
		field_strength = min(max(field_strength + dif, MIN_FIELD_STR), MAX_FIELD_STR)
		active_power_usage = 5 * field_strength	//change to 500 later
		if(owned_field)
			owned_field.ChangeFieldStrength(field_strength)

	if(href_list["freq"])
		var/dif = text2num(href_list["freq"])
		field_frequency = min(max(field_frequency + dif, MIN_FIELD_FREQ), MAX_FIELD_FREQ)
		if(owned_field)
			owned_field.ChangeFieldFrequency(field_frequency)

/obj/machinery/power/rust_core/proc/Startup()
	if(owned_field)
		return

	owned_field = new(loc, src)
	owned_field.ChangeFieldStrength(field_strength)
	owned_field.ChangeFieldFrequency(field_frequency)
	set_light(light_range_on, light_power_on)
	icon_state = "core1"
	use_power = 2
	. = 1

/obj/machinery/power/rust_core/proc/Shutdown()
	//todo: safety checks for field status
	if(owned_field)
		icon_state = "core0"
		qdel(owned_field)
		use_power = 1
		set_light(0)

/obj/machinery/power/rust_core/proc/AddParticles(var/name, var/quantity = 1)
	if(owned_field)
		owned_field.AddParticles(name, quantity)
		. = 1

/obj/machinery/power/rust_core/bullet_act(var/obj/item/projectile/Proj)
	if(owned_field)
		. = owned_field.bullet_act(Proj)

/obj/machinery/power/rust_core/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li>[format_tag("ID Tag","id_tag")]</li>
		</ul>
	"}

/obj/machinery/power/rust_core/proc/set_strength(var/value)
	value = Clamp(value, MIN_FIELD_STR, MAX_FIELD_STR)
	field_strength = value
	active_power_usage = RUST_CORE_STR_COST * value
	if(owned_field)
		owned_field.ChangeFieldStrength(value)

/obj/machinery/power/rust_core/proc/set_frequency(var/value)
	value = Clamp(value, MIN_FIELD_FREQ, MAX_FIELD_FREQ)
	field_frequency = value
	if(owned_field)
		owned_field.ChangeFieldFrequency(value)
