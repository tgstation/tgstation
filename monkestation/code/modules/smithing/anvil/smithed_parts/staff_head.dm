/obj/item/smithed_part/weapon_part/staff_head
	icon_state = "staffhead"
	base_name = "staff head"
	weapon_name = "staff"

	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "staff-hilt"

/obj/item/smithed_part/weapon_part/staff_head/finish_weapon()
	. = ..()
	damtype = STAMINA
	reach = 2
	AddComponent(/datum/component/multi_hit, icon_state = "swipe", width = 3, continues_travel = TRUE)

	attack_speed = CLICK_CD_LARGE_WEAPON
	stamina_cost = round(30 * (100 / smithed_quality))

	force = round(((material_stats.density + material_stats.hardness) / 3) * (smithed_quality * 0.01))
	throwforce = force * 0.1 // good luck whipping a staff at something
	w_class = WEIGHT_CLASS_HUGE
