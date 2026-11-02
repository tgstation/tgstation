/**
 * POTION SELLER (Ratwood code/modules/roguetown/roguemachine/potionseller.dm): a vat of potions sold by the dram. Unlocked
 * with its key, the owner pours bottles in, names each fluid, sets its price per dram (0 gives it away), sets the price of empty
 * bottles, pours fluids back out and takes the profits. Locked, it sells: a buyer inserts coins and a bottle (or buys one of its
 * ten bottles) and has it filled. The crafted one comes with its own key.
 */
#define POTION_SELLER_SOUND 'modular_redtard/economy/sound/potionseller.ogg'

/obj/structure/roguemachine/potionseller
	/// Locked it sells to customers; unlocked its owner tends it (Ratwood locked).
	var/locked = TRUE
	var/keycontrol = "merchant"
	/// The buyer's bottle in the machine (Ratwood inserted).
	var/obj/item/reagent_containers/glass/bottle/inserted
	/// Reagent type -> list("NAME" = shelf name, "PRICE" = mammons per dram).
	var/list/potions = list()
	/// Profits taken from sales, for the owner (Ratwood wgain).
	var/profits = 0
	var/bottle_price
	/// Empty bottles it still sells (Ratwood bottle_sold_max).
	var/bottles_left

/obj/structure/roguemachine/potionseller/Initialize(mapload)
	. = ..()
	bottle_price = rogue_value("machines_potion_bottle_price")
	bottles_left = rogue_value("machines_potion_bottles")
	if(!reagents)
		create_reagents(rogue_value("machines_potion_volume"), NO_REACT)
	update_appearance()

/// A crafted seller comes with its own key (Ratwood is_crafted).
/obj/structure/roguemachine/potionseller/crafted/Initialize(mapload)
	. = ..()
	var/obj/item/roguekey/key = new /obj/item/roguekey/physician(get_turf(src))
	key.lockid = "potion_seller_[REF(src)]"
	key.name = "potion seller key"
	keycontrol = key.lockid

/obj/structure/roguemachine/potionseller/Destroy()
	if(inserted)
		inserted.forceMove(drop_location())
		inserted = null
	if(profits > 0)
		rogue_coins_out(profits, null, null, src)
		profits = 0
	return ..()

/obj/structure/roguemachine/potionseller/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == inserted)
		inserted = null

/obj/structure/roguemachine/potionseller/update_icon_state()
	icon_state = locked ? "streetvendor1" : "streetvendor0"
	return ..()

/obj/structure/roguemachine/potionseller/update_overlays()
	. = ..()
	if(locked && length(potions))
		set_light(1, 1, "#1b7bf1")
		. += mutable_appearance(icon, "vendor-gen")
	else
		set_light(0)

/obj/structure/roguemachine/potionseller/examine(mob/user)
	. = ..()
	. += span_info("Insert coins and a bottle, then pick a potion. Its key unlocks it for its owner to pour potions in and price them.")

/obj/structure/roguemachine/potionseller/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
		if(!rockhill_key_fits(tool, keycontrol))
			to_chat(user, span_warning("Wrong key."))
			return ITEM_INTERACT_BLOCKING
		locked = !locked
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		update_appearance()
		SStgui.update_uis(src)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguecoin))
		take_coins(tool, user)
		ui_interact(user)
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/reagent_containers/glass/bottle))
		return NONE
	if(!locked)
		pour_in(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(inserted)
		to_chat(user, span_warning("Something is already inside!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] is stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING
	inserted = tool
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/// The owner pours a bottle into the vat; new fluids go on the shelf free until priced (Ratwood insert()).
/obj/structure/roguemachine/potionseller/proc/pour_in(obj/item/reagent_containers/glass/bottle/bottle, mob/living/user)
	if(!bottle.reagents?.total_volume)
		to_chat(user, span_warning("Nothing to add."))
		return
	if(reagents.maximum_volume < bottle.reagents.total_volume + reagents.total_volume)
		to_chat(user, span_warning("Machine is filled to the lid."))
		return
	for(var/datum/reagent/fluid as anything in bottle.reagents.reagent_list)
		if(!potions[fluid.type])
			potions[fluid.type] = list("NAME" = fluid.name, "PRICE" = 0)
	bottle.reagents.trans_to(src, bottle.reagents.total_volume, transferred_by = user)
	playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
	update_appearance()
	ui_interact(user)

/// A fluid ran dry and leaves the shelf.
/obj/structure/roguemachine/potionseller/proc/forget_empty(reagent_type)
	if(reagents.get_reagent_amount(reagent_type) < 1)
		reagents.del_reagent(reagent_type)
		potions -= reagent_type
		update_appearance()

/obj/structure/roguemachine/potionseller/interact(mob/user)
	if(!ishuman(user))
		return FALSE
	return ..()

/obj/structure/roguemachine/potionseller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(src, ROGUE_SOUND_BEEP, 100, FALSE, -1)
		ui = new(user, src, "RoguePotionSeller", name)
		ui.open()

/obj/structure/roguemachine/potionseller/ui_data(mob/user)
	var/list/data = list()
	data["owner_mode"] = !locked
	data["budget"] = budget
	data["profits"] = profits
	data["bottle_price"] = bottle_price
	data["bottles_left"] = bottles_left
	data["inserted"] = inserted ? list("name" = inserted.name, "volume" = round(inserted.reagents.total_volume), "max" = round(inserted.reagents.maximum_volume)) : null
	var/list/items = list()
	for(var/reagent_type in potions)
		var/volume = round(reagents.get_reagent_amount(reagent_type))
		if(volume < 1 && locked)
			continue
		items += list(list(
			"ref" = "[reagent_type]",
			"name" = potions[reagent_type]["NAME"],
			"price" = potions[reagent_type]["PRICE"],
			"volume" = volume,
		))
	data["potions"] = items
	return data

/obj/structure/roguemachine/potionseller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = ui.user
	var/reagent_type = text2path(params["ref"])
	if(reagent_type && !potions[reagent_type])
		return TRUE
	switch(action)
		if("eject")
			if(inserted)
				user.put_in_hands(inserted)
			return TRUE
		if("change")
			if(locked)
				return_change(user)
			return TRUE
		if("buy_bottle")
			if(locked)
				sell_bottle(user)
			return TRUE
		if("buy")
			if(locked && reagent_type)
				sell(reagent_type, text2num(params["amount"]), user)
			return TRUE
	if(locked)
		return TRUE
	switch(action)
		if("withdraw_profits")
			if(profits > 0)
				rogue_coins_out(profits, user, null, src)
				profits = 0
			return TRUE
		if("set_name")
			var/new_name = trim(copytext_char(sanitize(params["name"]), 1, MAX_NAME_LEN))
			if(reagent_type && new_name)
				potions[reagent_type]["NAME"] = new_name
			return TRUE
		if("set_price")
			var/price = text2num(params["price"])
			if(reagent_type && isnum(price))
				potions[reagent_type]["PRICE"] = price < 0.1 ? 0 : round(min(price, ROGUE_TRANSFER_MAX), 0.1)
			return TRUE
		if("set_bottle_price")
			var/price = text2num(params["price"])
			if(isnum(price))
				bottle_price = clamp(round(price), 0, ROGUE_TRANSFER_MAX)
			return TRUE
		if("retrieve")
			if(reagent_type)
				pour_out(reagent_type, text2num(params["amount"]), user)
			return TRUE

/// Fills the buyer's bottle with drams of a potion for the budget (Ratwood "buy").
/obj/structure/roguemachine/potionseller/proc/sell(reagent_type, amount, mob/living/user)
	if(!inserted)
		say("MY POTIONS NEEDS A BOTTLE TO FILL, TRAVELER")
		return
	var/price = potions[reagent_type]["PRICE"]
	var/volume = reagents.get_reagent_amount(reagent_type)
	var/room = inserted.reagents.maximum_volume - inserted.reagents.total_volume
	if(room < 1)
		say("[uppertext("\the [inserted]")] IS TOO SMALL FOR MY POTIONS, TRAVELER")
		return
	amount = min(round(amount), room, volume)
	if(price > 0)
		amount = min(amount, floor(budget / price))
	if(amount <= 0)
		say(price > budget ? "MY POTIONS ARE TOO EXPENSIVE FOR YOU, TRAVELER" : "The machine cannot pour such an small amount")
		return
	var/cost = ceil(price * amount)
	budget -= cost
	profits += cost
	reagents.trans_to(inserted, amount, target_id = reagent_type, transferred_by = user)
	forget_empty(reagent_type)
	playsound(src, POTION_SELLER_SOUND, 100, TRUE, -1)

/// Sells one of the machine's empty bottles (Ratwood buybottle).
/obj/structure/roguemachine/potionseller/proc/sell_bottle(mob/living/user)
	if(bottles_left < 1)
		say("MY BOTTLES ARE ALL SOLD OUT, TRAVELER")
		return
	if(budget < bottle_price)
		say("MY BOTTLES ARE TOO EXPENSIVE FOR YOU, TRAVELER")
		return
	budget -= bottle_price
	profits += bottle_price
	bottles_left--
	user.put_in_hands(new /obj/item/reagent_containers/glass/bottle/rogue(get_turf(src)))

/// The owner pours drams of a fluid into a new bottle (Ratwood retrieve).
/obj/structure/roguemachine/potionseller/proc/pour_out(reagent_type, amount, mob/living/user)
	var/obj/item/reagent_containers/glass/bottle/alchemical/bottle = new(get_turf(src))
	amount = min(round(amount), bottle.reagents.maximum_volume, reagents.get_reagent_amount(reagent_type))
	if(amount <= 0)
		qdel(bottle)
		return
	reagents.trans_to(bottle, amount, target_id = reagent_type, transferred_by = user)
	forget_empty(reagent_type)
	user.put_in_hands(bottle)
	playsound(src, POTION_SELLER_SOUND, 100, TRUE, -1)

#undef POTION_SELLER_SOUND
