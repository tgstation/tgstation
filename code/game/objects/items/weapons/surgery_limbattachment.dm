/obj/item/robot_parts/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	var/limbloc = null

	if(!istype(M))
		return ..()

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(!istype(M, /mob/living/carbon/human))
		return ..()

	if((user.zone_sel.selecting == "l_arm") && (istype(src, /obj/item/robot_parts/l_arm)))
		limbloc = "l_hand"
	else if((user.zone_sel.selecting == "r_arm") && (istype(src, /obj/item/robot_parts/r_arm)))
		limbloc = "r_hand"
	else if((user.zone_sel.selecting == "r_leg") && (istype(src, /obj/item/robot_parts/r_leg)))
		limbloc = "r_foot"
	else if((user.zone_sel.selecting == "l_leg") && (istype(src, /obj/item/robot_parts/l_leg)))
		limbloc = "l_foot"
	else
		user << "\red That doesn't fit there!"
		return ..()

	var/mob/living/carbon/human/H = M
	var/datum/organ/external/S = H.organs[limbloc]
	if(S.status & DESTROYED)
		if(!(S.status & ATTACHABLE))
			user << "\red The wound is not ready for a replacement!"
			return 0
		if(M != user)
			M.visible_message( \
				"\red [user] is beginning to attach \the [src] where [H]'s [S.display_name] used to be.", \
				"\red [user] begins to attach \the [src] where your [S.display_name] used to be.")
		else
			M.visible_message( \
				"\red [user] begins to attach a robotic limb where \his [S.display_name] used to be with [src].", \
				"\red You begin to attach \the [src] where your [S.display_name] used to be.")

		if(do_mob(user, H, 100))
			if(M != user)
				M.visible_message( \
					"\red [user] finishes attaching [H]'s new [S.display_name].", \
					"\red [user] finishes attaching your new [S.display_name].")
			else
				M.visible_message( \
					"\red [user] finishes attaching \his new [S.display_name].", \
					"\red You finish attaching your new [S.display_name].")

			if(H == user && prob(25))
				user << "\red You mess up!"
				S.take_damage(15)

			S.status &= ~BROKEN
			S.status &= ~ATTACHABLE
			S.status &= ~DESTROYED
			S.status |= ROBOT
			M.update_body()
			M.updatehealth()
			M.UpdateDamageIcon()
			del(src)

			return 1
		return 0