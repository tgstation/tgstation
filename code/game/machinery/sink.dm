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
		O.clean_blood()
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\blue [user] washes \a [O] using \the [src]."))