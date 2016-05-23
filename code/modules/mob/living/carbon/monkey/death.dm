/mob/living/carbon/monkey/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, "gibbed-m")

/mob/living/carbon/monkey/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, "dust-m")

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		visible_message("<b>[src]</b> lets out a faint chimper as it collapses and stops moving...")	//ded -- Urist

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)