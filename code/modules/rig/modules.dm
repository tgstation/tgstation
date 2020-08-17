/obj/item/rig/module
	name = "RIG module"
	icon_state = "module"
	/// If it can be removed
	var/removable = TRUE
	/// How much space it takes up in the RIG
	var/complexity = 0
	/// Power use when idle
	var/idle_power_use = 0
	/// Power use when used
	var/power_use = 0
	/// Linked RIGsuit
	var/obj/item/rig/control/rig

/obj/item/rig/module/Destroy()
	..()
	if(rig)
		rig.uninstall(src)

/obj/item/rig/module/proc/on_install()
	return

/obj/item/rig/module/proc/on_uninstall()
	return

/obj/item/rig/module/storage
	name = "RIG storage module"
	complexity = 5
	var/datum/component/storage/concrete/storage
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_combined_w_class = 14
	var/max_items = 7

/obj/item/rig/module/storage/antag
	name = "RIG syndicate storage module"
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	max_items = 21

/obj/item/rig/module/storage/antag/wiz
	name = "RIG enchanted storage module"

/obj/item/rig/module/storage/Initialize()
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items

/obj/item/rig/module/storage/on_install()
	var/datum/component/storage/rigstorage = rig.AddComponent(/datum/component/storage, storage)
	rigstorage.max_w_class = max_w_class
	rigstorage.max_combined_w_class = max_combined_w_class
	rigstorage.max_items = max_items

/obj/item/rig/module/storage/on_uninstall()
	var/datum/component/storage/rigstorage = rig.GetComponent(/datum/component/storage)
	rigstorage.RemoveComponent()

/obj/item/rig/module/pai_upgrade
	name = "RIG pAI upgrade module"
	complexity = 2
	idle_power_use = 10
