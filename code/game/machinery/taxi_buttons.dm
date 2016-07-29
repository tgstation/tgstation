/obj/machinery/door_control/taxi
	name = "taxi caller"
	desc = "TAXI!"
	var/destination
	power_channel = ENVIRON
	req_access = list(access_taxi)
	var/obj/machinery/computer/taxi_shuttle/connected_computer

/obj/machinery/door_control/taxi/New()
	..()

	if(ticker)
		initialize()

/obj/machinery/door_control/taxi/initialize()
	..()
	for(var/obj/machinery/computer/taxi_shuttle/TS in taxi_computers)
		if(id_tag == TS.id_tag)
			connected_computer = TS
			if(!(src in connected_computer.connected_buttons))
				connected_computer.connected_buttons += src
			break

/obj/machinery/door_control/taxi/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!connected_computer)
		user.show_message("<span class='warning'>No request could be made to the Taxi Computer! Make contact with Centcomm to report them the issue!</span>", 2)
		initialize() //Try connecting again
		return

	var/datum/shuttle/taxi/T = connected_computer.shuttle
	if(!T)
		user.show_message("<span class='warning'>The Taxi Computer was unable to enstablish connection with the taxi shuttle. Please contact tech support.</span>")
		return

	var/wait_time = T.move_time_access

	if(!allowed(user) && (wires & 1))
		wait_time = T.move_time_no_access

	use_power(5)
	icon_state = "doorctrl1"
	add_fingerprint(user)

	spawn
		if(!connected_computer.callTo(destination, wait_time))
			if( (T.cooldown - (world.time - T.last_moved)) > 0) //If it's going to show a negative value, there's something else wrong
				src.visible_message("Taxi engines are on cooldown for the next [round((T.cooldown - (world.time - T.last_moved)) / 10)] second\s. Please wait before trying again.")

	spawn(30)
		icon_state = initial(icon_state)

/obj/machinery/door_control/taxi/abandoned
	name = "taxi caller"
	desc = "...Taxi?"
	destination = "abandoned"
	id_tag = "taxi_null"
	req_access = list()

/obj/machinery/door_control/taxi/abandoned/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && (wires & 1))
		to_chat(user, "<span class='rose'>Access Denied.</span>")
		flick("doorctrl-denied",src)
		return

	icon_state = "doorctrl1"
	add_fingerprint(user)

	src.visible_message("<span class='rose'>UNKNOWN TAXI engines are on cooldown. Plea-</span>")

	spawn(30)
		icon_state = initial(icon_state)