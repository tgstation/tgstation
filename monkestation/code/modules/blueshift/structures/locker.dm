/obj/structure/closet/secure_closet/corrections_officer
	name = "corrections officer riot gear"
	icon = 'monkestation/code/modules/blueshift/icons/unique/closet.dmi'
	icon_state = "riot"
	door_anim_time = 0 //Somebody resprite or remove this 'riot' locker. It's evil.

/obj/structure/closet/secure_closet/corrections_officer/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/riot(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/clothing/shoes/jackboots/peacekeeper(src)
	new /obj/item/clothing/head/helmet/toggleable/riot(src)
	new /obj/item/shield/riot(src)
