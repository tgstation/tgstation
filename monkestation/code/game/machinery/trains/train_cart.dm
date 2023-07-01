/obj/machinery/cart
	name = "cargo kart"
	desc = "helps with the move"
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "flatbed"
	density = TRUE
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	pass_flags_self = PASSTABLE
	anchored = FALSE

	var/datum/train_network/linked_network
	var/obj/attached_object
	var/should_reanchor = FALSE


	var/admeme = FALSE
	var/list/attaching_blacklist = list(
		/obj/machinery/nuclearbomb/selfdestruct,
	)

	var/list/blacklist_types = list(
		/obj/machinery/atmospherics,
		/obj/machinery/power,
		/obj/machinery/disposal,
		/obj/structure/grille,
		/obj/machinery/door,
		/obj/structure/window,
		/obj/structure/cable

	)

/obj/machinery/cart/Destroy()
	. = ..()
	if(linked_network)
		linked_network.disconnect_train(src, null)

/obj/machinery/cart/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!attached_object)
		return
	visible_message("[user] attempts to unlatch the [attached_object.name] from the [src.name].")
	if(!do_after(user, 2 SECONDS, src))
		return

	attached_object.cant_grab = FALSE
	attached_object = null

/obj/machinery/cart/AltClick(mob/user)
	. = ..()
	if(!linked_network)
		return
	visible_message("[user] attempts to disconnect the [src.name] from the network.")
	if(!do_after(user, 2 SECONDS, src))
		return
	linked_network.disconnect_train(src, user)

/obj/machinery/cart/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!Adjacent(over) || !usr.Adjacent(over))
		return
	if(!istype(over, /obj/machinery/cart))
		return
	if(!linked_network)
		var/datum/train_network/new_network = new
		new_network.connect_train(src, usr)

	if(!linked_network.end_cart)
		return

	visible_message("[usr] attempts to connect the [name] and [over.name] together")
	if(!do_after(usr, 2 SECONDS, over))
		return
	linked_network.connect_train(over, usr)



/obj/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(src, /obj/vehicle/ridden/cargo_train) || istype(src, /obj/machinery/cart))
		return
	if(istype(over, /obj/machinery/cart))
		var/obj/machinery/cart/dropped_cart = over
		if(!dropped_cart.admeme)
			if(!Adjacent(over) || !usr.Adjacent(over))
				return
			if(src.type in dropped_cart.attaching_blacklist)
				return
			for(var/obj in dropped_cart.blacklist_types)
				if(src.type in typesof(obj))
					return
		if(dropped_cart.attached_object)
			return
		visible_message("[usr] attempts to attach the [name] to the [over.name]")

		if(!do_after(usr, 3 SECONDS, over))
			return
		dropped_cart.attached_object = src

		cant_grab = TRUE
		src.forceMove(get_turf(dropped_cart))
