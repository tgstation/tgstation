/obj/vehicle/ridden/speedbike
	name = "Speedbike"
	icon = 'icons/obj/toys/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/cover_iconstate = "cover_blue"

/obj/vehicle/ridden/speedbike/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/vehicle/ridden/speedbike/post_buckle_mob(mob/living/user)
	. = ..()
	update_appearance()

/obj/vehicle/ridden/speedbike/post_unbuckle_mob()
	. = ..()
	update_appearance()

/obj/vehicle/ridden/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	return ..()

/obj/vehicle/ridden/speedbike/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		var/mutable_appearance/cover_overlay = mutable_appearance(icon, cover_iconstate, ABOVE_MOB_LAYER, src, appearance_flags = KEEP_APART)
		cover_overlay = color_atom_overlay(cover_overlay)
		. += cover_overlay

/obj/vehicle/ridden/speedbike/red
	icon_state = "speedbike_red"
	cover_iconstate = "cover_red"
