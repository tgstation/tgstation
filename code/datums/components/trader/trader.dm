#define TRADER_BUY_ICON "TRADER_BUY_ICON"
#define TRADER_SELL_ICON "TRADER_SELL_ICON"
#define TRADER_TALK_ICON "TRADER_TALK_ICON"
#define TRADER_LORE_ICON "TRADER_LORE_ICON"
#define TRADER_DISCUSS_BUY_ICON "TRADER_DISCUSS_BUY_ICON"
#define TRADER_DISCUSS_SELL_ICON "TRADER_DISCUSS_SELL_ICON"

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
	var/list/products = list()
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
	 * ADDITIONAL_DESCRIPTION is any additional text added to explain how the variables of the item effect the price; if it's stack based, it's final price depends how much is in the stack
	 * EX; /obj/item/stack/sheet/mineral/diamond = list(500, INFINITY, ", per 100 cm3 sheet of diamond")
	 * This list is filled by Initialize(), if you want to change the starting wanted items, modify initial_wanteds()
	*/
	var/list/wanted_items = list()

	var/list/radial_icons_cache = list()

	///Contains information of a specific trader
	var/datum/trader_data/trader_data

/datum/component/trader/Initialize(trader_data_path)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/trader = parent
	if (!trader.ai_controller)
		return COMPONENT_INCOMPATIBLE
	if (!trader_data_path)
		CRASH("Initialised trader component with no trader data.")

	trader_data = new trader_data_path()

	radial_icons_cache = list(
		TRADER_BUY_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy"),
		TRADER_SELL_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell"),
		TRADER_TALK_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk"),
		TRADER_LORE_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lore"),
		TRADER_DISCUSS_BUY_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_selling"),
		TRADER_DISCUSS_SELL_ICON = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buying"),
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

	//TODO: also check if we are angry with them!
	var/mob/living/living_trader = parent
	if(living_trader.stat != CONSCIOUS || customer.combat_mode)
		return
	var/list/npc_options = list()
	if(products.len)
		npc_options["Buy"] = radial_icons_cache[TRADER_BUY_ICON]
	if(wanted_items.len)
		npc_options["Sell"] = radial_icons_cache[TRADER_SELL_ICON]
	if(length(trader_data.say_phrases))
		npc_options["Talk"] = radial_icons_cache[TRADER_TALK_ICON]
	if(!npc_options.len)
		return

	living_trader.face_atom(customer)

	INVOKE_ASYNC(src, PROC_REF(open_npc_options), customer, npc_options)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Generates a radial of the initial radials of the NPC
 * Called via asynch, due to the sleep caused by show_radial_menu
 * Arguments:
 * * customer - (Mob REF) The mob trying to buy something
 */
/datum/component/trader/proc/open_npc_options(mob/living/carbon/customer, list/npc_options)
	var/npc_result = show_radial_menu(customer, parent, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	switch(npc_result)
		if("Buy")
			buy_item(customer)
		if("Sell")
			try_sell(customer)
		if("Talk")
			discuss(customer)
/**
 * Generates a radial of the items the NPC sells and lets the user try to buy one
 * Arguments:
 * * customer - (Mob REF) The mob trying to buy something
 */
/datum/component/trader/proc/buy_item(mob/customer)
	if(!LAZYLEN(products))
		return
	var/mob/living/trader = parent
	trader.say("Bought by you!")

/**
 * Tries to call sell_item on one of the customer's held items, if fail gives a chat message
 *
 * Gets both items in the customer's hands, and then tries to call sell_item on them, if both fail, he gives a chat message
 * Arguments:
 * * customer - (Mob REF) The mob trying to sell something
 */
/datum/component/trader/proc/try_sell(mob/customer)
	var/mob/living/trader = parent
	trader.say("Sold to me!")

///Talk about what items are being sold/wanted by the trader and in what quantity or lore
/datum/component/trader/proc/discuss(mob/customer)
	var/mob/living/trader = parent

	var/list/npc_options = list(
		"Lore" = radial_icons_cache[TRADER_LORE_ICON],
		"Selling?" = radial_icons_cache[TRADER_DISCUSS_SELL_ICON],
		"Buying?" = radial_icons_cache[TRADER_DISCUSS_BUY_ICON],
	)
	var/pick = show_radial_menu(customer, parent, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	switch(pick)
		if("Lore")
			trader.say(trader_data.return_trader_phrase(TRADER_LORE_PHRASE))
		if("Buying?")
			trader.say("I am looking for [wanted_items]")
		if("Selling?")
			trader.say("I am selling [products]")

///Sets quantity of all products to initial(quanity); this proc is currently called during initialize
/datum/component/trader/proc/restock_products()
	products = trader_data.initial_products.Copy()

///Sets quantity of all wanted_items to initial(quanity);  this proc is currently called during initialize
/datum/component/trader/proc/renew_item_demands()
	wanted_items = trader_data.initial_wanteds.Copy()

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
	if(customer.incapacitated() || !customer.Adjacent(parent))
		return FALSE
	return TRUE

#undef TRADER_BUY_ICON
#undef TRADER_SELL_ICON
#undef TRADER_TALK_ICON
#undef TRADER_LORE_ICON
#undef TRADER_DISCUSS_BUY_ICON
#undef TRADER_DISCUSS_SELL_ICON
