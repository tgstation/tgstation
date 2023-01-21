#define ITEM_REJECTED_PHRASE "ITEM_REJECTED_PHRASE"
#define ITEM_SELLING_CANCELED_PHRASE "ITEM_SELLING_CANCELED_PHRASE"
#define ITEM_SELLING_ACCEPTED_PHRASE "ITEM_SELLING_ACCEPTED_PHRASE"
#define INTERESTED_PHRASE "INTERESTED_PHRASE"
#define BUY_PHRASE "BUY_PHRASE"
#define NO_CASH_PHRASE "NO_CASH_PHRASE"
#define NO_STOCK_PHRASE "NO_STOCK_PHRASE"
#define NOT_WILLING_TO_BUY_PHRASE "NOT_WILLING_TO_BUY_PHRASE"
#define ITEM_IS_WORTHLESS_PHRASE "ITEM_IS_WORTHLESS_PHRASE"
#define TRADER_HAS_ENOUGH_ITEM_PHRASE "TRADER_HAS_ENOUGH_ITEM_PHRASE"
#define TRADER_LORE_PHRASE "TRADER_LORE_PHRASE"
#define TRADER_NOT_BUYING_ANYTHING "TRADER_NOT_BUYING_ANYTHING"
#define TRADER_NOT_SELLING_ANYTHING "TRADER_NOT_SELLING_ANYTHING"

#define TRADER_PRODUCT_INFO_PRICE 1
#define TRADER_PRODUCT_INFO_QUANTITY 2
//Only valid for wanted_items
#define TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION 3

/**
 * # Trader
 *
 * A mob that has some dialogue options with radials, allows for selling items and buying em'
 *
 */
/mob/living/simple_animal/hostile/retaliate/trader
	name = "Trader"
	desc = "Come buy some!"
	icon = 'icons/mob/simple/traders.dmi'
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
	 * This list is filled by Initialize(), if you want to change the starting products, modify initial_products()
	 * *
	 */
	var/list/products
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
	 * EX; /obj/item/stack/sheet/mineral/diamond = list(500, INFINITY, ", per 2000 cm3 sheet of diamond")
	 * This list is filled by Initialize(), if you want to change the starting wanted items, modify initial_wanteds()
	*/
	var/list/wanted_items
	///Associated list of defines matched with list of phrases; phrase to be said is dealt by return_trader_phrase()
	var/list/say_phrases = list(
		ITEM_REJECTED_PHRASE = list(
			"Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk."
		),
		ITEM_SELLING_CANCELED_PHRASE = list(
			"What a shame, tell me if you changed your mind."
		),
		ITEM_SELLING_ACCEPTED_PHRASE = list(
		"Pleasure doing business with you."
		),
		INTERESTED_PHRASE = list(
			"Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?"
		),
		BUY_PHRASE = list(
			"Pleasure doing business with you."
		),
		NO_CASH_PHRASE = list(
			"Sorry adventurer, I can't give credit! Come back when you're a little mmmmm... richer!"
		),
		NO_STOCK_PHRASE = list(
			"Sorry adventurer, but that item is not in stock at the moment."
		),
		NOT_WILLING_TO_BUY_PHRASE = list(
			"I don't want to buy that item for the time being, check back another time."
		),
		ITEM_IS_WORTHLESS_PHRASE = list(
			"This item seems to be worthless on a closer look, I won't buy this."
		),
		TRADER_HAS_ENOUGH_ITEM_PHRASE = list(
			"I already bought enough of this for the time being."
		),
		TRADER_LORE_PHRASE = list(
			"Hello! I am the test trader.",
			"Oooooooo~!"
		),
		TRADER_NOT_BUYING_ANYTHING = list(
			"I'm currently buying nothing at the moment."
		),
		TRADER_NOT_SELLING_ANYTHING = list(
			"I'm currently selling nothing at the moment."
		),
	)
	///The name of the currency that is used when buying or selling items
	var/currency_name = "credits"

///Initializes the products and item demands of the trader
/mob/living/simple_animal/hostile/retaliate/trader/Initialize(mapload)
	. = ..()
	restock_products()
	renew_item_demands()

///Returns a list of the starting price/quanity/fluff text about the product listings; products = initial(products) doesn't work so this exists mainly for restock_products()
/mob/living/simple_animal/hostile/retaliate/trader/proc/initial_products()
	return list(/obj/item/food/burger/ghost = list(200, INFINITY),
	)

///Returns a list of the starting price/quanity/fluff text about the wanted items; wanted_items = initial(wanted_items) doesn't work so this exists mainly for renew_item_demands()
/mob/living/simple_animal/hostile/retaliate/trader/proc/initial_wanteds()
	return list(/obj/item/ectoplasm = list(100, INFINITY, ""),
	)

/**
 * Depending on the passed parameter/override, returns a randomly picked string out of a list
 *
 * Do note when overriding this argument, you will need to ensure pick(the list) doesn't get supplied with a list of zero length
 * Arguments:
 * * say_text - (String) a define that matches the key of a entry in say_phrases
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/return_trader_phrase(say_text)
	if(!length(say_phrases[say_text]))
		return
	return pick(say_phrases[say_text])
	//return (length(say_phrases[say_text]) ? pick(say_phrases[say_text]) : "")

///Sets up the radials for the user and calls procs related to the actions the user wants to take
/mob/living/simple_animal/hostile/retaliate/trader/interact(mob/user)
	if(user == target)
		return FALSE
	var/list/npc_options = list()
	if(products.len)
		npc_options["Buy"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy")
	if(length(say_phrases[TRADER_LORE_PHRASE]))
		npc_options["Talk"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk")
	if(wanted_items.len)
		npc_options["Sell"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell")
	if(!npc_options.len)
		return FALSE
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
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
 * * user - (Mob REF) The mob checking the menu
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
		"Buying?" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buying"),
	)
	var/pick = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	switch(pick)
		if("Lore")
			say(return_trader_phrase(TRADER_LORE_PHRASE))
		if("Buying?")
			trader_buys_what(user)
		if("Selling?")
			trader_sells_what(user)

///Displays to the user what the trader is willing to buy and how much until a restock happens
/mob/living/simple_animal/hostile/retaliate/trader/proc/trader_buys_what(mob/user)
	if(!wanted_items.len)
		say(return_trader_phrase(TRADER_NOT_BUYING_ANYTHING))
		return
	var/list/product_info
	to_chat(user, span_green("I'm willing to buy the following; "))
	for(var/obj/item/thing as anything in wanted_items)
		product_info = wanted_items[thing]
		var/tern_op_result = (product_info[TRADER_PRODUCT_INFO_QUANTITY] == INFINITY ? "as many as I can." : "[product_info[TRADER_PRODUCT_INFO_QUANTITY]]") //Coder friendly string concat
		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //Zero demand
			to_chat(user, span_notice("[span_red("(DOESN'T WANT MORE)")] [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [currency_name][product_info[TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION]]; willing to buy [span_red("[tern_op_result]")] more."))
		else
			to_chat(user, span_notice("[initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [currency_name][product_info[TRADER_PRODUCT_INFO_PRICE_MOD_DESCRIPTION]]; willing to buy [span_green("[tern_op_result]")]"))

///Displays to the user what the trader is selling and how much is in stock
/mob/living/simple_animal/hostile/retaliate/trader/proc/trader_sells_what(mob/user)
	if(!products.len)
		say(return_trader_phrase(TRADER_NOT_SELLING_ANYTHING))
		return
	var/list/product_info
	to_chat(user, span_green("I'm currently selling the following; "))
	for(var/obj/item/thing as anything in products)
		product_info = products[thing]
		var/tern_op_result = (product_info[TRADER_PRODUCT_INFO_QUANTITY] == INFINITY ? "an infinite amount" : "[product_info[TRADER_PRODUCT_INFO_QUANTITY]]") //Coder friendly string concat
		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //Out of stock
			to_chat(user, span_notice("[span_red("(OUT OF STOCK)")] [initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [currency_name]; [span_red("[tern_op_result]")] left in stock"))
		else
			to_chat(user, span_notice("[initial(thing.name)] for [product_info[TRADER_PRODUCT_INFO_PRICE]] [currency_name]; [span_green("[tern_op_result]")] left in stock"))

/**
 * Generates a radial of the items the NPC sells and lets the user try to buy one
 * Arguments:
 * * user - (Mob REF) The mob trying to buy something
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
		if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0) //out of stock
			item_image.overlays += image(icon = 'icons/hud/radial.dmi', icon_state = "radial_center")
		items += list("[initial(thing.name)]" = item_image)
	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/obj/item/item_to_buy = display_names[pick]
	face_atom(user)
	product_info = products[item_to_buy]
	if(!product_info[TRADER_PRODUCT_INFO_QUANTITY])
		say("[initial(item_to_buy.name)] appears to be out of stock.")
		return
	say("It will cost you [product_info[TRADER_PRODUCT_INFO_PRICE]] [currency_name] to buy \the [initial(item_to_buy.name)]. Are you sure you want to buy it?")
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
	)
	var/buyer_will_buy = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(buyer_will_buy != "Yes")
		return
	face_atom(user)
	if(!spend_buyer_offhand_money(user, product_info[TRADER_PRODUCT_INFO_PRICE]))
		say(return_trader_phrase(NO_CASH_PHRASE))
		return
	item_to_buy = new item_to_buy(get_turf(user))
	user.put_in_hands(item_to_buy)
	playsound(src, sell_sound, 50, TRUE)
	product_info[TRADER_PRODUCT_INFO_QUANTITY] -= 1
	say(return_trader_phrase(BUY_PHRASE))

///Calculates the value of money in the hand of the buyer and spends it if it's sufficient
/mob/living/simple_animal/hostile/retaliate/trader/proc/spend_buyer_offhand_money(mob/user, the_cost)
	var/value = 0
	var/obj/item/holochip/cash = user.is_holding_item_of_type(/obj/item/holochip)
	if(cash)
		value += cash.credits
	if((value >= the_cost) && cash)
		return cash.spend(the_cost)
	return FALSE //Purchase unsuccessful

/**
 * Tries to call sell_item on one of the user's held items, if fail gives a chat message
 *
 * Gets both items in the user's hands, and then tries to call sell_item on them, if both fail, he gives a chat message
 * Arguments:
 * * user - (Mob REF) The mob trying to sell something
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/try_sell(mob/user)
	var/sold_item = FALSE
	for(var/obj/item/an_item in user.held_items)
		if(sell_item(user, an_item))
			sold_item = TRUE
			break
	if(!sold_item)
		say(return_trader_phrase(ITEM_REJECTED_PHRASE))

/**
 * Checks if an item is in the list of wanted items and if it is after a Yes/No radial returns generate_cash with the value of the item for the NPC
 * Arguments:
 * * user - (Mob REF) The mob trying to sell something
 * * selling - (Item REF) The item being sold
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/sell_item(mob/user, obj/item/selling)
	var/cost
	if(!selling)
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
			if(istype(selling, typepath))
				product_info = wanted_items[typepath]
				typepath_for_product_info = typepath
				break

	if(!product_info) //Nothing interesting to sell
		return FALSE
	if(product_info[TRADER_PRODUCT_INFO_QUANTITY] <= 0)
		say(return_trader_phrase(TRADER_HAS_ENOUGH_ITEM_PHRASE))
		return FALSE
	cost = apply_sell_price_mods(selling, product_info[TRADER_PRODUCT_INFO_PRICE])
	if(cost <= 0)
		say(return_trader_phrase(ITEM_IS_WORTHLESS_PHRASE))
		return FALSE
	say(return_trader_phrase(INTERESTED_PHRASE))
	say("You will receive [cost] [currency_name] for the [selling].")
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
	)
	face_atom(user)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(npc_result != "Yes")
		say(return_trader_phrase(ITEM_SELLING_CANCELED_PHRASE))
		return TRUE
	say(return_trader_phrase(ITEM_SELLING_ACCEPTED_PHRASE))
	playsound(src, sell_sound, 50, TRUE)
	log_econ("[selling] has been sold to [src] (typepath used for product info; [typepath_for_product_info]) by [user] for [cost] cash.")
	exchange_sold_items(selling, cost, typepath_for_product_info)
	generate_cash(cost, user)
	return TRUE

/**
 * Handles modifying/deleting the items to ensure that a proper amount is converted into cash; put into it's own proc to make the children of this not override a 30+ line sell_item()
 *
 * Arguments:
 * * selling - (Item REF) this is the item being sold
 * * value_exchanged_for - (Number) the "value", useful for a scenario where you want to remove enough items equal to the value
 * * original_typepath - (Typepath) For scenarios where a children of a parent is being sold but we want to modify the parent's product information
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/exchange_sold_items(obj/item/selling, value_exchanged_for, original_typepath)
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
 * Modifies the 'base' price of a item based on certain variables
 *
 * Arguments:
 * * Reference to the item; this is the item being sold
 * * Original cost; the original cost of the item, to be manipulated depending on the variables of the item, one example is using item.amount if it's a stack
 */
/mob/living/simple_animal/hostile/retaliate/trader/proc/apply_sell_price_mods(obj/item/selling, original_cost)
	if(isstack(selling))
		var/obj/item/stack/stackoverflow = selling
		original_cost *= stackoverflow.amount
	return original_cost

/**
 * Creates an item equal to the value set by the proc and puts it in the user's hands if possible
 * Arguments:
 * * value - A number; The amount of cash that will be on the holochip
 * * user - Reference to a mob; The mob we put the holochip in hands of
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
	icon_state = "mrbones"
	gender = MALE
	loot = list(/obj/effect/decal/remains/human)

	say_phrases = list(
		ITEM_REJECTED_PHRASE = list(
			"Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk."
		),
		ITEM_SELLING_CANCELED_PHRASE = list(
			"What a shame, tell me if you changed your mind."
		),
		ITEM_SELLING_ACCEPTED_PHRASE = list(
		"Pleasure doing business with you."
		),
		INTERESTED_PHRASE = list(
			"Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?"
		),
		BUY_PHRASE = list(
			"Bone appetit!"
		),
		NO_CASH_PHRASE = list(
			"Sorry adventurer, I can't give credit! Come back when you're a little mmmmm... richer!"
		),
		NO_STOCK_PHRASE = list(
			"Sorry adventurer, but that item is not in stock at the moment."
		),
		NOT_WILLING_TO_BUY_PHRASE = list(
			"I don't want to buy that item for the time being, check back another time."
		),
		ITEM_IS_WORTHLESS_PHRASE = list(
			"This item seems to be worthless on a closer look, I won't buy this."
		),
		TRADER_HAS_ENOUGH_ITEM_PHRASE = list(
			"I already bought enough of this for the time being."
		),
		TRADER_LORE_PHRASE = list(
			"Hello, I am Mr. Bones!",
			"The ride never ends!",
			"I'd really like a refreshing carton of milk!",
			"I'm willing to play big prices for BONES! Need materials to make merch, eh?",
			"It's a beautiful day outside. Birds are singing, Flowers are blooming... On days like these, kids like you... Should be buying my wares!"
		),
		TRADER_NOT_BUYING_ANYTHING = list(
			"I'm currently buying nothing at the moment."
		),
		TRADER_NOT_SELLING_ANYTHING = list(
			"I'm currently selling nothing at the moment."
		),
	)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones/initial_products()
	return list(
		/obj/item/clothing/head/helmet/skull = list(150, INFINITY),
		/obj/item/clothing/mask/bandana/skull/black = list(50, INFINITY),
		/obj/item/food/cookie/sugar/spookyskull = list(10, INFINITY),
		/obj/item/instrument/trombone/spectral = list(10000, INFINITY),
		/obj/item/shovel/serrated = list(150, INFINITY),
		)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones/initial_wanteds()
	return list(
		/obj/item/reagent_containers/condiment/milk = list(1000, INFINITY, ""),
		/obj/item/stack/sheet/bone = list(420, INFINITY, ", per sheet of bone"),
		)
