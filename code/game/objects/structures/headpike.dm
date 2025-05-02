/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	icon_state = "headpike"
	density = FALSE
	anchored = TRUE
	var/obj/item/spear/spear
	var/obj/item/spear/speartype = /obj/item/spear
	var/obj/item/bodypart/head/victim

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"
	speartype = /obj/item/spear/bonespear

/obj/structure/headpike/bamboo //for bamboo spears
	icon_state = "headpike-bamboo"
	speartype = /obj/item/spear/bamboospear

/obj/structure/headpike/military //for military spears
	icon_state = "headpike-military"
	speartype = /obj/item/spear/military

/obj/structure/headpike/Initialize(mapload)
	. = ..()
	if(mapload)
		CheckParts()
	pixel_x = rand(-8, 8)

/obj/structure/headpike/Destroy()
	QDEL_NULL(victim)
	QDEL_NULL(spear)
	return ..()

/obj/structure/headpike/CheckParts(list/parts_list)
	victim = locate() in parts_list
	if(!victim) //likely a mapspawned one
		victim = new(src)
		victim.real_name = generate_random_name()
	spear = locate(speartype) in parts_list
	if(!spear)
		spear = new speartype(src)
	update_appearance()
	return ..()

/obj/structure/headpike/update_name()
	name = "[victim.real_name] on a [spear.name]"
	return ..()

/obj/structure/headpike/update_overlays()
	. = ..()
	if(!victim)
		return
	var/mutable_appearance/appearance = new()
	appearance.copy_overlays(victim)
	appearance.pixel_z = 12
	appearance.layer = layer + 0.1
	. += appearance

/obj/structure/headpike/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != victim && gone != spear)
		return
	if(gone == victim)
		victim = null
	if(gone == spear)
		spear = null
	if(!QDELETED(src))
		deconstruct(TRUE)

/obj/structure/headpike/atom_deconstruct(disassembled)
	var/obj/item/bodypart/head/our_head = victim
	var/obj/item/spear/our_spear = spear
	victim = null
	spear = null
	our_head?.forceMove(drop_location()) //Make sure the head always comes off
	if(!disassembled)
		return ..()
	our_spear?.forceMove(drop_location())

/obj/structure/headpike/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You take down [src]."))
	deconstruct(TRUE)
