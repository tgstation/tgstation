/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	icon_state = "headpike"
	density = FALSE
	anchored = TRUE
	var/obj/item/spear/spear
	var/obj/item/spear/speartype
	var/obj/item/bodypart/head/victim

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"
	speartype = /obj/item/spear/bonespear

/obj/structure/headpike/bamboo //for bamboo spears
	icon_state = "headpike-bamboo"
	speartype = /obj/item/spear/bamboospear

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
		victim.real_name = random_unique_name(prob(50))
	spear = locate(speartype) in parts_list
	if(!spear)
		spear = new speartype(src)
	update_appearance()
	return ..()

/obj/structure/headpike/update_name()
	name = "[victim.real_name] on a [spear]"
	return ..()

/obj/structure/headpike/update_overlays()
	. = ..()
	if(!victim)
		return
	var/mutable_appearance/MA = new()
	MA.copy_overlays(victim)
	MA.pixel_y = 12
	MA.pixel_x = pixel_x
	. += victim

/obj/structure/headpike/handle_atom_del(atom/A)
	if(A == victim)
		victim = null
	if(A == spear)
		spear = null
	if(!QDELETED(src))
		deconstruct(TRUE)
	return ..()

/obj/structure/headpike/deconstruct(disassembled)
	if(!disassembled)
		return ..()
	if(victim)
		victim.forceMove(drop_location())
		victim = null
	if(spear)
		spear.forceMove(drop_location())
		spear = null
	return ..()

/obj/structure/headpike/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You take down [src]."))
	deconstruct(TRUE)
