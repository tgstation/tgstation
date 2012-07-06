/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check mass spatial depth and density."
	icon = 'pda.dmi'
	icon_state = "crap"
	item_state = "analyzer"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

/obj/item/weapon/pickaxe/hand_pick
	name = "hand pick"
	icon_state = "excavation"
	item_state = "minipick"
	digspeed = 50
	desc = "A smaller, more precise version of the pickaxe."

/obj/item/weapon/pickaxe/mini_pick
	name = "mini pick"
	icon_state = "excavation"
	item_state = "minipick"
	digspeed = 60
	desc = "A miniature excavation tool for precise digging around delicate finds."

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract cores from geological samples."
	icon = 'device.dmi'
	icon_state = "core_sampler"
	item_state = "screwdriver_brown"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

/obj/item/device/beacon_locator
	name = "locater device"
	desc = "Used to scan and locate signals on a particular frequency."
	icon = 'device.dmi'
	icon_state = "pinoff"	//pinonfar, pinonmedium, pinonclose, pinondirect, pinonnull
	item_state = "electronic"
