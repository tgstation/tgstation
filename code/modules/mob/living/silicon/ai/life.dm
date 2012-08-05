/mob/living/silicon/ai/Life()
	if (src.stat == 2)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes
		var/turf/T = get_turf(src)

		if (src.stat!=0)
			src:cameraFollow = null
			src:current = null
			src:machine = null

		src.updatehealth()

		src.update_mind()

		if(aiPDA && aiPDA.name != name)
			aiPDA.owner = name
			aiPDA.name = name + " (" + aiPDA.ownjob + ")"

		if (src.malfhack)
			if (src.malfhack.aidisabled)
				src << "\red ERROR: APC access disabled, hack attempt canceled."
				src.malfhacking = 0
				src.malfhack = null
			else



		if (src.health <= config.health_threshold_dead)
			death()
			return

		if (src.machine)
			if (!( src.machine.check_eye(src) ))
				src.reset_view(null)

		//var/stage = 0
		if (src.client)
			//stage = 1
			if (istype(src, /mob/living/silicon/ai))
				var/blind = 0
				//stage = 2
				var/area/loc = null
				if (istype(T, /turf))
					//stage = 3
					loc = T.loc
					if (istype(loc, /area))
						//stage = 4
						if (!loc.master.power_equip && !istype(src.loc,/obj/item))
							//stage = 5
							blind = 1

				if (!blind)	//lol? if(!blind)	#if(src.blind.layer)    <--something here is clearly wrong :P
							//I'll get back to this when I find out  how this is -supposed- to work ~Carn //removed this shit since it was confusing as all hell --39kk9t
					//stage = 4.5
					src.sight |= SEE_TURFS
					src.sight |= SEE_MOBS
					src.sight |= SEE_OBJS
					src.see_in_dark = 8
					src.see_invisible = SEE_INVISIBLE_LEVEL_TWO

					var/area/home = get_area(src)
					if(!home)	return//something to do with malf fucking things up I guess. <-- aisat is gone. is this still necessary? ~Carn
					if(home.powered(EQUIP))
						home.use_power(1000, EQUIP)

					if (src:aiRestorePowerRoutine==2)
						src << "Alert cancelled. Power has been restored without our assistance."
						src:aiRestorePowerRoutine = 0
						src.blind.layer = 0
						spawn(1)
							while (src.getOxyLoss()>0 && stat!=2)
								sleep(50)
								src.adjustOxyLoss(-1)
							src.oxyloss = 0
						return
					else if (src:aiRestorePowerRoutine==3)
						src << "Alert cancelled. Power has been restored."
						src:aiRestorePowerRoutine = 0
						src.blind.layer = 0
						spawn(1)
							while (src.getOxyLoss()>0 && stat!=2)
								sleep(50)
								src.adjustOxyLoss(-1)
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
							if (!is_special_character(src))
								src.set_zeroth_law("")
							src.clear_supplied_laws()
							var/time = time2text(world.realtime,"hh:mm:ss")
							lawchanges.Add("[time] <b>:</b> [src.name]'s noncore laws have been reset due to power failure")
							spawn(50)
								while ((src:aiRestorePowerRoutine!=0) && stat!=2)
									src.oxyloss += 2
									sleep(50)

							spawn(20)
								src << "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."
								sleep(50)
								if (loc.master.power_equip)
									if (!istype(T, /turf/space))
										src << "Alert cancelled. Power has been restored without our assistance."
										src:aiRestorePowerRoutine = 0
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
											theAPC.attack_ai(src)
											src:aiRestorePowerRoutine = 3
											src << "Your laws have been reset:"
											src.show_laws()
									sleep(50)
									theAPC = null

/mob/living/silicon/ai/updatehealth()
	if (src.nodamage == 0)
		if(src.fire_res_on_core)
			src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getBruteLoss()
		else
			src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
	else
		src.health = 100
		src.stat = 0

/mob/living/silicon/ai/proc/update_mind()
	if(!mind && client)
		mind = new
		mind.current = src
		mind.assigned_role = "AI"
		mind.key = key