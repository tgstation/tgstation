/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = 1

	if(monkeyizing)
		return

	blinded = null

	//Status updates, death etc.
	clamp_values()
	handle_regular_status_updates()

	if(client)
		handle_regular_hud_updates()
		update_items()

	if(stat != DEAD)
		process_killswitch()
		if(!resting)
			use_power()

	update_canmove()


/mob/living/silicon/robot/proc/clamp_values()
	SetParalysis(min(paralysis, 30))
	adjustBruteLoss(0)	//WHY
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)


/mob/living/silicon/robot/proc/use_power()
	if(cell)
		if(cell.charge <= 0)
			uneq_all()
			stat = UNCONSCIOUS
		else if(cell.charge <= 100)
			uneq_all()
			cell.use(1)
		else
			if(module_state_1)
				cell.use(5)
			if(module_state_2)
				cell.use(5)
			if(module_state_3)
				cell.use(5)
			cell.use(1)
			blinded = 0
			stat = CONSCIOUS
	else
		uneq_all()
		stat = UNCONSCIOUS


/mob/living/silicon/robot/proc/handle_regular_status_updates()
	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	health = maxHealth - (getOxyLoss() + getFireLoss() + getBruteLoss())

	if(getOxyLoss() > 50)
		Paralyse(3)

	if(health <= config.health_threshold_dead && stat != DEAD) //die only once
		death()

	if(stat != DEAD)	//Alive.
		if(health < 50)	//Gradual break down of modules as more damage is sustained
			if(uneq_module(module_state_3))
				src << "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>"
			if(health < 0)
				if(uneq_module(module_state_2))
					src << "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>"
				if(health < -50)
					if(uneq_module(module_state_1))
						src << "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>"

		if(paralysis || stunned || weakened)	//Stunned etc.
			stat = 1
			if(stunned > 0)
				AdjustStunned(-1)
			if(weakened > 0)
				AdjustWeakened(-1)
			if(paralysis > 0)
				AdjustParalysis(-1)
				blinded = 1
			else
				blinded = 0

		else	//Not stunned.
			stat = 0

	else	//Dead.
		blinded = 1
		stat = DEAD

	if(stuttering)
		stuttering--

	if(eye_blind)
		eye_blind--
		blinded = 1

	if(ear_deaf > 0)
		ear_deaf--
	if(ear_damage < 25)
		ear_damage -= 0.05
		ear_damage = max(ear_damage, 0)

	if(sdisabilities & BLIND)
		blinded = 1
	if(sdisabilities & DEAF)
		ear_deaf = 1

	if(eye_blurry > 0)
		eye_blurry--
		eye_blurry = max(0, eye_blurry)

	if(druggy > 0)
		druggy--
		druggy = max(0, druggy)

	return 1


/mob/living/silicon/robot/proc/handle_regular_hud_updates()
	if(stat == DEAD || XRAY in mutations || sight_mode & BORGXRAY)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if(sight_mode & BORGMESON && sight_mode & BORGTHERM)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if(sight_mode & BORGMESON)
		sight |= SEE_TURFS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_MINIMUM
	else if(sight_mode & BORGTHERM)
		sight |= SEE_MOBS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if(stat != 2)
		sight &= ~SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO

	for(var/image/hud in client.images)
		if(copytext(hud.icon_state,1,4) == "hud")	//ugly, but icon comparison is worse, I believe
			client.images.Remove(hud)

	var/obj/item/borg/sight/hud/hud = locate(/obj/item/borg/sight/hud) in src
	if(hud && hud.hud)
		hud.hud.process_hud(src)

	if(healths)
		if(stat != DEAD)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(50 to 100)
					healths.icon_state = "health2"
				if(0 to 50)
					healths.icon_state = "health3"
				if(-50 to 0)
					healths.icon_state = "health4"
				if(config.health_threshold_dead to -50)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(syndicate && client)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor")
					client.images += I
		if(connected_ai)
			connected_ai.connected_robots -= src
			connected_ai = null
		if(mind)
			if(!mind.special_role)
				mind.special_role = "traitor"
				ticker.mode.traitors += mind

	if(cells)
		if(cell)
			var/cellcharge = cell.charge/cell.maxcharge
			switch(cellcharge)
				if(0.75 to INFINITY)
					cells.icon_state = "charge4"
				if(0.5 to 0.75)
					cells.icon_state = "charge3"
				if(0.25 to 0.5)
					cells.icon_state = "charge2"
				if(0 to 0.25)
					cells.icon_state = "charge1"
				else
					cells.icon_state = "charge0"
		else
			cells.icon_state = "charge-empty"

	if(bodytemp)
		switch(bodytemperature) //310.055 optimal body temp
			if(335 to INFINITY)
				bodytemp.icon_state = "temp2"
			if(320 to 335)
				bodytemp.icon_state = "temp1"
			if(300 to 320)
				bodytemp.icon_state = "temp0"
			if(260 to 300)
				bodytemp.icon_state = "temp-1"
			else
				bodytemp.icon_state = "temp-2"

		if(pullin)
			if(pulling)
				pullin.icon_state = "pull"
			else
				pullin.icon_state = "pull0"

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired)

	if(blind && stat != DEAD)
		if(blinded || resting)
			blind.layer = 18
		else
			blind.layer = 0
			if(disabilities & NEARSIGHTED)
				client.screen += global_hud.vimpaired

			if(eye_blurry)
				client.screen += global_hud.blurry

			if(druggy)
				client.screen += global_hud.druggy

	if(stat != DEAD)
		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	return 1


/mob/living/silicon/robot/proc/update_items()
	if(client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I,/obj/item/weapon/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3


/mob/living/silicon/robot/proc/process_killswitch()
	if(killswitch)
		killswitch_time --
		if(killswitch_time <= 0)
			src << "<span class='userdanger'>Killswitch activated.</span>"
			killswitch = 0
			spawn(5)
				gib()


/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || weakened || buckled || lockcharge || resting)
		canmove = 0
	else
		canmove = 1
	return canmove