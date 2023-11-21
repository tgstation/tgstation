/obj/item/storage/box/holy/penitent
    name = "Last Penitent Kit"
    typepath_for_preview = /obj/item/clothing/suit/chaplainsuit/armor/penitent_armor

/obj/item/storage/box/holy/penitent/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/penitent_armor(src)
	new /obj/item/clothing/head/helmet/chaplain/penitent(src)
