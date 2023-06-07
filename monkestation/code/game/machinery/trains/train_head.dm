/obj/vehicle/ridden/cargo_train
	name = "cargo train"
	desc = "A good way to transport items"
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "tractor"
	var/datum/train_network/listed_network

/obj/vehicle/ridden/cargo_train/Initialize(mapload)
	. = ..()
	make_ridable()

/obj/vehicle/ridden/cargo_train/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter)

/obj/vehicle/ridden/cargo_train/Destroy(force)
	. = ..()
	if(listed_network)
		listed_network.train_head = null
		listed_network = null

/obj/vehicle/ridden/cargo_train/Move(newloc, dir)
	var/turf/old_loc = src.loc
	. = ..()
	if(listed_network)
		listed_network.relay_move(old_loc)

/obj/vehicle/ridden/cargo_train/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!listed_network)
		listed_network = new
		listed_network.train_head = src

	visible_message("[usr] attempts to connect the [name] and [over.name] together")
	if(!do_after(usr, 2 SECONDS, over))
		return

	if(istype(over, /obj/machinery/cart))
		listed_network.connect_train(over)
