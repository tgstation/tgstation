/obj/structure/cat_house
	name = "cat house"
	desc = "Cozy home for cats."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat_house"
	density = TRUE
	anchored = TRUE
	///cat residing in this house
	var/mob/living/resident_cat

/obj/structure/cat_house/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_BASIC_MOB, PROC_REF(enter_home))

/obj/structure/cat_house/proc/enter_home(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(resident_cat) && istype(attacker, /mob/living/basic/pet/cat))
		attacker.forceMove(src)
		return
	if(resident_cat == attacker)
		attacker.forceMove(drop_location())

/obj/structure/cat_house/Entered(atom/movable/mover)
	. = ..()
	if(!istype(mover, /mob/living/basic/pet/cat))
		return
	resident_cat = mover
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/cat_house/Exited(atom/movable/mover)
	. = ..()
	if(mover != resident_cat)
		return
	resident_cat = null
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/cat_house/update_overlays()
	. = ..()
	if(isnull(resident_cat))
		return
	var/image/cat_icon = image(icon = resident_cat.icon, icon_state = resident_cat.icon_state, layer = LOW_ITEM_LAYER)
	cat_icon.transform = cat_icon.transform.Scale(0.7, 0.7)
	cat_icon.pixel_x = 0
	cat_icon.pixel_y = -9
	. += cat_icon
