/datum/hud/var/obj/screen/staminas/staminas
/datum/hud/var/obj/screen/staminabuffer/staminabuffer

/obj/screen/staminas
	icon = 'modular_citadel/icons/ui/screen_gen.dmi'
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina
	mouse_opacity = 0

/mob/living/carbon/human/proc/staminahudamount()
	if(stat == DEAD || recoveringstam)
		return "staminacrit"
	else
		switch(hal_screwyhud)
			if(1 to 2)
				return "staminacrit"
			if(5)
				return "stamina0"
			else
				switch(100 - getStaminaLoss())
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

//stam buffer
/obj/screen/staminabuffer
	icon = 'modular_citadel/icons/ui/screen_gen.dmi'
	name = "stamina buffer"
	icon_state = "stambuffer0"
	screen_loc = ui_stamina
	layer = ABOVE_HUD_LAYER + 0.1
	mouse_opacity = 0

/mob/living/carbon/human/proc/staminabufferhudamount()
	if(stat == DEAD || recoveringstam)
		return "stambuffer7"
	else
		switch(hal_screwyhud)
			if(1 to 2)
				return "stambuffer7"
			if(5)
				return "stambuffer0"
			else
				var/percentmult = 100/stambuffer
				switch(stambuffer*percentmult - bufferedstam*percentmult)
					if(95 to INFINITY)
						return "stambuffer0"
					if(90 to 95)
						return "stambuffer1"
					if(80 to 90)
						return "stambuffer2"
					if(60 to 80)
						return "stambuffer3"
					if(40 to 60)
						return "stambuffer4"
					if(20 to 40)
						return "stambuffer5"
					if(5 to 20)
						return "stambuffer6"
					else
						return "stambuffer7"
