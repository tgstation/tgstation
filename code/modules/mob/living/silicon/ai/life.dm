/mob/living/silicon/ai/Life()
	if (src.stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes
		var/turf/T = get_turf(src)

		if (src.stat!= CONSCIOUS)
			src.cameraFollow = null
			src.reset_view(null)
			src.unset_machine()

		src.updatehealth()

		update_gravity(mob_has_gravity())

		if (src.malfhack)
			if (src.malfhack.aidisabled)
				src << "<span class='danger'>ERROR: APC access disabled, hack attempt canceled.</span>"
				src.malfhacking = 0
				src.malfhack = null


		if (src.health <= config.health_threshold_dead)
			death()
			return

		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)

		// Handle power damage (oxy)
		if(src.aiRestorePowerRoutine != 0)
			// Lost power
			adjustOxyLoss(1)
		else
			// Gain Power
			adjustOxyLoss(-1)

		//stage = 1
		//if (istype(src, /mob/living/silicon/ai)) // Are we not sure what we are?
		var/blindness = 0
		//stage = 2
		var/area/loc = null
		if (istype(T, /turf))
			//stage = 3
			loc = T.loc
			if (istype(loc, /area))
				//stage = 4
				if (!loc.master.power_equip && !istype(src.loc,/obj/item))
					//stage = 5
					blindness = 1

		if (!blindness)
			//stage = 4.5
			if (src.blind.layer != 0)
				src.blind.layer = 0
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
			if(see_override)
				see_invisible = see_override

			var/area/home = get_area(src)
			if(!home)	return//something to do with malf fucking things up I guess. <-- aisat is gone. is this still necessary? ~Carn
			if(home.powered(EQUIP))
				home.use_power(1000, EQUIP)

			if (src:aiRestorePowerRoutine==2)
				src << "Alert cancelled. Power has been restored without our assistance."
				src:aiRestorePowerRoutine = 0
				src.blind.layer = 0
				return
			else if (src:aiRestorePowerRoutine==3)
				src << "Alert cancelled. Power has been restored."
				src:aiRestorePowerRoutine = 0
				src.blind.layer = 0
				return
		else

			//stage = 6
			src.blind.screen_loc = "1,1 to 15,15"
			if (src.blind.layer!=18)
				src.blind.layer = 18
			src.sight = src.sight&~SEE_TURFS
			src.sight = src.sight&~SEE_MOBS
			src.sight = src.sight&~SEE_OBJS
			src.see_in_dark = 0
			src.see_invisible = SEE_INVISIBLE_LIVING

			if (((!loc.master.power_equip) || istype(T, /turf/space)) && !istype(src.loc,/obj/item))
				if (src:aiRestorePowerRoutine==0)
					src:aiRestorePowerRoutine = 1

					src << "You've lost power!"
//							world << "DEBUG CODE TIME! [loc] is the area the AI is sucking power from"
					//if (!is_special_character(src))
						//src.set_zeroth_law("")
					//src.clear_supplied_laws() // Don't reset our laws.
					//var/time = time2text(world.realtime,"hh:mm:ss")
					//lawchanges.Add("[time] <b>:</b> [src.name]'s noncore laws have been reset due to power failure")
					spawn(20)
						src << "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."
						sleep(50)
						if (loc.master.power_equip)
							if (!istype(T, /turf/space))
								src << "Alert cancelled. Power has been restored without our assistance."
								src.aiRestorePowerRoutine = 0
								src.blind.layer = 0
								return
						src << "Fault confirmed: missing external power. Shutting down main control system to save power."
						sleep(20)
						src << "Emergency control system online. Verifying connection to power network."
						sleep(50)
						if (istype(T, /turf/space))
							src << "Unable to verify! No power connection detected!"
							src:aiRestorePowerRoutine = 2
							return
						src << "Connection verified. Searching for APC in power network."
						sleep(50)
						var/obj/machinery/power/apc/theAPC = null
/*
						for (var/something in loc)
							if (istype(something, /obj/machinery/power/apc))
								if (!(something:stat & BROKEN))
									theAPC = something
									break
*/
						var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
						for (PRP=1, PRP<=4, PRP++)
							var/area/AIarea = get_area(src)
							for(var/area/A in AIarea.master.related)
								for (var/obj/machinery/power/apc/APC in A)
									if (!(APC.stat & BROKEN))
										theAPC = APC
										break
							if (!theAPC)
								switch(PRP)
									if (1) src << "Unable to locate APC!"
									else src << "Lost connection with the APC!"
								src:aiRestorePowerRoutine = 2
								return
							if (loc.master.power_equip)
								if (!istype(T, /turf/space))
									src << "Alert cancelled. Power has been restored without our assistance."
									src:aiRestorePowerRoutine = 0
									src.blind.layer = 0 //This, too, is a fix to issue 603
									return
							switch(PRP)
								if (1) src << "APC located. Optimizing route to APC to avoid needless power waste."
								if (2) src << "Best route identified. Hacking offline APC power port."
								if (3) src << "Power port upload access confirmed. Loading control program into APC power port software."
								if (4)
									src << "Transfer complete. Forcing APC to execute program."
									sleep(50)
									src << "Receiving control information from APC."
									sleep(2)
									//bring up APC dialog
									apc_override = 1
									theAPC.attack_ai(src)
									apc_override = 0
									src:aiRestorePowerRoutine = 3
									src << "Here are your current laws:"
									src.show_laws()
							sleep(50)
							theAPC = null

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss()
	if(!fire_res_on_core)
		health -= getFireLoss()
