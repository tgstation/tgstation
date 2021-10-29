//GENERIC ID CARDS//
/obj/item/card/id/advanced/silver/generic
	name = "generic silver identification card"
	icon = 'modular_skyrat/master_files/icons/obj/card.dmi'
	icon_state = "card_silvergen"
	assigned_icon_state = "assigned_silver"

/obj/item/card/id/advanced/gold/generic
	name = "generic gold identification card"
	icon = 'modular_skyrat/master_files/icons/obj/card.dmi'
	icon_state = "card_goldgen"
	assigned_icon_state = "assigned_gold"

//POLYCHROMIC ID CARDS//
/obj/item/card/id/advanced/polychromic
	name = "polychromic identification card"
	desc = "A failed prototype for customizable ID cards, it looks.. strange." //Read: I'm too lazy to implement this properly
	icon = 'modular_skyrat/master_files/icons/obj/card.dmi'
	icon_state = "card_polychromic"
	assigned_icon_state = null //Built into the sprite itself.

/obj/item/card/id/advanced/polychromic/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/polychromic, list("#666666", "#CCBBAA", "#0000FF"))

//SOLGOV//
/obj/item/card/id/advanced/solgov
	name = "solgov identification card"
	icon = 'modular_skyrat/master_files/icons/obj/card.dmi'
	icon_state = "card_solgov"
	assigned_icon_state = "assigned_solgov"
