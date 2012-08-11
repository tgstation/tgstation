/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check mass spatial depth and density."
	icon = 'pda.dmi'
	icon_state = "crap"
	item_state = "analyzer"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	//slot_flags = SLOT_BELT

/obj/item/weapon/pickaxe/hand_pick
	name = "hand pick"
	icon_state = "excavation"
	item_state = "minipick"
	digspeed = 50
	desc = "A smaller, more precise version of the pickaxe."
	flags = FPRINT | TABLEPASS
	w_class = 2.0

/obj/item/weapon/pickaxe/mini_pick
	name = "mini pick"
	icon_state = "excavation"
	item_state = "minipick"
	digspeed = 60
	desc = "A miniature excavation tool for precise digging around delicate finds."
	flags = FPRINT | TABLEPASS
	w_class = 1.0

//todo: this
/obj/item/device/beacon_locator
	name = "locater device"
	desc = "Used to triangulate position signal emitters."
	icon = 'device.dmi'
	icon_state = "pinoff"	//pinonfar, pinonmedium, pinonclose, pinondirect, pinonnull
	item_state = "electronic"
	w_class = 1.0
