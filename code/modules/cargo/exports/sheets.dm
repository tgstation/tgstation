/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Hides

/datum/export/stack/skin/monkey
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "monkey hide"
	export_types = list(/obj/item/stack/sheet/animalhide/monkey)

/datum/export/stack/skin/human
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "piece"
	message = "of human skin"
	export_types = list(/obj/item/stack/sheet/animalhide/human)

/datum/export/stack/skin/goliath_hide
	cost = CARGO_CRATE_VALUE
	unit_name = "goliath hide"
	export_types = list(/obj/item/stack/sheet/animalhide/goliath_hide)

/datum/export/stack/skin/cat
	cost = CARGO_CRATE_VALUE * 0.75
	unit_name = "cat hide"
	export_types = list(/obj/item/stack/sheet/animalhide/cat)

/datum/export/stack/skin/corgi
	cost = CARGO_CRATE_VALUE
	unit_name = "corgi hide"
	export_types = list(/obj/item/stack/sheet/animalhide/corgi)

/datum/export/stack/skin/lizard
	cost = CARGO_CRATE_VALUE * 0.75
	unit_name = "lizard hide"
	export_types = list(/obj/item/stack/sheet/animalhide/lizard)

/datum/export/stack/skin/gondola
	cost = CARGO_CRATE_VALUE * 10
	unit_name = "gondola hide"
	export_types = list(/obj/item/stack/sheet/animalhide/gondola)

/datum/export/stack/skin/xeno
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "alien hide"
	export_types = list(/obj/item/stack/sheet/animalhide/xeno)

/datum/export/stack/licenseplate
	cost = CARGO_CRATE_VALUE * 0.125
	unit_name = "license plate"
	export_types = list(/obj/item/stack/license_plates/filled)


// Common materials.
// For base materials, see materials.dm

/datum/export/stack/plasteel
	cost = CARGO_CRATE_VALUE * 0.41 // 2000u of plasma + 2000u of iron.
	message = "of plasteel"
	export_types = list(/obj/item/stack/sheet/plasteel)

// 1 glass + 0.5 iron, cost is rounded up.
/datum/export/stack/rglass
	cost = CARGO_CRATE_VALUE * 0.02
	message = "of reinforced glass"
	export_types = list(/obj/item/stack/sheet/rglass)

/datum/export/stack/plastitanium
	cost = CARGO_CRATE_VALUE * 0.65 // plasma + titanium costs
	message = "of plastitanium"
	export_types = list(/obj/item/stack/sheet/mineral/plastitanium)

/datum/export/stack/wood
	cost = CARGO_CRATE_VALUE * 0.05
	unit_name = "wood plank"
	export_types = list(/obj/item/stack/sheet/mineral/wood)

/datum/export/stack/cloth
	cost = CARGO_CRATE_VALUE * 0.025
	message = "rolls of cloth"
	export_types = list(/obj/item/stack/sheet/cloth)

/datum/export/stack/durathread
	cost = CARGO_CRATE_VALUE * 0.35
	message = "rolls of durathread"
	export_types = list(/obj/item/stack/sheet/durathread)


/datum/export/stack/cardboard
	cost = CARGO_CRATE_VALUE * 0.01
	message = "of cardboard"
	export_types = list(/obj/item/stack/sheet/cardboard)

/datum/export/stack/sandstone
	cost = CARGO_CRATE_VALUE * 0.005
	unit_name = "block"
	message = "of sandstone"
	export_types = list(/obj/item/stack/sheet/mineral/sandstone)

/datum/export/stack/cable
	cost = CARGO_CRATE_VALUE * 0.001
	unit_name = "cable piece"
	export_types = list(/obj/item/stack/cable_coil)

/datum/export/stack/ammonia_crystals
	cost = CARGO_CRATE_VALUE * 0.125
	unit_name = "of ammonia crystal"
	export_types = list(/obj/item/stack/ammonia_crystals)

/datum/export/stack/pizza
	cost = CARGO_CRATE_VALUE * 0.06
	unit_name = "of sheetza"
	export_types = list(/obj/item/stack/sheet/pizza)

/datum/export/stack/meat
	cost = CARGO_CRATE_VALUE * 0.04
	unit_name = "of meat"
	export_types = list(/obj/item/stack/sheet/meat)


// Weird Stuff

/datum/export/stack/abductor
	cost = CARGO_CRATE_VALUE * 2
	message = "of alien alloy"
	export_types = list(/obj/item/stack/sheet/mineral/abductor)
