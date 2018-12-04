/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/timer_set = 90
	var/default_timer_set = 90
	var/minimum_timer_set = 90
	var/maximum_timer_set = 3600
	var/ui_style = "nanotrasen"

	var/numeric_input = ""
	var/timing = FALSE
	var/exploding = FALSE
	var/exploded = FALSE
	var/detonation_timer = null
	var/r_code = "ADMIN"
	var/yes_code = FALSE
	var/safety = TRUE
	var/obj/item/disk/nuclear/auth = null
	use_power = NO_POWER_USE
	var/previous_level = ""
	var/obj/item/nuke_core/core = null
	var/deconstruction_state = NUKESTATE_INTACT
	var/lights = ""
	var/interior = ""
	var/proper_bomb = TRUE //Please
	var/obj/effect/countdown/nuclearbomb/countdown

/obj/machinery/nuclearbomb/Initialize()
	. = ..()
	countdown = new(src)
	GLOB.nuke_list += src
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_icon()
	GLOB.poi_list |= src
	previous_level = get_security_level()

/obj/machinery/nuclearbomb/Destroy()
	safety = FALSE
	if(!exploding)
		// If we're not exploding, set the alert level back to normal
		set_safety()
	GLOB.poi_list -= src
	GLOB.nuke_list -= src
	QDEL_NULL(countdown)
	QDEL_NULL(core)
	. = ..()

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(exploding)
		to_chat(user, "It is in the process of exploding. Perhaps reviewing your affairs is in order.")
	if(timing)
		to_chat(user, "There are [get_time_left()] seconds until detonation.")

/obj/machinery/nuclearbomb/selfdestruct
	name = "station self-destruct terminal"
	desc = "For when it all gets too much to bear. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = TRUE //stops it being moved

/obj/machinery/nuclearbomb/syndicate
	//ui_style = "syndicate" // actually the nuke op bomb is a stole nt bomb

/obj/machinery/nuclearbomb/syndicate/get_cinematic_type(off_station)
	var/datum/game_mode/nuclear/NM = SSticker.mode
	switch(off_station)
		if(0)
			if(istype(NM) && !NM.nuke_team.syndies_escaped())
				return CINEMATIC_ANNIHILATION
			else
				return CINEMATIC_NUKE_WIN
		if(1)
			return CINEMATIC_NUKE_MISS
		if(2)
			return CINEMATIC_NUKE_FAR
	return CINEMATIC_NUKE_FAR

/obj/machinery/nuclearbomb/proc/disk_check(obj/item/disk/nuclear/D)
	if(D.fake)
		say("Authentication failure; disk not recognised.")
		return FALSE
	else
		return TRUE

/obj/machinery/nuclearbomb/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/disk/nuclear))
		if(!disk_check(I))
			return
		if(!user.transferItemToLoc(I, src))
			return
		auth = I
		add_fingerprint(user)
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/screwdriver/nuke))
				to_chat(user, "<span class='notice'>You start removing [src]'s front panel's screws...</span>")
				if(I.use_tool(src, user, 60, volume=100))
					deconstruction_state = NUKESTATE_UNSCREWED
					to_chat(user, "<span class='notice'>You remove the screws from [src]'s front panel.</span>")
					update_icon()
				return

		if(NUKESTATE_PANEL_REMOVED)
			if(I.tool_behaviour == TOOL_WELDER)
				if(!I.tool_start_check(user, amount=1))
					return
				to_chat(user, "<span class='notice'>You start cutting [src]'s inner plate...</span>")
				if(I.use_tool(src, user, 80, volume=100, amount=1))
					to_chat(user, "<span class='notice'>You cut [src]'s inner plate.</span>")
					deconstruction_state = NUKESTATE_WELDED
					update_icon()
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				to_chat(user, "<span class='notice'>You start loading the plutonium core into [core_box]...</span>")
				if(do_after(user,50,target=src))
					if(core_box.load(core, user))
						to_chat(user, "<span class='notice'>You load the plutonium core into [core_box].</span>")
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_icon()
						core = null
					else
						to_chat(user, "<span class='warning'>You fail to load the plutonium core into [core_box]. [core_box] has already been used!</span>")
				return
			if(istype(I, /obj/item/stack/sheet/metal))
				if(!I.tool_start_check(user, amount=20))
					return

				to_chat(user, "<span class='notice'>You begin repairing [src]'s inner metal plate...</span>")
				if(I.use_tool(src, user, 100, amount=20))
					to_chat(user, "<span class='notice'>You repair [src]'s inner metal plate. The radiation is contained.</span>")
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					STOP_PROCESSING(SSobj, core)
					update_icon()
				return
	. = ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			to_chat(user, "<span class='notice'>You start removing [src]'s front panel...</span>")
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, "<span class='notice'>You remove [src]'s front panel.</span>")
				deconstruction_state = NUKESTATE_PANEL_REMOVED
				update_icon()
			return TRUE
		if(NUKESTATE_WELDED)
			to_chat(user, "<span class='notice'>You start prying off [src]'s inner plate...</span>")
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, "<span class='notice'>You pry off [src]'s inner plate. You can see the core's green glow!</span>")
				deconstruction_state = NUKESTATE_CORE_EXPOSED
				update_icon()
				START_PROCESSING(SSobj, core)
			return TRUE

/obj/machinery/nuclearbomb/proc/get_nuke_state()
	if(exploding)
		return NUKE_ON_EXPLODING
	if(timing)
		return NUKE_ON_TIMING
	if(safety)
		return NUKE_OFF_LOCKED
	else
		return NUKE_OFF_UNLOCKED

/obj/machinery/nuclearbomb/update_icon()
	if(deconstruction_state == NUKESTATE_INTACT)
		switch(get_nuke_state())
			if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
				icon_state = "nuclearbomb_base"
				update_icon_interior()
				update_icon_lights()
			if(NUKE_ON_TIMING)
				cut_overlays()
				icon_state = "nuclearbomb_timing"
			if(NUKE_ON_EXPLODING)
				cut_overlays()
				icon_state = "nuclearbomb_exploding"
	else
		icon_state = "nuclearbomb_base"
		update_icon_interior()
		update_icon_lights()

/obj/machinery/nuclearbomb/proc/update_icon_interior()
	cut_overlay(interior)
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			interior = "panel-unscrewed"
		if(NUKESTATE_PANEL_REMOVED)
			interior = "panel-removed"
		if(NUKESTATE_WELDED)
			interior = "plate-welded"
		if(NUKESTATE_CORE_EXPOSED)
			interior = "plate-removed"
		if(NUKESTATE_CORE_REMOVED)
			interior = "core-removed"
		if(NUKESTATE_INTACT)
			return
	add_overlay(interior)

/obj/machinery/nuclearbomb/proc/update_icon_lights()
	if(lights)
		cut_overlay(lights)
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED)
			lights = ""
			return
		if(NUKE_OFF_UNLOCKED)
			lights = "lights-safety"
		if(NUKE_ON_TIMING)
			lights = "lights-timing"
		if(NUKE_ON_EXPLODING)
			lights = "lights-exploding"
	add_overlay(lights)

/obj/machinery/nuclearbomb/process()
	if(timing && !exploding)
		if(detonation_timer < world.time)
			explode()
		else
			var/volume = (get_time_left() <= 20 ? 30 : 5)
			playsound(loc, 'sound/items/timer.ogg', volume, 0)

/obj/machinery/nuclearbomb/ui_interact(mob/user, ui_key="main", datum/tgui/ui=null, force_open=0, datum/tgui/master_ui=null, datum/ui_state/state=GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "nuclear_bomb", name, 500, 600, master_ui, state)
		ui.set_style(ui_style)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth
	data["code_approved"] = yes_code
	var/first_status
	if(auth)
		if(yes_code)
			first_status = timing ? "Func/Set" : "Functional"
		else
			first_status = "Auth S2."
	else
		if(timing)
			first_status = "Set"
		else
			first_status = "Auth S1."
	var/second_status = exploded ? "Warhead triggered, thanks for flying Nanotrasen" : (safety ? "Safe" : "Engaged")
	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored
	data["safety"] = safety
	data["timing"] = timing
	data["time_left"] = get_time_left()

	data["timer_set"] = timer_set
	data["timer_is_not_default"] = timer_set != default_timer_set
	data["timer_is_not_min"] = timer_set != minimum_timer_set
	data["timer_is_not_max"] = timer_set != maximum_timer_set

	var/message = "AUTH"
	if(auth)
		message = "[numeric_input]"
		if(yes_code)
			message = "*****"
	data["message"] = message

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
		if("insert_disk")
			if(!auth)
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					auth = I
					. = TRUE
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("R")
						numeric_input = ""
						yes_code = FALSE
						. = TRUE
					if("E")
						if(numeric_input == r_code)
							numeric_input = ""
							yes_code = TRUE
							. = TRUE
						else
							numeric_input = "ERROR"
					if("0","1","2","3","4","5","6","7","8","9")
						if(numeric_input != "ERROR")
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							. = TRUE
		if("timer")
			if(auth && yes_code)
				var/change = params["change"]
				if(change == "reset")
					timer_set = default_timer_set
				else if(change == "decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				else if(change == "increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				else if(change == "input")
					var/user_input = input(usr, "Set time to detonation.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = CLAMP(N,minimum_timer_set,maximum_timer_set)
				. = TRUE
		if("safety")
			if(auth && yes_code && !exploded)
				set_safety()
		if("anchor")
			if(auth && yes_code)
				set_anchor()
		if("toggle_timer")
			if(auth && yes_code && !safety && !exploded)
				set_active()


/obj/machinery/nuclearbomb/proc/set_anchor()
	if(!isinspace())
		anchored = !anchored
	else
		to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")

/obj/machinery/nuclearbomb/proc/set_safety()
	safety = !safety
	if(safety)
		if(timing)
			set_security_level(previous_level)
			for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
				S.switch_mode_to(initial(S.mode))
				S.alert = FALSE
		timing = FALSE
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/proc/set_active()
	if(safety)
		to_chat(usr, "<span class='danger'>The safety is still on.</span>")
		return
	timing = !timing
	if(timing)
		previous_level = get_security_level()
		detonation_timer = world.time + (timer_set * 10)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(TRACK_INFILTRATOR)
		countdown.start()
		set_security_level("delta")
	else
		detonation_timer = null
		set_security_level(previous_level)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(initial(S.mode))
			S.alert = FALSE
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(exploding)
		return
	qdel(src)

/obj/machinery/nuclearbomb/tesla_act(power, tesla_flags)
	..()
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 127
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_icon()
	sound_to_playing_players('sound/machines/alarm.ogg')
	if(SSticker && SSticker.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, .proc/actually_explode), 100)

/obj/machinery/nuclearbomb/proc/actually_explode()
	if(!core)
		Cinematic(CINEMATIC_NUKE_NO_CORE,world)
		SSticker.roundend_check_paused = FALSE
		return

	GLOB.enter_allowed = FALSE

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	var/area/A = get_area(bomb_location)
	if(bomb_location && is_station_level(bomb_location.z))
		if(istype(A, /area/space))
			off_station = NUKE_NEAR_MISS
		if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = NUKE_NEAR_MISS
	else if(bomb_location.onSyndieBase())
		off_station = NUKE_SYNDICATE_BASE
	else
		off_station = NUKE_MISS_STATION

	if(off_station < 2)
		SSshuttle.registerHostileEnvironment(src)
		SSshuttle.lockdown = TRUE

	//Cinematic
	SSticker.mode.OnNukeExplosion(off_station)
	really_actually_explode(off_station)
	SSticker.roundend_check_paused = FALSE

/obj/machinery/nuclearbomb/proc/really_actually_explode(off_station)
	Cinematic(get_cinematic_type(off_station),world,CALLBACK(SSticker,/datum/controller/subsystem/ticker/proc/station_explosion_detonation,src))
	INVOKE_ASYNC(GLOBAL_PROC,.proc/KillEveryoneOnZLevel, z)

/obj/machinery/nuclearbomb/proc/get_cinematic_type(off_station)
	if(off_station < 2)
		return CINEMATIC_SELFDESTRUCT
	else
		return CINEMATIC_SELFDESTRUCT_MISS

/obj/machinery/nuclearbomb/beer
	name = "Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	var/obj/structure/reagent_dispensers/beerkeg/keg

/obj/machinery/nuclearbomb/beer/Initialize()
	. = ..()
	keg = new(src)
	QDEL_NULL(core)

/obj/machinery/nuclearbomb/beer/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		to_chat(user, "<span class='notice'>It has [keg.reagents.total_volume] unit\s left.</span>")
	else
		to_chat(user, "<span class='danger'>It's empty.</span>")

/obj/machinery/nuclearbomb/beer/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		W.afterattack(keg, user, TRUE) 	// redirect refillable containers to the keg, allowing them to be filled
		return TRUE 										// pretend we handled the attack, too.
	if(istype(W, /obj/item/nuke_core_container))
		to_chat(user, "<span class='notice'>[src] has had its plutonium core removed as a part of being decommissioned.</span>")
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/actually_explode()
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm()
		return
	if(is_station_level(bomb_location.z))
		var/datum/round_event_control/E = locate(/datum/round_event_control/vent_clog/beer) in SSevents.control
		if(E)
			E.runEvent()
		addtimer(CALLBACK(src, .proc/really_actually_explode), 110)
	else
		visible_message("<span class='notice'>[src] fizzes ominously.</span>")
		addtimer(CALLBACK(src, .proc/fizzbuzz), 110)

/obj/machinery/nuclearbomb/beer/proc/disarm()
	detonation_timer = null
	exploding = FALSE
	exploded = TRUE
	set_security_level(previous_level)
	for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
		S.switch_mode_to(initial(S.mode))
		S.alert = FALSE
	countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/beer/proc/fizzbuzz()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent("beer", 100)

	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(200, get_turf(src), R)
	foam.start()
	disarm()

/obj/machinery/nuclearbomb/beer/really_actually_explode()
	disarm()

/proc/KillEveryoneOnZLevel(z)
	if(!z)
		return
	for(var/mob/M in GLOB.mob_list)
		if(M.stat != DEAD && M.z == z)
			M.gib()

/*
This is here to make the tiles around the station mininuke change when it's armed.
*/

/obj/machinery/nuclearbomb/selfdestruct/set_anchor()
	return

/obj/machinery/nuclearbomb/selfdestruct/set_active()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

/obj/machinery/nuclearbomb/selfdestruct/set_safety()
	..()
	if(timing)
		SSmapping.add_nuke_threat(src)
	else
		SSmapping.remove_nuke_threat(src)

//==========DAT FUKKEN DISK===============
/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	persistence_replacement = /obj/item/disk/nuclear/fake
	max_integrity = 250
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/fake = FALSE
	var/turf/lastlocation
	var/last_disk_move

/obj/item/disk/nuclear/Initialize()
	. = ..()
	if(!fake)
		GLOB.poi_list |= src
		last_disk_move = world.time
		START_PROCESSING(SSobj, src)

/obj/item/disk/nuclear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, !fake)

/obj/item/disk/nuclear/process()
	if(fake)
		STOP_PROCESSING(SSobj, src)
		CRASH("A fake nuke disk tried to call process(). Who the fuck and how the fuck")
	var/turf/newturf = get_turf(src)
	if(newturf && lastlocation == newturf)
		if(last_disk_move < world.time - 5000 && prob((world.time - 5000 - last_disk_move)*0.0001))
			var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
			if(istype(loneop))
				loneop.weight += 1
	else
		lastlocation = newturf
		last_disk_move = world.time
		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
		if(istype(loneop) && prob(loneop.weight))
			loneop.weight = max(loneop.weight - 1, 0)

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || user.has_trait(TRAIT_DISK_VERIFIER) || (user.mind && user.mind.has_trait(TRAIT_DISK_VERIFIER)))
		to_chat(user, "<span class='warning'>The serial numbers on [src] are incorrect.</span>")

/obj/item/disk/nuclear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/H = I
		if(H.nuke_disk)
			to_chat(user, "<span class='notice'>Wait... what?</span>")
			qdel(H.nuke_disk)
			H.nuke_disk = null
			return
		user.visible_message("<span class='warning'>[user] captures [src]!</span>", "<span class='userdanger'>You've got the disk! Defend it with your life!</span>")
		forceMove(H)
		H.nuke_disk = src
		return TRUE
	return ..()

/obj/item/disk/nuclear/Destroy(force=FALSE)
	// respawning is handled in /obj/Destroy()
	if(force)
		GLOB.poi_list -= src
	. = ..()

/obj/item/disk/nuclear/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, 1)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, /atom/proc/add_atom_colour, (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message("<span class='suicide'>[user] was destroyed by the nuclear blast!</span>")
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
