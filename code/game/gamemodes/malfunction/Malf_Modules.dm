// TO DO:
/*
epilepsy flash on lights
delay round message
microwave makes robots
dampen radios
reactivate cameras - done
eject engine
core sheild
cable stun
rcd light flash thingy on matter drain



*/

/datum/game_mode/malfunction/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0


/datum/game_mode/malfunction/AI_Module/large/
	uses = 1

/datum/game_mode/malfunction/AI_Module/small/
	uses = 5


/datum/game_mode/malfunction/AI_Module/large/fireproof_core
	module_name = "Core upgrade"
	mod_pick_name = "coreup"

/client/proc/fireproof_core()
	set category = "AI Modules"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in world)
		ai.fire_res_on_core = 1
	usr.verbs -= /client/proc/fireproof_core
	usr << "\red Core fireproofed."

/datum/game_mode/malfunction/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	mod_pick_name = "turret"

/client/proc/upgrade_turrets()
	set category = "AI Modules"
	set name = "Upgrade Turrets"
	usr.verbs -= /client/proc/upgrade_turrets
	for(var/obj/machinery/turret/turret in world)
		turret.health += 30
		turret.shot_delay = 20

/datum/game_mode/malfunction/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	mod_pick_name = "rcd"

/client/proc/disable_rcd()
	set category = "AI Modules"
	set name = "Disable RCDs"
	for(var/obj/item/weapon/rcd/rcd in world)
		rcd = new /obj/item/weapon/rcd_fake(rcd)

/datum/game_mode/malfunction/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	uses = 2

/client/proc/overload_machine(obj/machinery/M as obj in world)
	set name = "Overload Machine"
	for(var/datum/game_mode/malfunction/AI_Module/small/overload_machine/overload in usr:current_modules)
		if(overload.uses > 0)
			overload.uses --
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue You hear a loud electrical buzzing sound!"))
			spawn(50)
				explosion(get_turf(M), 0,1,1,0)
		if(overload.uses == 0)
			usr.verbs -= /client/proc/overload_machine

/datum/game_mode/malfunction/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	uses = 3

/client/proc/blackout()
	set category = "AI Modules"
	set name = "Blackout"
	for(var/datum/game_mode/malfunction/AI_Module/small/blackout/blackout in usr:current_modules)
		if(blackout.uses > 0)
			blackout.uses --
			for(var/obj/machinery/power/apc/apc in world)
				if(prob(30))
				 apc.overload_lighting()
		if(blackout.uses == 0)
			usr.verbs -= /client/proc/blackout

/datum/game_mode/malfunction/AI_Module/small/interhack
	module_name = "Hack intercept"
	mod_pick_name = "interhack"

/client/proc/interhack()
	set category = "AI Modules"
	set name = "Hack intercept"
	usr.verbs -= /client/proc/interhack
	ticker.mode:hack_intercept()

/datum/game_mode/malfunction/AI_Module/small/reactivate_camera
	mod_pick_name = "recam"
	uses = 10

/client/proc/reactivate_camera(obj/machinery/camera/C as obj in world)
	set name = "Reactivate Camera"
	for(var/datum/game_mode/malfunction/AI_Module/small/reactivate_camera/camera in usr:current_modules)
		if(camera.uses > 0)
			if(!C.status)
				C.status = !C.status
				camera.uses --
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue You hear a quiet click."))
			else
				usr << "This camera is either active, or not repairable."
		if(camera.uses == 0)
			usr.verbs -= /client/proc/reactivate_camera


/datum/game_mode/malfunction/AI_Module/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/game_mode/malfunction/AI_Module/module_picker/New()
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/large/fireproof_core
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/large/upgrade_turrets
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/large/disable_rcd
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/small/overload_machine
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/small/interhack
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/small/blackout
	src.possible_modules += new /datum/game_mode/malfunction/AI_Module/small/reactivate_camera

/datum/game_mode/malfunction/AI_Module/module_picker/proc/use(user as mob)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else if(src.processing_time <= 0)
		dat = "<B> No processing time is left available. No more modules are able to be chosen at this time."
	else
		dat = "<B>Select use of processing time: (currently [src.processing_time] left.)</B><BR>"
		dat += "<HR>"
		dat += "<B>Install Module:</B><BR>"
		dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
		for(var/datum/game_mode/malfunction/AI_Module/large/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (55)<BR>"
		for(var/datum/game_mode/malfunction/AI_Module/small/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (15)<BR>"
		dat += "<HR>"

	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")
	return

/datum/game_mode/malfunction/AI_Module/module_picker/Topic(href, href_list)
	..()
	if (href_list["coreup"])
		usr.verbs += /client/proc/fireproof_core
		src.temp = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent. One use."
		src.processing_time -= 50
	else if (href_list["turret"])
		usr.verbs += /client/proc/upgrade_turrets
		src.temp = "Improves the firing speed and health of all AI turrets. This effect is permanent. One use."
		src.processing_time -= 50
	else if (href_list["rcd"])
		usr.verbs += /client/proc/disable_rcd
		src.temp = 	"Send a specialised pulse to break all RCD devices on the station. One use."
		src.processing_time -= 50
	else if (href_list["overload"])
		usr.verbs += /client/proc/overload_machine
		usr:current_modules += new /datum/game_mode/malfunction/AI_Module/small/overload_machine
		src.temp = "Overloads an electrical machine, causing a small explosion. 2 uses."
		src.processing_time -= 15
	else if (href_list["blackout"])
		usr.verbs += /client/proc/blackout
		src.temp = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
		usr:current_modules += new /datum/game_mode/malfunction/AI_Module/small/blackout
		src.processing_time -= 15
	else if (href_list["interhack"])
		usr.verbs += /client/proc/interhack
		src.temp = "Hacks the status upgrade from Cent. Com, removing any information about malfunctioning electrical systems. One use."
		usr:current_modules += new /datum/game_mode/malfunction/AI_Module/small/interhack
		src.processing_time -= 15
	else if (href_list["recam"])
		usr.verbs += /client/proc/reactivate_camera
		src.temp = "Reactivates a currently disabled camera. 10 uses."
		usr:current_modules += new /datum/game_mode/malfunction/AI_Module/small/reactivate_camera
		src.processing_time -= 15
	else
		if (href_list["temp"])
			src.temp = null
	src.use(usr)
	return
