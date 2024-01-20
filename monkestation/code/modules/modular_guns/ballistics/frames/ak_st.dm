/obj/item/gun/ballistic/modular/ak_st
	icon = 'monkestation/code/modules/modular_guns/icons/ak.dmi'
	icon_state = "frame-st"

/obj/item/gun/ballistic/modular/ak_st/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/weapon_attachments,\
		attachment_type = GUN_ATTACH_AK_ST, \
		hand_slots = list(
			new /datum/attachment_handler/magazine,
			new /datum/attachment_handler/grip,
			new /datum/attachment_handler/stock,
		), \
	)
	AddComponent(/datum/component/gun_stat_holder,\
		stability = 55 ,\
		loudness = 90 ,\
		firing_speed = 12 ,\
		ease_of_use = 86 ,\
	)
	AddComponent(/datum/component/gun_jammable,\
		jam_time = 5 SECONDS, \
		jamming_prob = 5, \
	)

