/obj/structure/closet/secure_closet/blueshield
	icon = 'modular_frontier/modules/blueshield/icons/obj/closet.dmi'
	name = "\proper blueshield's locker"
	req_access = list(ACCESS_BLUESHIELD)
	icon_state = "blu"

/obj/structure/closet/secure_closet/blueshield/PopulateContents()
	..()
	new /obj/item/storage/belt/rapier(src)
	new /obj/item/clothing/suit/armor/vest/blueshirt(src)
	new /obj/item/clothing/head/helmet/blueshirt(src)
	new /obj/item/gun/energy/e_gun/advtaser(src)
	new /obj/item/melee/baton/loaded(src)
