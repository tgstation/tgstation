/obj/item/tcgcard
	name = "-001: Coder"
	desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	icon = 'icons/obj/tcg.dmi'
	var/power = null //How hard this card hits (by default).
	var/resolve = null //How hard this card can get hit (by default).
	var/series = "1" // What card series this card belongs to.
	var/cardset = "none" //Any special set this card belongs to. Leave as none for no set.

/obj/item/coin/thunderdome
	name = "Thunderdome Flipper"
	desc = "A Thunderdome TCG flipper, for finding who gets to go first."
	icon_state = "coin_valid"
	custom_materials = list(/datum/material/plastic = 400)
	material_flags = NONE
