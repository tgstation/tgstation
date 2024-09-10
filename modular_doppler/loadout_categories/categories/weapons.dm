/// Inhand items (Moves overrided items to backpack)
/datum/loadout_category/weapons
	category_name = "Weapons"
	category_ui_icon = FA_ICON_GUN
	type_to_generate = /datum/loadout_item/weapon
	tab_order = /datum/loadout_category/inhands::tab_order + 1

/datum/loadout_item/weapon
	abstract_type = /datum/loadout_item/weapon

/datum/loadout_item/weapon/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.l_hand && !outfit.r_hand)
		outfit.r_hand = item_path
	else
		if(outfit.l_hand)
			LAZYADD(outfit.backpack_contents, outfit.l_hand)
		outfit.l_hand = item_path

/datum/loadout_item/weapon/toy_sword
	name = "Toy Sword"
	item_path = /obj/item/toy/sword

/datum/loadout_item/weapon/toy_gun
	name = "Toy Gun"
	item_path = /obj/item/toy/gun

/datum/loadout_item/weapon/toy_laser_red
	name = "Red Toy Laser"
	item_path = /obj/item/gun/energy/laser/redtag

/datum/loadout_item/weapon/toy_laser_blue
	name = "Blue Toy Laser"
	item_path = /obj/item/gun/energy/laser/bluetag

/datum/loadout_item/weapon/donk_pistol
	name = "Donk Pistol"
	item_path = /obj/item/gun/ballistic/automatic/pistol/toy

/datum/loadout_item/weapon/donk_shotgun
	name = "Donk Shotgun"
	item_path = /obj/item/gun/ballistic/shotgun/toy/unrestricted

/datum/loadout_item/weapon/donk_rifle
	name = "Donk Rifle"
	item_path = /obj/item/gun/ballistic/automatic/toy/unrestricted
