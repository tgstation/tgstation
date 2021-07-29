/obj/effect/spawner/random/machinery
	name = "machinery spawner"
	desc = "Randomized electronics for extra fun."

/obj/effect/spawner/random/machinery/snackvend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_snack"
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."
	///whether it hacks the vendor on spawn currently used only by stinky mapedits
	var/hacked = FALSE

/obj/effect/spawner/random/machinery/snackvend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	var/obj/machinery/vending/snack/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL


/obj/effect/spawner/random/machinery/colavend
	icon = 'icons/obj/vending.dmi'
	icon_state = "random_cola"
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."
	///whether it hacks the vendor on spawn currently used only by stinky mapedits
	var/hacked = FALSE

/obj/effect/spawner/random/machinery/colavend/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	var/obj/machinery/vending/cola/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random/machinery/arcade
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	name = "spawn random arcade machine"
	desc = "Automagically transforms into a random arcade machine. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/random/machinery/arcade/Initialize(mapload)
	..()

	var/static/list/gameodds = list(
		/obj/item/circuitboard/computer/arcade/battle = 49,
		/obj/item/circuitboard/computer/arcade/orion_trail = 49,
		/obj/item/circuitboard/computer/arcade/amputation = 2)
	var/obj/item/circuitboard/circuit = pickweight(gameodds)
	var/new_build_path = initial(circuit.build_path)

	if(!ispath(new_build_path))
		stack_trace("Circuit with incorrect build path: [circuit]")
		return INITIALIZE_HINT_QDEL

	var/obj/arcade = new new_build_path(loc)
	arcade.setDir(dir)

	// And request a qdel.
	return INITIALIZE_HINT_QDEL
