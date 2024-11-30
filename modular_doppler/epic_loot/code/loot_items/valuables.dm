/datum/export/epic_loot_valuables
	cost = PAYCHECK_COMMAND * 3
	unit_name = "valuables"
	export_types = list(
		/obj/item/epic_loot/press_pass,
		/obj/item/epic_loot/hdd,
		/obj/item/epic_loot/slim_diary,
		/obj/item/epic_loot/plasma_explosive,
		/obj/item/epic_loot/silver_chainlet,
	)

/datum/export/epic_loot_valuables_super
	cost = PAYCHECK_COMMAND * 4
	unit_name = "high valuables"
	export_types = list(
		/obj/item/epic_loot/ssd,
		/obj/item/epic_loot/military_flash,
		/obj/item/epic_loot/diary,
		/obj/item/epic_loot/corpo_folder,
		/obj/item/epic_loot/intel_folder,
		/obj/item/epic_loot/gold_chainlet,
	)

// An old press pass, perhaps of an unlucky soul who was reporting on the incident that made this place abandoned in the first place
/obj/item/epic_loot/press_pass
	name = "expired press pass"
	desc = "An old lanyard with an expired press pass stuck to it. Most of the text has worn off, you can't tell who it was for or who it was issued by."
	icon_state = "press_pass"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/epic_loot/press_pass/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Medical Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> frontier first aid kit.")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> premium robotic repair kit.")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> 'Sector 9 Special' autoinjector.")

	return .

// A computer SSD
/obj/item/epic_loot/ssd
	name = "solid-state drive"
	desc = "A solid-state drive for computers, may even contain some still-valuable information on it!"
	icon_state = "ssd"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*8, \
						/datum/material/silver = SMALL_MATERIAL_AMOUNT*2,)

/obj/item/epic_loot/ssd/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> pair of binoculars.")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> assault belt.")

	return .

// A computer hard drive
/obj/item/epic_loot/hdd
	name = "hard drive"
	desc = "A hard drive for computers, may even contain some still-valuable information on it!"
	icon_state = "hard_disk"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*8, \
						/datum/material/silver = SMALL_MATERIAL_AMOUNT*2,)

/obj/item/epic_loot/hdd/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> assault pack.")

	return .

// Military-grade flash drives, made for use specifically with military computers
/obj/item/epic_loot/military_flash
	name = "military flash drive"
	desc = "A military-grade flash drive for use in matching military-grade computer systems. Might even contain some still-valuable information on it!"
	icon_state = "military_flash"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

/obj/item/epic_loot/military_flash/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> tag case.")
	. += span_notice("<b>Medical Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> autoinjector pouch.")

	return .

// Someone's personal diary, or bootleg captain's log, whatever
/obj/item/epic_loot/diary
	name = "sealed diary"
	desc = "An old, apparently well-kept diary with unknown information inside. May hold important data on the location it was found in."
	icon_state = "diary"
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/epic_loot/diary/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>2</b> of these can be traded for <b>1</b> rengo precision rifle.")
	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> keycard holder.")

	return .

// A slimmer version of the regular diary
/obj/item/epic_loot/slim_diary
	name = "sealed slim diary"
	desc = "An old, apparently well-kept diary with unknown information inside. May hold important data on the location it was found in."
	icon_state = "slim_diary"
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'

/obj/item/epic_loot/slim_diary/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>2</b> smoke grenades.")
	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> pair of sunglasses.")

	return .

// Straight up, a brick of plasma-cringe explosive, keep away from fire
/obj/item/epic_loot/plasma_explosive
	name = "brick of plasma-based explosive"
	desc = "A really quite dangerous brick of a plasma-based explosive. Usually, a demolition charge or something of the sort, but, it's still a <b>bomb</b>."
	icon_state = "plasma_explosive"
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 3, // for the. container?
		/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 5) // the part that explodes

/obj/item/epic_loot/plasma_explosive/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/explodable, 0, 1, 3, 5, 5)

/obj/item/epic_loot/plasma_explosive/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> grenade fuze can be traded for <b>2</b> offensive impact grenades.")
	. += span_notice("- <b>1</b> of these + <b>1</b> grenade fuze + <b>1</b> box of nails can be traded for <b>2</b> defensive impact grenades")

	return .

// A folder from some corporation with likely valuable data inside
/obj/item/epic_loot/corpo_folder
	name = "corporate data folder"
	desc = "A blue folder with no label of who it's from. What is labeled, however, is the series of marks of confidential or trade secret information inside."
	icon_state = "nt_folders"
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/epic_loot/corpo_folder/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> intelligence folder can be traded for <b>1</b> fire axe.")
	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> organizational pouch.")

	return .

// Brown unlabeled folder of doom, may contain government secrets
/obj/item/epic_loot/intel_folder
	name = "intelligence folder"
	desc = "A an unmarked, unassuming folder for documents. What is labeled, however, is the series of marks of confidential or trade secret information inside."
	icon_state = "documents"
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/epic_loot/intel_folder/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> corporate data folder can be traded for <b>1</b> fire axe.")
	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> security belt.")

	return .

// A small chainlet made of silver
/obj/item/epic_loot/silver_chainlet
	name = "silver chainlet"
	desc = "A small chainlet for decorating clothing or other items, made from silver."
	icon_state = "silver_chain"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT)

/obj/item/epic_loot/silver_chainlet/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Medical Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> civil defense medical kit.")
	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> gold chainlet can be traded for <b>1</b> documents pouch.")

	return .

// A small chainlet made of gold
/obj/item/epic_loot/gold_chainlet
	name = "gold chainlet"
	desc = "A small chainlet for decorating clothing or other items, made from gold."
	icon_state = "gold_chain"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT)

/obj/item/epic_loot/gold_chainlet/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Equipment Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> silver chainlet can be traded for <b>1</b> documents pouch.")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> ammo pouch.")

	return .
