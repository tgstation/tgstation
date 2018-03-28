/obj/item/storage/box
	icon_hippie = 'hippiestation/icons/obj/storage.dmi'

/obj/item/storage/box/monkeycubes
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/box/papersack
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/box/cyber_implants
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/box/emergency/old
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/box/mechanical/old
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/toolbox/brass
	icon = 'icons/obj/storage.dmi'

/obj/item/storage/box/lights
	icon_hippie = 'hippiestation/icons/obj/storage.dmi'

/obj/item/storage/box/seclarp
	name = "\improper Medieval Officer Kit"
	desc = "You've commited crimes against Nanotrasen and her people. What say you in your defense?"

/obj/item/storage/box/seclarp/PopulateContents()
	new /obj/item/clothing/head/helmet/larp(src)
	new /obj/item/clothing/suit/armor/larp(src)
	new /obj/item/clothing/shoes/jackboots/larp(src)