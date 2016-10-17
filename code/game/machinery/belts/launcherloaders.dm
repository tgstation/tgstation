/obj/machinery/launcher_loader
	icon = 'goon/icons/obj/stationobjs.dmi'
	icon_state = "launcher_loader_0"
	name = "Automatic mass-driver loader (AMDL)"
	desc = "An automated, hydraulic mass-driver loader."
	density = 0
	opacity = 0
	layer = 2.6
	anchored = 1

	var/obj/machinery/mass_driver/driver = null

	var/id = "null"
	var/operating = 0
	var/driver_operating = 0
	var/trash = 0
	var/obj/machinery/door/poddoor/door = null

/obj/machinery/launcher_loader/New()
	..()
	spawn(5)
		var/list/drivers = new/list()
		for(var/obj/machinery/mass_driver/D in range(1,src))
			drivers += D
		if(drivers.len)
			if(drivers.len > 1)
				for(var/obj/machinery/mass_driver/D2 in drivers)
					if(D2.id == src.id)
						driver = D2
						break
				if(!driver) driver = pick(drivers)
			else
				driver = pick(drivers)
			src.dir = get_dir(src,driver)

/obj/machinery/launcher_loader/proc/destroy()
	if (driver)
		driver = null
	if (door)
		door = null
	return ..()

/obj/machinery/launcher_loader/proc/activate()
	if(operating || !isturf(src.loc)) return
	operating = 1
	flick("launcher_loader_1",src)
	playsound(src, "goon/sound/effects/pump.ogg",50, 1)
	sleep(3)
	for(var/atom/movable/AM in src.loc)
		if(AM.anchored || AM == src) continue
		if(trash && AM.delivery_destination != "Disposals")
			AM.delivery_destination = "Disposals"
		step(AM,src.dir)
	operating = 0
	handle_driver()

/obj/machinery/launcher_loader/proc/handle_driver()
	if(driver && !driver_operating)
		driver_operating = 1

	spawn(0)
		for(var/obj/machinery/door/poddoor/P)
			if (P.id == driver.id)
				door = P
				if (door)
					door.open()
			spawn(99)
				if (door)
					door.close() //this may need some adjusting still

		spawn(door ? 55 : 20) driver_operating = 0

		spawn(door ? 20 : 10)
			if (driver)
				for(var/obj/machinery/mass_driver/D in machines)
					if(D.id == driver.id)
						D.drive()
/obj/machinery/launcher_loader/process()
	if(!operating && !driver_operating)
		var/drive = 0
		for(var/atom/movable/M in src.loc)
			if(M == src || M.anchored) continue
			drive = 1
			break
		if(drive) activate()

/obj/machinery/launcher_loader/Crossed(atom/A)
	if (isobserver(A) || istype(A, /mob/living/simple_animal/revenant)) return
	if (istype(A, /obj/effect/overlay)) return
	activate()

/obj/machinery/launcher_loader/north
	dir = NORTH
/obj/machinery/launcher_loader/east
	dir = EAST
/obj/machinery/launcher_loader/south
	dir = SOUTH
/obj/machinery/launcher_loader/west
	dir = WEST

/obj/machinery/cargo_router
	icon = 'goon/icons/obj/delivery.dmi'
	icon_state = "amdl_0"
	name = "Cargo Router"
	desc = "Scans the barcode on objects and reroutes them accordingly."
	density = 0
	opacity = 0
	anchored = 1

	var/default_direction = NORTH //The direction things get sent into when the router does not have a destination for the given barcode or when there is none attached.
	var/list/destinations = new/list() //List of tags and the associated directions.

	var/obj/machinery/mass_driver/driver = null
	var/operating = 0
	var/driver_operating = 0

/obj/machinery/cargo_router/proc/destroy()
	if (driver)
		driver = null
	return ..()

/obj/machinery/cargo_router/proc/activate()
	if(operating || !isturf(src.loc)) return
	operating = 1

	var/next_dest = null

	for(var/atom/movable/AM in src.loc)
		if(AM.anchored || AM == src) continue
		if(AM.delivery_destination && !next_dest)
			if(destinations.Find(AM.delivery_destination))
				next_dest = destinations[AM.delivery_destination]
				break

	if(next_dest) src.dir = next_dest
	else src.dir = default_direction

	flick("amdl_1",src)
	playsound(src, "goon/sound/effects/pump.ogg",50, 1)
	sleep(3)

	for(var/atom/movable/AM2 in src.loc)
		if(AM2.anchored || AM2 == src) continue
		step(AM2,src.dir)

	driver = (locate(/obj/machinery/mass_driver) in get_step(src,src.dir))

	operating = 0
	handle_driver()

/obj/machinery/cargo_router/proc/handle_driver()
	if(driver && !driver_operating)
		driver_operating = 1

		spawn(0)
			spawn(20)
				driver_operating = 0
				driver = null

			spawn(10)
				if (driver)
					driver.drive()

/obj/machinery/cargo_router/process()
	if(!operating && !driver_operating)
		var/drive = 0
		for(var/atom/movable/M in src.loc)
			if(M == src || M.anchored) continue
			drive = 1
			break
		if(drive)
			activate()

/obj/machinery/cargo_router/Crossed(atom/A)
	if (isobserver(A) || istype(A, /mob/living/simple_animal/revenant))
		return
	if (istype(A, /obj/effect/overlay))
		return
	activate()

/obj/machinery/cargo_router/exampleRouter/New()
	destinations = list("Medical-Science Dock" = SOUTH, "Catering Dock" = NORTH, "EVA Dock" = WEST, "Disposals" = EAST)
	default_direction = EAST //By default send things to disposals, for this example, if they dont have a code or we don't have a destination.
	//You could leave one direction open and use that as default to send things with invalid destinations back to QM or something.
	//Or if QM is already in the list of destinations , use that direction as default. I don't know.
	..()