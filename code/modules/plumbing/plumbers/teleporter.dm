//A bluespace input pipe for plumbing
/obj/machinery/plumbing/sender
	name = "chemical beacon"
	desc = "A bluespace anchor for chemicals. Does not require power."
	icon_state = "disposal"

	var/obj/machinery/plumbing/receiver/target = null

/obj/machinery/plumbing/sender/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

/obj/machinery/plumbing/sender/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return

	var/obj/item/multitool/M = I

	if(!istype(M.buffer, /obj/machinery/plumbing/receiver))
		to_chat(user, "<span class='warning'>Invalid buffer.</span>")
		return

	target = M.buffer
	target.senders += src
	to_chat(user, "<span class='green'>You succesfully link [src] to the [M.buffer].</span>")
	return TRUE


//A bluespace output pipe for plumbing. Supports multiple recipients. Must be constructed with a circuit board
/obj/machinery/plumbing/receiver
	name = "chemical recipient"
	desc = "Receives chemicals from one or more chemical beacons. Use a multitool on this machine and then all subsequent chemical beacons."
	icon_state = "disposal"

	//How much chemicals we can teleport per process
	var/pull_amount = 20
	//All synced up chemical beacons we can tap from
	var/list/senders = list()
	//We only grab one machine per process, so store which one is next
	var/next_index = 1

/obj/machinery/plumbing/receiver/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)

/obj/machinery/plumbing/receiver/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return

	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, "<span class='notice'>You store linkage information in [I]'s buffer.</span>")
	return TRUE

/obj/machinery/plumbing/receiver/process()
	if(machine_stat & NOPOWER)
		return

	if(senders.len)
		if(senders.len < next_index)
			next_index = 1

		var/obj/machinery/plumbing/sender/S = senders[next_index]
		S.reagents.trans_to(src, pull_amount, round_robin = TRUE)

		next_index++
