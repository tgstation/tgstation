// This file contains all boxes used by the Service department and its purpose on the station.
// Because we want to avoid some sort of "miscellaneous" file, let's put all the bureaucracy (pens and stuff) and the HoP's stuff here as well.

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	illustration = "drinkglass"

/obj/item/storage/box/drinkingglasses/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/reagent_containers/cup/glass/drinkingglass

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	illustration = "cup"

/obj/item/storage/box/cups/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/reagent_containers/cup/glass/sillycup

//Some spare PDAs in a box
/obj/item/storage/box/pdas
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	illustration = "pda"

/obj/item/storage/box/pdas/PopulateContents()
	. = list()
	for(var/i in 1 to 4)
		. += /obj/item/modular_computer/pda

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	illustration = "id"

/obj/item/storage/box/ids/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/card/id/advanced

/obj/item/storage/box/silver_ids
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	illustration = "id"

/obj/item/storage/box/silver_ids/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/card/id/advanced/silver

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = span_alert("Keep out of reach of children.")
	illustration = "mousetrap"

/obj/item/storage/box/mousetraps/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/assembly/mousetrap

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "spbox"
	illustration = ""
	storage_type = /datum/storage/box/snappops

/obj/item/storage/box/snappops/PopulateContents()
	. = list()
	for(var/i in 1 to 8)
		. += /obj/item/toy/snappop

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	inhand_icon_state = "zippo"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	worn_icon_state = "lighter"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound = 'sound/items/handling/matchbox_pickup.ogg'
	custom_price = PAYCHECK_CREW * 0.4
	base_icon_state = "matchbox"
	illustration = null
	storage_type = /datum/storage/box/matches

/obj/item/storage/box/matches/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ignites_matches)

/obj/item/storage/box/matches/PopulateContents()
	. = list()
	for(var/i in 1 to 10)
		. += /obj/item/match

/obj/item/storage/box/matches/update_icon_state()
	. = ..()
	switch(length(contents))
		if(10)
			icon_state = base_icon_state
		if(5 to 9)
			icon_state = "[base_icon_state]_almostfull"
		if(1 to 4)
			icon_state = "[base_icon_state]_almostempty"
		if(0)
			icon_state = "[base_icon_state]_e"

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	foldable_result = /obj/item/stack/sheet/cardboard //BubbleWrap
	illustration = "light"
	storage_type = /datum/storage/box/lights

/obj/item/storage/box/lights/bulbs/PopulateContents()
	. = list()
	for(var/i in 1 to 21)
		. += /obj/item/light/bulb

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/storage/box/lights/tubes/PopulateContents()
	. = list()
	for(var/i in 1 to 21)
		. += /obj/item/light/tube

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/storage/box/lights/mixed/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/light/tube = 14,
		/obj/item/light/bulb = 7,
	))

/obj/item/storage/box/fountainpens
	name = "box of fountain pens"
	illustration = "fpen"

/obj/item/storage/box/fountainpens/PopulateContents()
	. = list()
	for(var/i in 1 to 7)
		. += /obj/item/pen/fountain

/obj/item/storage/box/dishdrive
	name = "DIY Dish Drive Kit"
	desc = "Contains everything you need to build your own Dish Drive!"
	custom_premium_price = PAYCHECK_CREW * 3

/obj/item/storage/box/dishdrive/PopulateContents(datum/storage_config/config)
	config.compute_max_item_count = TRUE

	var/static/list/obj/item/items_inside = list(
		/obj/item/circuitboard/machine/dish_drive,
		/obj/item/screwdriver,
		/obj/item/stack/cable_coil/five,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/iron/five,
		/obj/item/stock_parts/servo,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stock_parts/matter_bin,
		/obj/item/wrench,
	)

	return items_inside

/obj/item/storage/box/actionfigure
	name = "box of action figures"
	desc = "The latest set of collectable action figures."
	icon_state = "box"

/obj/item/storage/box/actionfigure/PopulateContents()
	. = list()

	var/static/list/obj/item/toy/figure/types = subtypesof(/obj/item/toy/figure)
	for(var/i in 1 to 4)
		. += pick(types)

/obj/item/storage/box/tail_pin
	name = "pin the tail on the corgi supplies"
	desc = "For ages 10 and up. ...Why is this even on a space station? Aren't you a little old for babby games?" //Intentional typo.
	custom_price = PAYCHECK_COMMAND * 1.25

/obj/item/storage/box/tail_pin/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/poster/tail_board = 3,
		/obj/item/tail_pin = 3,
	))

/obj/item/storage/box/party_poppers
	name = "box of party poppers"
	desc = "Turn any event into a celebration and ensure the janitor stays busy."

/obj/item/storage/box/party_poppers/PopulateContents()
	. = list()
	for(var/i in 1 to 5)
		. += /obj/item/reagent_containers/spray/chemsprayer/party

/obj/item/storage/box/balloons
	name = "box of long balloons"
	desc = "A completely randomized and wacky box of long balloons, harvested straight from balloon farms on the clown planet."
	illustration = "balloon"
	storage_type = /datum/storage/box/balloons

/obj/item/storage/box/balloons/PopulateContents()
	. = list()
	for(var/i in 1 to 24)
		. += /obj/item/toy/balloon/long

/obj/item/storage/box/stickers
	name = "sticker pack"
	desc = "A pack of removable stickers. Removable? What a rip off!<br>On the back, <b>DO NOT GIVE TO THE CLOWN!</b> is printed in large lettering."
	icon = 'icons/obj/toys/stickers.dmi'
	icon_state = "stickerpack"
	illustration = null
	w_class = WEIGHT_CLASS_TINY
	storage_type = /datum/storage/box/stickers

	///Laels to pick from for this box illustration
	var/static/list/pack_labels = list(
		"smile",
		"frown",
		"heart",
		"silentman",
		"tider",
		"star",
	)

/obj/item/storage/box/stickers/Initialize(mapload)
	. = ..()
	if(isnull(illustration))
		illustration = pick(pack_labels)
		update_appearance()

/obj/item/storage/box/stickers/proc/generate_non_contraband_stickers_list()
	var/list/allowed_stickers = list()

	for(var/obj/item/sticker/sticker_type as anything in subtypesof(/obj/item/sticker))
		if(!sticker_type::exclude_from_random)
			allowed_stickers += sticker_type

	return allowed_stickers

/obj/item/storage/box/stickers/PopulateContents()
	var/static/list/non_contraband

	if(isnull(non_contraband))
		non_contraband = generate_non_contraband_stickers_list()

	. = list()
	for(var/i in 1 to rand(4, 8))
		. += pick(non_contraband)

/obj/item/storage/box/stickers/googly
	name = "googly eye sticker pack"
	desc = "Turn anything and everything into something vaguely alive!"
	illustration = "googly-alt"

/obj/item/storage/box/stickers/googly/PopulateContents()
	. = list()
	for(var/i in 1 to 6)
		. += /obj/item/sticker/googly
