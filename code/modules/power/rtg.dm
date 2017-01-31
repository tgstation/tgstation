// Radioisotope Thermoelectric Generator (RTG)
// Simple power generator that would replace "magic SMES" on various derelicts.

/obj/machinery/power/rtg
	name = "radioisotope thermoelectric generator"
	desc = "A simple nuclear power generator, used in small outposts to reliably provide power for decades."
	icon = 'icons/obj/power.dmi'
	icon_state = "rtg"
	density = 1
	anchored = 1
	use_power = 0

	// You can buckle someone to RTG, then open its panel. Fun stuff.
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

	var/power_gen = 1000 // Enough to power a single APC. 4000 output with T4 capacitor.
	var/board_path = /obj/item/weapon/circuitboard/machine/rtg
	var/irradiate = TRUE // RTGs irradiate surroundings, but only when panel is open.

/obj/machinery/power/rtg/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new board_path(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/rtg
	name = "RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg
	origin_tech = "programming=2;materials=4;powerstorage=3;engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/machinery/power/rtg/Initialize()
	..()
	connect_to_network()

/obj/machinery/power/rtg/process()
	..()
	add_avail(power_gen)
	if(panel_open && irradiate)
		radiation_pulse(get_turf(src), 2, 3, 6) // Weak but noticeable.

/obj/machinery/power/rtg/RefreshParts()
	var/part_level = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		part_level += SP.rating

	power_gen = initial(power_gen) * part_level

/obj/machinery/power/rtg/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	else if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-open", initial(icon_state), I))
		return
	else if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/power/rtg/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB && user_buckle_mob(user.pulling, user, check_loc = 0))
		return
	..()


/obj/machinery/power/rtg/advanced
	desc = "An advanced RTG capable of moderating isotope decay, increasing power output but reducing lifetime. It uses plasma-fueled radiation collectors to increase output even further."
	power_gen = 1250 // 2500 on T1, 10000 on T4.
	board_path = /obj/item/weapon/circuitboard/machine/rtg/advanced

/obj/item/weapon/circuitboard/machine/rtg/advanced
	name = "Advanced RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg/advanced
	origin_tech = "programming=3;materials=5;powerstorage=4;engineering=3;plasmatech=3"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)



// Void Core, power source for Abductor ships and bases.
// Provides a lot of power, but tends to explode when mistreated.

/obj/machinery/power/rtg/abductor
	name = "Void Core"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "core"
	desc = "An alien power source that produces energy seemingly out of nowhere."
	board_path = /obj/item/weapon/circuitboard/machine/abductor/core
	power_gen = 20000 // 280 000 at T1, 400 000 at T4. Starts at T4.
	irradiate = FALSE // Green energy!
	can_buckle = FALSE
	pixel_y = 7
	var/going_kaboom = FALSE // Is it about to explode?

/obj/item/weapon/circuitboard/machine/abductor/core
	name = "alien board (Void Core)"
	build_path = /obj/machinery/power/rtg/abductor
	origin_tech = "programming=5;abductor=5;powerstorage=8;engineering=8"
	req_components = list(
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/cell/infinite/abductor = 1)
	def_components = list(
		/obj/item/weapon/stock_parts/capacitor = /obj/item/weapon/stock_parts/capacitor/quadratic,
		/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/quadultra)

/obj/machinery/power/rtg/abductor/proc/overload()
	if(going_kaboom)
		return
	going_kaboom = TRUE
	visible_message("<span class='danger'>\The [src] lets out an shower of sparks as it starts to lose stability!</span>",\
		"<span class='italics'>You hear a loud electrical crack!</span>")
	playsound(src.loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
	tesla_zap(src, 5, power_gen * 0.05)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/explosion, get_turf(src), 2, 3, 4, 8), 100) // Not a normal explosion.

/obj/machinery/power/rtg/abductor/bullet_act(obj/item/projectile/Proj)
	..()
	if(!going_kaboom && istype(Proj) && !Proj.nodamage && ((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE)))
		message_admins("[key_name_admin(Proj.firer)] triggered an Abductor Core explosion via projectile.")
		log_game("[key_name(Proj.firer)] triggered an Abductor Core explosion via projectile.")
		overload()

/obj/machinery/power/rtg/abductor/blob_act(obj/structure/blob/B)
	overload()

/obj/machinery/power/rtg/abductor/ex_act()
	if(going_kaboom)
		qdel(src)
	else
		overload()

/obj/machinery/power/rtg/abductor/fire_act(exposed_temperature, exposed_volume)
	overload()

/obj/machinery/power/rtg/abductor/tesla_act()
	..() //extend the zap
	overload()
