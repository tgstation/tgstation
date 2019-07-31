/obj/item/pipe/bluespace
	pipe_type = /obj/machinery/atmospherics/pipe/bluespace
	var/bluespace_network_name = "default"
	icon_state = "bluespace"
	disposable = FALSE

/obj/item/pipe/bluespace/attack_self(mob/user)
	var/new_name = input(user, "Enter identifier for bluespace pipe network", "bluespace pipe", bluespace_network_name) as text|null
	if(!isnull(new_name))
		bluespace_network_name = new_name

/obj/item/pipe/bluespace/make_from_existing(obj/machinery/atmospherics/pipe/bluespace/make_from)
	bluespace_network_name = make_from.bluespace_network_name
	return ..()

/obj/item/pipe/bluespace/build_pipe(obj/machinery/atmospherics/pipe/bluespace/A)
	A.bluespace_network_name = bluespace_network_name
	return ..()
