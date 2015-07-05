
/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_time = 0

	var/power_type


/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5


/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade"
	mod_pick_name = "coreup"
	description = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
	cost = 50
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/fireproof_core

/mob/living/silicon/ai/proc/fireproof_core()
	set category = "Malfunction"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in player_list)
		ai.fire_res_on_core = 1
	src.verbs -= /mob/living/silicon/ai/proc/fireproof_core
	src << "<span class='notice'>Core fireproofed.</span>"

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 50
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/upgrade_turrets

/mob/living/silicon/ai/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"

	if(!canUseTopic())
		return

	src.verbs -= /mob/living/silicon/ai/proc/upgrade_turrets
	for(var/obj/machinery/porta_turret/turret in machines)
		if(turret.ai) //Make sure only the AI's turrets are affected.
			turret.health += 30
			turret.eprojectile = /obj/item/projectile/beam/heavylaser //Once you see it, you will know what it means to FEAR.
			turret.eshot_sound = 'sound/weapons/lasercannonfire.ogg'
	src << "<span class='notice'>Turrets upgraded.</span>"

/datum/AI_Module/large/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/lockdown

/mob/living/silicon/ai/proc/lockdown()
	set category = "Malfunction"
	set name = "Initiate Hostile Lockdown"

	if(!canUseTopic())
		return

	var/obj/machinery/door/airlock/AL
	for(var/obj/machinery/door/D in airlocks)
		if(D.z != ZLEVEL_STATION && D.z != ZLEVEL_MINING)
			continue
		spawn()
			if(istype(D, /obj/machinery/door/airlock))
				AL = D
				if(AL.canAIControl() && !AL.stat) //Must be powered and have working AI wire.
					AL.locked = 0 //For airlocks that were bolted open.
					AL.safe = 0 //DOOR CRUSH
					AL.close()
					AL.bolt() //Bolt it!
					AL.secondsElectrified = -1  //Shock it!
			else if(!D.stat) //So that only powered doors are closed.
				D.close() //Close ALL the doors!

	var/obj/machinery/computer/communications/C = locate() in machines
	if(C)
		C.post_status("alert", "lockdown")

	verbs -= /mob/living/silicon/ai/proc/lockdown
	minor_announce("Hostile runtime detected in door controllers. Isolation Lockdown protocols are now in effect. Please remain calm.","Network Alert:", 1)
	src << "<span class = 'warning'>Lockdown Initiated. Network reset in 90 seconds.</span>"
	spawn(900) //90 Seconds.
		disablelockdown() //Reset the lockdown after 90 seconds.

/mob/living/silicon/ai/proc/disablelockdown()
	set category = "Malfunction"
	set name = "Disable Lockdown"

	var/obj/machinery/door/airlock/AL
	for(var/obj/machinery/door/D in airlocks)
		spawn()
			if(istype(D, /obj/machinery/door/airlock))
				AL = D
				if(AL.canAIControl() && !AL.stat) //Must be powered and have working AI wire.
					AL.unbolt()
					AL.secondsElectrified = 0
					AL.open()
					AL.safe = 1
			else if(!D.stat) //Opens only powered doors.
				D.open() //Open everything!

	minor_announce("Automatic system reboot complete. Have a secure day.","Network reset:")

/datum/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to break all RCD devices on the station."
	cost = 50

	power_type = /mob/living/silicon/ai/proc/disable_rcd

/mob/living/silicon/ai/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Disable RCDs"

	if(!canUseTopic())
		return

	for(var/datum/AI_Module/large/disable_rcd/rcdmod in current_modules)
		if(rcdmod.uses > 0)
			rcdmod.uses --
			for(var/obj/item/weapon/rcd/rcd in world)
				rcd.disabled = 1
			for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
				rcd.disabled = 1
			src << "<span class='warning>RCD-disabling pulse emitted.</span>"
		else src << "<span class='notice'>Out of uses.</span>"

/datum/AI_Module/large/mecha_domination
	module_name = "Viral Mech Domination"
	mod_pick_name = "mechjack"
	description = "Hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/mech_takeover

/mob/living/silicon/ai/proc/mech_takeover()
	set name = "Compile Mecha Virus"
	set category = "Malfunction"
	set desc = "Target a mech by clicking it. Click the appropriate command when ready."
	if(stat)
		return
	can_dominate_mechs = 1 //Yep. This is all it does. Honk!
	src << "Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b>"
	verbs -= /mob/living/silicon/ai/proc/mech_takeover


/datum/AI_Module/large/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert. \
	Anyone can check the fire alarm's interface and may be tipped off by its status."
	one_time = 1
	cost = 25

	power_type = /mob/living/silicon/ai/proc/break_fire_alarms

/mob/living/silicon/ai/proc/break_fire_alarms()
	set name = "Override Thermal Sensors"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	for(var/obj/machinery/firealarm/F in world)
		if(F.z != ZLEVEL_STATION)
			continue
		F.emagged = 1
	src << "<span class='notice'>All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized.</span>"
	src.verbs -= /mob/living/silicon/ai/proc/break_fire_alarms

/datum/AI_Module/large/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_time = 1
	cost = 50

	power_type = /mob/living/silicon/ai/proc/break_air_alarms

/mob/living/silicon/ai/proc/break_air_alarms()
	set name = "Disable Air Alarm Safeties"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	for(var/obj/machinery/alarm/A in world)
		if(A.z != ZLEVEL_STATION)
			continue
		A.emagged = 1
	src << "<span class='notice'>All air alarm safeties on the station have been overriden. Air alarms may now use the Flood environmental mode."
	src.verbs -= /mob/living/silicon/ai/proc/break_air_alarms



/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	cost = 15

	power_type = /mob/living/silicon/ai/proc/overload_machine

/mob/living/silicon/ai/proc/overload_machine(obj/machinery/M as obj in world)
	set name = "Overload Machine"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if (istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/overload_machine/overload in current_modules)
			if(overload.uses > 0)
				overload.uses --
				audible_message("<span class='italics'>You hear a loud electrical buzzing sound!</span>")
				src << "<span class='warning'>Overloading machine circuitry...</span>"
				spawn(50)
					if(M)
						explosion(get_turf(M), 0,1,1,0)
						qdel(M)
			else src << "<span class='notice'>Out of uses.</span>"
	else src << "<span class='notice'>That's not a machine.</span>"

/datum/AI_Module/small/override_machine
	module_name = "Machine override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. 4 uses."
	uses = 4
	cost = 15

	power_type = /mob/living/silicon/ai/proc/override_machine


/mob/living/silicon/ai/proc/override_machine(obj/machinery/M as obj in world)
	set name = "Override Machine"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if (istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/override_machine/override in current_modules)
			if(override.uses > 0)
				override.uses --
				audible_message("<span class='italics'>You hear a loud electrical buzzing sound!</span>")
				src << "<span class='warning'>Reprogramming machine behaviour...</span>"
				spawn(50)
					if(M && !M.gc_destroyed)
						new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, src, 1)
			else src << "<span class='notice'>Out of uses.</span>"
	else src << "<span class='notice'>That's not a machine.</span>"

/datum/AI_Module/large/place_cyborg_transformer
	module_name = "Robotic Factory (Removes Shunting)"
	mod_pick_name = "cyborgtransformer"
	description = "Build a machine anywhere, using expensive nanomachines, that can convert a living human into a loyal cyborg slave when placed inside."
	cost = 100
	power_type = /mob/living/silicon/ai/proc/place_transformer
	var/list/turfOverlays = list()

/datum/AI_Module/large/place_cyborg_transformer/New()
	for(var/i=0;i<3;i++)
		var/image/I = image("icon"='icons/turf/overlays.dmi')
		turfOverlays += I
	..()

/mob/living/silicon/ai/proc/place_transformer()
	set name = "Place Robotic Factory"
	set category = "Malfunction"
	if(!canPlaceTransformer())
		return
	var/sure = alert(src, "Are you sure you want to place the machine here?", "Are you sure?", "Yes", "No")
	if(sure == "Yes")
		if(!canPlaceTransformer())
			return
		var/turf/T = get_turf(eyeobj)
		new /obj/machinery/transformer/conveyor(T)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		var/datum/AI_Module/large/place_cyborg_transformer/PCT = locate() in current_modules
		PCT.uses --
		can_shunt = 0
		src << "<span class='warning'>You cannot shunt anymore.</span>"

/mob/living/silicon/ai/proc/canPlaceTransformer()
	if(!eyeobj || !isturf(src.loc) || !canUseTopic())
		return
	var/datum/AI_Module/large/place_cyborg_transformer/PCT = locate() in current_modules
	if(!PCT || PCT.uses < 1)
		alert(src, "Out of uses.")
		return
	var/turf/middle = get_turf(eyeobj)
	var/list/turfs = list(middle, locate(middle.x - 1, middle.y, middle.z), locate(middle.x + 1, middle.y, middle.z))
	var/alert_msg = "There isn't enough room. Make sure you are placing the machine in a clear area and on a floor."
	var/success = 1
	if(turfs.len == 3)
		for(var/n=1;n<4,n++)
			var/fail
			var/turf/T = turfs[n]
			if(!istype(T, /turf/simulated/floor))
				fail = 1
			var/datum/camerachunk/C = cameranet.getCameraChunk(T.x, T.y, T.z)
			if(!C.visibleTurfs[T])
				alert_msg = "We cannot get camera vision of this location."
				fail = 1
			for(var/atom/movable/AM in T.contents)
				if(AM.density)
					fail = 1
			var/image/I = PCT.turfOverlays[n]
			I.loc = T
			client.images += I
			if(fail)
				success = 0
				I.icon_state = "redOverlay"
			else
				I.icon_state = "greenOverlay"
			spawn(30)
				if(client && (I.loc == T))
					client.images -= I
	if(success)
		return 1
	alert(src, alert_msg)
	return

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	description = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
	uses = 3
	cost = 15

	power_type = /mob/living/silicon/ai/proc/blackout

/mob/living/silicon/ai/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"

	if(!canUseTopic())
		return

	for(var/datum/AI_Module/small/blackout/blackout in current_modules)
		if(blackout.uses > 0)
			blackout.uses --
			for(var/obj/machinery/power/apc/apc in world)
				if(prob(30*apc.overload))
					apc.overload_lighting()
				else apc.overload++
			src << "<span class='notice'>Overcurrent applied to the powernet.</span>"
		else src << "<span class='notice'>Out of uses.</span>"

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	description = "Reactivates a currently disabled camera. 5 uses."
	uses = 5
	cost = 5

	power_type = /mob/living/silicon/ai/proc/reactivate_camera

/mob/living/silicon/ai/proc/reactivate_camera(obj/machinery/camera/C as obj in cameranet.cameras)
	set name = "Reactivate Camera"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if (istype (C, /obj/machinery/camera))
		for(var/datum/AI_Module/small/reactivate_camera/camera in current_modules)
			if(camera.uses > 0)
				if(!C.status)
					C.deactivate(src)
					camera.uses --
					src << "<span class='notice'>Camera reactivated.</span>"
				else
					src << "<span class='notice'>This camera is either active, or not repairable.</span>"
			else src << "<span class='notice'>Out of uses.</span>"
	else src << "<span class='notice'>That's not a camera.</span>"

/datum/AI_Module/small/upgrade_camera
	module_name = "Upgrade Camera"
	mod_pick_name = "upgradecam"
	description = "Upgrades a camera to have X-ray vision, motion sensing and be EMP-Proof. 5 uses."
	uses = 5
	cost = 5

	power_type = /mob/living/silicon/ai/proc/upgrade_camera

/mob/living/silicon/ai/proc/upgrade_camera(obj/machinery/camera/C as obj in cameranet.cameras)
	set name = "Upgrade Camera"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if(istype(C))
		var/datum/AI_Module/small/upgrade_camera/UC = locate(/datum/AI_Module/small/upgrade_camera) in current_modules
		if(UC)
			if(UC.uses > 0)
				if(C.assembly)
					var/upgraded = 0

					if(!C.isXRay())
						C.upgradeXRay()
						//Update what it can see.
						cameranet.updateVisibility(C, 0)
						upgraded = 1

					if(!C.isEmpProof())
						C.upgradeEmpProof()
						upgraded = 1

					if(!C.isMotion())
						C.upgradeMotion()
						upgraded = 1
						// Add it to machines that process
						SSmachine.processing |= C//machines |= C

					if(upgraded)
						UC.uses --
						C.visible_message("<span class='notice'>\icon[C] *beep*</span>")
						src << "<span class='notice'>You successully upgrade the camera.</span>"
					else
						src << "<span class='warning'>This camera is already upgraded!</span>"
			else
				src << "<span class='warning'>Out of uses!</span>"

/datum/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/module_picker/New()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if(AM.power_type != null)
			src.possible_modules += AM

/datum/module_picker/proc/remove_verbs(var/mob/living/silicon/ai/A)

	for(var/datum/AI_Module/AM in possible_modules)
		A.verbs.Remove(AM.power_type)


/datum/module_picker/proc/use(user as mob)
	var/dat
	dat = "<B>Select use of processing time: (currently #[src.processing_time] left.)</B><BR>"
	dat += "<HR>"
	dat += "<B>Install Module:</B><BR>"
	dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
	for(var/datum/AI_Module/large/module in src.possible_modules)
		dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=\ref[src];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	for(var/datum/AI_Module/small/module in src.possible_modules)
		dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A><A href='byond://?src=\ref[src];showdesc=[module.mod_pick_name]'>\[?\]</A> ([module.cost])<BR>"
	dat += "<HR>"
	if (src.temp)
		dat += "[src.temp]"
	var/datum/browser/popup = new(user, "modpicker", "Malf Module Menu")
	popup.set_content(dat)
	popup.open()
	return

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		A <<"You are already dead!" //Omae Wa Mou Shindeiru
		return

	for(var/datum/AI_Module/AM in possible_modules)
		if (href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > src.processing_time)
				temp = "You cannot afford this module."
				break

			// Add new uses if we can, and it is allowed.
			var/datum/AI_Module/already_AM = locate(AM.type) in A.current_modules
			if(already_AM)
				if(!AM.one_time)
					already_AM.uses += AM.uses
					src.processing_time -= AM.cost
					temp = "Additional use added to [already_AM.module_name]"
					break
				else
					temp = "This module is only needed once."
					break

			// Give the power and take away the money.
			A.verbs += AM.power_type
			A.current_modules += new AM.type
			temp = AM.description
			src.processing_time -= AM.cost

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	src.use(usr)
	return
