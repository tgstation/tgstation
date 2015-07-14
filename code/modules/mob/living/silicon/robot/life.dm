/mob/living/silicon/robot/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if (src.notransform)
		return

	clamp_values()
	..()

	if(!stat)
		use_power()

/mob/living/silicon/robot/proc/clamp_values()
	SetStunned(min(stunned, 30))
	SetParalysis(min(paralysis, 30))
	SetWeakened(min(weakened, 20))
	sleeping = 0
	adjustBruteLoss(0)
	adjustToxLoss(0)
	adjustOxyLoss(0)
	adjustFireLoss(0)

/mob/living/silicon/robot/proc/use_power()
	if(cell && cell.charge)
		if(cell.charge <= 100)
			uneq_all()
		var/amt = Clamp((lamp_intensity - 2) * 2,1,cell.charge) //Always try to use at least one charge per tick, but allow it to completely drain the cell.
		cell.use(amt) //Usage table: 1/tick if off/lowest setting, 4 = 4/tick, 6 = 8/tick, 8 = 12/tick, 10 = 16/tick
	else
		uneq_all()
		stat = UNCONSCIOUS
		update_headlamp()


/mob/living/silicon/robot/handle_regular_status_updates()
	if(camera && !scrambledcodes)
		if(stat == DEAD || wires.IsCameraCut())
			camera.status = 0
		else
			camera.status = 1

	if (..()) //Alive.

		if(health <= config.health_threshold_dead) //die only once
			death()
			return

		if(health < 50) //Gradual break down of modules as more damage is sustained
			if(uneq_module(module_state_3))
				src << "<span class='warning'>SYSTEM ERROR: Module 3 OFFLINE.</span>"
			if(health < 0)
				if(uneq_module(module_state_2))
					src << "<span class='warning'>SYSTEM ERROR: Module 2 OFFLINE.</span>"
				if(health < -50)
					if(uneq_module(module_state_1))
						src << "<span class='warning'>CRITICAL ERROR: All modules OFFLINE.</span>"

		if(getOxyLoss() > 50)
			Paralyse(3)

		if (paralysis || stunned || weakened) //Stunned etc.
			stat = UNCONSCIOUS
			update_headlamp()

		return 1

/mob/living/silicon/robot/handle_status_effects()
	..()
	if (stuttering)
		stuttering = max(0, stuttering - 1)

	if (druggy)
		druggy = max(0, druggy - 1)

/mob/living/silicon/robot/handle_regular_hud_updates()

	if(!client)
		return

	if (syndicate)
		if(ticker.mode.name == "traitor")
			for(var/datum/mind/tra in ticker.mode.traitors)
				if(tra.current)
					var/I = image('icons/mob/mob.dmi', loc = tra.current, icon_state = "traitor") //no traitor sprite in that dmi!
					src.client.images += I
		if(connected_ai)
			connected_ai.connected_robots -= src
			connected_ai = null
		if(mind)
			if(!mind.special_role)
				mind.special_role = "traitor"
				ticker.mode.traitors += mind
	..()
	return 1

/mob/living/silicon/robot/update_sight()

	if (stat == DEAD || src.sight_mode & BORGXRAY)
		src.sight |= SEE_TURFS
		src.sight |= SEE_MOBS
		src.sight |= SEE_OBJS
		src.see_in_dark = 8
		src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		src.see_in_dark = 8
		if (src.sight_mode & BORGMESON && src.sight_mode & BORGTHERM)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.see_invisible = SEE_INVISIBLE_MINIMUM
		else if (src.sight_mode & BORGMESON)
			src.sight |= SEE_TURFS
			src.see_invisible = SEE_INVISIBLE_MINIMUM
			src.see_in_dark = 1
		else if (src.sight_mode & BORGTHERM)
			src.sight |= SEE_MOBS
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		else if (src.stat != DEAD)
			src.sight &= ~SEE_MOBS
			src.sight &= ~SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(see_override)
			see_invisible = see_override

/mob/living/silicon/robot/handle_hud_icons()
	update_items()
	update_cell()
	..()

/mob/living/silicon/robot/handle_hud_icons_health()
	if (healths)
		if (stat != DEAD)
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

/mob/living/silicon/robot/proc/update_cell()
	if (cell)
		var/cellcharge = src.cell.charge/src.cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				clear_alert("charge")
			if(0.5 to 0.75)
				throw_alert("charge","lowcell",1)
			if(0.25 to 0.5)
				throw_alert("charge","lowcell",2)
			if(0.01 to 0.25)
				throw_alert("charge","lowcell",3)
			else
				throw_alert("charge","emptycell")
	else
		throw_alert("charge","nocell")

/mob/living/silicon/robot/proc/update_items()
	if (client)
		client.screen -= contents
		for(var/obj/I in contents)
			if(I && !(istype(I,/obj/item/weapon/stock_parts/cell) || istype(I,/obj/item/device/radio)  || istype(I,/obj/machinery/camera) || istype(I,/obj/item/device/mmi)))
				client.screen += I
	if(module_state_1)
		module_state_1:screen_loc = ui_inv1
	if(module_state_2)
		module_state_2:screen_loc = ui_inv2
	if(module_state_3)
		module_state_3:screen_loc = ui_inv3


//Robots on fire
/mob/living/silicon/robot/handle_fire()
	if(..())
		return
	if(fire_stacks > 0)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()

	//adjustFireLoss(3)
	return

/mob/living/silicon/robot/update_fire()
	overlays -= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")
	if(on_fire)
		overlays += image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing")

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()

/mob/living/silicon/robot/update_canmove()
	if(paralysis || stunned || weakened || buckled || lockcharge)
		canmove = 0
	else
		canmove = 1
	return canmove
