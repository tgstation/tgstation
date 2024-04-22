/obj/item/smithed_part/weapon_part/pickaxe_head
	icon_state = "pickaxehead"
	base_name = "pickaxe head"
	weapon_name = "pickaxe"
	weapon_inhand_icon_state = "pickaxe"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'

	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "pickaxe-hilt"

/obj/item/smithed_part/weapon_part/pickaxe_head/finish_weapon()
	. = ..()
	tool_behaviour = TOOL_MINING

	toolspeed = 1 / round(((material_stats.density + material_stats.hardness) / 10) * (smithed_quality * 0.01))
	force = round(((material_stats.density + material_stats.hardness) / 15) * (smithed_quality * 0.01))

	throwforce = force * 1.5
	w_class = WEIGHT_CLASS_NORMAL
