/obj/machinery/dye_machine
	name = "dye machine"
	desc = "Insert plants to turn them into dye."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "dye_machine"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/dye_machine
	density = TRUE

/obj/machinery/dye_machine/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/food/grown))
		var/obj/item/food/grown/plant = weapon
		var/obj/item/dye/dye_pack = new(get_turf(src))
		dye_pack.name = "[plant] dye pack"
		dye_pack.desc = "A package of [plant] dye for coloring hair, beards, and clothes."
		dye_pack.color = plant.filling_color
		to_chat(user, "You extract the plant into dye.")
		qdel(plant)
