/obj/vehicle/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/overlay_state = "cover_blue"
	var/image/overlay = null

/obj/vehicle/space/speedbike/buckle_mob(mob/living/M, force = 0, check_loc = 1)
 	. = ..()
		riding_datum = new/datum/riding/space/speedbike

/obj/vehicle/space/speedbike/New()
	. = ..()
	overlay = image("icons/obj/bike.dmi", overlay_state)
	overlay.layer = ABOVE_MOB_LAYER
	add_overlay(overlay)

/obj/effect/overlay/temp/speedbike_trail
	name = "speedbike trails"
	icon_state = "ion_fade"
	layer = BELOW_MOB_LAYER
	duration = 10
	randomdir = 0

/obj/effect/overlay/temp/speedbike_trail/New(loc,move_dir)
	..()
	setDir(move_dir)

/obj/vehicle/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/overlay/temp/speedbike_trail(loc,move_dir)
	. = ..()

/obj/vehicle/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"

//BM SPEEDWAGON

/obj/vehicle/space/speedbike/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	overlay_state = "speedwagon_cover"

/obj/vehicle/space/speedbike/speedwagon/Bump(mob/living/A)
	. = ..()
	if(A.density && has_buckled_mobs() && (istype(A, /mob/living/carbon/human) && has_buckled_mobs()))
		var/atom/throw_target = get_edge_target_turf(A, pick(cardinal))
		A.throw_at(throw_target, 4, 3)
		A.Weaken(5)
		A.adjustStaminaLoss(30)
		A.apply_damage(rand(20,35), BRUTE)
		visible_message("<span class='danger'>[src] crashes into [A]!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/vehicle/space/speedbike/speedwagon/buckle_mob(mob/living/M, force = 0, check_loc = 1)
 	. = ..()
		riding_datum = new/datum/riding/space/speedbike/speedwagon
