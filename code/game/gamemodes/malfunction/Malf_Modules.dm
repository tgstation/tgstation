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

/datum/AI_Module
	var/uses = 0
	var/module_name
	var/mod_pick_name
	var/description = ""
	var/engaged = 0


/datum/AI_Module/large/
	uses = 1

/datum/AI_Module/small/
	uses = 5


/datum/AI_Module/large/fireproof_core
	module_name = "Core upgrade"
	mod_pick_name = "coreup"

/client/proc/fireproof_core()
	set category = "Malfunction"
	set name = "Fireproof Core"
	for(var/mob/living/silicon/ai/ai in player_list)
		ai.fire_res_on_core = 1
	usr.verbs -= /client/proc/fireproof_core
	usr << "\red Core fireproofed."

/datum/AI_Module/large/upgrade_turrets
	module_name = "AI Turret upgrade"
	mod_pick_name = "turret"

/client/proc/upgrade_turrets()
	set category = "Malfunction"
	set name = "Upgrade Turrets"
	usr.verbs -= /client/proc/upgrade_turrets
	for(var/obj/machinery/turret/turret in player_list)
		turret.health += 30
		turret.shot_delay = 20

/datum/AI_Module/large/disable_rcd
	module_name = "RCD disable"
	mod_pick_name = "rcd"

/client/proc/disable_rcd()
	set category = "Malfunction"
	set name = "Disable RCDs"
	for(var/datum/AI_Module/large/disable_rcd/rcdmod in usr:current_modules)
		if(rcdmod.uses > 0)
			rcdmod.uses --
			for(var/obj/item/weapon/rcd/rcd in world)
				rcd.disabled = 1
			for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
				rcd.disabled = 1
			usr << "RCD-disabling pulse emitted."
		else usr << "Out of uses."

/datum/AI_Module/small/overload_machine
	module_name = "Machine overload"
	mod_pick_name = "overload"
	uses = 2

/client/proc/overload_machine(obj/machinery/M as obj in world)
	set name = "Overload Machine"
	set category = "Malfunction"
	if (istype(M, /obj/machinery))
		for(var/datum/AI_Module/small/overload_machine/overload in usr:current_modules)
			if(overload.uses > 0)
				overload.uses --
				for(var/mob/V in hearers(M, null))
					V.show_message("\blue You hear a loud electrical buzzing sound!", 2)
				spawn(50)
					explosion(get_turf(M), 0,1,1,0)
					del(M)
			else usr << "Out of uses."
	else usr << "That's not a machine."

/datum/AI_Module/small/blackout
	module_name = "Blackout"
	mod_pick_name = "blackout"
	uses = 3

/client/proc/blackout()
	set category = "Malfunction"
	set name = "Blackout"
	for(var/datum/AI_Module/small/blackout/blackout in usr:current_modules)
		if(blackout.uses > 0)
			blackout.uses --
			for(var/obj/machinery/power/apc/apc in world)
				if(prob(30*apc.overload))
					apc.overload_lighting()
				else apc.overload++
		else usr << "Out of uses."

/datum/AI_Module/small/interhack
	module_name = "Hack intercept"
	mod_pick_name = "interhack"

/client/proc/interhack()
	set category = "Malfunction"
	set name = "Hack intercept"
	usr.verbs -= /client/proc/interhack
	ticker.mode:hack_intercept()

/datum/AI_Module/small/reactivate_camera
	module_name = "Reactivate camera"
	mod_pick_name = "recam"
	uses = 10

/client/proc/reactivate_camera(obj/machinery/camera/C as obj in world)
	set name = "Reactivate Camera"
	set category = "Malfunction"
	if (istype (C, /obj/machinery/camera))
		for(var/datum/AI_Module/small/reactivate_camera/camera in usr:current_modules)
			if(camera.uses > 0)
				if(!C.status)
					C.status = !C.status
					camera.uses --
					for(var/mob/V in viewers(src, null))
						V.show_message(text("\blue You hear a quiet click."))
				else
					usr << "This camera is either active, or not repairable."
			else usr << "Out of uses."
	else usr << "That's not a camera."


/datum/AI_Module/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/AI_Module/module_picker/New()
	src.possible_modules += new /datum/AI_Module/large/fireproof_core
	src.possible_modules += new /datum/AI_Module/large/upgrade_turrets
	src.possible_modules += new /datum/AI_Module/large/disable_rcd
	src.possible_modules += new /datum/AI_Module/small/overload_machine
	src.possible_modules += new /datum/AI_Module/small/interhack
	src.possible_modules += new /datum/AI_Module/small/blackout
	src.possible_modules += new /datum/AI_Module/small/reactivate_camera

/datum/AI_Module/module_picker/proc/use(user as mob)
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
		for(var/datum/AI_Module/large/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (50)<BR>"
		for(var/datum/AI_Module/small/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (15)<BR>"
		dat += "<HR>"

	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")
	return

/datum/AI_Module/module_picker/Topic(href, href_list)
	..()
	if (href_list["coreup"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/fireproof_core))
				already = 1
		if (!already)
			usr.verbs += /client/proc/fireproof_core
			usr:current_modules += new /datum/AI_Module/large/fireproof_core
			src.temp = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
			src.processing_time -= 50
		else src.temp = "This module is only needed once."

	else if (href_list["turret"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/upgrade_turrets))
				already = 1
		if (!already)
			usr.verbs += /client/proc/upgrade_turrets
			usr:current_modules += new /datum/AI_Module/large/upgrade_turrets
			src.temp = "Improves the firing speed and health of all AI turrets. This effect is permanent."
			src.processing_time -= 50
		else src.temp = "This module is only needed once."

	else if (href_list["rcd"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/disable_rcd))
				mod:uses += 1
				already = 1
		if (!already)
			usr:current_modules += new /datum/AI_Module/large/disable_rcd
			usr.verbs += /client/proc/disable_rcd
			src.temp = 	"Send a specialised pulse to break all RCD devices on the station."
		else src.temp = "Additional use added to RCD disabler."
		src.processing_time -= 50

	else if (href_list["overload"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/overload_machine))
				mod:uses += 2
				already = 1
		if (!already)
			usr.verbs += /client/proc/overload_machine
			usr:current_modules += new /datum/AI_Module/small/overload_machine
			src.temp = "Overloads an electrical machine, causing a small explosion. 2 uses."
		else src.temp = "Two additional uses added to Overload module."
		src.processing_time -= 15

	else if (href_list["blackout"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/blackout))
				mod:uses += 3
				already = 1
		if (!already)
			usr.verbs += /client/proc/blackout
			src.temp = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
			usr:current_modules += new /datum/AI_Module/small/blackout
		else src.temp = "Three additional uses added to Blackout module."
		src.processing_time -= 15

	else if (href_list["interhack"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/interhack))
				already = 1
		if (!already)
			usr.verbs += /client/proc/interhack
			src.temp = "Hacks the status upgrade from Cent. Com, removing any information about malfunctioning electrical systems."
			usr:current_modules += new /datum/AI_Module/small/interhack
			src.processing_time -= 15
		else src.temp = "This module is only needed once."

	else if (href_list["recam"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/reactivate_camera))
				mod:uses += 10
				already = 1
		if (!already)
			usr.verbs += /client/proc/reactivate_camera
			src.temp = "Reactivates a currently disabled camera. 10 uses."
			usr:current_modules += new /datum/AI_Module/small/reactivate_camera
		else src.temp = "Ten additional uses added to ReCam module."
		src.processing_time -= 15

	else
		if (href_list["temp"])
			src.temp = null
	src.use(usr)
	return
