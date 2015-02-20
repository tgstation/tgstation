/mob/living/silicon/robot/mommi/Login()

	..()
	/* Inherited
	regenerate_icons()
	show_laws(0)
	if(mind)
		ticker.mode.remove_revolutionary(mind)
	return
	*/
	if(keeper && !emagged)
		for(var/mob/living/living in mob_list)
			if(istype(living, /mob/living/silicon))
				continue
			static_overlays.Add(living.static_overlay)
			client.images.Add(living.static_overlay)
