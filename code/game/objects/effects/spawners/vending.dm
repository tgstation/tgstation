/obj/effect/spawner/randomsnackvend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_snack"
	name = "Spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomsnackvend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	new random_vendor(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/randomsnackvend/contraband
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_snack"
	name = "Spawn random hacked snack vending machine"
	desc = "Automagically transforms into a random hacked snack vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomsnackvend/contraband/Initialize(mapload)
..()
	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	var/obj/machinery/vending/snack/vend = new random_vendor(loc)
	vend.extended_inventory = TRUE

	return INITIALIZE_HINT_QDEL


/obj/effect/spawner/randomcolavend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_cola"
	name = "Spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomcolavend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	new random_vendor(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/randomcolavend/contraband
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_cola"
	name = "Spawn random hacked cola vending machine"
	desc = "Automagically transforms into a random hacked cola vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomcolavend/contraband/Initialize(mapload)
	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	var/obj/machinery/vending/cola/vend = new random_vendor(loc)
	vend.extended_inventory = TRUE

	return INITIALIZE_HINT_QDEL
