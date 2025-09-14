
/obj/machinery/vending/subtype_vendor
	name = "\improper subtype vendor"
	desc = "A vending machine that vends all subtypes of a specific type."
	color = COLOR_ADMIN_PINK
	verb_say = "codes"
	verb_ask = "queries"
	verb_exclaim = "compiles"
	armor_type = /datum/armor/machinery_vending
	circuit = null
	product_slogans = "Spawn \" too annoying? Too lazy to open game panel? This one's for you!;Subtype vendor, for all your debugging woes!"
	default_price = 0
	all_products_free = TRUE
	/// Spawns coders by default
	var/type_to_vend = /obj/item/food/grown/citrus

/obj/machinery/vending/subtype_vendor/Initialize(mapload, type_to_vend)
	if(type_to_vend)
		src.type_to_vend = type_to_vend
	return ..()

///Adds the subtype to the product list
/obj/machinery/vending/subtype_vendor/RefreshParts()
	products.Cut()
	for(var/type in get_sane_item_types(type_to_vend))
		LAZYADDASSOC(products, type, 50)

	//no refill canister so we fill the records with their max amounts directly
	build_inventories(start_empty = FALSE)

/obj/machinery/vending/subtype_vendor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!can_interact(user) || !user.can_perform_action(src, ALLOW_SILICON_REACH|FORBID_TELEKINESIS_REACH))
		return

	if(!user.client?.holder?.check_for_rights(R_SERVER|R_DEBUG))
		speak("Hey! You can't use this! Get outta here!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/type_to_vend_now = tgui_input_text(user, "What type to set it to?", "Set type to vend", "/obj/item/toy/plush")
	type_to_vend_now = text2path(type_to_vend_now)
	if(!ispath(type_to_vend_now))
		speak("That's not a real path, dumbass! Try again!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	type_to_vend = type_to_vend_now
	RefreshParts()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
