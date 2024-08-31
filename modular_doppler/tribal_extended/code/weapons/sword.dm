/obj/item/claymore/bone
	name = "bone sword"
	desc = "Jagged pieces of bone are tied to what looks like a goliaths femur."
	icon = 'modular_doppler/tribal_extended/icons/items_and_weapons.dmi'
	lefthand_file = 'modular_doppler/tribal_extended/icons/swords_lefthand.dmi'
	righthand_file = 'modular_doppler/tribal_extended/icons/swords_righthand.dmi'
	worn_icon = 'modular_doppler/tribal_extended/icons/back.dmi'
	icon_state = "bone_sword"
	inhand_icon_state = "bone_sword"
	worn_icon_state = "bone_sword"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 20
	throwforce = 10
	armour_penetration = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 0
	armor_type = /datum/armor/claymore_bone

/datum/armor/claymore_bone
	fire = 100
	acid = 50
