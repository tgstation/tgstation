
//---------- external shield generator
//generates an energy field that loops around any built up area in space (is useless inside) halts movement and airflow, is blocked by walls, windows, airlocks etc

/obj/machinery/shield_gen/external/New()
	..()

/obj/machinery/shield_gen/external/get_shielded_turfs()
	var
		list
			open = list(get_turf(src))
			closed = list()

	while(open.len)
		for(var/turf/T in open)
			for(var/turf/O in orange(1, T))
				if(get_dist(O,src) > field_radius)
					continue
				var/add_this_turf = 0
				if(istype(O,/turf/space))
					for(var/turf/simulated/G in orange(1, O))
						add_this_turf = 1
						break
					for(var/obj/structure/S in orange(1, O))
						add_this_turf = 1
						break
					for(var/obj/structure/S in O)
						add_this_turf = 0
						break

					if(add_this_turf && !(O in open) && !(O in closed))
						open += O
			open -= T
			closed += T

	return closed

/obj/machinery/shield_gen/external/process()
	/*if(stat & (NOPOWER|BROKEN))
		return*/
	if(!active)
		return
	/*spawn(100)
		power()*/
	/*if(src.active >= 1)
		if(src.power == 0)
			src.visible_message("\red The [src.name] shuts down due to lack of power!", \
				"You hear heavy droning fade out")
			icon_state = "generator0"
			src.active = 0*/
	..()

/obj/item/weapon/circuitboard/shield_gen/external
	name = "Circuit Board (External Shield Generator)"
	build_path = "/obj/machinery/shield_gen/external"
	board_type = "machine"
	origin_tech = "electromagnetic=3;engineering=2;power=1"
	frame_desc = "Requires, 2 Cable Coil, 2 Nano Manipulator, 1 Advanced Matter Bin, 1 Console Screen and 1 High-Power Micro-Laser. "
	req_components = list(
							"/obj/item/weapon/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/manipulator/nano" = 2,
							"/obj/item/weapon/stock_parts/matter_bin/adv" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1,
							"/obj/item/weapon/stock_parts/micro_laser/high" = 1)
