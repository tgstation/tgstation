///Normal toolbox
/datum/storage/toolbox
	open_sound = 'sound/items/handling/toolbox/toolbox_open.ogg'
	rustle_sound = 'sound/items/handling/toolbox/toolbox_rustle.ogg'

///Heirloom toolbox
/datum/storage/toolbox/heirloom
	max_specific_storage = WEIGHT_CLASS_SMALL

///Syndicate toolbox
/datum/storage/toolbox/syndicate
	silent = TRUE

///Artistic toolbox
/datum/storage/toolbox/artistic
	max_total_storage = 20
	max_slots = 11

///Guncase toolbox
/datum/storage/toolbox/guncase
	max_total_storage = 7 //enough to hold ONE bulky gun and the ammo boxes
	max_slots = 4
	max_specific_storage = WEIGHT_CLASS_BULKY

///Monkey Guncase toolbox
/datum/storage/toolbox/guncase/monkey/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_locked(STORAGE_SOFT_LOCKED)

///Doublesword toolbox
/datum/storage/toolbox/guncase/doublesword
	max_slots = 5
	max_total_storage = 10 //it'll hold enough

///Fishing toolbox
/datum/storage/toolbox/fishing/New(atom/parent, max_slots, max_specific_storage, max_total_storage, rustle_sound, remove_rustle_sound)
	. = ..()
	set_holdable(exception_hold_list = /obj/item/fishing_rod)

///Fishing toolbox small
/datum/storage/toolbox/fishing/small
	max_specific_storage = WEIGHT_CLASS_SMALL //It can still hold a fishing rod

///Crafter toolbox
/datum/storage/toolbox/crafter
	max_total_storage = 20
	max_slots = 11
