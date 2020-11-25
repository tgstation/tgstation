/obj/effect/spawner/randomsnackvend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_snack"
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomsnackvend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	new random_vendor(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/randomcolavend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_cola"
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomcolavend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	new random_vendor(loc)

	return INITIALIZE_HINT_QDEL
