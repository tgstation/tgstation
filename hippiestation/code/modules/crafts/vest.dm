/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A hazard vest with metal plate taped on it. It offers minor protection."
	icon = 'hippiestation/icons/obj/armor.dmi'
	alternate_worn_icon = 'hippiestation/icons/obj/armor.dmi'
	icon_state = "makeshiftarmor-worn"
	item_state = "makeshiftarmor"
	w_class = 3
	blood_overlay_type = "armor"
	armor = list(melee = 30, bullet = 10, laser = 0, energy = 0, bomb = 5, bio = 0, rad = 0)

/datum/crafting_recipe/makeshift_armor
	name = "makeshift armor"
	result =  /obj/item/clothing/suit/armor/makeshift
	reqs = list(/obj/item/stack/sheet/metal = 1,
				/obj/item/clothing/suit/hazardvest = 1,
				/obj/item/stack/ducttape = 5)
	time = 80
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON