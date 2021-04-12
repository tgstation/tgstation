/**
  * # Vending NPC
  *
  * A vendor that has some dialogue options with radials, allows for selling items and is immune to regular vendor stuff like tipping, using power or being deconstructed
  *
  */

/mob/living/simple_animal/hostile/retaliate/trader
	name = "Trader"
	desc = "Come buy some!"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	loot = list(/obj/effect/mob_spawn/human/corpse)
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	wander = FALSE
	ranged = TRUE
	///Sound used when item sold/bought
	var/sell_sound = 'sound/effects/cashregister.ogg'
	///Phrases used when you talk to the NPC
	var/list/lore = list("Hello! I am the test trader.",
						"Oooooooo~~"
						)
	///Associated list of items the NPC sells with how much they cost.
	var/list/products = list(/obj/item/food/burger/ghost = 200)
	///Associated list of items able to be sold to the NPC with the money given for them.
	var/list/wanted_items = list(/obj/item/ectoplasm = 100)
	///Phrase said when NPC finds none of your inhand items in wanted_items.
	var/itemrejectphrase = "Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk."
	///Phrase said when you cancel selling a thing to the NPC.
	var/itemsellcancelphrase = "What a shame, tell me if you changed your mind."
	///Phrase said when you accept selling a thing to the NPC.
	var/itemsellacceptphrase = "Pleasure doing business with you."
	///Phrase said when the NPC finds an item in the wanted_items list in your hands.
	var/interestedphrase = "Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?"
	///Phrase said when the NPC sells you an item.
	var/buyphrase = "Pleasure doing business with you."
	///Phrase said when you have too little money to buy an item.
	var/nocashphrase = "Sorry adventurer, I can't give credit! Come back when you're a little mmmmm... richer!"

/mob/living/simple_animal/hostile/retaliate/trader/attack_hand(mob/user)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	var/list/npc_options = list()
	if(products.len)
		npc_options += list("Buy" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_buy"))
	if(lore.len)
		npc_options += list("Talk" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_talk"))
	if(wanted_items.len)
		npc_options += list("Sell" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_sell"))
	if(!(npc_options.len))
		return FALSE
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	switch(npc_result)
		if("Buy")
			return buy_item(user)
		if("Sell")
			return try_sell(user)
		if("Talk")
			return deep_lore()
	face_atom(user)

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
	if(!(sell_item(user, activehanditem)||sell_item(user, inactivehanditem)))
		say(itemrejectphrase)

///Makes the NPC say one picked thing from the lore list variable, can be overriden for fun stuff
/mob/living/simple_animal/hostile/retaliate/trader/proc/deep_lore()
	say(pick(lore))

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
	for(var/i in 1 to length(products))
		var/obj/item/thing = products[i]
		display_names["[initial(thing.name)]"] = thing
		var/image/item_image = image(icon = initial(thing.icon), icon_state = initial(thing.icon_state))
		items += list("[initial(thing.name)]" = item_image)
	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/path_reference = display_names[pick]
	try_buy(user, path_reference)
	face_atom(user)


/**
  * Tries to buy an item from the trader
  * Arguments:
  * * user - The mob trying to buy something
  * * item_to_buy - Item that is being bought
  */
/mob/living/simple_animal/hostile/retaliate/trader/proc/try_buy(mob/user, item_to_buy)
	var/cost = products[item_to_buy]
	to_chat(user, "<span class='notice'>It will cost you [cost] to buy this item. Are you sure you want to buy it?</span>")
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
		)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(npc_result != "Yes")
		return
	face_atom(user)
	var/obj/item/holochip/cash
	cash = user.is_holding_item_of_type(/obj/item/holochip)
	if(!cash || cash.credits < products[item_to_buy])
		say(nocashphrase)
		return
	cash.spend(products[item_to_buy])
	var/obj/item/bought_item = new item_to_buy(loc)
	user.put_in_hands(bought_item)
	playsound(src, sell_sound, 50, TRUE)
	say(buyphrase)

/**
  * Checks if an item is in the list of wanted items and if it is after a Yes/No radial returns generate_cash with the value of the item for the NPC
  * Arguments:
  * * user - The mob trying to sell something
  * * selling - The item being sold
  */
/mob/living/simple_animal/hostile/retaliate/trader/proc/sell_item(mob/user, selling)
	var/obj/item/sellitem = selling
	var/progressive_type = ""
	var/cost
	if(!sellitem)
		return FALSE
	for(var/type_level in splittext("[sellitem.type]","/"))
		if(type_level == "")
			continue
		progressive_type += ("/"+type_level)
		if(text2path(progressive_type) in wanted_items)
			cost = wanted_items[text2path(progressive_type)]
	if(!cost)
		return FALSE
	say(interestedphrase)
	to_chat(user, "<span class='notice'>You will receive [cost] credits for each one of [sellitem].</span>")
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
		)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	face_atom(user)
	if(npc_result != "Yes")
		say(itemsellcancelphrase)
		return TRUE
	say(itemsellacceptphrase)
	playsound(src, sell_sound, 50, TRUE)
	if(isstack(sellitem))
		var/obj/item/stack/stackoverflow = sellitem
		log_econ("[stackoverflow] has been sold to [src] by [user] for [cost * stackoverflow.amount] cash.")
		generate_cash(cost * stackoverflow.amount, user)
		stackoverflow.use(stackoverflow.amount)
		return TRUE
	log_econ("[sellitem] has been sold to [src] by [user] for [cost] cash.")
	generate_cash(cost, user)
	qdel(sellitem)
	return TRUE

/**
  * Creates a holochip the value set by the proc and puts it in the user's hands
  * Arguments:
  * * value - The amount of cash that will be on the holochip
  * * user - The mob we put the holochip in hands of
  */
/mob/living/simple_animal/hostile/retaliate/trader/proc/generate_cash(value, mob/user)
	var/obj/item/holochip/chip = new /obj/item/holochip(src, value)
	user.put_in_hands(chip)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	speak_emote = list("rattles")
	speech_span = SPAN_SANS
	sell_sound = 'sound/voice/hiss2.ogg'
	products = list(/obj/item/clothing/head/helmet/skull = 150,
					/obj/item/clothing/mask/bandana/skull = 50,
					/obj/item/food/cookie/sugar/spookyskull = 10,
					/obj/item/instrument/trombone/spectral = 10000,
					/obj/item/shovel/serrated = 150
					)
	wanted_items = list(/obj/item/reagent_containers/food/condiment/milk = 1000,
						/obj/item/stack/sheet/bone = 420)
	buyphrase = "Bone appetit!"
	icon_state = "mrbones"
	gender = MALE
	loot = list(/obj/effect/decal/remains/human)
	lore = list("Hello, I am Mr. Bones!",
				"The ride never ends!",
				"I'd really like a refreshing carton of milk!",
				"I'm willing to play big prices for BONES! Need materials to make merch, eh?"
				)
