/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if (computer)
			break
//	spawn(100) //Wont the MC just call this process() before and at the 10 second mark anyway?
//		process()

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return

/obj/machinery/optable/blob_act()
	if(prob(75))
		del(src)

/obj/machinery/optable/attack_paw(mob/user as mob)
	if ((M_HULK in usr.mutations))
		usr << text("\blue You destroy the operating table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		del(src)
	if (!( locate(/obj/machinery/optable, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			visible_message("The monkey hides under the table!")
	return

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (M_HULK in usr.mutations)
		usr << text("\blue You destroy the table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		del(src)
	return

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((( istype(O, /obj/item/weapon) ) || user.get_active_hand() == O))

		user.drop_item()
		if (O.loc != src.loc)
			step(O, get_dir(O, src))
		return
	else
		if(O.loc == user) //no you can't pull things out of your ass
			return
		if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
			return
		if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
			return
		if(!ismob(O)) //humans only
			return
		if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robutts dont fit
			return
		if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
			return
		if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
			return
		if(isrobot(user))
			if(!istype(user:module, /obj/item/weapon/robot_module/medical))
				user << "<span class='warning'>You do not have the means to do this!</span>"
				return
		if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
			return
		var/mob/living/L = O
		if(!istype(L) || L.buckled || L == user)
			return
		if (L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
		L.resting = 1
		L.loc = src.loc
		visible_message("\red [L] has been laid on the operating table by [user].", 3)
		for(var/obj/OO in src)
			OO.loc = src.loc
		src.add_fingerprint(user)
		icon_state = "table2-active"
		src.victim = L
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

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user as mob)
	if (C == user)
		user.visible_message("[user] climbs on the operating table.","You climb on the operating table.")
	else
		visible_message("\red [C] has been laid on the operating table by [user].", 3)
	if (C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src
	C.resting = 1
	C.loc = src.loc
	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		src.victim = H
		icon_state = H.pulse ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.buckled || usr.restrained())
		return

	if(src.victim)
		usr << "\blue <B>The table is already occupied!</B>"
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob)
	if (istype(W, /obj/item/weapon/grab))
		if(iscarbon(W:affecting))
			take_victim(W:affecting,usr)
			del(W)
			return
	if(isrobot(user)) return
	user.drop_item()
	if(W && W.loc)
		W.loc = src.loc
	return