/obj/machinery/sink
	name = "sink"
	icon = 'device.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment


	attack_hand(mob/M as mob)
		if(isrobot(M) || isAI(M))
			return

		if(busy)
			M << "\red Someone's already washing something here."
			return

		var/turf/location = M.loc
		if(!isturf(location)) return
		usr << "\blue You start washing up."

		busy = 1
		sleep(40)
		busy = 0

		if(M.loc != location) return		//Person has moved away from the sink

		M.clean_blood()
		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			C.clean_blood()
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


	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(busy)
			user << "\red Someone's already washing something here."
			return

		if (istype(O, /obj/item/weapon/reagent_containers/glass/bucket))
			O:reagents.add_reagent("water", 70)
			user.visible_message( \
				"\blue [user] fills the [O] using the [src].", \
				"\blue You fill the [O] using the [src].")
			return

		if (istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/food/drinks))
			O:reagents.add_reagent("water", 10)
			user.visible_message( \
				"\blue [user] fills the [O] using the [src].", \
				"\blue You fill the [O] using the [src].")
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
				return

		var/turf/location = user.loc
		if(!isturf(location)) return

		var/obj/item/I = O
		if(!I || !istype(I,/obj/item)) return

		usr << "\blue You start washing up."

		busy = 1
		sleep(40)
		busy = 0

		if(user.loc != location) return				//User has moved
		if(!I) return 								//Item's been destroyed while washing
		if(user.get_active_hand() != I) return		//Person has switched hands or the item in their hands

		O.clean_blood()
		user.visible_message( \
			"\blue [user] washes \a [I] using \the [src].", \
			"\blue You wash \a [I] using \the [src].")

	shower
		name = "Shower"
		desc = "This is dumb."

	kitchen
		name = "Kitchen Sink"
		icon_state = "sink_alt"

	kitchen2
		name = "Kitchen Sink"
		icon_state = "sink_alt2"
