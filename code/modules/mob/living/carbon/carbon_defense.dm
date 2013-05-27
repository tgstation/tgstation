/mob/living/carbon/hitby(atom/movable/AM)
	if(in_throw_mode && !get_active_hand())	//empty active hand and we're in throw mode
		if(istype(AM, /obj/item))
			var/obj/item/I = AM
			put_in_active_hand(I)
			visible_message("<span class='warning'>[src] catches [I]!</span>")
			throw_mode_off()
			return
	..()