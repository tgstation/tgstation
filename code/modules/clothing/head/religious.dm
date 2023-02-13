/obj/item/clothing/head/chaplain/
	icon = 'icons/obj/clothing/head/chaplain.dmi'
	worn_icon = 'icons/mob/clothing/head/chaplain.dmi'

/obj/item/clothing/head/chaplain/clownmitre
	name = "Hat of the Honkmother"
	desc = "It's hard for parishoners to see a banana peel on the floor when they're looking up at your glorious chapeau."
	icon_state = "clownmitre"

/obj/item/clothing/head/chaplain/kippah
	name = "kippah"
	desc = "Signals that you follow the Jewish Halakha. Keeps the head covered and the soul extra-Orthodox."
	icon_state = "kippah"

/obj/item/clothing/head/chaplain/medievaljewhat
	name = "medieval Jewish hat"
	desc = "A silly looking hat, intended to be placed on the heads of the station's oppressed religious minorities."
	icon_state = "medievaljewhat"

/obj/item/clothing/head/chaplain/taqiyah/white
	name = "white taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahwhite"

/obj/item/clothing/head/chaplain/taqiyah/white/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/small)

/obj/item/clothing/head/chaplain/taqiyah/red
	name = "red taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahred"

/obj/item/clothing/head/chaplain/taqiyah/red/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/small)
