/obj/item/storage/box/holy/solaire
	name = "Solaire Kit"

/obj/item/storage/box/holy/solaire/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/solaire(src)
	new /obj/item/clothing/head/helmet/chaplain/solaire(src)


/obj/item/clothing/head/helmet/chaplain/solaire
	name = "solaire helmet"
	desc = "Now that I am Undead, I have come to this great land to seek my very own sun!"
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	icon_state = "solaire"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/armor/riot/chaplain/solaire
	name = "solaire armor"
	desc = "The sun is a wondrous body. Like a magnificent father! If only I could be so grossly incandescent!"
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	icon_state = "solaire"
