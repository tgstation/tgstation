/mob/living/carbon/slime/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "[colour] baby slime dead"

	if(!gibbed)
		if(istype(src, /mob/living/carbon/slime/adult))
			ghostize()
			explosion(loc, -1,-1,3,12)
			if(src)	del(src)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("<b>The [name]</b> seizes up and falls limp...", 1) //ded -- Urist

	update_canmove()
	if(blind)	blind.layer = 0

	ticker.mode.check_win()

	return ..(gibbed)