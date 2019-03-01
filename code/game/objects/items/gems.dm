/obj/item/gem
	name = "gemstone"
	desc = "The core of a gem's being"
	icon_state = "ruby"
	icon = 'icons/obj/items_and_weapons.dmi'
	slot_flags = ITEM_SLOT_ID
	item_flags = DROPDEL
	var/forcedposition = FALSE

/obj/item/gem/proc/chooseposition()
	if(forcedposition == FALSE)
		var/gemposition = pick("belly","left hand","right hand","forehead","back head","back","chest","left leg","right leg","left eye","right eye")
		name = "[gemposition] [icon_state]"

/obj/item/gem/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)
	chooseposition()

/obj/item/gem/peridot
	icon_state = "peridot"

/obj/item/gem/amethyst
	icon_state = "amethyst"

/obj/item/gem/pearl
	icon_state = "pearl"

/obj/item/gem/jade
	icon_state = "jade"

/obj/item/gem/agate
	icon_state = "agate"

/obj/item/gem/rosequartz
	icon_state = "rosequartz"

/obj/item/gem/sapphire
	icon_state = "sapphire"

/obj/item/gem/sapphire/chooseposition() //removes gems from forehead, and eyes.
	if(forcedposition == FALSE)
		var/gemposition = pick("belly","left hand","right hand","back head","back","chest","left leg","right leg")
		name = "[gemposition] [icon_state]"

/obj/item/gem/bismuth
	icon_state = "bismuth"
