/obj/item/ship_parts
	name = "ship parts"
	desc = "Ship parts, use them in hand to redeem them. Used for building ships."
	icon = 'voidcrew/modules/shuttle/ship_parts/icons/ship_item.dmi'
	icon_state = "ship"

	///The faction this ship can purchase
	var/ship_faction = NEUTRAL_SHIP

/obj/item/ship_parts/attack_self(mob/user)
	. = ..()
	user.client.prefs.ships_owned[type]++
	user.client.prefs.save_ships()
	to_chat(user, span_notice("You have redeemed [src], you may redeem it to purchase future ships."))
	qdel(src)

/obj/item/ship_parts/neutral
	name = "neutral ship parts"
	color = COLOR_BEIGE
	ship_faction = NEUTRAL_SHIP

/obj/item/ship_parts/nanotrasen
	name = "nanotrasen ship parts"
	color = COLOR_BLUE_LIGHT
	ship_faction = NANOTRASEN_SHIP

/obj/item/ship_parts/syndicate
	name = "syndicate ship parts"
	color = COLOR_RED_LIGHT
	ship_faction = SYNDICATE_SHIP
