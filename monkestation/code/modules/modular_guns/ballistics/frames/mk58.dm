/obj/item/gun/ballistic/modular/mk_58
	icon = 'monkestation/code/modules/modular_guns/icons/mk58.dmi'
	icon_state = "frame"

/obj/item/gun/ballistic/modular/mk_58/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/weapon_attachments,\
		attachment_type = GUN_ATTACH_MK_58, \
		hand_slots = list(
			new /datum/attachment_handler/magazine,
			new /datum/attachment_handler/grip,
			new /datum/attachment_handler/stock,
			new /datum/attachment_handler/underbarrel,
			new /datum/attachment_handler/welrod,
			new /datum/attachment_handler/barrel,
			new /datum/attachment_handler/keychain,
		), \
		tool_slots = list(
			new /datum/attachment_handler/frame/screw,
		), \
	)
	AddComponent(/datum/component/gun_stat_holder,\
		stability = 98 ,\
		loudness = 45 ,\
		firing_speed = 3 ,\
		ease_of_use = 65 ,\
	)

	AddComponent(/datum/component/gun_jammable,\
		jam_time = 5 SECONDS, \
		jamming_prob = 3, \
	)

