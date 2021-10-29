/obj/structure/closet/body_bag/stasis
	name = "stasis body bag"
	desc = "A body bag designed for the preservation of cadavers via integrated cryogenic technology and cryo-insulative mesh. Due to size limitations, it only works on dead bodies."
	icon = 'modular_skyrat/modules/stasisrework/icons/obj/stasisbag.dmi'
	icon_state = "greenbodybag"
	foldedbag_path = /obj/item/bodybag/stasis
	mob_storage_capacity = 1
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/stasis/open(mob/living/user, force = FALSE)
	for(var/mob/living/M in contents)
		thaw_them(M)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/stasis/close()
	. = ..()
	for(var/mob/living/M in contents)
		if(M.stat == DEAD)
			chill_out(M)
	if(.)
		density = FALSE
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/stasis/proc/chill_out(mob/living/target)
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	ADD_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	target.extinguish_mob()

/obj/structure/closet/body_bag/stasis/proc/thaw_them(mob/living/target)
	target.remove_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	REMOVE_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
