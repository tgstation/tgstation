///Used to contain the traders initial wares, and speech
/datum/trader_data

	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'
	///The currency name
	var/currency_name = "credits"
	///The initial products that the trader offers
	var/list/initial_products = list(
		/obj/item/food/burger/ghost = list(200, INFINITY),
	)
	///The initial products that the trader buys
	var/list/initial_wanteds = list(
		/obj/item/ectoplasm = list(100, INFINITY, ""),
	)
	///The speech data of the trader
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

/**
 * Depending on the passed parameter/override, returns a randomly picked string out of a list
 *
 * Do note when overriding this argument, you will need to ensure pick(the list) doesn't get supplied with a list of zero length
 * Arguments:
 * * say_text - (String) a define that matches the key of a entry in say_phrases
 */
/datum/trader_data/proc/return_trader_phrase(say_text)
	if(!length(say_phrases[say_text]))
		return
	return pick(say_phrases[say_text])

/datum/trader_data/mr_bones
	sell_sound = 'sound/voice/hiss2.ogg'

	initial_products = list(
		/obj/item/clothing/head/helmet/skull = list(150, INFINITY),
		/obj/item/clothing/mask/bandana/skull/black = list(50, INFINITY),
		/obj/item/food/cookie/sugar/spookyskull = list(10, INFINITY),
		/obj/item/instrument/trombone/spectral = list(10000, INFINITY),
		/obj/item/shovel/serrated = list(150, INFINITY),
	)

	initial_wanteds = list(
		/obj/item/reagent_containers/condiment/milk = list(1000, INFINITY, ""),
		/obj/item/stack/sheet/bone = list(420, INFINITY, ", per sheet of bone"),
	)

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
