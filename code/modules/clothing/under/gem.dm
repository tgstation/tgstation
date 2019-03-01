/obj/item/clothing/under/chameleon/gem
	name = "Homeworld Uniform"
	desc = "For the Radiant Pink Diamond."
	icon_state = "homeworld_pink"
	item_color = "homeworld_pink"
	item_state = "p_suit"
	item_flags = DROPDEL

/obj/item/clothing/shoes/chameleon/gem
	name = "Homeworld Boots"
	desc = "Shapeshifting boots for a shapeshifting creature."
	icon_state = "jackboots"
	item_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	item_color = "hosred"
	item_flags = DROPDEL

/obj/item/clothing/under/chameleon/gem/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/obj/item/clothing/shoes/chameleon/gem/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/obj/item/clothing/under/gem
	name = "Homeworld Uniform"
	desc = "For the Radiant Pink Diamond."
	icon_state = "homeworld_pink"
	item_color = "homeworld_pink"
	item_state = "p_suit"

/obj/item/clothing/under/chameleon/gem/yellow
	name = "Homeworld Uniform"
	desc = "For the Daunting Yellow Diamond."
	icon_state = "homeworld_yellow"
	item_color = "homeworld_yellow"
	item_state = "y_suit"
	item_flags = DROPDEL

/obj/item/clothing/under/gem/yellow
	name = "Homeworld Uniform"
	desc = "For the Daunting Yellow Diamond."
	icon_state = "homeworld_yellow"
	item_color = "homeworld_yellow"
	item_state = "y_suit"

/obj/item/clothing/under/chameleon/gem/blue
	name = "Homeworld Uniform"
	desc = "For the Elegant Blue Diamond."
	icon_state = "homeworld_blue"
	item_color = "homeworld_blue"
	item_state = "b_suit"
	item_flags = DROPDEL

/obj/item/clothing/under/gem/blue
	name = "Homeworld Uniform"
	desc = "For the Elegant Blue Diamond."
	icon_state = "homeworld_blue"
	item_color = "homeworld_blue"
	item_state = "b_suit"

/obj/item/clothing/under/chameleon/gem/white
	name = "Homeworld Uniform"
	desc = "For the Busy White Diamond."
	icon_state = "homeworld_white"
	item_color = "homeworld_white"
	item_state = "w_suit"
	item_flags = DROPDEL

/obj/item/clothing/under/gem/white
	name = "Homeworld Uniform"
	desc = "For the Busy White Diamond."
	icon_state = "homeworld_white"
	item_color = "homeworld_white"
	item_state = "w_suit"

/obj/item/clothing/under/zooman
	name = "Zooman Uniform"
	desc = "Ugh, loincloths."
	icon_state = "zooman"
	item_color = "zooman"
	item_state = "w_suit"

/obj/item/clothing/ears/zooman
	name = "Zooman Earrings"
	desc = "They are the voice that guides you."
	icon = 'icons/obj/radio.dmi'
	icon_state = "zooman_ear"
	item_state = "zooman_ear"
	slot_flags = ITEM_SLOT_EARS