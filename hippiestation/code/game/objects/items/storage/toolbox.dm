/obj/item/storage/toolbox
	icon = 'hippiestation/icons/obj/storage.dmi'

/obj/item/toy/windupToolbox
	icon = 'hippiestation/icons/obj/storage.dmi'

/obj/item/his_grace
	icon = 'hippiestation/icons/obj/storage.dmi'

/obj/item/storage/toolbox/syndicate/PopulateContents()

	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench/syndicate(src)
	new /obj/item/weldingtool/syndicate(src)
	new /obj/item/crowbar/syndicate(src)
	new /obj/item/wirecutters/syndicate(src)
	new /obj/item/device/multitool/syndicate(src)
	new /obj/item/clothing/gloves/combat(src)