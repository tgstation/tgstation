/obj/machinery/vending/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	panel_type = "panel11"
	light_mask = "tool-light-mask"
	products = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/crowbar = 5,
		/obj/item/weldingtool = 3,
		/obj/item/wirecutters = 5,
		/obj/item/wrench = 5,
		/obj/item/analyzer = 5,
		/obj/item/t_scanner = 5,
		/obj/item/screwdriver = 5,
		/obj/item/flashlight/glowstick = 3,
		/obj/item/flashlight/glowstick/red = 3,
		/obj/item/flashlight = 5,
		/obj/item/clothing/ears/earmuffs = 1,
	)
	contraband = list(
		/obj/item/clothing/gloves/color/fyellow = 2,
	)
	premium = list(
		/obj/item/storage/belt/utility = 2,
		/obj/item/multitool = 2,
		/obj/item/weldingtool/hugetank = 2,
		/obj/item/clothing/head/utility/welding = 2,
		/obj/item/clothing/gloves/color/yellow = 1,
	)
	refill_canister = /obj/item/vending_refill/youtool
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 1.5
	payment_department = ACCOUNT_ENG

/obj/item/vending_refill/youtool
	machine_name = "YouTool"
	icon_state = "refill_engi"

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
	/// Spawns coders by default
	var/type_to_vend = /obj/item/food/grown/citrus

/obj/machinery/vending/subtype_vendor/Initialize(mapload, type_to_vend)
	. = ..()
	if(type_to_vend)
		src.type_to_vend = type_to_vend
	load_subtypes()

/obj/machinery/vending/subtype_vendor/proc/load_subtypes()
	products = list()
	product_records = list()

	for(var/type in typesof(type_to_vend))
		LAZYADDASSOC(products, type, 50)

	build_inventories()

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
	load_subtypes()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
