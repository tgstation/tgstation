/mob/living/carbon/monkey/gib_animation(var/animate)
	..(animate, "gibbed-m")

/mob/living/carbon/monkey/dust_animation(var/animate)
	..(animate, "dust-m")

/mob/living/carbon/monkey/dust(var/animation = 1)
	..()

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health5"
	stat = DEAD

	if(!gibbed)
		visible_message("<b>[src]</b> lets out a faint chimper as it collapses and stops moving...")	//ded -- Urist

	update_canmove()
	if(blind)	blind.layer = 0

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)