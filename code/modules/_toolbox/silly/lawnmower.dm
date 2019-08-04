/obj/vehicle/ridden/lawnmower
	name = "lawn mower"
	desc = "Equipped with reliable safeties to prevent <i>accidents</i> in the workplace."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "lawnmower"
	var/emagged = FALSE
	var/list/drive_sounds = list('sound/toolbox/mowermove1.ogg', 'sound/toolbox/mowermove2.ogg')
	var/list/gib_sounds = list('sound/toolbox/mowermovesquish.ogg')
	var/driver
	var/engine_sound = 'sound/toolbox/car/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 20

/obj/vehicle/ridden/lawnmower/Initialize(mapload)
	. = ..()
	update_icon()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-5, 2), TEXT_WEST = list( 5, 2)))

/obj/vehicle/ridden/lawnmower/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>The safety mechanisms on \the [src] are already disabled!</span>")
		return
	to_chat(user, "<span class='warning'>You disable the safety mechanisms on \the [src].</span>")
	emagged = TRUE

/obj/vehicle/ridden/lawnmower/Bump(atom/A)
	if(emagged)
		if(isliving(A))
			var/mob/living/M = A
			M.adjustBruteLoss(15)
			var/atom/newLoc = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
			M.throw_at(newLoc, 4, 1)

/obj/vehicle/ridden/lawnmower/Move()
	..()

	var/gibbed = FALSE
	var/mob/living/carbon/H

	if(has_buckled_mobs())
		H = buckled_mobs[1]

	if(H && !(world.time < last_enginesound_time + engine_sound_length))
		last_enginesound_time = world.time
		playsound(src, engine_sound, 100, TRUE)
		playsound(src, 'sound/toolbox/car/carrev.ogg', 100, TRUE)

	if(emagged)
		for(var/mob/living/carbon/human/M in loc)
			if(M == H)
				continue
			if(M.lying)
				visible_message("<span class='danger'>\the [src] grinds [M.name]'s flesh!</span>")
				//M.gib()
				playsound(src, 'sound/weapons/circsawhit.ogg', 100, TRUE)
				M.adjustBruteLoss(rand(20,60))
				M.Knockdown(30)
				M.add_splatter_floor(loc)
				var/list/listlimbs = list(
					BODY_ZONE_L_ARM,
					BODY_ZONE_R_ARM,
					BODY_ZONE_L_LEG,
					BODY_ZONE_R_LEG)
				var/obj/item/bodypart/part = M.get_bodypart(pick(listlimbs))
				if(part && prob(30) && part.dismember(BRUTE))
					playsound(get_turf(M), pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg'), 80, 1)
				shake_camera(M, 20, 1)
				gibbed = TRUE

	if(gibbed)
		shake_camera(H, 10, 1)
		playsound(loc, pick(gib_sounds), 75, 1)
	else
		playsound(loc, pick(drive_sounds), 75, 1)

//Starting emagged
/obj/vehicle/ridden/lawnmower/emagged
	emagged = TRUE