/**
  * # Vending NPC
  *
  * A vendor that has some dialogue options with radials, allows for selling items and is immune to regular vendor stuff like tipping, using power or being deconstructed
  *
  */

/obj/machinery/vending/npc
	name = "Vending NPC"
	desc = "Come buy some!"
	circuit = null
	tiltable = FALSE
	payment_department = NO_FREEBIES
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	integrity_failure = 0
	light_power = 0
	light_range = 0
	verb_say = "says"
	verb_ask = "asks"
	verb_exclaim = "exclaims"
	speech_span = null
	age_restrictions = FALSE //hey kid, wanna buy some?
	use_power = NO_POWER_USE
	onstation_override = TRUE
	vending_sound = 'sound/effects/cashregister.ogg'
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "faceless"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	layer = MOB_LAYER
	products = list(/obj/item/reagent_containers/food/snacks/burger/ghost = 1)
	///Corpse spawned when vendor is deconstructed (MURDERED)
	var/corpse = /obj/effect/mob_spawn/human/corpse
	///Phrases used when you talk to the NPC
	var/list/lore = list("Hello! I am the test NPC.",
						"Man, shut the fuck up."
						)
	///List of items able to be sold to the NPC
	var/list/wanted_items = list(/obj/item/ectoplasm = 100)
	///Phrase said when NPC finds none of your inhand items in wanted_items.
	var/itemrejectphrase = "Sorry, I'm not a fan of anything you're showing me. Give me something better and we'll talk."
	///Phrase said when you cancel selling a thing to the NPC.
	var/itemsellcancelphrase = "What a shame, tell me if you changed your mind."
	///Phrase said when you accept selling a thing to the NPC.
	var/itemsellacceptphrase = "Pleasure doing business with you."
	///Phrase said when the NPC finds an item in the wanted_items list in your hands.
	var/interestedphrase = "Hey, you've got an item that interests me, I'd like to buy it, I'll give you some cash for it, deal?"

/obj/machinery/vending/npc/Initialize()
	. = ..()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(bill)
	QDEL_NULL(Radio)

/obj/machinery/vending/npc/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/vending/npc/crowbar_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/wrench_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/machinery/vending/npc/deconstruct(disassembled = TRUE)
	if(corpse)
		new corpse(src)
	qdel(src)

/obj/machinery/vending/npc/loadingAttempt(obj/item/I, mob/user)
	return

/obj/machinery/vending/npc/emag_act(mob/user)
	return

/obj/machinery/vending/npc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		return
	..()

/obj/machinery/vending/npc/interact(mob/user)
	face_atom(user)
	var/list/npc_options = list()
	if(products.len)
		npc_options += list("Buy" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_buy"))
	if(lore.len)
		npc_options += list("Talk" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_talk"))
	if(wanted_items.len)
		npc_options += list("Sell" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_sell"))
	if(!(npc_options.len))
		return FALSE
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return FALSE
	switch(npc_result)
		if("Buy")
			return ui_interact(user)
		if("Sell")
			return try_sell(user)
		if("Talk")
			return deep_lore()
	face_atom(user)
	return FALSE

/obj/machinery/vending/npc/ui_act(action, params)
	. = ..()
	face_atom(usr)

/**
  * Checks if the user is ok to use the radial
  *
  * Checks if the user is not a mob or is incapacitated or not adjacent to the source of the radial, in those cases returns FALSE, otherwise returns TRUE
  * Arguments:
  * * user - The mob checking the menu
  */
/obj/machinery/vending/npc/proc/check_menu(mob/user)
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
/obj/machinery/vending/npc/proc/try_sell(mob/user)
	var/obj/item/activehanditem = user.get_active_held_item()
	var/obj/item/inactivehanditem = user.get_inactive_held_item()
	if(!(sell_item(user, activehanditem)||sell_item(user, inactivehanditem)))
		say(itemrejectphrase)

///Makes the NPC say one picked thing from the lore list variable, can be overriden for fun stuff
/obj/machinery/vending/npc/proc/deep_lore()
	say(pick(lore))

/**
  * Checks if an item is in the list of wanted items and if it is after a Yes/No radial returns generate_cash with the value of the item for the NPC
  * Arguments:
  * * user - The mob trying to sell something
  * * selling - The item being sold
  */
/obj/machinery/vending/npc/proc/sell_item(mob/user, selling)
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
	var/list/npc_options = list(
		"Yes" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_no")
		)
	var/npc_result = show_radial_menu(user, src, npc_options, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return TRUE
	face_atom(user)
	if(npc_result != "Yes")
		say(itemsellcancelphrase)
		return TRUE
	say(itemsellacceptphrase)
	playsound(src, vending_sound, 50, TRUE, extrarange = -3)
	if(istype(sellitem, /obj/item/stack))
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
/obj/machinery/vending/npc/proc/generate_cash(value, mob/user)
	var/obj/item/holochip/chip = new /obj/item/holochip(src, value)
	user.put_in_hands(chip)

/obj/machinery/vending/npc/mrbones
	name = "Mr. Bones"
	desc = "A skeleton merchant, he seems very humerus."
	verb_say = "rattles"
	vending_sound = 'sound/voice/hiss2.ogg'
	speech_span = SPAN_SANS
	default_price = 500
	extra_price = 1000
	products = list(/obj/item/clothing/head/helmet/skull = 1,
					/obj/item/clothing/mask/bandana/skull = 1,
					/obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull = 5,
					/obj/item/instrument/trombone/spectral = 1,
					/obj/item/shovel/serrated = 1
					)
	product_ads = "Why's there so little traffic, is this a skeleton crew?;You should buy like there's no to-marrow!"
	vend_reply = "Bone appetit!"
	icon_state = "mrbones"
	gender = MALE
	corpse = /obj/effect/decal/remains/human
	lore = list("Hello, I am Mr. Bones!",
				"The ride never ends!",
				"I'd really like a refreshing carton of milk!",
				"I'm willing to play big prices for BONES! Need materials to make merch, eh?"
				)
	wanted_items = list(/obj/item/reagent_containers/food/condiment/milk = 1000,
						/obj/item/stack/sheet/bone = 420)
