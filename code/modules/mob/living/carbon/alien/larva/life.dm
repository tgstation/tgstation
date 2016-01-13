//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (notransform)
		return
	if(..())
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

	//some kind of bug in canmove() isn't properly calling update_icons, so this is here as a placeholder
	update_icons()

/mob/living/carbon/alien/larva/handle_hud_icons_health()

	if (healths)
		if (stat != 2)
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(20 to 25)
					healths.icon_state = "health1"
				if(15 to 20)
					healths.icon_state = "health2"
				if(10 to 15)
					healths.icon_state = "health3"
				if(5 to 10)
					healths.icon_state = "health4"
				if(0 to 5)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"


/mob/living/carbon/alien/larva/handle_regular_status_updates()

	if(..()) //alive

		if(health <= -maxHealth)
			death()
			return

		return 1