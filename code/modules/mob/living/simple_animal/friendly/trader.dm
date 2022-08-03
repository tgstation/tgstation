/**
 * # Trader
 *
 * A mob that has some dialogue options with radials, allows for selling items and buying em'
 *
 */

/mob/living/simple_animal/hostile/retaliate/trader
	name = "Trader"
	desc = "Come buy some!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	del_on_death = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	wander = FALSE
	ranged = TRUE
	combat_mode = TRUE
	move_resist = MOVE_FORCE_STRONG
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = TRUE
	check_friendly_fire = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND|INTERACT_ATOM_ATTACK_HAND|INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'
	/**
	 * Format; list(TYPEPATH = list(PRICE, QUANTITY))
	 * Associated list of items the NPC sells with how much they cost and the quantity available before a restock
	 * This list is filled upon Initialize(), if you want to change the starting products, modify initial_products()
	 * *
	 */
	var/list/products
	/**
	 * CHILDREN OF TYPEPATHS INCLUDED IN WANTED_ITEMS WILL BE TREATED AS THE PARENT IF NO ENTRY EXISTS FOR THE CHILDREN
	 *
	 *
	 * Format; list(TYPEPATH = list(PRICE, QUANTITY, ADDITIONAL_DESCRIPTION))
	 * Associated list of items able to be sold to the NPC with the money given for them.
	 * The price given should be the "base" price; any price manipulation based on variables should be done with apply_sell_price_mods()
	 * ADDITIONAL_DESCRIPTION is any additional text added to explain how the variables of the item effect the price; if it's stack based, it's final price depends how much is in the stack
	 * EX; /obj/item/stack/sheet/mineral/diamond = list(500, INFINITY, ", per 2000 cm3 sheet of diamond")
	 * This list is filled upon Initialize(), if you want to change the starting wanted items, modify initial_wanteds()
	 * *
	*/
	var/list/wanted_items
	///Phrase said when NPC finds none of your inhand items in wanted_items.
	var/itemrejectphrase = list("Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk.")
	///Phrase said when you cancel selling a thing to the NPC.
	var/itemsellcancelphrase = list("What a shame, tell me if you changed your mind.")
	///Phrase said when you accept selling a thing to the NPC.
	var/itemsellacceptphrase = list("Pleasure doing business with you.")
	///Phrase said when the NPC finds an item in the wanted_items list in your hands.
	var/interestedphrase = list("Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?")
	///Phrase said when the NPC sells you an item.
	var/buyphrase = list("Pleasure doing business with you.")
	///Phrase said when you have too little money to buy an item.
	var/nocashphrase = list("Sorry adventurer, I can't give credit! Come back when you're a little mmmmm... richer!")
	///Phrase said when the requested item is out of stock
	var/nostockphrase = list("That item seems to be out of stock, you'll have to come back another time.")
	///Phrase said when the trader doesn't want any more of a item
	var/notwillingtobuyphrase = list("I don't want to buy that item for the time being, check back another time.")
	///Phrase said when the value of a item being sold to the trader turns out to be worth nothing after modifiers
	var/itemisworthless = list("This item seems to be worthless on a closer look, I won't buy this.")
	///Phrase said when the trader already bought enough of this item recently
	var/traderhasenoughitem = list("I already bought enough of this for the time being.")
	///Phrases used when you talk to the NPC
	var/list/lore = list(
		"Hello! I am the test trader.",
		"Oooooooo~!"
	)
	///The name of the currency that is used when buying or selling items
	var/currency_name = "credits"

/mob/living/simple_animal/hostile/retaliate/trader/Initialize()
	. = ..()
	restock_products()
	renew_item_demands()

///Returns a list of the starting price/quanity/fluff text about the product listings; products = initial(products) doesn't work so this exists mainly for restock_products()
/mob/living/simple_animal/hostile/retaliate/trader/proc/initial_products()
	return list(/obj/item/food/burger/ghost = list(200, INFINITY)
				)

///Returns a list of the starting price/quanity/fluff text about the wanted items; wanted_items = initial(wanted_items) doesn't work so this exists mainly for renew_item_demands()
/mob/living/simple_animal/hostile/retaliate/trader/proc/initial_wanteds()
	return list(/obj/item/ectoplasm = list(100, INFINITY, "")
				)

/mob/living/simple_animal/hostile/retaliate/trader/interact(mob/user)
	if(user == target)
		return FALSE
	var/list/npc_options = list()
	if(products.len)
		npc_options["Buy"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy")
	if(lore.len)
		npc_options["Talk"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk")
	if(wanted_items.len)
		npc_options["Sell"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell")
	if(!npc_options.len)
		return FALSE
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	switch(npc_result)
		if("Buy")
			buy_item(user)
		if("Sell")
			try_sell(user)
		if("Talk")
			discuss(user)
	face_atom(user)
	return TRUE

/**
 * Checks if the user is ok to use the radial
 *
 * Checks if the user is not a mob or is incapacitated or not adjacent to the source of the radial, in those cases returns FALSE, otherwise returns TRUE
 * Arguments:
 * * user - The mob checking the menu
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

///Talk about what items are being sold/wanted by the trader and in what quantity or lore
/mob/living/simple_animal/hostile/retaliate/trader/proc/discuss(mob/user)
	var/list/npc_options = list(
		"Lore" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lore"),
		"Selling?" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_selling"),
		"Buying?" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buying")
	)
	var/pick = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(pick == "Lore")
		say(pick(lore))
	if(pick == "Buying?")
		trader_buys_what(user)
	if(pick == "Selling?")
		trader_sells_what(user)

///Displays to the user what the trader is willing to buy and how much until a restock happens
/mob/living/simple_animal/hostile/retaliate/trader/proc/trader_buys_what(mob/user)
	if(!wanted_items.len)
		to_chat(user, span_green("I'm currently buying nothing at the moment."))
		return
	var/list/product_info
	to_chat(user, span_green("I'm willing to buy the following; "))
	for(var/obj/item/thing as anything in wanted_items)
		product_info = wanted_items[thing]
		var/tern_op_result = (product_info[2] == INFINITY ? "as many as I can." : "[product_info[2]]") //Coder friendly string concat
		if(product_info[2] <= 0) //Zero demand
			to_chat(user, span_notice("[span_red("(DOESN'T WANT MORE)")] [initial(thing.name)] for [product_info[1]] [currency_name][product_info[3]]; willing to buy [span_red("[tern_op_result]")] more."))
		else
			to_chat(user, span_notice("[initial(thing.name)] for [product_info[1]] [currency_name][product_info[3]]; willing to buy [span_green("[tern_op_result]")]"))

///Displays to the user what the trader is selling and how much is in stock
/mob/living/simple_animal/hostile/retaliate/trader/proc/trader_sells_what(mob/user)
	if(!products.len)
		to_chat(user, span_green("I'm currently selling nothing at the moment."))
		return
	var/list/product_info
	to_chat(user, span_green("I'm currently selling the following; "))
	for(var/obj/item/thing as anything in products)
		product_info = products[thing]
		var/tern_op_result = (product_info[2] == INFINITY ? "an infinite amount" : "[product_info[2]]") //Coder friendly string concat
		if(product_info[2] <= 0) //Out of stock
			to_chat(user, span_notice("[span_red("(OUT OF STOCK)")] [initial(thing.name)] for [product_info[1]] [currency_name]; [span_red("[tern_op_result]")] left in stock"))
		else
			to_chat(user, span_notice("[initial(thing.name)] for [product_info[1]] [currency_name]; [span_green("[tern_op_result]")] left in stock"))

/**
 * Generates a radial of the items the NPC sells and lets the user try to buy one
 * Arguments:
 * * user - The mob trying to buy something
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/buy_item(mob/user)
	if(!LAZYLEN(products))
		return

	var/list/display_names = list()
	var/list/items = list()
	var/list/product_info
	for(var/obj/item/thing as anything in products)
		display_names["[initial(thing.name)]"] = thing
		var/image/item_image = image(icon = initial(thing.icon), icon_state = initial(thing.icon_state))
		product_info = products[thing]
		if(product_info[2] <= 0) //out of stock
			item_image.overlays += image(icon = 'icons/hud/radial.dmi', icon_state = "radial_center")
		items += list("[initial(thing.name)]" = item_image)
	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/obj/item/item_to_buy = display_names[pick]
	face_atom(user)
	product_info = products[item_to_buy]
	if(!product_info[2])
		to_chat(user, span_red("The item appears to be out of stock."))
		return
	to_chat(user, span_notice("It will cost you [product_info[1]] credits to buy \the [initial(item_to_buy.name)]. Are you sure you want to buy it?"))
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
	)
	var/buyer_will_buy = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(buyer_will_buy != "Yes")
		return
	face_atom(user)
	if(!spend_buyer_offhand_money(user, product_info[1]))
		say(pick(nocashphrase))
		return
	item_to_buy = new item_to_buy(get_turf(user))
	user.put_in_hands(item_to_buy)
	playsound(src, sell_sound, 50, TRUE)
	product_info[2] -= 1
	say(pick(buyphrase))

///Calculates the value of money in the hand of the buyer and spends it if it's sufficient
/mob/living/simple_animal/hostile/retaliate/trader/proc/spend_buyer_offhand_money(mob/user, the_cost)
	var/value = 0
	var/obj/item/holochip/cash
	cash = user.is_holding_item_of_type(/obj/item/holochip)
	if(cash)
		value += cash.credits
	if((value >= the_cost) && cash)
		cash.spend(the_cost)
		return TRUE
	return FALSE //Purchase unsuccessful

/**
 * Tries to call sell_item on one of the user's held items, if fail gives a chat message
 *
 * Gets both items in the user's hands, and then tries to call sell_item on them, if both fail, he gives a chat message
 * Arguments:
 * * user - The mob trying to sell something
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/try_sell(mob/user)
	var/obj/item/activehanditem = user.get_active_held_item()
	var/obj/item/inactivehanditem = user.get_inactive_held_item()
	if(!sell_item(user, activehanditem) && !sell_item(user, inactivehanditem))
		say(pick(itemrejectphrase))

/**
 * Checks if an item is in the list of wanted items and if it is after a Yes/No radial returns generate_cash with the value of the item for the NPC
 * Arguments:
 * * user - The mob trying to sell something
 * * selling - The item being sold
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/sell_item(mob/user, obj/item/selling)
	var/cost
	if(!selling)
		return FALSE
	var/list/product_info
	var/obj/initialized_type //Need to intialize obj to access parent_type and keep a record of the typepath
	var/sell_typepath = selling.type
	while(sell_typepath != null && sell_typepath != /obj)
		initialized_type = new sell_typepath
		if(wanted_items[sell_typepath])
			product_info = wanted_items[sell_typepath]
			break
		sell_typepath = initialized_type.parent_type
	if(!product_info) //Nothing interesting to sell
		return FALSE
	if(product_info[2] <= 0)
		say(pick(traderhasenoughitem))
		return FALSE
	cost = apply_sell_price_mods(selling, product_info[1])
	if(cost <= 0)
		say(pick(itemisworthless))
		return FALSE
	say(pick(interestedphrase))
	to_chat(user, span_notice("You will receive [cost] credits for each one of [selling]."))
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
	)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	face_atom(user)
	if(npc_result != "Yes")
		say(pick(itemsellcancelphrase))
		return TRUE
	say(pick(itemsellacceptphrase))
	playsound(src, sell_sound, 50, TRUE)
	log_econ("[selling] has been sold to [src] by [user] for [cost] cash.")
	exchange_sold_items(selling, cost, sell_typepath)
	generate_cash(cost, user)
	return TRUE

/**
	Handles modifying/deleting the items to ensure that a proper amount is converted into cash; put into it's own proc to make the children of this not override a 30+ line sell_item()

	original_typepath is for scenarios where a children of a parent is being sold but we want to modify the parent's product information
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/exchange_sold_items(obj/item/selling, value_exchanged_for, original_typepath)
	var/list/product_info = wanted_items[original_typepath]
	if(isstack(selling))
		var/obj/item/stack/the_stack = selling
		var/actually_sold = min(the_stack.amount, product_info[2])
		the_stack.use(actually_sold)
		product_info[2] -= (actually_sold)
	else
		qdel(selling)
		product_info[2] -= 1

///Modifies the 'base' price of a item based on certain variables
/mob/living/simple_animal/hostile/retaliate/trader/proc/apply_sell_price_mods(obj/item/selling, original_cost)
	if(isstack(selling))
		var/obj/item/stack/stackoverflow = selling
		original_cost *= stackoverflow.amount
	return original_cost


/**
 * Creates an item equal to the value set by the proc and puts it in the user's hands if possible
 * Arguments:
 * * value - The amount of cash that will be on the holochip
 * * user - The mob we put the holochip in hands of
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/generate_cash(value, mob/user)
	var/obj/item/holochip/chip = new /obj/item/holochip(get_turf(user), value)
	user.put_in_hands(chip)

///Sets quantity of all products to initial(quanity); this proc is currently not called anywhere on the base class of traders
/mob/living/simple_animal/hostile/retaliate/trader/proc/restock_products()
	products = initial_products()

///Sets quantity of all wanted_items to initial(quanity); this proc is currently not called anywhere on the base class of traders
/mob/living/simple_animal/hostile/retaliate/trader/proc/renew_item_demands()
	wanted_items = initial_wanteds()

/mob/living/simple_animal/hostile/retaliate/trader/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	speak_emote = list("rattles")
	speech_span = SPAN_SANS
	sell_sound = 'sound/voice/hiss2.ogg'
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	buyphrase = "Bone appetit!"
	icon_state = "mrbones"
	gender = MALE
	loot = list(/obj/effect/decal/remains/human)
	lore = list(
		"Hello, I am Mr. Bones!",
		"The ride never ends!",
		"I'd really like a refreshing carton of milk!",
		"I'm willing to play big prices for BONES! Need materials to make merch, eh?",
		"It's a beautiful day outside. Birds are singing, Flowers are blooming... On days like these, kids like you... Should be buying my wares!"
	)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones/initial_products()
	return list(
		/obj/item/clothing/head/helmet/skull = list(150, INFINITY),
		/obj/item/clothing/mask/bandana/skull = list(50, INFINITY),
		/obj/item/food/cookie/sugar/spookyskull = list(10, INFINITY),
		/obj/item/instrument/trombone/spectral = list(10000, INFINITY),
		/obj/item/shovel/serrated = list(150, INFINITY)
				)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones/initial_wanteds()
	return list(
		/obj/item/reagent_containers/food/condiment/milk = list(1000, INFINITY, ""),
		/obj/item/stack/sheet/bone = list(420, INFINITY, ", per sheet of bone")
				)
