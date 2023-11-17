/obj/structure/cat_house
	name = "cat house"
	desc = "cozy home for cats"
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat_house"
	density = TRUE
	anchored = TRUE
	var/mob/living/resident_cat
	var/scale_x = 0.5
	var/scale_y = 0.5

/obj/structure/cat_house/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_BASIC_MOB, PROC_REF(enter_home))

/obj/structure/cat_house/proc/enter_home(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(resident_cat)
		return
	if(istype(attacker, /mob/living/basic/pet/cat))
		attacker.forceMove(src)

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
	var/image/ore_icon = image(icon = resident_cat.icon, icon_state = resident_cat.icon_state, layer = LOW_ITEM_LAYER)
	ore_icon.transform = ore_icon.transform.Scale(scale_x, scale_y)
	. += ore_icon
