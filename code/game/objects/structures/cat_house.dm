/obj/structure/cat_house
	name = "cat house"
	desc = "Cozy home for cats."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "cat_house"
	density = TRUE
	anchored = TRUE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 5)
	///cat residing in this house
	var/mob/living/resident_cat

/obj/structure/cat_house/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_BASIC_MOB, PROC_REF(enter_home))

/obj/structure/cat_house/Destroy(force)
	. = ..()
	if(resident_cat)
		resident_cat.forceMove(drop_location())

/obj/structure/cat_house/examine(mob/user)
	. = ..()
	if(resident_cat)
		. += span_notice("[resident_cat] is currently residing inside of it.")

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

/obj/structure/cat_house/container_resist_act(mob/living/user)
	if(resident_cat == user)
		user.forceMove(drop_location())

/obj/structure/cat_house/update_overlays()
	. = ..()
	if(isnull(resident_cat))
		return
	var/image/cat_icon = image(icon = resident_cat.icon, icon_state = resident_cat.icon_state, layer = LOW_ITEM_LAYER, dir = SOUTH)
	cat_icon.transform = cat_icon.transform.Scale(0.7, 0.7)
	cat_icon.pixel_w = 0
	cat_icon.pixel_z = -9
	. += cat_icon

///Called when a simple animal attacks the house.
/obj/structure/cat_house/proc/enter_home(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(resident_cat) && istype(attacker, /mob/living/basic/pet/cat))
		attacker.forceMove(src)
		return COMSIG_BASIC_ATTACK_CANCEL_CHAIN
	if(resident_cat == attacker)
		attacker.forceMove(drop_location())
		return COMSIG_BASIC_ATTACK_CANCEL_CHAIN
