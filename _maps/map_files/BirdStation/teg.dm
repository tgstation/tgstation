//awful code

/obj/machinery/power/generator/birdstation/initialize()

	circ1 = null
	circ2 = null

	circ1 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,EAST)
	circ2 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,WEST)
	connect_to_network()

	if(circ1)
		circ1.side = 2
		circ1.update_icon()
	if(circ2)
		circ2.side = 1
		circ2.update_icon()

	if(!circ1 || !circ2)
		explosion(get_turf(src), 5, 10, 20, 40, 1)
		qdel(src)

	update_icon()
