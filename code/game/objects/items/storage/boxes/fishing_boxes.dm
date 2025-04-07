
/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 2

/obj/item/storage/box/fishing_hooks/PopulateContents()
	return list(
		/obj/item/fishing_hook/magnet,
		/obj/item/fishing_hook/shiny,
		/obj/item/fishing_hook/weighted,
	)

/obj/item/storage/box/fishing_hooks/master/PopulateContents(datum/storage_config/config)
	config.compute_max_item_weight = TRUE

	. = ..()
	. += /obj/item/fishing_hook/stabilized
	. += /obj/item/fishing_hook/jaws

/obj/item/storage/box/fishing_lines
	name = "fishing line set"
	illustration = "fish"
	custom_price = PAYCHECK_CREW * 2

/obj/item/storage/box/fishing_lines/PopulateContents()
	return list(
		/obj/item/fishing_line/bouncy,
		/obj/item/fishing_line/reinforced,
		/obj/item/fishing_line/cloaked,
	)

/obj/item/storage/box/fishing_lines/master/PopulateContents()
	. = ..()
	. += /obj/item/fishing_line/auto_reel

/obj/item/storage/box/fish_debug
	name = "box full of fish"
	illustration = "fish"

/obj/item/storage/box/fish_debug/PopulateContents(datum/storage_config/config)
	config.compute_max_values()

	return subtypesof(/obj/item/fish)
