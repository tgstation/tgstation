/mob/living/carbon/monkey/gib_animation(animate)
	..(animate, "gibbed-m")

/mob/living/carbon/monkey/dust_animation(animate)
	..(animate, "dust-m")

/mob/living/carbon/monkey/dust(var/animation = 1)
	..()

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		visible_message("<b>[src]</b> lets out a faint chimper as it collapses and stops moving...")	//ded -- Urist

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)