/obj/item/weldingtool/makeshift
	name = "makeshift welding tool"
	desc = "A MacGyver-style welder."
	icon = 'massmeta/icons/obj/improvised.dmi'
	icon_state = "welder_makeshift"
	toolspeed = 2
	max_fuel = 10
	starting_fuel = FALSE
	change_icons = FALSE
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.7)

/obj/item/weldingtool/makeshift/switched_on(mob/user)
	..()
	if(welding && get_fuel() >= 1 && prob(2))
		var/datum/effect_system/reagents_explosion/e = new()
		to_chat(user, span_userdanger("Shoddy construction causes [src] to blow the fuck up!"))
		e.set_up(round(get_fuel() / 10, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
