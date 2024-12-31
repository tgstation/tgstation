#define TRADER_RADIAL_BUY "TRADER_RADIAL_BUY"
#define TRADER_RADIAL_SELL "TRADER_RADIAL_SELL"
#define TRADER_RADIAL_TALK "TRADER_RADIAL_TALK"
#define TRADER_RADIAL_LORE "TRADER_RADIAL_LORE"
#define TRADER_RADIAL_NO "TRADER_RADIAL_NO"
#define TRADER_RADIAL_YES "TRADER_RADIAL_YES"
#define TRADER_RADIAL_OUT_OF_STOCK "TRADER_RADIAL_OUT_OF_STOCK"
#define TRADER_RADIAL_DISCUSS_BUY "TRADER_RADIAL_DISCUSS_BUY"
#define TRADER_RADIAL_DISCUSS_SELL "TRADER_RADIAL_DISCUSS_SELL"

#define TRADER_OPTION_BUY "Buy"
#define TRADER_OPTION_SELL "Sell"
#define TRADER_OPTION_TALK "Talk"
#define TRADER_OPTION_LORE "Lore"
#define TRADER_OPTION_NO "No"
#define TRADER_OPTION_YES "Yes"
#define TRADER_OPTION_BUYING "Buying?"
#define TRADER_OPTION_SELLING "Selling?"

//The defines below show the index the info is located in the product_info entry list

#define TRADER_PRODUCT_INFO_PRICE 1
#define TRADER_PRODUCT_INFO_QUANTITY 2
//Only valid for wanted_items
#define TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION 3

/**
 * # Trader NPC Component
 * Manages the barks and the stocks of the traders
 * Also manages the interactive radial menu
 */
/datum/component/trader

	/**
	 * Format; list(TYPEPATH = list(PRICE, QUANTITY))
	 * Associated list of items the NPC sells with how much they cost and the quantity available before a restock
	 * This list is filled by Initialize(), if you want to change the starting products, modify initial_products()
	 * *
	 */
	var/list/obj/item/products = list()
	/**
	 * A list of wanted items that the trader would wish to buy, each typepath has a assigned value, quantity and additional flavor text
	 *
	 * CHILDREN OF TYPEPATHS INCLUDED IN WANTED_ITEMS WILL BE TREATED AS THE PARENT IF NO ENTRY EXISTS FOR THE CHILDREN
	 *
	 * As an additional note; if you include multiple children of a typepath; the typepath with the most children should be placed after all other typepaths
	 * Bad; list(/obj/item/milk = list(100, 1, ""), /obj/item/milk/small = list(50, 2, ""))
	 * Good; list(/obj/item/milk/small = list(50, 2, ""), /obj/item/milk = list(100, 1, ""))
	 * This is mainly because sell_item() uses a istype(item_being_sold, item_in_entry) to determine what parent should the child be automatically considered as
	 * If /obj/item/milk/small/spooky was being sold; /obj/item/milk/small would be the first to check against rather than /obj/item/milk
	 *
	 * Format; list(TYPEPATH = list(PRICE, QUANTITY, ADDITIONAL_DESCRIPTION))
	 * Associated list of items able to be sold to the NPC with the money given for them.
	 * The price given should be the "base" price; any price manipulation based on variables should be done with apply_sell_price_mods()
	 * ADDITIONAL_DESCRIPTION is any additional text added to explain how the variables of the item effect the price; if it's stack based, its final price depends how much is in the stack
	 * EX; /obj/item/stack/sheet/mineral/diamond = list(500, INFINITY, ", per 100 cm3 sheet of diamond")
	 * This list is filled by Initialize(), if you want to change the starting wanted items, modify initial_wanteds()
	*/
	var/list/wanted_items = list()

	///Contains images of all radial icons
	var/static/list/radial_icons_cache = list()

	///Contains information of a specific trader
	var/datum/trader_data/trader_data

/*
Can accept both a type path, and an instance of a datum. Type path has priority.
*/
/datum/component/trader/Initialize(trader_data_path = null, trader_data = null)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(ispath(trader_data_path, /datum/trader_data))
		trader_data = new trader_data_path
	if(isnull(trader_data))
		CRASH("Initialised trader component with no trader data.")

	src.trader_data = trader_data

	radial_icons_cache = list(
		TRADER_RADIAL_BUY = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy"),
		TRADER_RADIAL_SELL = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell"),
		TRADER_RADIAL_TALK = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk"),
		TRADER_RADIAL_LORE = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lore"),
		TRADER_RADIAL_DISCUSS_BUY = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buying"),
		TRADER_RADIAL_DISCUSS_SELL = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_selling"),
		TRADER_RADIAL_YES = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		TRADER_RADIAL_NO = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
		TRADER_RADIAL_OUT_OF_STOCK = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_center"),
	)

	restock_products()
	renew_item_demands()

/datum/component/trader/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/component/trader/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

///If our trader is alive, and the customer left clicks them with an empty hand without combat mode
/datum/component/trader/proc/on_attack_hand(atom/source, mob/living/carbon/customer)
	SIGNAL_HANDLER
	if(!can_trade(customer) || customer.combat_mode)
		return
	var/list/npc_options = list()
	if(length(products))
		npc_options[TRADER_OPTION_BUY] = radial_icons_cache[TRADER_RADIAL_BUY]
	if(length(wanted_items))
		npc_options[TRADER_OPTION_SELL] = radial_icons_cache[TRADER_RADIAL_SELL]
	if(length(trader_data.say_phrases))
		npc_options[TRADER_OPTION_TALK] = radial_icons_cache[TRADER_RADIAL_TALK]
	if(!length(npc_options))
		return

	var/mob/living/trader = parent
	trader.face_atom(customer)

	INVOKE_ASYNC(src, PROC_REF(open_npc_options), customer, npc_options)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Generates a radial of the initial radials of the NPC
 * Called via asynch, due to the sleep caused by show_radial_menu
 * Arguments:
 * * customer - (Mob REF) The mob trying to buy something
 */
/datum/component/trader/proc/open_npc_options(mob/living/carbon/customer, list/npc_options)
	if(!can_trade(customer))
		return
	var/npc_result = show_radial_menu(customer, parent, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	switch(npc_result)
		if(TRADER_OPTION_BUY)
			buy_item(customer)
		if(TRADER_OPTION_SELL)
			try_sell(customer)
		if(TRADER_OPTION_TALK)
			discuss(customer)

/**
 * Checks if the customer is ok to use the radial
 *
 * Checks if the customer is not a mob or is incapacitated or not adjacent to the source of the radial, in those cases returns FALSE, otherwise returns TRUE
 * Arguments:
 * * customer - (Mob REF) The mob checking the menu
 */
/datum/component/trader/proc/check_menu(mob/customer)
	if(!istype(customer))
		return FALSE
	if(IS_DEAD_OR_INCAP(customer) || !customer.Adjacent(parent))
		return FALSE
	return TRUE

/**
 * Generates a radial of the items the NPC sells and lets the user try to buy one
 * Arguments:
 * * customer - (Mob REF) The mob trying to buy something
 */
/datum/component/trader/proc/buy_item(mob/customer)
	if(!can_trade(customer))
		return

	if(!LAZYLEN(products))
		return

	var/list/display_names = list()
	var/list/items = list()
	var/list/product_info

	for(var/obj/item/thing as anything in products)
		display_names["[initial(thing.name)]"] = thing

		if(!radial_icons_cache[thing])
			radial_icons_cache[thing] = image(icon = initial(thing.icon), icon_state = initial(thing.icon_state_preview) ? initial(thing.icon_state_preview) : initial(thing.icon_state))

		var/image/item_image = radial_icons_cache[thing]
		product_info = products[thing]

		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //out of stock
			item_image.overlays += radial_icons_cache[TRADER_RADIAL_OUT_OF_STOCK]

		items += list("[initial(thing.name)]" = item_image)

	var/pick = show_radial_menu(customer, parent, items, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	if(!pick || !can_trade(customer))
		return

	var/obj/item/item_to_buy = display_names[pick]
	var/mob/living/trader = parent
	trader.face_atom(customer)
	product_info = products[item_to_buy]

	if(!product_info[TRADER_PRODUCT_INFO_QUANTITY])
		trader.say("[initial(item_to_buy.name)] appears to be out of stock.")
		return

	trader.say("It will cost you [product_info[TRADER_PRODUCT_INFO_PRICE]] [trader_data.currency_name] to buy \the [initial(item_to_buy.name)]. Are you sure you want to buy it?")
	var/list/npc_options = list(
		TRADER_OPTION_YES = radial_icons_cache[TRADER_RADIAL_YES],
		TRADER_OPTION_NO = radial_icons_cache[TRADER_RADIAL_NO],
	)

	var/buyer_will_buy = show_radial_menu(customer, trader, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	if(buyer_will_buy != TRADER_OPTION_YES || !can_trade(customer))
		return

	trader.face_atom(customer)

	if(!spend_buyer_offhand_money(customer, product_info[TRADER_PRODUCT_INFO_PRICE]))
		trader.say(trader_data.return_trader_phrase(NO_CASH_PHRASE))
		return

	item_to_buy = new item_to_buy(get_turf(customer))
	customer.put_in_hands(item_to_buy)
	playsound(trader, trader_data.sell_sound, 50, TRUE)
	log_econ("[item_to_buy] has been sold to [customer] (typepath used for product info; [item_to_buy.type]) by [trader] for [product_info[TRADER_PRODUCT_INFO_PRICE]] cash.")
	product_info[TRADER_PRODUCT_INFO_QUANTITY] -= 1
	trader.say(trader_data.return_trader_phrase(BUY_PHRASE))

///Calculates the value of money in the hand of the buyer and spends it if it's sufficient
/datum/component/trader/proc/spend_buyer_offhand_money(mob/customer, the_cost)
	var/value = 0
	var/obj/item/holochip/cash = customer.is_holding_item_of_type(/obj/item/holochip)
	if(cash)
		value += cash.credits
	if((value >= the_cost) && cash)
		return cash.spend(the_cost)
	return FALSE //Purchase unsuccessful

/**
 * Tries to call sell_item on one of the customer's held items, if fail gives a chat message
 *
 * Gets both items in the customer's hands, and then tries to call sell_item on them, if both fail, he gives a chat message
 * Arguments:
 * * customer - (Mob REF) The mob trying to sell something
 */
/datum/component/trader/proc/try_sell(mob/customer)
	if(!can_trade(customer))
		return
	var/sold_item = FALSE
	for(var/obj/item/an_item in customer.held_items)
		if(sell_item(customer, an_item))
			sold_item = TRUE
			break
	if(!sold_item && can_trade(customer)) //only talk if you are not dead or in combat
		var/mob/living/trader = parent
		trader.say(trader_data.return_trader_phrase(ITEM_REJECTED_PHRASE))


/**
 * Checks if an item is in the list of wanted items and if it is after a Yes/No radial returns generate_cash with the value of the item for the NPC
 * Arguments:
 * * customer - (Mob REF) The mob trying to sell something
 * * selling - (Item REF) The item being sold
 */
/datum/component/trader/proc/sell_item(mob/customer, obj/item/selling)
	if(isnull(selling))
		return FALSE
	var/list/product_info
	//Keep track of the typepath; rather mundane but it's required for correctly modifying the wanted_items
	//should a product be sellable because even if it doesn't have a entry because it's a child of a parent that is present on the list
	var/typepath_for_product_info

	if(selling.type in wanted_items)
		product_info = wanted_items[selling.type]
		typepath_for_product_info = selling.type
	else //Assume wanted_items is setup in the correct way; read wanted_items documentation for more info
		for(var/typepath in wanted_items)
			if(!istype(selling, typepath))
				continue

			product_info = wanted_items[typepath]
			typepath_for_product_info = typepath
			break

	if(!product_info) //Nothing interesting to sell
		return FALSE

	var/mob/living/trader = parent

	if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0)
		trader.say(trader_data.return_trader_phrase(TRADER_HAS_ENOUGH_ITEM_PHRASE))
		return FALSE

	var/cost = apply_sell_price_mods(selling, product_info[TRADER_PRODUCT_INFO_PRICE])
	if(cost <= 0)
		trader.say(trader_data.return_trader_phrase(ITEM_IS_WORTHLESS_PHRASE))
		return FALSE

	trader.say(trader_data.return_trader_phrase(INTERESTED_PHRASE))
	trader.say("You will receive [cost] [trader_data.currency_name] for the [selling].")
	var/list/npc_options = list(
		TRADER_OPTION_YES = radial_icons_cache[TRADER_RADIAL_YES],
		TRADER_OPTION_NO = radial_icons_cache[TRADER_RADIAL_NO],
	)

	trader.face_atom(customer)

	var/npc_result = show_radial_menu(customer, trader, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	if(!can_trade(customer))
		return
	if(npc_result != TRADER_OPTION_YES)
		trader.say(trader_data.return_trader_phrase(ITEM_SELLING_CANCELED_PHRASE))
		return TRUE

	trader.say(trader_data.return_trader_phrase(ITEM_SELLING_ACCEPTED_PHRASE))
	playsound(trader, trader_data.sell_sound, 50, TRUE)
	log_econ("[selling] has been sold to [trader] (typepath used for product info; [typepath_for_product_info]) by [customer] for [cost] cash.")
	exchange_sold_items(selling, cost, typepath_for_product_info)
	generate_cash(cost, customer)
	return TRUE

/**
 * Modifies the 'base' price of a item based on certain variables
 *
 * Arguments:
 * * Reference to the item; this is the item being sold
 * * Original cost; the original cost of the item, to be manipulated depending on the variables of the item, one example is using item.amount if it's a stack
 */
/datum/component/trader/proc/apply_sell_price_mods(obj/item/selling, original_cost)
	if(isstack(selling))
		var/obj/item/stack/stackoverflow = selling
		original_cost *= stackoverflow.amount
	return original_cost

/**
 * Handles modifying/deleting the items to ensure that a proper amount is converted into cash; put into its own proc to make the children of this not override a 30+ line sell_item()
 *
 * Arguments:
 * * selling - (Item REF) this is the item being sold
 * * value_exchanged_for - (Number) the "value", useful for a scenario where you want to remove enough items equal to the value
 * * original_typepath - (Typepath) For scenarios where a children of a parent is being sold but we want to modify the parent's product information
 */
/datum/component/trader/proc/exchange_sold_items(obj/item/selling, value_exchanged_for, original_typepath)
	var/list/product_info = wanted_items[original_typepath]
	if(isstack(selling))
		var/obj/item/stack/the_stack = selling
		var/actually_sold = min(the_stack.amount, product_info[TRADER_PRODUCT_INFO_QUANTITY])
		the_stack.use(actually_sold)
		product_info[TRADER_PRODUCT_INFO_QUANTITY] -= (actually_sold)
	else
		qdel(selling)
		product_info[TRADER_PRODUCT_INFO_QUANTITY] -= 1

/**
 * Creates an item equal to the value set by the proc and puts it in the user's hands if possible
 * Arguments:
 * * value - A number; The amount of cash that will be on the holochip
 * * customer - Reference to a mob; The mob we put the holochip in hands of
 */
/datum/component/trader/proc/generate_cash(value, mob/customer)
	var/obj/item/holochip/chip = new /obj/item/holochip(get_turf(customer), value)
	customer.put_in_hands(chip)

///Talk about what items are being sold/wanted by the trader and in what quantity or lore
/datum/component/trader/proc/discuss(mob/customer)
	var/list/npc_options = list(
		TRADER_OPTION_LORE = radial_icons_cache[TRADER_RADIAL_LORE],
		TRADER_OPTION_SELLING = radial_icons_cache[TRADER_RADIAL_DISCUSS_SELL],
		TRADER_OPTION_BUYING = radial_icons_cache[TRADER_RADIAL_DISCUSS_BUY],
	)
	var/pick = show_radial_menu(customer, parent, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	if(!can_trade(customer))
		return
	switch(pick)
		if(TRADER_OPTION_LORE)
			var/mob/living/trader = parent
			trader.say(trader_data.return_trader_phrase(TRADER_LORE_PHRASE))
		if(TRADER_OPTION_BUYING)
			trader_buys_what(customer)
		if(TRADER_OPTION_SELLING)
			trader_sells_what(customer)

///Displays to the customer what the trader is willing to buy and how much until a restock happens
/datum/component/trader/proc/trader_buys_what(mob/customer)
	if(!can_trade(customer))
		return
	if(!length(wanted_items))
		var/mob/living/trader = parent
		trader.say(trader_data.return_trader_phrase(TRADER_NOT_BUYING_ANYTHING))
		return

	var/list/buy_info = list(span_green("I'm willing to buy the following:"))

	var/list/product_info
	for(var/obj/item/thing as anything in wanted_items)
		product_info = wanted_items[thing]
		var/tern_op_result = (product_info[TRADER_PRODUCT_INFO_QUANTITY] == INFINITY ? "as many as I can." : "[product_info[TRADER_PRODUCT_INFO_QUANTITY]]") //Coder friendly string concat
		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //Zero demand
			buy_info += span_notice("&bull; [span_red("(DOESN'T WANT MORE)")] [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [trader_data.currency_name][product_info[TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION]]; willing to buy [span_red("[tern_op_result]")] more.")
		else
			buy_info += span_notice("&bull; [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [trader_data.currency_name][product_info[TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION]]; willing to buy [span_green("[tern_op_result]")]")

	to_chat(customer, boxed_message(buy_info.Join("\n")))

///Displays to the customer what the trader is selling and how much is in stock
/datum/component/trader/proc/trader_sells_what(mob/customer)
	if(!can_trade(customer))
		return
	var/mob/living/trader = parent
	if(!length(products))
		trader.say(trader_data.return_trader_phrase(TRADER_NOT_SELLING_ANYTHING))
		return
	var/list/sell_info = list(span_green("I'm currently selling the following:"))
	var/list/product_info
	for(var/obj/item/thing as anything in products)
		product_info = products[thing]
		var/tern_op_result = (product_info[TRADER_PRODUCT_INFO_QUANTITY] == INFINITY ? "an infinite amount" : "[product_info[TRADER_PRODUCT_INFO_QUANTITY]]") //Coder friendly string concat
		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //Out of stock
			sell_info += span_notice("&bull; [span_red("(OUT OF STOCK)")] [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [trader_data.currency_name]; [span_red("[tern_op_result]")] left in stock")
		else
			sell_info += span_notice("&bull; [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [trader_data.currency_name]; [span_green("[tern_op_result]")] left in stock")
	to_chat(customer, boxed_message(sell_info.Join("\n")))

///Sets quantity of all products to initial(quanity); this proc is currently called during initialize
/datum/component/trader/proc/restock_products()
	products = trader_data.initial_products.Copy()

///Sets quantity of all wanted_items to initial(quanity);  this proc is currently called during initialize
/datum/component/trader/proc/renew_item_demands()
	wanted_items = trader_data.initial_wanteds.Copy()

///Returns if the trader is conscious and its combat mode is disabled.
/datum/component/trader/proc/can_trade(mob/customer)
	var/mob/living/trader = parent
	if(trader.combat_mode)
		trader.balloon_alert(customer, "in combat!")
		return FALSE
	if(IS_DEAD_OR_INCAP(trader))
		trader.balloon_alert(customer, "indisposed!")
		return FALSE
	return TRUE

#undef TRADER_RADIAL_BUY
#undef TRADER_RADIAL_SELL
#undef TRADER_RADIAL_TALK
#undef TRADER_RADIAL_LORE
#undef TRADER_RADIAL_DISCUSS_BUY
#undef TRADER_RADIAL_DISCUSS_SELL
#undef TRADER_RADIAL_NO
#undef TRADER_RADIAL_YES
#undef TRADER_RADIAL_OUT_OF_STOCK
#undef TRADER_PRODUCT_INFO_PRICE
#undef TRADER_PRODUCT_INFO_QUANTITY
#undef TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION

#undef TRADER_OPTION_BUY
#undef TRADER_OPTION_SELL
#undef TRADER_OPTION_TALK
#undef TRADER_OPTION_LORE
#undef TRADER_OPTION_NO
#undef TRADER_OPTION_YES
#undef TRADER_OPTION_BUYING
#undef TRADER_OPTION_SELLING
