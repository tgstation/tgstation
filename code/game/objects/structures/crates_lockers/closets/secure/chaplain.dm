/obj/structure/closet/secure_closet/chaplain
	name = "chapel wardrobe"
	desc = "It's a lockable storage unit for Nanotrasen-approved religious attire."
	req_access = list(access_chapel_office)
	icon_state = "chaplainsecure1"
	icon_closed = "chaplainsecure"
	icon_locked = "chaplainsecure1"
	icon_opened = "chaplainsecureopen"
	icon_broken = "chaplainsecurebroken"
	icon_off = "chaplainsecureoff"

	New()
		..()
		sleep(2)
		new /obj/item/clothing/under/rank/chaplain(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/suit/nun(src)
		new /obj/item/clothing/head/nun_hood(src)
		new /obj/item/clothing/suit/chaplain_hoodie(src)
		new /obj/item/clothing/head/chaplain_hood(src)
		new /obj/item/clothing/suit/holidaypriest(src)
		new /obj/item/clothing/under/wedding/bride_white(src)
		new /obj/item/clothing/head/hasturhood(src)
		new /obj/item/clothing/suit/hastur(src)
		new /obj/item/clothing/suit/unathi/robe(src)
		new /obj/item/clothing/head/wizard/amp(src) //This will need to be removed when/if psychic wizards are properly implimented
		new /obj/item/clothing/suit/wizrobe/psypurple(src) //This will need to be removed when/if psychic wizards are properly implimented
		new /obj/item/clothing/suit/imperium_monk(src)
		new /obj/item/clothing/mask/chapmask(src)
		new /obj/item/clothing/under/sl_suit(src)
		new /obj/item/weapon/storage/backpack/cultpack(src)
		new /obj/item/weapon/storage/fancy/candle_box(src)
		new /obj/item/weapon/storage/fancy/candle_box(src)
		return