/datum/crafting_recipe/lance
	name = "Explosive Lance (Grenade)"
	result = /obj/item/spear/explosive
	reqs = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	blacklist = list(/obj/item/spear/bonespear, /obj/item/spear/bamboospear)
	parts = list(
		/obj/item/spear = 1,
		/obj/item/grenade = 1
	)
	time = 1.5 SECONDS
	category = CAT_WEAPON_MELEE
