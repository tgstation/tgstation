//
// Sheet Exports
//

/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0


// Leather, skin and other farming by-products.

/datum/export/stack/skin
	unit_name = ""

// Monkey hide. Cheap.
/datum/export/stack/skin/monkey
	cost = 150
	unit_name = "monkey hide"
	export_types = list(/obj/item/stack/sheet/animalhide/monkey)

// Human skin. Illegal
/datum/export/stack/skin/human
	cost = 2000
	contraband = 1
	unit_name = "piece"
	message = "of human skin"
	export_types = list(/obj/item/stack/sheet/animalhide/human)

// Goliath hide. Expensive.
/datum/export/stack/skin/goliath_hide
	cost = 2500
	unit_name = "goliath hide"
	export_types = list(/obj/item/stack/sheet/animalhide/goliath_hide)

// Cat hide. Just in case Runtime is catsploding again.
/datum/export/stack/skin/cat
	cost = 2000
	contraband = 1
	unit_name = "cat hide"
	export_types = list(/obj/item/stack/sheet/animalhide/cat)

// Corgi hide. You monster.
/datum/export/stack/skin/corgi
	cost = 2500
	contraband = 1
	unit_name = "corgi hide"
	export_types = list(/obj/item/stack/sheet/animalhide/corgi)

// Lizard hide. Very expensive.
/datum/export/stack/skin/lizard
	cost = 5000
	unit_name = "lizard hide"
	export_types = list(/obj/item/stack/sheet/animalhide/lizard)

// Alien hide. Extremely expensive.
/datum/export/stack/skin/xeno
	cost = 3000
	unit_name = "alien hide"
	export_types = list(/obj/item/stack/sheet/animalhide/xeno)


// Common materials.
// For base materials, see materials.dm

// Plasteel. Lightweight, strong and contains some plasma too.
/datum/export/stack/plasteel
	cost = 85
	message = "of plasteel"
	export_types = list(/obj/item/stack/sheet/plasteel)

// Reinforced Glass. Common building material. 1 glass + 0.5 metal, cost is rounded up.
/datum/export/stack/rglass
	cost = 8
	message = "of reinforced glass"
	export_types = list(/obj/item/stack/sheet/rglass)

// Bluespace Polycrystals. About as common on the asteroid as

/datum/export/stack/bscrystal
	cost = 750
	message = "of bluespace crystals"
	export_types = list(/obj/item/stack/sheet/bluespace_crystal)

// Wood. Quite expensive in the grim and dark 26 century.
/datum/export/stack/wood
	cost = 25
	unit_name = "wood plank"
	export_types = list(/obj/item/stack/sheet/mineral/wood)

// Cardboard. Cheap.
/datum/export/stack/cardboard
	cost = 2
	message = "of cardboard"
	export_types = list(/obj/item/stack/sheet/cardboard)

// Sandstone. Literally dirt cheap.
/datum/export/stack/sandstone
	cost = 1
	unit_name = "block"
	message = "of sandstone"
	export_types = list(/obj/item/stack/sheet/mineral/sandstone)

// Cable.
/datum/export/stack/cable
	cost = 0.2
	unit_name = "cable piece"
	export_types = list(/obj/item/stack/cable_coil)

/datum/export/stack/cable/get_cost(O)
	return round(..())


// Weird Stuff

// Alien Alloy. Like plasteel, but better.
// Major players would pay a lot to get some, so you can get a lot of money from producing and selling those.
// Just don't forget to fire all your production staff before the end of month.
/datum/export/stack/abductor
	cost = 5000
	message = "of alien alloy"
	export_types = list(/obj/item/stack/sheet/mineral/abductor)

// Adamantine. Does not occur naurally.
/datum/export/stack/adamantine
	unit_name = "bar"
	cost = 7500
	message = "of adamantine"
	export_types = list(/obj/item/stack/sheet/mineral/adamantine)

// Mythril. Does not occur naurally.
/datum/export/stack/mythril
	cost = 15000
	message = "of mythril"
	export_types = list(/obj/item/stack/sheet/mineral/mythril)
