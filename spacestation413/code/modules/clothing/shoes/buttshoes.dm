/obj/item/clothing/shoes/buttshoes
	desc = "Why?"
	name = "butt shoes"
	alternate_worn_icon = 'icons/mob/feet2.dmi'
	icon = 'icons/obj/clothing/shoes2.dmi'
	icon_state = "buttshoes"
	item_state = "buttshoes"
	item_color = "buttshoes"

/obj/item/clothing/shoes/buttshoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/fart.ogg'=1), 50)
