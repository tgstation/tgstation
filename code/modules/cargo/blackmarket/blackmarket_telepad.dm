/obj/item/circuitboard/machine/ltsrbt
	name = "LTSRBT (Machine Board)"
	icon_state = "bluespacearray"
	build_path = /obj/machinery/ltsrbt
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 2)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/machinery/ltsrbt
	name = "Long-To-Short-Range-Bluespace-Transciever"
	desc = "The LTSRBT is a compact teleportation machine for recieving and sending items outside the station and inside the station.\nUsing teleportation frequencies stolen from NT it is near undetectable.\nEssential for any illegal market operations on NT stations.\n"
	icon_state = "exonet_node"
	circuit = /obj/item/circuitboard/machine/ltsrbt
	density = TRUE

	idle_power_usage = 200

	var/power_efficiency = 1
	// Uses lots of power.
	var/power_usage_per_teleport = 10000
	// The time it takes for the machine to recharge before being able to send or recieve items.
	var/recharge_time = 0
	// Current recharge progress.
	var/recharge_cooldown = 0

	var/teleporting = FALSE
	var/recieving
	var/transmitting
	var/list/datum/blackmarket_purchase/queue = list()

/obj/machinery/ltsrbt/Initialize()
	. = ..()
	SSblackmarket.telepads |= src

// To-Do: Drop orders correctly. re-queue everything that is being recieved.
/obj/machinery/ltsrbt/Destroy()
	SSblackmarket.telepads -= src
	. = ..()

/obj/machinery/ltsrbt/RefreshParts()
	var/base_recharge_time = 50
	for(var/obj/item/stock_parts/scanning_module/scan in component_parts)
		// On tier 4 recharge time is 10.
		recharge_time = base_recharge_time - scan.rating * 5
		recharge_cooldown = recharge_time

	power_efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		power_efficiency += laser.rating
	// Shouldn't happen but you never know.
	if(!power_efficiency)
		power_efficiency = 1

/obj/machinery/ltsrbt/proc/add_to_queue(datum/blackmarket_purchase/purchase)
	if(!recharge_cooldown && !recieving)
		recieving = purchase
		return
	queue += purchase

/obj/machinery/ltsrbt/process()
	if(stat & NOPOWER)
		return

	if(recharge_cooldown)
		recharge_cooldown--
		return

	if(teleporting)
		return

	var/turf/T = get_turf(src)
	if(recieving)
		var/datum/blackmarket_purchase/P = recieving

		if(!P.item)
			P.item = P.entry.spawn_item(T)

		use_power(power_usage_per_teleport / power_efficiency)
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 1, get_turf(src))
		sparks.attach(P.item)
		sparks.start()

		recieving = null
		transmitting = P

		recharge_cooldown = recharge_time
		return
	else if(transmitting)
		var/datum/blackmarket_purchase/P = transmitting
		if(!P.item)
			transmitting = null
			qdel(P)
		if(!P.item in T.contents)
			P.uplink.visible_message("<span class='warning'>[P.uplink] flashes a message that a purchase has been stolen.</span>")
			transmitting = null
			qdel(P)
			return
		do_teleport(P.item, get_turf(P.uplink))
		use_power(power_usage_per_teleport / power_efficiency)
		transmitting = null
		qdel(P)

		recharge_cooldown = recharge_time
		return

	if(queue.len)
		recieving = pick_n_take(queue)
