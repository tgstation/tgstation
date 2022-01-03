/obj/machinery/loom
	name = "loom"
	desc = "Turn plants into cloth!"
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "loom"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/loom
	density = TRUE
	var/rating = 1

/obj/machinery/loom/RefreshParts()
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating = M.rating

/obj/machinery/loom/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/food/grown))
		var/obj/item/food/grown/plant = weapon
		var/obj/item/stack/sheet/cloth/cloth_made = new(get_turf(src))
		cloth_made.add(rating)
		cloth_made.name = "[plant.name] cloth"
		cloth_made.desc = "Cloth woven from [plant.name]."
		cloth_made.color = plant.filling_color
		to_chat(user, "You wove [plant] into cloth.")
		qdel(plant)
	if(istype(weapon, /obj/item/grown/cotton))
		var/obj/item/stack/sheet/cloth/cloth_made = new(get_turf(src))
		cloth_made.add(rating)
		to_chat(user, "You wove [weapon] into cloth.")
		qdel(weapon)
