/obj/item/tcgcard
	name = "-001: Coder"
	desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardback_nt"
	var/power = null //How hard this card hits (by default).
	var/resolve = null //How hard this card can get hit (by default).
	var/series = 1 // What card series this card belongs to.
	var/cardset = "none" //Any special set this card belongs to. Leave as none for no set.
	var/cardnumber = 0 //What number the card is in the series.
	var/cardtype = "creature" //The card's type. Valid types are creature, location, item, instant, and land.

/obj/item/tcgcard/update_icon_state()
	. = ..()
	//yeah this is gonna take some fucky string list bullshit

/obj/item/cardpack
	name = "Trading Card Pack: Series 1"
	desc = "Contains six cards of varying rarity from Series 1. Collect them all!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardpack_1"
	var/series = 1 //Mirrors the card series.
	var/cards_in_series = 81 //How many cards exist in a given series

/obj/item/cardpack/attack_self(mob/user)
	. = ..()
	var/contains_coin = 15

	for(var/i = 1 to 6)
		var/obj/item/tcgcard/newcard = new /obj/item/tcgcard(get_turf(user))
		newcard.cardnumber = rand(1, cards_in_series)
		newcard.update_icon_state()
		qdel(src)
	to_chat(user, "<span_class='notice'>Wow! Check out these cards!</span>")
	new /obj/effect/decal/cleanable/wrapping(get_turf(user))
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 20, TRUE)
	if(contains_coin)
		to_chat(user, "<span_class='notice'>...and it came with a flipper, too!</span>")
		new /obj/item/coin/thunderdome(loc)

/obj/item/coin/thunderdome
	name = "Thunderdome Flipper"
	desc = "A Thunderdome TCG flipper, for finding who gets to go first."
	icon_state = "coin_valid"
	custom_materials = list(/datum/material/plastic = 400)
	material_flags = NONE
