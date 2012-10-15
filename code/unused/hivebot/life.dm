/mob/living/silicon/hivebot/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return

	if (src.stat != 2)
		use_power()

	src.blinded = null

	clamp_values()

	handle_regular_status_updates()

	if(client)
		src.shell = 0
		handle_regular_hud_updates()
		update_items()
		if(dependent)
			mainframe_check()

	update_canmove()


/mob/living/silicon/hivebot
	proc
		clamp_values()

			stunned = max(min(stunned, 10),0)
			paralysis = max(min(paralysis, 1), 0)
			weakened = max(min(weakened, 15), 0)
			sleeping = max(min(sleeping, 1), 0)
			setToxLoss(0)
			setOxyLoss(0)

		use_power()

			if (src.energy)
				if(src.energy <= 0)
					death()

				else if (src.energy <= 10)
					src.module_active = null
					src.module_state_1 = null
					src.module_state_2 = null
					src.module_state_3 = null
					src.energy -=1
				else
					if(src.module_state_1)
						src.energy -=1
					if(src.module_state_2)
						src.energy -=1
					if(src.module_state_3)
						src.energy -=1
					src.energy -=1
					src.blinded = 0
					src.stat = 0
			else
				src.blinded = 1
				src.stat = 1

		update_canmove()
			if(paralysis || stunned || weakened || buckled) canmove = 0
			else canmove = 1


		handle_regular_status_updates()

			health = src.health_max - (getFireLoss() + getBruteLoss())

			if(health <= 0)
				death()

			if (src.stat != 2) //Alive.

				if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
					if (src.stunned > 0)
						src.stunned--
						src.stat = 0
					if (src.weakened > 0)
						src.weakened--
						src.lying = 0
						src.stat = 0
					if (src.paralysis > 0)
						src.paralysis--
						src.blinded = 0
						src.lying = 0
						src.stat = 1

				else	//Not stunned.
					src.lying = 0
					src.stat = 0

			else //Dead.
				src.blinded = 1
				src.stat = 2

			src.density = !( src.lying )

			if ((src.sdisabilities & 1))
				src.blinded = 1
			if ((src.sdisabilities & 4))
				src.ear_deaf = 1

			if (src.eye_blurry > 0)
				src.eye_blurry--
				src.eye_blurry = max(0, src.eye_blurry)

			if (src.druggy > 0)
				src.druggy--
				src.druggy = max(0, src.druggy)

			return 1

		handle_regular_hud_updates()

			if (src.stat == 2 || XRAY in src.mutations)
				src.sight |= SEE_TURFS
				src.sight |= SEE_MOBS
				src.sight |= SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
			else if (src.stat != 2)
				src.sight &= ~SEE_MOBS
				src.sight &= ~SEE_TURFS
				src.sight &= ~SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if (src.healths)
				if (src.stat != 2)
					switch(health)
						if(health_max to INFINITY)
							src.healths.icon_state = "health0"
						if(src.health_max*0.80 to src.health_max)
							src.healths.icon_state = "health1"
						if(src.health_max*0.60 to src.health_max*0.80)
							src.healths.icon_state = "health2"
						if(src.health_max*0.40 to src.health_max*0.60)
							src.healths.icon_state = "health3"
						if(src.health_max*0.20 to src.health_max*0.40)
							src.healths.icon_state = "health4"
						if(0 to health_max*0.20)
							src.healths.icon_state = "health5"
						else
							src.healths.icon_state = "health6"
				else
					src.healths.icon_state = "health7"

			if (src.cells)
				switch(src.energy)
					if(src.energy_max*0.75 to INFINITY)
						src.cells.icon_state = "charge4"
					if(0.5*src.energy_max to 0.75*src.energy_max)
						src.cells.icon_state = "charge3"
					if(0.25*src.energy_max to 0.5*src.energy_max)
						src.cells.icon_state = "charge2"
					if(0 to 0.25*src.energy_max)
						src.cells.icon_state = "charge1"
					else
						src.cells.icon_state = "charge0"

			switch(src.bodytemperature) //310.055 optimal body temp

				if(335 to INFINITY)
					src.bodytemp.icon_state = "temp2"
				if(320 to 335)
					src.bodytemp.icon_state = "temp1"
				if(300 to 320)
					src.bodytemp.icon_state = "temp0"
				if(260 to 300)
					src.bodytemp.icon_state = "temp-1"
				else
					src.bodytemp.icon_state = "temp-2"


			if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"

			src.client.screen -= src.hud_used.blurry
			src.client.screen -= src.hud_used.druggy
			src.client.screen -= src.hud_used.vimpaired

			if ((src.blind && src.stat != 2))
				if ((src.blinded))
					src.blind.layer = 18
				else
					src.blind.layer = 0

					if (src.disabilities & 1)
						src.client.screen += src.hud_used.vimpaired

					if (src.eye_blurry)
						src.client.screen += src.hud_used.blurry

					if (src.druggy)
						src.client.screen += src.hud_used.druggy

			if (src.stat != 2)
				if (src.machine)
					if (!( src.machine.check_eye(src) ))
						src.reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1


		update_items()
			if (src.client)
				src.client.screen -= src.contents
				src.client.screen += src.contents
			if(src.module_state_1)
				src.module_state_1:screen_loc = ui_inv1
			if(src.module_state_2)
				src.module_state_2:screen_loc = ui_inv2
			if(src.module_state_3)
				src.module_state_3:screen_loc = ui_inv3

		mainframe_check()
			if(mainframe)
				if(mainframe.stat == 2)
					mainframe.return_to(src)
			else
				death()