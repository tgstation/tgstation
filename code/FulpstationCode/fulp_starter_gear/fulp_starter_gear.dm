/obj/item/storage/belt/security/fulp_starter_full/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/radio(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/loaded(src)
	update_icon()

/obj/item/storage/box/security/improved/PopulateContents()
	..() // we want the regular stuff too; crowbar for latejoins into depowered situations
	new /obj/item/crowbar/red(src)