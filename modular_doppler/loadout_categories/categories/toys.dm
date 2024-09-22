/// Inhand items (Moves overrided items to backpack)
/datum/loadout_category/toys
	category_name = "Recreative"
	category_ui_icon = FA_ICON_GUITAR
	type_to_generate = /datum/loadout_item/toy
	tab_order = /datum/loadout_category/inhands::tab_order + 1

/datum/loadout_item/toy
	abstract_type = /datum/loadout_item/toy

/datum/loadout_item/toy/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.l_hand && !outfit.r_hand)
		outfit.r_hand = item_path
	else
		if(outfit.l_hand)
			LAZYADD(outfit.backpack_contents, outfit.l_hand)
		outfit.l_hand = item_path

/datum/loadout_item/toy/toy_sword
	name = "Fake Energy-Sword"
	item_path = /obj/item/toy/sword

/datum/loadout_item/toy/toy_gun
	name = "Fake .357 Revolver"
	item_path = /obj/item/toy/gun

/datum/loadout_item/toy/toy_laser_red
	name = "Red Practice Laser"
	item_path = /obj/item/gun/energy/laser/redtag

/datum/loadout_item/toy/toy_laser_blue
	name = "Blue Practice Laser"
	item_path = /obj/item/gun/energy/laser/bluetag

/datum/loadout_item/toy/donk_pistol
	name = "DONK CO. Makarov Pistol"
	item_path = /obj/item/gun/ballistic/automatic/pistol/toy

/datum/loadout_item/toy/donk_rifle
	name = "DONK CO. C-20r"
	item_path = /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted

/datum/loadout_item/toy/synth
	name = "Keyboard"
	item_path = /obj/item/instrument/piano_synth

/datum/loadout_item/toy/guitar
	name = "Acoustic Guitar"
	item_path = /obj/item/instrument/guitar

/datum/loadout_item/toy/banjo
	name = "Banjo"
	item_path = /obj/item/instrument/banjo

/datum/loadout_item/toy/violin
	name = "Violin"
	item_path = /obj/item/instrument/violin

/datum/loadout_item/toy/eguitar
	name = "Electric Guitar"
	item_path = /obj/item/instrument/eguitar

/datum/loadout_item/toy/glockenspiel
	name = "Glockenspiel"
	item_path = /obj/item/instrument/glockenspiel

/datum/loadout_item/toy/recorder
	name = "Recorder"
	item_path = /obj/item/instrument/recorder

/datum/loadout_item/toy/violin
	name = "Violin"
	item_path = /obj/item/instrument/violin

/datum/loadout_item/toy/harmonica
	name = "Harmonica"
	item_path = /obj/item/instrument/harmonica
	restricted_roles =  list(JOB_PRISONER)
