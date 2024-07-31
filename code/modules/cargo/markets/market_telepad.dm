#define DEFAULT_RESTOCK_COST CARGO_CRATE_VALUE * 3.375
#define PLACE_ON_MARKET_COST PAYCHECK_LOWER * 1.2

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
	icon = 'icons/obj/machines/ltsrbt.dmi'
	icon_state = "ltsrbt_idle"
	base_icon_state = "ltsrbt"
	circuit = /obj/item/circuitboard/machine/ltsrbt
	density = TRUE

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 2
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

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
	var/open = FALSE
	var/obj/item/loaded
	var/current_name = ""
	var/current_desc = ""
	var/current_price = CARGO_CRATE_VALUE
	var/placed_on_market_recently = FALSE
	/**
	 * Attacking the machinery with enough credits will restock the markets, allowing for more/better items.
	 * The cost doubles each time this is done.
	 */
	var/static/restock_cost = DEFAULT_RESTOCK_COST

/obj/machinery/ltsrbt/Initialize(mapload)
	. = ..()
	register_context()
	SSmarket.telepads += src
	ADD_TRAIT(src, TRAIT_SECLUDED_LOCATION, INNATE_TRAIT) //you cannot sell disky, boss.
	update_appearance()

/obj/machinery/ltsrbt/Destroy()
	SSmarket.telepads -= src
	// Bye bye orders.
	if(length(SSmarket.telepads))
		for(var/datum/market_purchase/P in queue)
			SSmarket.queue_item(P)
	. = ..()

/obj/machinery/ltsrbt/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item)
		if(open)
			context[SCREENTIP_CONTEXT_LMB] = "Insert"
			return CONTEXTUAL_SCREENTIP_SET
		if(held_item.get_item_credit_value() && !(machine_stat & NOPOWER))
			context[SCREENTIP_CONTEXT_LMB] = "Restock"
			return CONTEXTUAL_SCREENTIP_SET
		return NONE
	if(open)
		context[SCREENTIP_CONTEXT_LMB] = "Close"
		return CONTEXTUAL_SCREENTIP_SET
	context[SCREENTIP_CONTEXT_LMB] = "Open"
	if(loaded && !(machine_stat & NOPOWER))
		context[SCREENTIP_CONTEXT_RMB] = "Place on market"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/ltsrbt/examine(mob/user)
	. = ..()
	if(!(machine_stat & NOPOWER))
		. += span_info("A small display reads:")
		. += span_tinynoticeital("Current market restock price: [EXAMINE_HINT("[restock_cost] cr")].")
		. += span_tinynoticeital("Market placement fee: [EXAMINE_HINT("[PLACE_ON_MARKET_COST] cr")].")
		. += span_tinynoticeital("Withholding tax on local items: [EXAMINE_HINT("[MARKET_WITHHOLDING_TAX * 100]%")].")

/obj/machinery/ltsrbt/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "[base_icon_state]_off"
	else
		icon_state = "[base_icon_state][(receiving || length(queue) || placed_on_market_recently) ? "" : "_idle"]"

/obj/machinery/ltsrbt/update_overlays()
	. = ..()
	if(!open)
		. += "[base_icon_state]_closed"
	else
		var/mutable_appearance/overlay = mutable_appearance(icon, "[base_icon_state]_open")
		overlay.pixel_y -= 2
		. += overlay

/obj/machinery/ltsrbt/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!open)
		if(!user.combat_mode)
			balloon_alert("open the machine!")
			return ITEM_INTERACT_BLOCKING
		return NONE
	if(locate(/mob/living) in tool.get_all_contents())
		say("Living being detected, cannot sell!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		balloon_alert("stuck to your hands!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert("item loaded.")
	loaded = tool
	open = FALSE
	playsound(src, 'sound/machines/oven/oven_close.ogg', 75, TRUE)

/obj/machinery/ltsrbt/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !open)
		return
	open = !open
	if(open && loaded)
		loaded.forceMove(drop_location())
		current_name = loaded.name
		current_desc = loaded.desc
	playsound(src, 'sound/machines/oven/oven_open.ogg', 75, TRUE)
	update_appearance()

/obj/machinery/ltsrbt/Exited(atom/movable/gone)
	if(gone == loaded)
		loaded = null
		current_price = initial(current_price)
		current_name = ""
		current_desc = ""
	return ..()

/obj/machinery/ltsrbt/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(open)
		balloon_alert(user, "close it first!")
	if(!loaded)
		balloon_alert(user, "nothing loaded!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(machine_stat & NOPOWER)
		balloon_alert(user, "machine unpowered!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, recharge_cooldown))
		balloon_alert(user, "on cooldown!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	ui_interact(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/ltsrbt/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LTSRBT", name)
		ui.open()

/obj/machinery/ltsrbt/ui_state()
	if(!loaded || !COOLDOWN_FINISHED(src, recharge_cooldown))
		return GLOB.never_state //close it.
	else
		return GLOB.default_state

#define LTSRBT_MIN_PRICE PAYCHECK_LOWER
#define LTSRBT_MAX_PRICE CARGO_CRATE_VALUE * 50

/obj/machinery/ltsrbt/ui_static_data(mob/user)
	var/list/data = list()
	if(!loaded || !COOLDOWN_FINISHED(src, recharge_cooldown))
		return data
	data["loaded_icon"] = icon2base64(getFlatIcon(loaded, no_anim=TRUE))
	data["min_price"] = LTSRBT_MIN_PRICE
	data["max_price"] = LTSRBT_MAX_PRICE

/obj/machinery/ltsrbt/ui_data(mob/user)
	var/list/data = list()
	if(!loaded || !COOLDOWN_FINISHED(src, recharge_cooldown))
		return data
	data["name"] = current_name
	data["price"] = current_price
	data["desc"] = current_desc

/obj/machinery/ltsrbt/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("change_name")
			var/value = params["value"]
			if(!CAN_BYPASS_FILTER(usr) && is_ic_filtered_for_pdas(value))
				return TRUE
			current_name = trim(value, MAX_NAME_LEN)
			return TRUE
		if("change_desc")
			var/value = params["value"]
			if(!CAN_BYPASS_FILTER(usr) && is_ic_filtered_for_pdas(value))
				return TRUE
			current_desc = trim(value, MAX_DESC_LEN)
			return TRUE
		if("change_price")
			current_desc = clamp(params["value"], LTSRBT_MIN_PRICE, LTSRBT_MAX_PRICE)
			return TRUE
		if("place_on_market")
			place_on_market(usr)
			return TRUE

#undef LTSRBT_MIN_PRICE
#undef LTSRBT_MAX_PRICE

#define LTSRBT_MAX_MARKET_ITEMS 40
/obj/machinery/ltsrbt/proc/place_on_market(mob/user)
	if(QDELETED(loaded))
		return
	if(locate(/mob/living) in loaded.get_all_contents())
		say("Living being detected, cannot sell!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
		return
	var/datum/bank_account/account
	var/datum/market/our_market = SSmarket.markets[/datum/market/blackmarket]
	if(!isAdminGhostAI(user))
		if(!isliving(user))
			return
		if(length(our_market.available_items[/datum/market_item/local_good::category]) >= LTSRBT_MAX_MARKET_ITEMS)
			say("Local market saturated, buy some goods first!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		var/mob/living/living_user = user
		var/obj/item/card/id/card = living_user.get_idcard(TRUE)
		if(!(card?.registered_account))
			say("No bank account to charge market fees detected!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		if(!card.registered_account.adjust_money(PLACE_ON_MARKET_COST, "Market: Placement Fee"))
			say("Insufficient credits!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		account = card.registered_account

	loaded.moveToNullspace()
	//Something happened and the item was deleted or relocated as soon as it was moved to nullspace.
	if(QDELETED(loaded) || loaded.loc != null)
		say("Runtime at market_placement.dm, line 153: loaded item gone!") //metajoke
		return
	var/datum/market_item/local_good/new_item = new(loaded, account)
	new_item.name = current_name
	var/item_desc = current_desc
	if(account)
		item_desc += "[item_desc ? " - " : ""]Seller: [account.account_holder]"
	new_item.desc = item_desc
	new_item.price = current_price

	our_market.add_item(new_item)

	say("Item placed on the market!")
	playsound(src, 'sound/effects/cashregister.ogg', 40, FALSE)
	COOLDOWN_START(src, recharge_cooldown, recharge_time * 3)
	placed_on_market_recently = TRUE
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), recharge_time * 3 + 0.1 SECONDS)

#undef LTSRBT_MAX_MARKET_ITEMS

/obj/machinery/ltsrbt/RefreshParts()
	. = ..()
	recharge_time = base_recharge_time
	// On tier 4 recharge_time should be 20 and by default it is 80 as scanning modules should be tier 1.
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		recharge_time -= scanning_module.tier * 1 SECONDS

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
