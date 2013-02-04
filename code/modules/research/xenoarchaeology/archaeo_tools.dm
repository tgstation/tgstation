//---- miscellaneous devices ----//

//also known as the x-ray diffractor
/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	icon = 'pda.dmi'
	icon_state = "crap"
	item_state = "analyzer"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

/obj/item/device/beacon_locator
	name = "locater device"
	desc = "Used to scan and locate signals on a particular frequency."
	icon = 'device.dmi'
	icon_state = "pinoff"	//pinonfar, pinonmedium, pinonclose, pinondirect, pinonnull
	item_state = "electronic"

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract cores from geological samples."
	icon = 'device.dmi'
	icon_state = "core_sampler"
	item_state = "screwdriver_brown"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

//todo: tape

//---- excavation devices devices ----//
//sorted in order of delicacy

/obj/item/weapon/pickaxe/brush
	name = "brush"
	//icon_state = "brush"
	//item_state = "minipick"
	digspeed = 50
	desc = "Featuring thick metallic wires for clearing away dust and loose scree."
	excavation_amount = 0.5
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "brushing"

/obj/item/weapon/pickaxe/quarter_pick
	name = "1/4 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging."
	excavation_amount = 1
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/half_pick
	name = "1/2 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging."
	excavation_amount = 3
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/pick
	name = "1/1 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging."
	excavation_amount = 5
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/hand
	name = "hand pickaxe"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A smaller, more precise version of the pickaxe."
	excavation_amount = 15
	drill_sound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"
