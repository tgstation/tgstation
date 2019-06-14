/obj/mecha/working/cleaner
	desc = "CLEAN CLEAN CLEAN"
	name = "\improper Cleaner"
	icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	step_in = 1.8
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/ripley
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	max_equip = 3
	internals_req_access = list(ACCESS_JANITOR, ACCESS_MECH_SCIENCE)
	enclosed = FALSE // you don't need to clean space
	/var/obj/item/storage/bag/trash/bluespace/trashbag

/obj/mecha/working/cleaner/Initialize()
	. = ..()
	AddComponent(/datum/component/cleaning, 1)
	trashbag = new /obj/item/storage/bag/trash/bluespace(src)

/obj/mecha/working/cleaner/Topic(href, href_list)
	..()
	if(href_list["unload_trashbag"])
		if(trashbag)
			SEND_SIGNAL(trashbag, COMSIG_TRY_STORAGE_QUICK_EMPTY)
	return

/obj/mecha/working/cleaner/click_action(obj/target, mob/user)
	. = ..()
	if(trashbag && get_dir(src, target) == dir)
		trashbag.pre_attack(target, user)

/obj/mecha/working/cleaner/get_stats_part()
	var/output = ..()
	output += "<a href='?src=[REF(src)];unload_trashbag=1'>Unload trash compartment</a><br>"
	return output