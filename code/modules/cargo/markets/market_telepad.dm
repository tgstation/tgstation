#define DEFAULT_RESTOCK_COST 675

/obj/item/circuitboard/machine/ltsrbt
	name = "LTSRBT (Machine Board)"
	icon_state = "bluespacearray"
	build_path = /obj/machinery/ltsrbt
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/datum/stock_part/ansible = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/scanning_module = 2)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/machinery/ltsrbt
	name = "Long-To-Short-Range-Bluespace-Transceiver"
	desc = "The LTSRBT is a compact teleportation machine for receiving and sending items outside the station and inside the station.\nUsing teleportation frequencies stolen from NT it is near undetectable.\nEssential for any illegal market operations on NT stations.\n"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "exonet_node_idle"
	base_icon_state = "exonet_node"
	circuit = /obj/item/circuitboard/machine/ltsrbt
	density = TRUE

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2

	/// Divider for energy_usage_per_teleport.
	var/power_efficiency = 1
	/// Power used per teleported which gets divided by power_efficiency.
	var/energy_usage_per_teleport = 10 KILO JOULES
	/// The time it takes for the machine to recharge before being able to send or receive items.
	var/recharge_time = 0
	/// Current recharge progress.
	COOLDOWN_DECLARE(recharge_cooldown)
	/// Base recharge time in seconds which is used to get recharge_time.
	var/base_recharge_time = 10 SECONDS
	/// Current /datum/market_purchase being received.
	var/datum/market_purchase/receiving
	/// Current /datum/market_purchase being sent to the target uplink.
	var/datum/market_purchase/transmitting
	/// Queue for purchases that the machine should receive and send.
	var/list/datum/market_purchase/queue = list()
	/**
	 * Attacking the machinery with enough credits will restock the markets, allowing for more/better items.
	 * The cost doubles each time this is done.
	 */
	var/static/restock_cost = DEFAULT_RESTOCK_COST

/obj/machinery/ltsrbt/Initialize(mapload)
	. = ..()
	register_context()
	SSmarket.telepads += src

/obj/machinery/ltsrbt/Destroy()
	SSmarket.telepads -= src
	// Bye bye orders.
	if(length(SSmarket.telepads))
		for(var/datum/market_purchase/P in queue)
			SSmarket.queue_item(P)
	. = ..()

/obj/machinery/ltsrbt/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item && held_item.get_item_credit_value())
		context[SCREENTIP_CONTEXT_LMB] = "Restock"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/machinery/ltsrbt/examine(mob/user)
	. = ..()
	if(machine_stat & NOPOWER)
		. += span_info("A display reads: \"Current market restock price: [EXAMINE_HINT("[restock_cost] cr")]\".")

/obj/machinery/ltsrbt/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]_off"
	else
		icon_state = "[base_icon_state][(receiving || length(queue)) ? "" : "_idle"]"

/obj/machinery/ltsrbt/RefreshParts()
	. = ..()
	recharge_time = base_recharge_time
	// On tier 4 recharge_time should be 20 and by default it is 80 as scanning modules should be tier 1.
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		recharge_time -= scanning_module.tier * 1 SECONDS
	recharge_cooldown = recharge_time

	power_efficiency = 0
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		power_efficiency += laser.tier
	// Shouldn't happen but you never know.
	if(!power_efficiency)
		power_efficiency = 1

/// Adds /datum/market_purchase to queue unless the machine is free, then it sets the purchase to be instantly received
/obj/machinery/ltsrbt/proc/add_to_queue(datum/market_purchase/purchase)
	if(!recharge_cooldown && !receiving && !transmitting)
		receiving = purchase
		update_appearance(UPDATE_ICON_STATE)
	else
		queue += purchase

	RegisterSignal(purchase, COMSIG_QDELETING, PROC_REF(on_purchase_del))

/obj/machinery/ltsrbt/proc/on_purchase_del(datum/market_purchase/purchase)
	SIGNAL_HANDLER
	queue -= purchase
	if(receiving == purchase)
		receiving = null
	if(transmitting == purchase)
		transmitting = null

	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/ltsrbt/process(seconds_per_tick)
	if(machine_stat & NOPOWER)
		return

	if(!COOLDOWN_FINISHED(src, recharge_cooldown) && isnull(receiving) && isnull(transmitting))
		return

	var/turf/turf = get_turf(src)
	if(receiving)

		receiving.item = receiving.entry.spawn_item(turf, receiving)
		receiving.post_purchase_effects(receiving.item)

		use_energy(energy_usage_per_teleport / power_efficiency)
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 1, get_turf(src))
		sparks.attach(receiving.item)
		sparks.start()

		transmitting = receiving
		receiving = null

		COOLDOWN_START(src, recharge_cooldown, recharge_time)
		return
	if(transmitting)
		if(transmitting.item.loc == turf)
			do_teleport(transmitting.item, get_turf(transmitting.uplink))
			use_energy(energy_usage_per_teleport / power_efficiency)
		QDEL_NULL(transmitting)
		return

	if(length(queue))
		receiving = pick_n_take(queue)

/obj/machinery/ltsrbt/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/creds_value = tool.get_item_credit_value()
	if(!creds_value)
		return NONE

	. = ITEM_INTERACT_SUCCESS

	if(machine_stat & NOPOWER)
		return

	if(creds_value < restock_cost)
		say("Insufficient credits!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
		return

	if(istype(tool, /obj/item/holochip))
		var/obj/item/holochip/chip = tool
		chip.spend(restock_cost)
	else
		qdel(tool)
		if(creds_value != restock_cost)
			var/obj/item/holochip/change = new(creds_value - restock_cost)
			user.put_in_hands(change)

	SSmarket.restock()
	restock_cost *= 2

#undef DEFAULT_RESTOCK_COST
