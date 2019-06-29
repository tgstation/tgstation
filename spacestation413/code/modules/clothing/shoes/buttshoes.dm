/obj/item/clothing/shoes/buttshoes
	desc = "Why?"
	name = "butt shoes"
	alternate_worn_icon = 'spacestation413/icons/mob/feet.dmi'
	icon = 'spacestation413/icons/obj/clothing/shoes.dmi'
	icon_state = "buttshoes"
	item_state = "buttshoes"
	item_color = "buttshoes"

/obj/item/clothing/shoes/buttshoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('spacestation413/sound/effects/fart.ogg'=1), 50)
