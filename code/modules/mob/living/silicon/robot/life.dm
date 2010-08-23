/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = 1

	if (src.monkeyizing)
		return


	src.blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_items()
	if (src.stat != 2) //still using power
		use_power()
		process_killswitch()
		process_locks()
	update_canmove()



/mob/living/silicon/robot
	proc
		clamp_values()

			stunned = max(min(stunned, 30),0)
			paralysis = max(min(paralysis, 30), 0)
			weakened = max(min(weakened, 20), 0)
			sleeping = max(min(sleeping, 5), 0)
			bruteloss = max(bruteloss, 0)
			toxloss = max(toxloss, 0)
			oxyloss = max(oxyloss, 0)
			fireloss = max(fireloss, 0)

		use_power()

			if (src.cell)
				if(src.cell.charge <= 0)
					src.stat = 1
				else if (src.cell.charge <= 100)
					src.module_active = null
					src.module_state_1 = null
					src.module_state_2 = null
					src.module_state_3 = null
					src.cell.use(1)
				else
					if(src.module_state_1)
						src.cell.use(5)
					if(src.module_state_2)
						src.cell.use(5)
					if(src.module_state_3)
						src.cell.use(5)
					src.cell.use(1)
					src.blinded = 0
					src.stat = 0
			else
				src.stat = 1

		update_canmove()
			if(paralysis || stunned || weakened || buckled) canmove = 0
			else canmove = 1


		handle_regular_status_updates()

			//Stop AI using us as a camera
			if(src.stat)
				src.camera.status = 0.0

			health = 300 - (oxyloss + fireloss + bruteloss)

			if(oxyloss > 50) paralysis = max(paralysis, 3)

			if(src.sleeping)
				src.paralysis = max(src.paralysis, 3)
				src.sleeping--

			if(src.resting)
				src.weakened = max(src.weakened, 5)

			if(health < 0)
				death()

			if (src.stat != 2) //Alive.

				if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
					src.stat = 1
					if (src.stunned > 0)
						src.stunned--
					if (src.weakened > 0)
						src.weakened--
					if (src.paralysis > 0)
						src.paralysis--
						src.blinded = 1
					else
						src.blinded = 0

				else	//Not stunned.
					src.stat = 0

			else //Dead.
				src.blinded = 1
				src.stat = 2

			if (src.stuttering) src.stuttering--

			if (src.eye_blind)
				src.eye_blind--
				src.blinded = 1

			if (src.ear_deaf > 0) src.ear_deaf--
			if (src.ear_damage < 25)
				src.ear_damage -= 0.05
				src.ear_damage = max(src.ear_damage, 0)

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

			if (src.stat == 2 || src.mutations & 4)
				src.sight |= SEE_TURFS
				src.sight |= SEE_MOBS
				src.sight |= SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = 2
			else if (src.stat != 2)
				src.sight &= ~SEE_MOBS
				src.sight &= ~SEE_TURFS
				src.sight &= ~SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = 2

			if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
			if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

			if (src.healths)
				if (src.stat != 2)
					switch(health)
						if(300 to INFINITY)
							src.healths.icon_state = "health0"
						if(250 to 300)
							src.healths.icon_state = "health1"
						if(200 to 250)
							src.healths.icon_state = "health2"
						if(150 to 200)
							src.healths.icon_state = "health3"
						if(100 to 150)
							src.healths.icon_state = "health4"
						if(0 to 100)
							src.healths.icon_state = "health5"
						else
							src.healths.icon_state = "health6"
				else
					src.healths.icon_state = "health7"

			if (src.syndicate && src.client)
				if(ticker.mode.name == "traitor")
					for(var/datum/mind/tra in ticker.mode.traitors)
						if(tra.current)
							var/I = image('mob.dmi', loc = tra.current, icon_state = "traitor")
							src.client.images += I
				if(src.connected_ai)
					src.connected_ai.connected_robots -= src
					src.connected_ai = null
				if(src.mind)
					if(!src.mind.special_role)
						src.mind.special_role = "traitor"
						ticker.mode.traitors += src.mind


			if (src.cells)
				if (src.cell)
					switch(src.cell.charge)
						if(src.cell.maxcharge*0.75 to INFINITY)
							src.cells.icon_state = "charge4"
						if(0.5*src.cell.maxcharge to 0.75*src.cell.maxcharge)
							src.cells.icon_state = "charge3"
						if(0.25*src.cell.maxcharge to 0.5*src.cell.maxcharge)
							src.cells.icon_state = "charge2"
						if(0 to 0.25*src.cell.maxcharge)
							src.cells.icon_state = "charge1"
						else
							src.cells.icon_state = "charge0"
				else
					src.cells.icon_state = "charge-empty"

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
//Oxygen and fire does nothing yet!!
//			if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
//			if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"

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


		process_killswitch()
			if(killswitch)
				killswitch_time --
				if(killswitch_time <= 0)
					if(src.client)
						src << "\red <B>Killswitch Activated"
					killswitch = 0
					spawn(5)
						gib(src)

		process_locks()
			if(weapon_lock)
				src.module_state_1 = null
				src.module_state_2 = null
				src.module_state_3 = null
				weaponlock_time --
				if(weaponlock_time <= 0)
					if(src.client)
						src << "\red <B>Weapon Lock Timed Out!"
					weapon_lock = 0
					weaponlock_time = 120
