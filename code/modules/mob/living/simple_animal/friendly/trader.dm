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
	///Phrases used when you talk to the NPC
	var/list/lore = list(
		"Hello! I am the test trader.",
		"Oooooooo~!"
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
			deep_lore()
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
	for(var/obj/item/thing as anything in products)
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
/mob/living/simple_animal/hostile/retaliate/trader/proc/try_buy(mob/user, obj/item/item_to_buy)
	var/cost = products[item_to_buy]
	to_chat(user, span_notice("It will cost you [cost] credits to buy \the [initial(item_to_buy.name)]. Are you sure you want to buy it?"))
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
	item_to_buy = new item_to_buy(get_turf(user))
	user.put_in_hands(item_to_buy)
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
	var/cost
	if(!sellitem)
		return FALSE
	var/datum/checked_type = sellitem.type
	do
		if(checked_type in wanted_items)
			cost = wanted_items[checked_type]
			break
		checked_type = checked_type.parent_type
	while(checked_type != /obj)
	if(!cost)
		return FALSE
	say(interestedphrase)
	to_chat(user, span_notice("You will receive [cost] credits for each one of [sellitem]."))
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
	var/obj/item/holochip/chip = new /obj/item/holochip(get_turf(user), value)
	user.put_in_hands(chip)

/mob/living/simple_animal/hostile/retaliate/trader/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	speak_emote = list("rattles")
	speech_span = SPAN_SANS
	sell_sound = 'sound/voice/hiss2.ogg'
	mob_biotypes = MOB_UNDEAD|MOB_HUMANOID
	products = list(
		/obj/item/clothing/head/helmet/skull = 150,
		/obj/item/clothing/mask/bandana/skull = 50,
		/obj/item/food/cookie/sugar/spookyskull = 10,
		/obj/item/instrument/trombone/spectral = 10000,
		/obj/item/shovel/serrated = 150
	)
	wanted_items = list(
		/obj/item/reagent_containers/food/condiment/milk = 1000,
		/obj/item/stack/sheet/bone = 420
	)
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
