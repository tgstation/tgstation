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
	///Associated list of defines matched with list of phrases; phrase to be said is dealt by return_trader_phrase()
	var/list/say_phrases = list()

	///The name of the currency that is used when buying or selling items
	var/currency_name = "credits"
	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'

	var/image/buy_icon
	var/image/sell_icon
	var/image/talk_icon
	var/image/lore_icon
	var/image/discuss_buying_icon
	var/image/discuss_selling_icon


	///The starting list of products to sell
	var/list/initial_products
	///The startling list of products to buy
	var/list/initial_wanteds

/datum/component/trader/Initialize(list/initial_products, list/initial_wanteds, list/say_phrases, sell_sound = 'sound/effects/cashregister.ogg', currency_name = "credits")
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/trader = parent
	if (!trader.ai_controller)
		return COMPONENT_INCOMPATIBLE

	src.initial_products = initial_products
	src.initial_wanteds = initial_wanteds
	src.say_phrases = say_phrases

	src.currency_name = currency_name
	src.sell_sound = sell_sound

	buy_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy")
	sell_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell")
	talk_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk")
	lore_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lore")
	discuss_selling_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_selling")
	discuss_buying_icon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buying")

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
		npc_options["Buy"] = buy_icon
	if(wanted_items.len)
		npc_options["Sell"] = sell_icon
	if(length(say_phrases))
		npc_options["Talk"] = talk_icon
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
		"Lore" = lore_icon,
		"Selling?" = discuss_selling_icon,
		"Buying?" = discuss_buying_icon,
	)
	var/pick = show_radial_menu(customer, parent, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), customer), require_near = TRUE, tooltips = TRUE)
	switch(pick)
		if("Lore")
			trader.say("LORE")
		if("Buying?")
			trader.say("I am looking for [wanted_items]")
		if("Selling?")
			trader.say("I am selling [products]")

///Sets quantity of all products to initial(quanity); this proc is currently called during initialize
/datum/component/trader/proc/restock_products()
	products = initial_products.Copy()

///Sets quantity of all wanted_items to initial(quanity);  this proc is currently called during initialize
/datum/component/trader/proc/renew_item_demands()
	wanted_items = initial_wanteds.Copy()

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
