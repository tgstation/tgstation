///A bluespace input pipe for plumbing
/obj/machinery/plumbing/sender
	name = "chemical beacon"
	desc = "A bluespace anchor for chemicals. Does not require power. Use a multitool linked to a Chemical Recipient on this machine to start teleporting reagents."
	icon_state = "beacon"
	density = FALSE

	///whoever we teleport our chems to
	var/obj/machinery/plumbing/receiver/target = null

/obj/machinery/plumbing/sender/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)

/obj/machinery/plumbing/sender/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return

	var/obj/item/multitool/M = I

	if(!istype(M.buffer, /obj/machinery/plumbing/receiver))
		to_chat(user, span_warning("Invalid buffer."))
		return

	if(target)
		lose_teleport_target()

	set_teleport_target(M.buffer)

	to_chat(user, span_green("You succesfully link [src] to the [M.buffer]."))
	return TRUE

///Lose our previous target and make our previous target lose us. Seperate proc because I feel like I'll need this again
/obj/machinery/plumbing/sender/proc/lose_teleport_target()
	target.senders.Remove(src)
	target = null
	icon_state = initial(icon_state)

///Set a receiving plumbing object
/obj/machinery/plumbing/sender/proc/set_teleport_target(new_target)
	target = new_target
	target.senders.Add(src)
	icon_state = initial(icon_state) + "_idle"

///Transfer reagents and display a flashing icon
/obj/machinery/plumbing/sender/proc/teleport_chemicals(obj/machinery/plumbing/receiver/R, amount)
	flick(initial(icon_state) + "_flash", src)
	reagents.trans_to(R, amount)

///A bluespace output pipe for plumbing. Supports multiple recipients. Must be constructed with a circuit board
/obj/machinery/plumbing/receiver
	name = "chemical recipient"
	desc = "Receives chemicals from one or more chemical beacons. Use a multitool on this machine and then all subsequent chemical beacons. Reset by opening the \
	panel and cutting the main wire."
	icon_state = "recipient"

	buffer = 150

	///How much chemicals we can teleport per process
	var/pull_amount = 20
	///All synced up chemical beacons we can tap from
	var/list/senders = list()
	///We only grab one machine per process, so store which one is next
	var/next_index = 1

/obj/machinery/plumbing/receiver/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)

/obj/machinery/plumbing/receiver/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return

	var/obj/item/multitool/M = I
	M.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return TRUE

/obj/machinery/plumbing/receiver/process(seconds_per_tick)
	if(machine_stat & NOPOWER || panel_open)
		return

	if(senders.len)
		if(senders.len < next_index)
			next_index = 1

		var/obj/machinery/plumbing/sender/S = senders[next_index]
		if(QDELETED(S))
			senders.Remove(S)
			return

		S.teleport_chemicals(src, pull_amount)

		flick(initial(icon_state) + "_flash", src)

		next_index++

		use_power(active_power_usage * seconds_per_tick)

///Notify all senders to forget us
/obj/machinery/plumbing/receiver/proc/lose_senders()
	for(var/A in senders)
		var/obj/machinery/plumbing/sender/S = A
		if(S == null)
			continue
		S.lose_teleport_target()

	senders = list()

/obj/machinery/plumbing/receiver/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state + "_open", initial(icon_state), I))
		update_appearance()
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/plumbing/receiver/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()

	if(panel_open)
		lose_senders()
