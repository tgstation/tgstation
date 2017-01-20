

/*

Contents:
- Proc for handling teleporting while grabbing someone
- Telport Ability
- Right-Click Teleport Ability

*/


//Handles elporting while grabbing someone
/obj/item/clothing/suit/space/space_ninja/proc/handle_teleport_grab(turf/T, mob/living/H)
	if(H.pulling && (isliving(H.pulling)))
		var/mob/living/victim =	H.pulling
		if(!victim.anchored)
			victim.forceMove(locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z))
	return


//Jaunt
/obj/item/clothing/suit/space/space_ninja/proc/ninjajaunt()
	set name = "Phase Jaunt (10E)"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit in direction facing."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(100,N_STEALTH_CANCEL))
		var/mob/living/carbon/human/H = affecting
		var/turf/destination = get_teleport_loc(H.loc,H,9,1,3,1,0,1)
		var/turf/mobloc = get_turf(H.loc)//Safety

		if(destination && isturf(mobloc))//So we don't teleport out of containers
			playsound(H.loc, "sparks", 50, 1)
			PoolOrNew(/obj/effect/overlay/temp/dir_setting/ninja/phase/out, list(get_turf(H), H.dir))

			handle_teleport_grab(destination, H)
			H.loc = destination

			spark_system.start()
			playsound(H.loc, 'sound/effects/phasein.ogg', 25, 1)
			playsound(H.loc, "sparks", 50, 1)
			PoolOrNew(/obj/effect/overlay/temp/dir_setting/ninja/phase, list(get_turf(H), H.dir))

			destination.phase_damage_creatures(20,H)//Paralyse and damage mobs and mechas on the turf
			s_coold = 1
		else
			H << "<span class='danger'>The VOID-shift device is malfunctioning, <B>teleportation failed</B>.</span>"
	return


//Right-Click teleport: It's basically admin "jump to turf"
/obj/item/clothing/suit/space/space_ninja/proc/ninjashift(turf/T in oview())
	set name = "Phase Shift (20E)"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit to a destination in view."
	set category = null//So it does not show up on the panel but can still be right-clicked.
	set src = usr.contents//Fixes verbs not attaching properly for objects. Praise the DM reference guide!

	if(!ninjacost(200,N_STEALTH_CANCEL))
		var/mob/living/carbon/human/H = affecting
		var/turf/mobloc = get_turf(H.loc)//To make sure that certain things work properly below.
		if(!T.density && isturf(mobloc))
			playsound(H.loc, "sparks", 50, 1)
			PoolOrNew(/obj/effect/overlay/temp/dir_setting/ninja/phase/out, list(get_turf(H), H.dir))

			handle_teleport_grab(T, H)
			H.forceMove(T)

			spark_system.start()
			playsound(H.loc, 'sound/effects/phasein.ogg', 25, 1)
			playsound(H.loc, "sparks", 50, 1)
			PoolOrNew(/obj/effect/overlay/temp/dir_setting/ninja/phase, list(get_turf(H), H.dir))

			T.phase_damage_creatures(20,H)//Paralyse and damage mobs and mechas on the turf
			s_coold = 1
		else
			H << "<span class='danger'>You cannot teleport into solid walls or from solid matter</span>"
	return


