#define DEFAULT_DOOMSDAY_TIMER 4500

//The malf AI action subtype. All malf actions are subtypes of this.
/datum/action/innate/ai
	name = "AI Action"
	desc = "You aren't entirely sure what this does, but it's very beepy and boopy."
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions_AI.dmi'
	var/mob/living/silicon/ai/owner_AI //The owner AI, so we don't have to typecast every time
	var/one_use //If this can only be used once
	var/uses //If we have multiple uses of the same power

/datum/action/innate/ai/Grant(mob/living/L)
	. = ..()
	if(!isAI(owner))
		Remove(owner)
		qdel(src)
		return
	else
		owner_AI = owner

/datum/action/innate/ai/IsAvailable()
	. = ..()
	if(owner_AI && owner_AI.malf_cooldown > world.time)
		return

/datum/action/innate/ai/Trigger()
	. = ..()
	if(initial(uses)) //So we don't have to have a "has_uses" var or something
		uses--
		if(!uses)
			to_chat(owner, "<span class='warning'>[name] has run out of uses!</span>")
			Remove(owner)
			qdel(src)
	if(one_use)
		Remove(owner)
		qdel(src)


//The datum and interface for the malf unlock menu, which lets them choose actions to unlock.
/datum/module_picker
	var/temp = null
	var/processing_time = 50
	var/list/possible_modules = list()

/datum/module_picker/New()
	for(var/type in typesof(/datum/AI_Module))
		var/datum/AI_Module/AM = new type
		if((AM.power_type && AM.power_type != /datum/action/innate/ai) || AM.upgrade)
			src.possible_modules += AM

/datum/module_picker/proc/remove_malf_verbs(mob/living/silicon/ai/AI) //Removes all malfunction-related abilities from the target AI.
	for(var/datum/AI_Module/AM in possible_modules)
		for(var/datum/action/A in AI.actions)
			if(istype(A, initial(AM.power_type)))
				A.Remove(AI)
				qdel(A)

/datum/module_picker/proc/use(mob/user)
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

/datum/module_picker/Topic(href, href_list)
	..()

	if(!isAI(usr))
		return
	var/mob/living/silicon/ai/A = usr

	if(A.stat == DEAD)
		to_chat(A, "You are already dead!") //Omae Wa Mou Shindeiru //great comment! very helpful! 10/10!
		return

	for(var/datum/AI_Module/AM in possible_modules)
		if (href_list[AM.mod_pick_name])

			// Cost check
			if(AM.cost > src.processing_time)
				temp = "You cannot afford this module."
				break

			// Add new uses if we can, and it is allowed.
			var/datum/action/innate/ai/action = locate(AM.power_type) in A.current_modules
			if(action) //No need to check for one_purchase, as that stuff is removed when we buy it
				action.uses += AM.uses
				src.processing_time -= AM.cost
				temp = "Additional use[AM.uses > 1 ? "s" : ""] added to [action.name]!"

			// Give the power and take away the money.
			A.view_core() //A BYOND bug requires you to be viewing your core before your verbs update
			if(AM.upgrade) //upgrade and upgrade() are separate, be careful!
				AM.upgrade(A) //upgrade that sucker!
				possible_modules -= AM
			else
				if(AM.power_type)
					var/datum/action/AC = new AM.power_type
					AC.Grant(A)
					A.current_modules += new AM.type
					temp = AM.description
					src.processing_time -= AM.cost
					if(AM.one_purchase)
						possible_modules -= AM
			if(AM.unlock_text)
				to_chat(A, AM.unlock_text)
			if(AM.unlock_sound)
				A.playsound_local(A, AM.unlock_sound, 50, 0)

		if(href_list["showdesc"])
			if(AM.mod_pick_name == href_list["showdesc"])
				temp = AM.description
	src.use(usr)


//The base module type, which holds info about each ability.
/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0
	var/cost = 5
	var/one_purchase = 0 //If this module can only be purchased once. This always applies to upgrades, even if the variable is set to false.

	var/power_type = /datum/action/innate/ai //If the module gives an active ability, use this. Mutually exclusive with upgrade.
	var/upgrade //If the module gives a passive upgrade, use this. Mutually exclusive with power_type.
	var/unlock_text = "<span class='notice'>Hello World!</span>" //Text shown when an ability is unlocked
	var/unlock_sound //Sound played when an ability is unlocked

/datum/AI_Module/proc/upgrade(mob/living/silicon/AI/AI) //Apply upgrades!
	return

/datum/AI_Module/large //Big, powerful stuff that can only be used once.
	uses = 1

/datum/AI_Module/small //Weak, usually localized stuff with five uses.
	uses = 5


//Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/AI_Module/large/nuke_station
	module_name = "Doomsday Device"
	mod_pick_name = "nukestation"
	description = "Activate a weapon that will disintegrate all organic life on the station after a 450 second delay. Can only be used while on the station, will fail if your core is moved off station or destroyed."
	cost = 130
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/nuke_station
	unlock_text = "<span class='notice'>You slowly, carefully, establish a connection with the on-station self-destruct. You can now activate it at any time.</span>"

/datum/action/innate/ai/nuke_station
	name = "Doomsday Device"
	desc = "Activates the doomsday device. This is not reversible."
	button_icon_state = "doomsday_device"

/datum/action/innate/ai/nuke_station/Activate()
	var/turf/T = get_turf(owner)
	if(!istype(T) || T.z != ZLEVEL_STATION)
		to_chat(owner, "<span class='warning'>You cannot activate the doomsday device while off-station!</span>")
		return
	if(alert(owner, "Send arming signal? (true = arm, false = cancel)", "purge_all_life()", "confirm = TRUE;", "confirm = FALSE;") != "confirm = TRUE;")
		return
	active = TRUE
	INVOKE_ASYNC(src, .proc/set_us_up_the_bomb, owner)

/datum/action/innate/ai/nuke_station/proc/set_us_up_the_bomb(mob/living/owner)
	to_chat(owner, "<span class='small boldannounce'>run -o -a 'selfdestruct'</span>")
	sleep(5)
	to_chat(owner, "<span class='small boldannounce'>Running executable 'selfdestruct'...</span>")
	sleep(rand(10, 30))
	owner.playsound_local(owner, 'sound/misc/bloblarm.ogg', 50, 0)
	to_chat(owner, "<span class='userdanger'>!!! UNAUTHORIZED SELF-DESTRUCT ACCESS !!!</span>")
	to_chat(owner, "<span class='boldannounce'>This is a class-3 security violation. This incident will be reported to Central Command.</span>")
	for(var/i in 1 to 3)
		sleep(20)
		to_chat(owner, "<span class='boldannounce'>Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%</span>")
	sleep(3)
	to_chat(owner, "<span class='small boldannounce'>auth 'akjv9c88asdf12nb' ******************</span>")
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0)
	sleep(30)
	to_chat(owner, "<span class='boldnotice'>Credentials accepted. Welcome, akjv9c88asdf12nb.</span>")
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0)
	sleep(5)
	to_chat(owner, "<span class='boldnotice'>Arm self-destruct device? (Y/N)</span>")
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0)
	sleep(20)
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(15)
	to_chat(owner, "<span class='boldnotice'>Confirm arming of self-destruct device? (Y/N)</span>")
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0)
	sleep(10)
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(rand(15, 25))
	to_chat(owner, "<span class='boldnotice'>Please repeat password to confirm.</span>")
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0)
	sleep(14)
	to_chat(owner, "<span class='small boldannounce'>******************</span>")
	sleep(40)
	to_chat(owner, "<span class='boldnotice'>Credentials accepted. Transmitting arming signal...</span>")
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0)
	sleep(30)
	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", 'sound/AI/aimalf.ogg')
	set_security_level("delta")
	var/obj/machinery/doomsday_device/DOOM = new(owner_AI)
	owner_AI.doomsday_device = DOOM
	owner_AI.doomsday_device.start()
	for(var/pinpointer in GLOB.pinpointer_list)
		var/obj/item/weapon/pinpointer/P = pinpointer
		P.switch_mode_to(TRACK_MALF_AI) //Pinpointers start tracking the AI wherever it goes
	Remove(owner)
	qdel(src)

/obj/machinery/doomsday_device
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	name = "doomsday device"
	icon_state = "nuclearbomb_base"
	desc = "A weapon which disintegrates all organic life in a large area."
	anchored = TRUE
	density = TRUE
	verb_exclaim = "blares"
	var/timing = FALSE
	var/obj/effect/countdown/doomsday/countdown
	var/detonation_timer
	var/list/milestones

/obj/machinery/doomsday_device/Initialize()
	. = ..()
	countdown = new(src)
	milestones = list()

/obj/machinery/doomsday_device/Destroy()
	QDEL_NULL(countdown)
	STOP_PROCESSING(SSfastprocess, src)
	SSshuttle.clearHostileEnvironment(src)
	SSmapping.remove_nuke_threat(src)
	for(var/A in GLOB.ai_list)
		var/mob/living/silicon/ai/AI = A
		if(AI.doomsday_device == src)
			AI.doomsday_device = null
	return ..()

/obj/machinery/doomsday_device/proc/start()
	detonation_timer = world.time + DEFAULT_DOOMSDAY_TIMER
	timing = TRUE
	countdown.start()
	START_PROCESSING(SSfastprocess, src)
	SSshuttle.registerHostileEnvironment(src)
	SSmapping.add_nuke_threat(src) //This causes all blue "circuit" tiles on the map to change to animated red icon state.

/obj/machinery/doomsday_device/proc/seconds_remaining()
	. = max(0, (round((detonation_timer - world.time) / 10)))

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || T.z != ZLEVEL_STATION)
		minor_announce("DOOMSDAY DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		SSshuttle.clearHostileEnvironment(src)
		qdel(src)
		return
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		timing = FALSE
		detonate(T.z)
	else
		var/key = num2text(sec_left)
		if(!(sec_left % 60) && !(key in milestones))
			milestones[key] = TRUE
			minor_announce("[key] SECONDS UNTIL DOOMSDAY DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)

/obj/machinery/doomsday_device/proc/detonate(z_level = ZLEVEL_STATION)
	for(var/mob/M in GLOB.player_list)
		M << 'sound/machines/Alarm.ogg'
	sleep(100)
	for(var/mob/living/L in GLOB.mob_list)
		var/turf/T = get_turf(L)
		if(!T || T.z != z_level)
			continue
		if(issilicon(L))
			continue
		to_chat(L, "<span class='userdanger'>The blast wave from [src] tears you atom from atom!</span>")
		L.dust()
	to_chat(world, "<B>The AI cleansed the station of life with the doomsday device!</B>")
	SSticker.force_ending = 1


//AI Turret Upgrade: Increases the health and damage of all turrets.
/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret Upgrade"
	mod_pick_name = "turret"
	description = "Improves the power and health of all AI turrets. This effect is permanent."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>You establish a power diversion to your turrets, upgrading their health and damage.</span>"
	unlock_sound = 'sound/items/rped.ogg'

/datum/AI_Module/large/upgrade_turrets/upgrade(mob/living/silicon/AI/AI)
	for(var/obj/machinery/porta_turret/ai/turret in GLOB.machines)
		turret.obj_integrity += 30
		turret.lethal_projectile = /obj/item/projectile/beam/laser/heavylaser //Once you see it, you will know what it means to FEAR.
		turret.lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'


//Hostile Station Lockdown: Locks, bolts, and electrifies every airlock on the station. After 90 seconds, the doors reset.
/datum/AI_Module/large/lockdown
	module_name = "Hostile Station Lockdown"
	mod_pick_name = "lockdown"
	description = "Overload the airlock, blast door and fire control networks, locking them down. Caution! This command also electrifies all airlocks. The networks will automatically reset after 90 seconds."
	cost = 30
	one_purchase = 1
	power_type = /datum/action/innate/ai/lockdown
	unlock_text = "<span class='notice'>You upload a sleeper trojan into the door control systems. You can send a signal to set it off at any time.</span>"
	unlock_sound = 'sound/machines/BoltsDown.ogg'

/datum/action/innate/ai/lockdown
	name = "Lockdown"
	desc = "Bolts, depowers, and electrifies every airlock, firelock, and blast door on the station. After 90 seconds, they will reset themselves."
	button_icon_state = "lockdown"
	one_use = TRUE

/datum/action/innate/ai/lockdown/Activate()
	for(var/obj/machinery/door/D in GLOB.airlocks)
		if(D.z != ZLEVEL_STATION)
			continue
		INVOKE_ASYNC(D, /obj/machinery/door.proc/hostile_lockdown, src)
		addtimer(CALLBACK(D, /obj/machinery/door.proc/disable_lockdown), 900)

	var/obj/machinery/computer/communications/C = locate() in GLOB.machines
	if(C)
		C.post_status("alert", "lockdown")

	minor_announce("Hostile runtime detected in door controllers. Isolation lockdown protocols are now in effect. Please remain calm.","Network Alert:", 1)
	to_chat(owner, "<span class='danger'>Lockdown initiated. Network reset in 90 seconds.</span>")
	addtimer(CALLBACK(GLOBAL_PROC, .proc/minor_announce,
		"Automatic system reboot complete. Have a secure day.",
		"Network reset:"), 900)


//Destroy RCDs: Detonates all non-cyborg RCDs on the station.
/datum/AI_Module/large/destroy_rcd
	module_name = "Destroy RCDs"
	mod_pick_name = "rcd"
	description = "Send a specialised pulse to detonate all hand-held and exosuit Rapid Construction Devices on the station."
	cost = 25
	one_purchase = 1
	power_type = /datum/action/innate/ai/destroy_rcds
	unlock_text = "<span class='notice'>After some improvisation, you rig your onboard radio to be able to send a signal to detonate all RCDs.</span>"
	unlock_sound = 'sound/items/timer.ogg'

/datum/action/innate/ai/destroy_rcds
	name = "Destroy RCDs"
	desc = "Detonate all non-cyborg RCDs on the station."
	button_icon_state = "detonate_rcds"
	one_use = TRUE

/datum/action/innate/ai/destroy_rcds/Activate()
	for(var/I in GLOB.rcd_list)
		if(!istype(I, /obj/item/weapon/construction/rcd/borg)) //Ensures that cyborg RCDs are spared.
			var/obj/item/weapon/construction/rcd/RCD = I
			RCD.detonate_pulse()

	to_chat(owner, "<span class='warning'>RCD detonation pulse emitted.</span>")
	owner_AI.malf_cooldown = world.time + 100


//Unlock Mech Domination: Unlocks the ability to dominate mechs. Big shocker, right?
/datum/AI_Module/large/mecha_domination
	module_name = "Unlock Mech Domination"
	mod_pick_name = "mechjack"
	description = "Allows you to hack into a mech's onboard computer, shunting all processes into it and ejecting any occupants. Once uploaded to the mech, it is impossible to leave.\
	Do not allow the mech to leave the station's vicinity or allow it to be destroyed."
	cost = 30
	upgrade = TRUE
	unlock_text = "<span class='notice'>Virus package compiled. Select a target mech at any time. <b>You must remain on the station at all times. Loss of signal will result in total system lockout.</b></span>"
	unlock_sound = 'sound/mecha/nominal.ogg'

/datum/AI_Module/large/mecha_domination/upgrade(mob/living/silicon/ai/AI)
	AI.can_dominate_mechs = TRUE //Yep. This is all it does. Honk!


//Thermal Sensor Override: Unlocks the ability to disable all fire alarms from doing their job.
/datum/AI_Module/large/break_fire_alarms
	module_name = "Thermal Sensor Override"
	mod_pick_name = "burnpigs"
	description = "Gives you the ability to override the thermal sensors on all fire alarms. This will remove their ability to scan for fire and thus their ability to alert. \
	Anyone can check the fire alarm's interface and may be tipped off by its status."
	one_purchase = TRUE
	cost = 25
	power_type = /datum/action/innate/ai/break_fire_alarms
	unlock_text = "<span class='notice'>You replace the thermal sensing capabilities of all fire alarms with a manual override, allowing you to turn them off at will.</span>"
	unlock_sound = 'goon/sound/machinery/FireAlarm.ogg'

/datum/action/innate/ai/break_fire_alarms
	name = "Override Thermal Sensors"
	desc = "Disables the automatic temperature sensing on all fire alarms, making them effectively useless."
	button_icon_state = "break_fire_alarms"
	one_use = TRUE

/datum/action/innate/ai/break_fire_alarms/Activate()
	for(var/obj/machinery/firealarm/F in GLOB.machines)
		if(F.z != ZLEVEL_STATION)
			continue
		F.emagged = 1
	to_chat(owner, "<span class='notice'>All thermal sensors on the station have been disabled. Fire alerts will no longer be recognized.</span>")


//Air Alarm Safety Override: Unlocks the ability to enable flooding on all air alarms.
/datum/AI_Module/large/break_air_alarms
	module_name = "Air Alarm Safety Override"
	mod_pick_name = "allow_flooding"
	description = "Gives you the ability to disable safeties on all air alarms. This will allow you to use the environmental mode Flood, which disables scrubbers as well as pressure checks on vents. \
	Anyone can check the air alarm's interface and may be tipped off by their nonfunctionality."
	one_purchase = 1
	cost = 50
	power_type = /datum/action/innate/ai/break_air_alarms
	unlock_text = "<span class='notice'>You remove the safety overrides on all air alarms, but you leave the confirm prompts open. You can hit 'Yes' at any time... you bastard.</span>"
	unlock_sound = 'sound/effects/spray.ogg'

/datum/action/innate/ai/break_air_alarms
	name = "Override Air Alarm Safeties"
	desc = "Enables the Flood setting on all air alarms."
	button_icon_state = "break_air_alarms"
	one_use = TRUE

/datum/action/innate/ai/break_air_alarms/Activate()
	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		if(AA.z != ZLEVEL_STATION)
			continue
		AA.emagged = 1
	to_chat(owner, "<span class='notice'>All air alarm safeties on the station have been overriden. Air alarms may now use the Flood environmental mode.")

/*/datum/AI_Module/small/overload_machine
	module_name = "Machine Overload"
	mod_pick_name = "overload"
	description = "Overloads an electrical machine, causing a small explosion. 2 uses."
	uses = 2
	cost = 20

	power_type = /mob/living/silicon/ai/proc/overload_machine

/mob/living/silicon/ai/proc/overload_machine(obj/machinery/M in GLOB.machines)
	set name = "Overload Machine"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if (istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/overload_machine/overload in current_modules)
			if(overload.uses > 0)
				overload.uses --
				M.audible_message("<span class='userdanger'>You hear a loud electrical buzzing sound coming from [M]!</span>")
				to_chat(src, "<span class='warning'>Overloading machine circuitry...</span>")
				spawn(50)
					if(M)
						explosion(get_turf(M), 0,2,3,0)
						qdel(M)
			else to_chat(src, "<span class='notice'>Out of uses.</span>")
	else to_chat(src, "<span class='notice'>That's not a machine.</span>")

/datum/AI_Module/small/override_machine
	module_name = "Machine Override"
	mod_pick_name = "override"
	description = "Overrides a machine's programming, causing it to rise up and attack everyone except other machines. 4 uses."
	uses = 4
	cost = 30

	power_type = /mob/living/silicon/ai/proc/override_machine


/mob/living/silicon/ai/proc/override_machine(obj/machinery/M in GLOB.machines)
	set name = "Override Machine"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	if (istype(M, /obj/machinery))
		if(!M.can_be_overridden())
			to_chat(src, "Can't override this device.")
		for(var/datum/AI_Module/small/override_machine/override in current_modules)
			if(override.uses > 0)
				override.uses --
				M.audible_message("<span class='userdanger'>You hear a loud electrical buzzing sound!</span>")
				to_chat(src, "<span class='warning'>Reprogramming machine behaviour...</span>")
				spawn(50)
					if(M && !QDELETED(M))
						new /mob/living/simple_animal/hostile/mimic/copy/machine(get_turf(M), M, src, 1)
			else to_chat(src, "<span class='notice'>Out of uses.</span>")
	else to_chat(src, "<span class='notice'>That's not a machine.</span>")

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
		var/obj/machinery/transformer/conveyor = new(T)
		conveyor.masterAI = src
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		var/datum/AI_Module/large/place_cyborg_transformer/PCT = locate() in current_modules
		PCT.uses --
		can_shunt = 0
		to_chat(src, "<span class='warning'>You cannot shunt anymore.</span>")

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
			if(!isfloorturf(T))
				fail = 1
			var/datum/camerachunk/C = GLOB.cameranet.getCameraChunk(T.x, T.y, T.z)
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
			for(var/obj/machinery/power/apc/apc in GLOB.machines)
				if(prob(30*apc.overload))
					apc.overload_lighting()
				else apc.overload++
			to_chat(src, "<span class='notice'>Overcurrent applied to the powernet.</span>")
		else to_chat(src, "<span class='notice'>Out of uses.</span>")

/datum/AI_Module/small/reactivate_cameras
	module_name = "Reactivate Camera Network"
	mod_pick_name = "recam"
	description = "Runs a network-wide diagnostic on the camera network, resetting focus and re-routing power to failed cameras. Can be used to repair up to 30 cameras."
	uses = 30
	cost = 10
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/reactivate_cameras

/mob/living/silicon/ai/proc/reactivate_cameras()
	set name = "Reactivate Cameranet"
	set category = "Malfunction"

	if(!canUseTopic() || malf_cooldown > world.time)
		return
	var/fixedcams = 0 //Tells the AI how many cams it fixed. Stats are fun.

	for(var/datum/AI_Module/small/reactivate_cameras/camera in current_modules)
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			var/initial_range = initial(C.view_range) //To prevent calling the proc twice
			if(camera.uses > 0)
				if(!C.status)
					C.toggle_cam(src, 0) //Reactivates the camera based on status. Badly named proc.
					fixedcams++
					camera.uses--
				if(C.view_range != initial_range)
					C.view_range = initial_range //Fixes cameras with bad focus.
					camera.uses--
					fixedcams++
					//If a camera is both deactivated and has bad focus, it will cost two uses to fully fix!
			else
				to_chat(src, "<span class='warning'>Out of uses.</span>")
				verbs -= /mob/living/silicon/ai/proc/reactivate_cameras //It is useless now, clean it up.
				break
	to_chat(src, "<span class='notice'>Diagnostic complete! Operations completed: [fixedcams].</span>")

	malf_cooldown = world.time + 30

/datum/AI_Module/large/upgrade_cameras
	module_name = "Upgrade Camera Network"
	mod_pick_name = "upgradecam"
	description = "Install broad-spectrum scanning and electrical redundancy firmware to the camera network, enabling EMP-Proofing and light-amplified X-ray vision." //I <3 pointless technobabble
	//This used to have motion sensing as well, but testing quickly revealed that giving it to the whole cameranet is PURE HORROR.
	one_time = 1
	cost = 35 //Decent price for omniscience!

	power_type = /mob/living/silicon/ai/proc/upgrade_cameras

/mob/living/silicon/ai/proc/upgrade_cameras()
	set name = "Upgrade Cameranet"
	set category = "Malfunction"

	if(!canUseTopic())
		return

	var/upgradedcams = 0
	see_override = SEE_INVISIBLE_MINIMUM //Night-vision, without which X-ray would be very limited in power.
	update_sight()

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if(C.assembly)
			var/upgraded = 0

			if(!C.isXRay())
				C.upgradeXRay()
				//Update what it can see.
				GLOB.cameranet.updateVisibility(C, 0)
				upgraded = 1

			if(!C.isEmpProof())
				C.upgradeEmpProof()
				upgraded = 1

			if(upgraded)
				upgradedcams++

	to_chat(src, "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: [upgradedcams]. Light amplification system online.</span>")
	verbs -= /mob/living/silicon/ai/proc/upgrade_cameras

/datum/AI_Module/large/eavesdrop
	module_name = "Enhanced Surveillance"
	mod_pick_name = "eavesdrop"
	description = "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations."
	cost = 30
	one_time = 1

	power_type = /mob/living/silicon/ai/proc/surveillance

/mob/living/silicon/ai/proc/surveillance()
	set category = "Malfunction"
	set name = "Enhanced Surveillance"

	if(eyeobj)
		eyeobj.relay_speech = TRUE
	to_chat(src, "<span class='notice'>OTA firmware distribution complete! Cameras upgraded: Enhanced surveillance package online.</span>")
	verbs -= /mob/living/silicon/ai/proc/surveillance*/


#undef DEFAULT_DOOMSDAY_TIMER