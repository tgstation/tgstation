/obj/item/pattern_kit
	name = "pattern kit"
	desc = "A pattern kit for clothing."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "pattern_kit"
	var/obj/item/clothing/clothing_to_make

/obj/machinery/pattern_table
	name = "pattern table"
	desc = "Use this to breakdown clothing to make pattern kits for them."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "pattern_table"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/pattern_table
	density = TRUE

/obj/machinery/pattern_table/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/clothing))
		var/obj/item/clothing/clothing_target = weapon
		var/obj/item/pattern_kit/pattern = new(get_turf(src))
		pattern.name = "[clothing_target] pattern kit"
		pattern.desc = "A pattern kit for [clothing_target]. Take it to a tailor to make clothing."
		pattern.clothing_to_make = clothing_target.type
		qdel(clothing_target)
