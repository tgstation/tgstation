/obj/vehicle/ridden/speedbike
	name = "Speedbike"
	icon = 'icons/obj/toys/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/cover_iconstate = "cover_blue"

/obj/vehicle/ridden/speedbike/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, cover_iconstate, ABOVE_MOB_LAYER))
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/vehicle/ridden/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	return ..()

/obj/vehicle/ridden/speedbike/red
	icon_state = "speedbike_red"
	cover_iconstate = "cover_red"
