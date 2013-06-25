
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Excavation pickaxes - sorted in order of delicacy. Players will have to choose the right one for each part of excavation.

/obj/item/weapon/pickaxe/brush
	name = "brush"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_brush"
	item_state = "syringe_0"
	digspeed = 20
	desc = "Thick metallic wires for clearing away dust and loose scree (1 centimetre excavation depth)."
	excavation_amount = 0.5
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "brushing"
	w_class = 2

/obj/item/weapon/pickaxe/one_pick
	name = "1/6 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick1"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (2 centimetre excavation depth)."
	excavation_amount = 1
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/two_pick
	name = "1/3 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick2"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (4 centimetre excavation depth)."
	excavation_amount = 2
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/three_pick
	name = "1/2 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick3"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (6 centimetre excavation depth)."
	excavation_amount = 3
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/four_pick
	name = "2/3 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick4"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (8 centimetre excavation depth)."
	excavation_amount = 4
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/five_pick
	name = "5/6 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick5"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (10 centimetre excavation depth)."
	excavation_amount = 5
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/six_pick
	name = "1/1 pick"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick6"
	item_state = "syringe_0"
	digspeed = 20
	desc = "A miniature excavation tool for precise digging (12 centimetre excavation depth)."
	excavation_amount = 6
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"
	w_class = 2

/obj/item/weapon/pickaxe/hand
	name = "hand pickaxe"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pick_hand"
	item_state = "syringe_0"
	digspeed = 30
	desc = "A smaller, more precise version of the pickaxe (30 centimetre excavation depth)."
	excavation_amount = 15
	drill_sound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"
	w_class = 3

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pack for holding pickaxes

/obj/item/weapon/storage/box/excavation
	name = "excavation pick set"
	icon = 'icons/obj/storage.dmi'
	icon_state = "excavation"
	desc = "A set of picks for excavation."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots = 7
	w_class = 2
	can_hold = list("/obj/item/weapon/pickaxe/brush",\
	"/obj/item/weapon/pickaxe/one_pick",\
	"/obj/item/weapon/pickaxe/two_pick",\
	"/obj/item/weapon/pickaxe/three_pick",\
	"/obj/item/weapon/pickaxe/four_pick",\
	"/obj/item/weapon/pickaxe/five_pick",\
	"/obj/item/weapon/pickaxe/six_pick")
	max_combined_w_class = 17
	max_w_class = 4
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/excavation/New()
	..()
	new /obj/item/weapon/pickaxe/brush(src)
	new /obj/item/weapon/pickaxe/one_pick(src)
	new /obj/item/weapon/pickaxe/two_pick(src)
	new /obj/item/weapon/pickaxe/three_pick(src)
	new /obj/item/weapon/pickaxe/four_pick(src)
	new /obj/item/weapon/pickaxe/five_pick(src)
	new /obj/item/weapon/pickaxe/six_pick(src)
