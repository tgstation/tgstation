/obj/vehicle/lawnmower
	name = "lawn mower"
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace."
	icon = 'hippiestation/icons/obj/vehicles.dmi'
	icon_state = "lawnmower"
	var/emagged = FALSE
	var/list/drive_sounds = list('hippiestation/sound/effects/mowermove1.ogg', 'hippiestation/sound/effects/mowermove2.ogg')
	var/list/gib_sounds = list('hippiestation/sound/effects/mowermovesquish.ogg')
	var/driver

/obj/vehicle/lawnmower/emagged
	emagged = TRUE

/obj/vehicle/lawnmower/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>The safety mechanisms on \the [src] are already disabled!</span>")
		return
	to_chat(user, "<span class='warning'>You disable the safety mechanisms on \the [src].</span>")
	emagged = TRUE

/obj/vehicle/lawnmower/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 0)
	. = ..()
	riding_datum = new/datum/riding/lawnmower

/obj/vehicle/lawnmower/Bump(atom/A)
	if(emagged)
		if(isliving(A))
			var/mob/living/M = A
			M.adjustBruteLoss(25)
			var/atom/newLoc = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(newLoc, 4, 1)

/obj/vehicle/lawnmower/Move()
	..()
	var/gibbed = FALSE
	var/mob/living/carbon/H

	if(has_buckled_mobs())
		H = buckled_mobs[1]

	if(emagged)
		for(var/mob/living/carbon/human/M in loc)
			if(M == H)
				continue
			if(M.lying)
				visible_message("<span class='danger'>\the [src] grinds [M.name] into a fine paste!</span>")
				M.gib()
				shake_camera(M, 20, 1)
				gibbed = TRUE

	if(gibbed)
		shake_camera(H, 10, 1)
		playsound(loc, pick(gib_sounds), 75, 1)
	else
		playsound(loc, pick(drive_sounds), 75, 1)
