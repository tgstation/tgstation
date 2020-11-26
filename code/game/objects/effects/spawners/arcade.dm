/obj/effect/spawner/randomarcade
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	name = "spawn random arcade machine"
	desc = "Automagically transforms into a random arcade machine. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomarcade/Initialize(mapload)
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
