/obj/item/gun/ballistic/modular/wintermute_sl
	icon = 'monkestation/code/modules/modular_guns/icons/wintermute.dmi'
	icon_state = "frame-sl"

/obj/item/gun/ballistic/modular/wintermute_sl/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/weapon_attachments,\
		attachment_type = GUN_ATTACH_WINTERMUTE, \
		hand_slots = list(
			new /datum/attachment_handler/magazine,
			new /datum/attachment_handler/grip,
			new /datum/attachment_handler/stock,
		), \
	)
	AddComponent(/datum/component/gun_stat_holder,\
		stability = 98 ,\
		loudness = 45 ,\
		firing_speed = 15 ,\
		ease_of_use = 65 ,\
	)

	AddComponent(/datum/component/gun_jammable,\
		jam_time = 5 SECONDS, \
		jamming_prob = 7, \
	)

