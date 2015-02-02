/obj/machinery/mecha_part_fabricator/dronefactory
	name = "drone factory"
	desc = "It remains unclear if allowing machines to create more machines was ever a good idea."
	icon = 'icons/obj/robotics.dmi'
	icon_state = "dfactory"
	anchored = 1
	density = 1

	resources = list(
								"$metal"=3200,
								"$glass"=1400)

	var/metal_cost = 800
	var/glass_cost = 350
	var/cooldown_duration = 50 // 5 seconds
	var/cooldown = 0
	var/drone_type = /obj/item/drone_shell
	var/circuit_type = /obj/item/weapon/circuitboard/mechfab/dronefactory

/obj/machinery/mecha_part_fabricator/dronefactory/malf
	drone_type = /obj/item/drone_shell/malf
	circuit_type = /obj/item/weapon/circuitboard/mechfab/dronefactory/malf


/obj/machinery/mecha_part_fabricator/dronefactory/New()
	..()
	component_parts = list()
	component_parts += new circuit_type(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	notify_ghosts("Drone factory created in [get_area(src)].", 'sound/items/rped.ogg')

/obj/machinery/mecha_part_fabricator/dronefactory/interact(mob/user as mob)
	build_drone(user)

/obj/machinery/mecha_part_fabricator/dronefactory/attack_ghost(mob/user)
	if(stat & (BROKEN|MAINT|NOPOWER))
		return
	build_drone(user)

/obj/machinery/mecha_part_fabricator/dronefactory/proc/build_drone(mob/user)
	if(cooldown)
		user << "<span class='notice'>\The [src] is busy!</span>"
		return

	var/turf/exit = get_step(src,SOUTH)
	if(!exit || exit.density)
		audible_message("\icon[src] <b>\The [src]</b> beeps, \"Error! Output hatch is obstructed.\"")
		return

	var/material=0
	if(resources["$metal"]>=metal_cost)
		if(resources["$glass"]>=glass_cost)
			resources["$metal"]-=metal_cost
			resources["$glass"]-=glass_cost
			overlays += "dfactory-active"
			cooldown = 1
			sleep(cooldown_duration)
			overlays -= "dfactory-active"
			new drone_type(exit)
			cooldown = 0
		else
			material = "glass"
	else
		material = "metal"
	if(material)
		user << "<span class='notice'>\The [src] is out of [material]!</span>"


/obj/machinery/mecha_part_fabricator/dronefactory/attackby(obj/W as obj, mob/user as mob)
	if(default_deconstruction_screwdriver(user, "dfactory-o", "dfactory", W))
		return

	if(exchange_parts(user, W))
		return

	if(panel_open)
		if(istype(W, /obj/item/weapon/crowbar))
			for(var/material in resources)
				remove_material(material, resources[material]/MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(W)
			return 1
		else
			user << "<span class='danger'>You can't load \the [name] while it's opened.</span>"
			return 1

	var/material
	if(istype(W, /obj/item/stack/sheet/metal))
		material = "$metal"
	else if(istype(W, /obj/item/stack/sheet/glass))
		material = "$glass"
	else if(istype(W, /obj/item/stack))
		user << "<span class='notice'>You can't load that in \the [name]!</span>"
		return 1
	else
		return ..()
	var/obj/item/stack/sheet/stack = W
	var/sname = "[stack.name]"
	if(res_max_amount - resources[material] < MINERAL_MATERIAL_AMOUNT) //overstuffing the fabricator
		user << "\The [src] [sname] storage is full."
		return
	if(resources[material] < res_max_amount)
		overlays += "fab-load-[sname]"
		var/transfer_amount = min(stack.amount, round((res_max_amount - resources[material])/MINERAL_MATERIAL_AMOUNT,1))
		resources[material] += transfer_amount * MINERAL_MATERIAL_AMOUNT
		stack.use(transfer_amount)
		user << "You insert [transfer_amount] [sname] sheet\s into \the [src]."
		sleep(10)
		overlays -= "fab-load-[sname]"
	else
		user << "\The [src] cannot hold any more [sname] sheet\s."

/obj/machinery/mecha_part_fabricator/dronefactory/emag_act()
	drone_type = /obj/item/drone_shell/malf
	circuit_type = /obj/item/weapon/circuitboard/mechfab/dronefactory/malf
	visible_message("\icon[src] <b>\The [src]</b> beeps: \"System reset to default factory settings.\"")