/datum/hud/var/obj/screen/staminas/staminas

/obj/screen/staminas
	icon = 'hippiestation/icons/mob/screen_gen.dmi'
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina
	mouse_opacity = 0

/mob/living/carbon/human/proc/staminahudamount()
	if(stat == DEAD || stunned || weakened)
		return "stamina6"
	else
		switch(hal_screwyhud)
			if(1 to 2)
				return "stamina6"
			if(5)
				return "stamina0"
			else
				switch(health - staminaloss)
					if(100 to INFINITY)
						return "stamina0"
					if(80 to 100)
						return "stamina1"
					if(60 to 80)
						return "stamina2"
					if(40 to 60)
						return "stamina3"
					if(20 to 40)
						return "stamina4"
					if(0 to 20)
						return "stamina5"
					else
						return "stamina6"