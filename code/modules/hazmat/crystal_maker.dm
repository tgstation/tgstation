/obj/machinery/hazmat
	icon = 'icons/obj/hazmat/machinery.dmi'

/obj/machinery/hazmat/crystal_maker
	name = "crystal maker"
	desc = "Insert diamonds or glass to generate crystals. Uses 1 sheet each."
	icon_state = "crystal_maker"

/obj/machinery/hazmat/crystal_maker/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/stack/sheet/glass))
		var/obj/item/crystal/random/C = new(get_turf(src))
		C.malf_chance = 10
		say("Producing GLASS crystal. Crystal structural stability: 90%.")
		return
	if(istype(I, /obj/item/stack/sheet/mineral/diamond))
		new /obj/item/crystal/random(get_turf(src))
		say("Producing DIAMOND crystal. Crystal structural stability: 100%.")
		return
	say("ERROR: Unknown material. Can not produce crystal.")