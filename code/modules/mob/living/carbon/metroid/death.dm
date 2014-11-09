/mob/living/carbon/slime/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "[colour] baby slime dead"

	if(!gibbed)
		if(istype(src, /mob/living/carbon/slime/adult))
			//ghostize() - Messes up making momma slime a baby
			var/mob/living/carbon/slime/M1 = new primarytype(loc)
			M1.universal_speak = universal_speak
			if(src.mind)
				src.mind.transfer_to(M1)
			else
				M1.key = src.key
				M1.rabid()
			var/mob/living/carbon/slime/M2 = new primarytype(loc)
			M2.rabid()
			if(src)	del(src)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<b>The [name]</b> seizes up and falls limp...", 1) //ded -- Urist

	update_canmove()
	if(blind)
		blind.layer = 0

	ticker.mode.check_win()

	return ..(gibbed)