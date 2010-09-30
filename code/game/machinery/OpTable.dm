/obj/machinery/optable/New()
	..()
	for(var/obj/machinery/computer/operating/O in world)
		if(src.id == O.id)
			src.computer = O
	spawn(100)
		process()

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return

/obj/machinery/optable/blob_act()
	if(prob(75))
		del(src)

/obj/machinery/optable/hand_p(mob/user as mob)

	return src.attack_paw(user)
	return

/obj/machinery/optable/attack_paw(mob/user as mob)
	if ((usr.mutations & 8))
		usr << text("\blue You destroy the operating table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [usr] destroys the operating table.")
		src.density = 0
		del(src)
	if (!( locate(/obj/machinery/optable, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			for(var/mob/M in viewers(user, null))
				M.show_message("The monkey hides under the table!", 1)
				//Foreach goto(69)
	return

/obj/machinery/optable/attack_hand(mob/user as mob)
	if ((usr.mutations & 8))
		usr << text("\blue You destroy the table.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [usr] destroys the table.")
		src.density = 0
		del(src)
	return



/obj/machinery/optable/CanPass(atom/movable/O as mob|obj, target as turf)
	if(!O)
		return 0
	if ((O.flags & 2 || istype(O, /obj/meteor)))
		return 1
	else
		return 0
	return

/obj/machinery/optable/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/M = locate(/mob/living/carbon/human, src.loc)
		if(M.resting)
			src.victim = M
			icon_state = "table2-active"
			return 1
	src.victim = null
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/grab))
		if(ismob(W:affecting))
			var/mob/M = W:affecting
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.resting = 1
			M.loc = src.loc
			for (var/mob/C in viewers(src))
				C.show_message("\red [M] has been laid on the operating table by [user].", 3)
			for(var/obj/O in src)
				O.loc = src.loc
			src.add_fingerprint(user)
			icon_state = "table2-active"
			src.victim = M
			del(W)
			return
	user.drop_item()
	if(W && W.loc)
		W.loc = src.loc
	return