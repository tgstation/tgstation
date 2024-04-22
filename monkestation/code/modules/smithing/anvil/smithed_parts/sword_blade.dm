/obj/item/smithed_part/weapon_part/sword_blade
	icon_state = "blade"
	base_name = "sword blade"
	weapon_name = "sword"

	weapon_inhand_icon_state = "sword"
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "blade-hilt"

/obj/item/smithed_part/weapon_part/sword_blade/finish_weapon()
	. = ..()
	sharpness = SHARP_EDGED
	wound_bonus = 15
	bare_wound_bonus = 25
	armour_penetration = 12

	attack_speed = CLICK_CD_BULKY_WEAPON
	stamina_cost = round(40 * (100 / smithed_quality))

	force = round(((material_stats.density + material_stats.hardness) / 10) * (smithed_quality * 0.01))
	throwforce = force * 0.75
	w_class = WEIGHT_CLASS_BULKY
