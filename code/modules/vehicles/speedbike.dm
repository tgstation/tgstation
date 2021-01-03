/obj/vehicle/ridden/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/overlay_state = "cover_blue"
	var/mutable_appearance/overlay

/obj/vehicle/ridden/speedbike/Initialize()
	. = ..()
	overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)
	add_overlay(overlay)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/vehicle/ridden/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	return ..()

/obj/vehicle/ridden/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"

//BM SPEEDWAGON

/obj/vehicle/ridden/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	var/static/mutable_appearance/overlay = mutable_appearance(icon, "speedwagon_cover", ABOVE_MOB_LAYER)
	max_buckled_mobs = 4
	var/crash_all = FALSE //CHAOS
	pixel_y = -48
	pixel_x = -48

/obj/vehicle/ridden/speedwagon/Initialize()
	. = ..()
	add_overlay(overlay)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedwagon)

/obj/vehicle/ridden/speedwagon/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return

	var/atom/throw_target = get_edge_target_turf(A, dir)
	if(crash_all)
		if(ismovable(A))
			var/atom/movable/AM = A
			AM.throw_at(throw_target, 4, 3)
		visible_message("<span class='danger'>[src] crashes into [A]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		H.Paralyze(100)
		H.adjustStaminaLoss(30)
		H.apply_damage(rand(20,35), BRUTE)
		if(!crash_all)
			H.throw_at(throw_target, 4, 3)
			visible_message("<span class='danger'>[src] crashes into [H]!</span>")
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)

/obj/vehicle/ridden/speedwagon/Moved()
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A in range(2, src))
		if(!(A in buckled_mobs))
			Bump(A)
