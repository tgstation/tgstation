

/*

Contents:
- Proc for handling teleporting while grabbing someone
- Telport Ability
- Right-Click Teleport Ability

*/


//Handles elporting while grabbing someone
/obj/item/clothing/suit/space/space_ninja/proc/handle_teleport_grab(turf/T, mob/living/H)
	if(istype(H.get_active_hand(),/obj/item/weapon/grab))//Handles grabbed persons.
		var/obj/item/weapon/grab/G = H.get_active_hand()
		G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
	if(istype(H.get_inactive_hand(),/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = H.get_inactive_hand()
		G.affecting.loc = locate(T.x+rand(-1,1),T.y+rand(-1,1),T.z)//variation of position.
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

		if(destination&&istype(mobloc, /turf))//So we don't teleport out of containers
			spawn(0)
				playsound(H.loc, "sparks", 50, 1)
				anim(mobloc,src,'icons/mob/mob.dmi',,"phaseout",,H.dir)

			handle_teleport_grab(destination, H)
			H.loc = destination

			spawn(0)
				spark_system.start()
				playsound(H.loc, 'sound/effects/phasein.ogg', 25, 1)
				playsound(H.loc, "sparks", 50, 1)
				anim(H.loc,H,'icons/mob/mob.dmi',,"phasein",,H.dir)

			spawn(0)
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
		if((!T.density)&&istype(mobloc, /turf))
			spawn(0)
				playsound(H.loc, 'sound/effects/sparks4.ogg', 50, 1)
				anim(mobloc,src,'icons/mob/mob.dmi',,"phaseout",,H.dir)

			handle_teleport_grab(T, H)
			H.loc = T

			spawn(0)
				spark_system.start()
				playsound(H.loc, 'sound/effects/phasein.ogg', 25, 1)
				playsound(H.loc, 'sound/effects/sparks2.ogg', 50, 1)
				anim(H.loc,H,'icons/mob/mob.dmi',,"phasein",,H.dir)

			spawn(0)//Any living mobs in teleport area are gibbed.
				T.phase_damage_creatures(20,H)//Paralyse and damage mobs and mechas on the turf
			s_coold = 1
		else
			H << "<span class='danger'>You cannot teleport into solid walls or from solid matter</span>"
	return


