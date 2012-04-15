/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures. Apparently this includes the clown."
	icon = 'surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/victim = null
	var/strapped = 0.0
	var/updatesicon = 1

	var/obj/machinery/computer/operating/computer = null
	var/id = 0.0

	New()
		..()
		if(!isnull(id))
			for(var/obj/machinery/computer/operating/O in world)
				if(src.id == O.id)
					src.computer = O

	ex_act(severity)
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

	blob_act()
		if(prob(75))
			del(src)

	hand_p(mob/user as mob)
		return src.attack_paw(user)
		return

	attack_paw(mob/user as mob)
		if ((usr.mutations & HULK))
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

	attack_hand(mob/user as mob)
		if ((usr.mutations & HULK))
			usr << text("\blue You destroy the table.")
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << text("\red [usr] destroys the table.")
			src.density = 0
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

	MouseDrop_T(obj/O as obj, mob/user as mob)
		if(isrobot(user))
			return
		if ((!( istype(O, /obj/item/weapon) ) || user.equipped() != O))
			return
		user.drop_item()
		if (O.loc != src.loc)
			step(O, get_dir(O, src))
		return

	proc/check_victim()
		if(locate(/mob/living/carbon, src.loc))
			var/mob/M = locate(/mob/living/carbon, src.loc)
			if(M.resting)
				victim = M
				if(updatesicon)
					icon_state = "table2-active"
				return 1
		if(victim)
			victim.update_clothing()
		victim = null
		if(updatesicon)
			icon_state = "table2-idle"
		processing_objects.Remove(src)
		return 0

	process()
		check_victim()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(isrobot(user))
			return
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
				if(updatesicon)
					icon_state = "table2-active"
				src.victim = M
				M.update_clothing()
				processing_objects.Add(src)
				del(W)
				return
		user.drop_item()
		if(W && W.loc)
			W.loc = src.loc
		return

/obj/machinery/optable/portable
	name = "mobile operating table"
	desc = "Used for advanced medical procedures. Seems to be movable, neat."
	icon = 'rollerbed.dmi'
	icon_state = "up"
	density = 1
	anchored = 0
	id = null
	updatesicon = 0

	New()
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!anchored)
			return
		return ..()

	verb/make_deployable()
		set category = "Object"
		set name = "Deploy Table"
		set src in oview(1)

		if(anchored)
			if(victim)
				usr << "You can't do that with someone on the table!"
			else
				anchored = 0
				for(var/mob/M in orange(5,src))
					M.show_message("\blue [usr] releases the locks on the table's casters!")
				icon_state = "up"
		else
			anchored = 1
			for(var/mob/M in orange(5,src))
				M.show_message("\blue [usr] locks the table's casters in place!")
			icon_state = "down"