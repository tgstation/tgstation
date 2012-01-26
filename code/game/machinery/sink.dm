/obj/machinery/sink
	name = "sink"
	icon = 'device.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment
	var/mode = 0	//0 == fill, 1 == pour

	var/obj/machinery/water/binary/fixture/cxn

	New()
		..()
		reagents = new(100)
		reagents.my_atom = src
		spawn(2)
			cxn = locate(/obj/machinery/water/binary/fixture) in loc
			if(cxn)
				cxn.parent = src

		verbs += /obj/machinery/sink/proc/mode_pour

	attack_hand(mob/M as mob)
		if(busy)
			M << "\red Someone's already washing something here."
			return

		var/turf/location = M.loc
		if(!isturf(location)) return
		M << "\blue You start washing up."

		// collect water, at least 10u?
		var/amt_needed = 25 - reagents.total_volume
		if(!cxn || cxn.fill(amt_needed) < amt_needed)
			M << "\The [src] barely trickles. Cleaning up with \the [src] is impossible!"
			return

		busy = 1
		sleep(40)
		busy = 0

		// react, for if there's something not water
		reagents.reaction(M, TOUCH)

		// ok, this is just goop..
		if(reagents.get_reagent_amount("water") < 10)
			M << "\red This does not feel... very water-like..."
			return

		if(M.loc != location) return		//Person has moved away from the sink

		if(M.blood_DNA)
			reagents.add_reagent("blood", 10) // down the sink
		M.clean_blood()
		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			/*
			if(C.r_hand)
				C.r_hand.clean_blood()		// The hand you attack with is empty anyway, the other one should not be washed while doing this.
			if(C.l_hand)
				C.l_hand.clean_blood()

			if(C.wear_mask)
				C.wear_mask.clean_blood()  //- NOPE, Washing machine -Errorage
			*/
			if(istype(M, /mob/living/carbon/human))
				/*if(C:w_uniform)
					C:w_uniform.clean_blood()  //- NOPE, Washing machine -Errorage
				if(C:wear_suit)
					C:wear_suit.clean_blood()  //- NOPE, Washing machine -Errorage
				if(C:shoes)
					C:shoes.clean_blood()*/  //- NOPE, Washing machine -Errorage
				if(C:gloves)
					C:gloves.clean_blood()
				/*if(C:head)
					C:head.clean_blood()*/ //- NOPE, Washing machine -Errorage
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [M] washes up using \the [src]."))

		// empty sink
		cxn.drain(reagents.total_volume)

	proc/mode_pour()
		set name = "Toggle Mode -> Pour"
		set category = "Object"
		set src in oview(1)

		mode = 1
		verbs -= /obj/machinery/sink/proc/mode_pour
		verbs += /obj/machinery/sink/proc/mode_fill
		usr << "You will now pour reagents down \the [src]."

	proc/mode_fill()
		set name = "Toggle Mode -> Fill"
		set category = "Object"
		set src in oview(1)

		mode = 0
		verbs -= /obj/machinery/sink/proc/mode_fill
		verbs += /obj/machinery/sink/proc/mode_pour
		usr << "You will now fill your container from the faucet."

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(busy)
			user << "\red Someone's already washing something here."
			return

		// collect water, any water?
		var/amt_needed = 10 - reagents.total_volume
		if(!cxn || cxn.fill(amt_needed) == 0)
			user << "\The [src] barely trickles. Getting water from \the [src] is impossible!"
			return

		if (istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks))
			if(!mode)
				// fill
				if(O.reagents.total_volume < O.reagents.maximum_volume)
					reagents.trans_to(O, reagents.total_volume)
					user.visible_message( \
						"\blue [user] fills \the [O] using \the [src].", \
						"\blue You fill \the [O] using \the [src].")
				else
					user.visible_message( \
						"\blue [user] spills water out of \the overflowing [O] into \the [src].", \
						"\blue You spill water out of \the overflowing [O] into \the [src].")
			else
				// pour
				if(O.reagents.total_volume > 0)
					O.reagents.trans_to(src, O.reagents.total_volume)
					user.visible_message( \
						"\blue [user] pours the contents of \the [O] into \the [src].", \
						"\blue You pour the contents of \the [O] into \the [src].")
				else
					user << "\The [O] is empty."
			// empty sink
			cxn.drain(reagents.total_volume)
			return
		else if (istype(O, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = O
			if (B.charges > 0 && B.status == 1)
				flick("baton_active", src)
				user.Stun(10)
				user.stuttering = 10
				user.Weaken(10)
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.charges--
				user.visible_message( \
					"[user] was stunned by his wet [O].", \
					"\red You have wet \the [O], it shocks you!")

				// empty sink
				cxn.drain(reagents.total_volume)
				return

		var/turf/location = user.loc
		if(!isturf(location)) return

		var/obj/item/I = O
		if(!I || !istype(I,/obj/item)) return

		usr << "\blue You start washing up."

		busy = 1
		sleep(40)
		busy = 0

		reagents.reaction(O, TOUCH)

		if(user.loc != location) return				//User has moved
		if(!I) return 								//Item's been destroyed while washing
		if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

		if(O.blood_DNA)
			reagents.add_reagent("blood", 10) // down the sink
		O.clean_blood()
		user.visible_message( \
			"\blue [user] washes \a [I] using \the [src].", \
			"\blue You wash \a [I] using \the [src].")

		// empty sink
		cxn.drain(reagents.total_volume)

	shower
		name = "shower"
		desc = "This is dumb."

	kitchen
		name = "kitchen sink"
		icon_state = "sink_alt"

	kitchen2
		name = "kitchen sink"
		icon_state = "sink_alt2"
