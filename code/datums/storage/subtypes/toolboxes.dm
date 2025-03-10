///Normal toolboxes
/datum/storage/toolbox
	open_sound = 'sound/items/handling/toolbox/toolbox_open.ogg'
	rustle_sound = 'sound/items/handling/toolbox/toolbox_rustle.ogg'

///Electrical toolbox
/datum/storage/toolbox/electrical
	max_slots = 8
	max_total_storage = 15

///Old heirloom toolbox
/datum/storage/toolbox/old_heirloom
	max_specific_storage = WEIGHT_CLASS_SMALL

///Syndicate toolbox
/datum/storage/toolbox/syndicate
	silent = TRUE

///Artistic toolbox
/datum/storage/toolbox/artistic
	max_total_storage = 25
	max_slots = 11

///Gun storage toolbox
/datum/storage/toolbox/guncase
	max_slots = 4
	max_total_storage = 7 //enough to hold ONE bulky gun and the ammo boxes
	allow_big_nesting = TRUE
	max_specific_storage = WEIGHT_CLASS_BULKY

///Double sword toolbox
/datum/storage/toolbox/double_sword
	max_slots = 5
	max_total_storage = 10 //it'll hold enough
	max_specific_storage = WEIGHT_CLASS_BULKY

///Fishing toolbox
/datum/storage/toolbox/fishing/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(exception_hold_list = /obj/item/fishing_rod)

///Small fishing toolbox
/datum/storage/toolbox/fishing/small
	max_specific_storage = WEIGHT_CLASS_SMALL

///Ancient bundle toolbox
/datum/storage/toolbox/ancient_bundle
	max_slots = 8
