/datum/species/gem/yellowdiamond
	name = "Yellow Diamond"
	id = "yellow diamond"
	height = "diamond"
	fixed_mut_color = "FF0"
	hair_color = "FD0"
	armor = 95
	hairstyle = "Long Hair 3"
	weapon = /datum/action/innate/gem/weapon/destabilize

/mob/living/carbon/human/species/gem/yellowdiamond
	race = /datum/species/gem/yellowdiamond

/mob/living/carbon/human/species/gem/yellowdiamond/Initialize()
	..()
	var/obj/item/clothing/under/chameleon/gem/underfuse = new/obj/item/clothing/under/chameleon/gem
	var/obj/item/clothing/shoes/chameleon/gem/undershoes = new/obj/item/clothing/shoes/chameleon/gem
	var/obj/item/gemid/yellowdiamond/underid = new/obj/item/gemid/yellowdiamond
	equip_to_slot_or_del(underfuse, SLOT_W_UNIFORM)
	equip_to_slot_or_del(underid, SLOT_WEAR_ID)
	equip_to_slot_or_del(undershoes, SLOT_SHOES)
	resize = 2
	fully_replace_character_name(null, "Yellow Diamond")
	hair_style = "Spiky"
	facial_hair_style = "Shaved"
	spawn(5)
	revive(full_heal = TRUE, admin_revive = TRUE)

/obj/item/gemid/yellowdiamond
	name = "chest yellow diamond"
	icon_state = "yellow diamond"
	forcedposition = TRUE