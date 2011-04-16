/obj/machinery/sink
	name = "sink"
	icon = 'device.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1


	attack_hand(mob/M as mob)
		M.clean_blood()
		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			C.clean_blood()
			if(C.r_hand)
				C.r_hand.clean_blood()
			if(C.l_hand)
				C.l_hand.clean_blood()
			if(C.wear_mask)
				C.wear_mask.clean_blood()
			if(istype(M, /mob/living/carbon/human))
				if(C:w_uniform)
					C:w_uniform.clean_blood()
				if(C:wear_suit)
					C:wear_suit.clean_blood()
				if(C:shoes)
					C:shoes.clean_blood()
				if(C:gloves)
					C:gloves.clean_blood()
				if(C:head)
					C:head.clean_blood()
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [M] washes up using \the [src]."))


	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (istype(O, /obj/item/weapon/baton))
			var/obj/item/weapon/baton/B = O
			if (B.charges > 0 && B.status == 1)
				flick("baton_active", src)
				user.stunned = 10
				user.stuttering = 10
				user.weakened = 10
				if(isrobot(user))
					var/mob/living/silicon/robot/R = user
					R.cell.charge -= 20
				else
					B.charges--
				user.visible_message( \
					"[user] was stunned by his wet [O].", \
					"\red You have wet \the [O], it shocks you!")
				return
		O.clean_blood()
		user.visible_message( \
			"\blue [user] washes \a [O] using \the [src].", \
			"\blue You wash \a [O] using \the [src].")

	shower
		name = "Shower"
		desc = "Plenty of hot water, owered by radiation! Nothing harmful could come from that right?"

	kitchen
		name = "Kitchen Sink"
		icon_state = "sink_alt"

	kitchen2
		name = "Kitchen Sink"
		icon_state = "sink_alt2"
