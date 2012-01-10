/mob/living/carbon/monkey/death(gibbed)
	if(src.stat == 2)
		return

	if (src.healths)
		src.healths.icon_state = "health5"
	if(!gibbed)
		for(var/mob/O in viewers(src, null))
			O.show_message("<b>The [src.name]</b> lets out a faint chimper as it collapses and stops moving...", 1) //ded -- Urist

	src.stat = 2
	src.canmove = 0
	if (src.blind)
		src.blind.layer = 0
	src.lying = 1

	var/h = src.hand
	src.hand = 0
	drop_item()
	src.hand = 1
	drop_item()
	src.hand = h

	ticker.mode.check_win()

	if (src.key)
		spawn(50)
			if(src.key && src.stat == 2)
				src.verbs += /mob/proc/ghost

	return ..(gibbed)