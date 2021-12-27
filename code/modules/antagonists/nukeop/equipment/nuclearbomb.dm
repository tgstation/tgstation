/// TRUE only if the station was actually hit by the nuke, otherwise FALSE
GLOBAL_VAR_INIT(station_was_nuked, FALSE)
GLOBAL_VAR(station_nuke_source)

/obj/machinery/nuclearbomb
	name = "nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/timer_set = 90
	var/minimum_timer_set = 90
	var/maximum_timer_set = 3600

	var/numeric_input = ""
	var/ui_mode = NUKEUI_AWAIT_DISK

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

/obj/machinery/nuclearbomb/Initialize(mapload)
	. = ..()
	countdown = new(src)
	GLOB.nuke_list += src
	core = new /obj/item/nuke_core(src)
	STOP_PROCESSING(SSobj, core)
	update_appearance()
	SSpoints_of_interest.make_point_of_interest(src)
	previous_level = get_security_level()

/obj/machinery/nuclearbomb/Destroy()
	safety = FALSE
	if(!exploding)
		// If we're not exploding, set the alert level back to normal
		set_safety()
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
	switch(off_station)
		if(0)
			if(get_antag_minds(/datum/antagonist/nukeop).len && syndies_escaped())
				return CINEMATIC_NUKE_WIN
			else
				return CINEMATIC_ANNIHILATION
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
		update_ui_mode()
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		add_fingerprint(user)
		return

	switch(deconstruction_state)
		if(NUKESTATE_INTACT)
			if(istype(I, /obj/item/screwdriver/nuke))
				to_chat(user, span_notice("You start removing [src]'s front panel's screws..."))
				if(I.use_tool(src, user, 60, volume=100))
					deconstruction_state = NUKESTATE_UNSCREWED
					to_chat(user, span_notice("You remove the screws from [src]'s front panel."))
					update_appearance()
				return

		if(NUKESTATE_PANEL_REMOVED)
			if(I.tool_behaviour == TOOL_WELDER)
				if(!I.tool_start_check(user, amount=1))
					return
				to_chat(user, span_notice("You start cutting [src]'s inner plate..."))
				if(I.use_tool(src, user, 80, volume=100, amount=1))
					to_chat(user, span_notice("You cut [src]'s inner plate."))
					deconstruction_state = NUKESTATE_WELDED
					update_appearance()
				return
		if(NUKESTATE_CORE_EXPOSED)
			if(istype(I, /obj/item/nuke_core_container))
				var/obj/item/nuke_core_container/core_box = I
				to_chat(user, span_notice("You start loading the plutonium core into [core_box]..."))
				if(do_after(user,50,target=src))
					if(core_box.load(core, user))
						to_chat(user, span_notice("You load the plutonium core into [core_box]."))
						deconstruction_state = NUKESTATE_CORE_REMOVED
						update_appearance()
						core = null
					else
						to_chat(user, span_warning("You fail to load the plutonium core into [core_box]. [core_box] has already been used!"))
				return
			if(istype(I, /obj/item/stack/sheet/iron))
				if(!I.tool_start_check(user, amount=20))
					return

				to_chat(user, span_notice("You begin repairing [src]'s inner metal plate..."))
				if(I.use_tool(src, user, 100, amount=20))
					to_chat(user, span_notice("You repair [src]'s inner metal plate. The radiation is contained."))
					deconstruction_state = NUKESTATE_PANEL_REMOVED
					STOP_PROCESSING(SSobj, core)
					update_appearance()
				return
	. = ..()

/obj/machinery/nuclearbomb/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(deconstruction_state)
		if(NUKESTATE_UNSCREWED)
			to_chat(user, span_notice("You start removing [src]'s front panel..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You remove [src]'s front panel."))
				deconstruction_state = NUKESTATE_PANEL_REMOVED
				update_appearance()
			return TRUE
		if(NUKESTATE_WELDED)
			to_chat(user, span_notice("You start prying off [src]'s inner plate..."))
			if(tool.use_tool(src, user, 30, volume=100))
				to_chat(user, span_notice("You pry off [src]'s inner plate. You can see the core's green glow!"))
				deconstruction_state = NUKESTATE_CORE_EXPOSED
				update_appearance()
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

/obj/machinery/nuclearbomb/update_icon_state()
	if(deconstruction_state != NUKESTATE_INTACT)
		icon_state = "nuclearbomb_base"
		return ..()
	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
			icon_state = "nuclearbomb_base"
		if(NUKE_ON_TIMING)
			icon_state = "nuclearbomb_timing"
		if(NUKE_ON_EXPLODING)
			icon_state = "nuclearbomb_exploding"
	return ..()

/obj/machinery/nuclearbomb/update_overlays()
	. += ..()
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
			playsound(loc, 'sound/items/timer.ogg', volume, FALSE)

/obj/machinery/nuclearbomb/proc/update_ui_mode()
	if(exploded)
		ui_mode = NUKEUI_EXPLODED
		return

	if(!auth)
		ui_mode = NUKEUI_AWAIT_DISK
		return

	if(timing)
		ui_mode = NUKEUI_TIMING
		return

	if(!safety)
		ui_mode = NUKEUI_AWAIT_ARM
		return

	if(!yes_code)
		ui_mode = NUKEUI_AWAIT_CODE
		return

	ui_mode = NUKEUI_AWAIT_TIMER

/obj/machinery/nuclearbomb/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBomb", name)
		ui.open()

/obj/machinery/nuclearbomb/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth

	var/hidden_code = (ui_mode == NUKEUI_AWAIT_CODE && numeric_input != "ERROR")

	var/current_code = ""
	if(hidden_code)
		while(length(current_code) < length(numeric_input))
			current_code = "[current_code]*"
	else
		current_code = numeric_input
	while(length(current_code) < 5)
		current_code = "[current_code]-"

	var/first_status
	var/second_status
	switch(ui_mode)
		if(NUKEUI_AWAIT_DISK)
			first_status = "DEVICE LOCKED"
			if(timing)
				second_status = "TIME: [get_time_left()]"
			else
				second_status = "AWAIT DISK"
		if(NUKEUI_AWAIT_CODE)
			first_status = "INPUT CODE"
			second_status = "CODE: [current_code]"
		if(NUKEUI_AWAIT_TIMER)
			first_status = "INPUT TIME"
			second_status = "TIME: [current_code]"
		if(NUKEUI_AWAIT_ARM)
			first_status = "DEVICE READY"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_TIMING)
			first_status = "DEVICE ARMED"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_EXPLODED)
			first_status = "DEVICE DEPLOYED"
			second_status = "THANK YOU"

	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored

	return data

/obj/machinery/nuclearbomb/ui_act(action, params)
	. = ..()
	if(.)
		return
	playsound(src, "terminal_type", 20, FALSE)
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
					playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					auth = I
					. = TRUE
			update_ui_mode()
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("C")
						if(auth && ui_mode == NUKEUI_AWAIT_ARM)
							set_safety()
							yes_code = FALSE
							playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
							update_ui_mode()
						else
							playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
						numeric_input = ""
						. = TRUE
					if("E")
						switch(ui_mode)
							if(NUKEUI_AWAIT_CODE)
								if(numeric_input == r_code)
									numeric_input = ""
									yes_code = TRUE
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									. = TRUE
								else
									playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
									numeric_input = "ERROR"
							if(NUKEUI_AWAIT_TIMER)
								var/number_value = text2num(numeric_input)
								if(number_value)
									timer_set = clamp(number_value, minimum_timer_set, maximum_timer_set)
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									set_safety()
									. = TRUE
							else
								playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
						update_ui_mode()
					if("0","1","2","3","4","5","6","7","8","9")
						if(numeric_input != "ERROR")
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							else
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
							. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("arm")
			if(auth && yes_code && !safety && !exploded)
				playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
				set_active()
				update_ui_mode()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("anchor")
			if(auth && yes_code)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				set_anchor()
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)

/obj/machinery/nuclearbomb/proc/set_anchor()
	if(isinspace() && !anchored)
		to_chat(usr, span_warning("There is nothing to anchor to!"))
	else
		set_anchored(!anchored)

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
	update_appearance()

/obj/machinery/nuclearbomb/proc/set_active()
	var/turf/our_turf = get_turf(src)
	if(safety)
		to_chat(usr, span_danger("The safety is still on."))
		return
	timing = !timing
	if(timing)
		message_admins("\The [src] was armed at [ADMIN_VERBOSEJMP(our_turf)] by [ADMIN_LOOKUPFLW(usr)].")
		log_game("\The [src] was armed at [loc_name(our_turf)] by [key_name(usr)].")
		previous_level = get_security_level()
		detonation_timer = world.time + (timer_set * 10)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(TRACK_INFILTRATOR)

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_ARMED, src)

		countdown.start()
		set_security_level("delta")
	else
		message_admins("\The [src] at [ADMIN_VERBOSEJMP(our_turf)] was disarmed by [ADMIN_LOOKUPFLW(usr)].")
		log_game("\The [src] at [loc_name(our_turf)] was disarmed by [key_name(usr)].")
		detonation_timer = null
		set_security_level(previous_level)
		for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
			S.switch_mode_to(initial(S.mode))
			S.alert = FALSE
		countdown.stop()

		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_DISARMED, src)

	update_appearance()

/obj/machinery/nuclearbomb/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/nuclearbomb/blob_act(obj/structure/blob/B)
	if(exploding)
		return
	qdel(src)

/obj/machinery/nuclearbomb/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

#define NUKERANGE 127
/obj/machinery/nuclearbomb/proc/explode()
	if(safety)
		timing = FALSE
		return

	exploding = TRUE
	yes_code = FALSE
	safety = TRUE
	update_appearance()
	sound_to_playing_players('sound/machines/alarm.ogg')
	if(SSticker?.mode)
		SSticker.roundend_check_paused = TRUE
	addtimer(CALLBACK(src, .proc/actually_explode), 100)

/obj/machinery/nuclearbomb/proc/actually_explode()
	if(!core)
		Cinematic(CINEMATIC_NUKE_NO_CORE,world)
		SSticker.roundend_check_paused = FALSE
		return

	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)

	var/off_station = 0
	var/turf/bomb_location = get_turf(src)
	var/area/A = get_area(bomb_location)

	if(bomb_location && is_station_level(bomb_location.z))
		if(istype(A, /area/space))
			off_station = NUKE_NEAR_MISS
		else if((bomb_location.x < (128-NUKERANGE)) || (bomb_location.x > (128+NUKERANGE)) || (bomb_location.y < (128-NUKERANGE)) || (bomb_location.y > (128+NUKERANGE)))
			off_station = NUKE_NEAR_MISS
		else // station actually nuked
			off_station = STATION_DESTROYED_NUKE
			GLOB.station_was_nuked = TRUE
	else if(bomb_location.onSyndieBase())
		off_station = NUKE_SYNDICATE_BASE
	else
		off_station = NUKE_MISS_STATION

	if(off_station < NUKE_MISS_STATION)
		SSshuttle.registerHostileEnvironment(src)
		SSshuttle.lockdown = TRUE
	//Cinematic
	GLOB.station_nuke_source = off_station
	really_actually_explode(off_station)
	SSticker.roundend_check_paused = FALSE

/obj/machinery/nuclearbomb/proc/really_actually_explode(off_station)
	var/turf/bomb_location = get_turf(src)
	Cinematic(get_cinematic_type(off_station),world,CALLBACK(SSticker,/datum/controller/subsystem/ticker/proc/station_explosion_detonation,src))
	if(off_station == STATION_DESTROYED_NUKE)
		INVOKE_ASYNC(GLOBAL_PROC,.proc/KillEveryoneOnStation)
		return
	if(off_station != NUKE_NEAR_MISS) // Don't kill people in the station if the nuke missed, even if we are technically on the same z-level
		INVOKE_ASYNC(GLOBAL_PROC,.proc/KillEveryoneOnZLevel, bomb_location.z)

/obj/machinery/nuclearbomb/proc/get_cinematic_type(off_station)
	if(off_station < NUKE_NEAR_MISS)
		return CINEMATIC_SELFDESTRUCT
	else
		return CINEMATIC_SELFDESTRUCT_MISS

/obj/machinery/nuclearbomb/beer
	name = "\improper Nanotrasen-brand nuclear fission explosive"
	desc = "One of the more successful achievements of the Nanotrasen Corporate Warfare Division, their nuclear fission explosives are renowned for being cheap to produce and devastatingly effective. Signs explain that though this particular device has been decommissioned, every Nanotrasen station is equipped with an equivalent one, just in case. All Captains carefully guard the disk needed to detonate them - at least, the sign says they do. There seems to be a tap on the back."
	proper_bomb = FALSE
	var/obj/structure/reagent_dispensers/beerkeg/keg

/obj/machinery/nuclearbomb/beer/Initialize(mapload)
	. = ..()
	keg = new(src)
	QDEL_NULL(core)

/obj/machinery/nuclearbomb/beer/examine(mob/user)
	. = ..()
	if(keg.reagents.total_volume)
		to_chat(user, span_notice("It has [keg.reagents.total_volume] unit\s left."))
	else
		to_chat(user, span_danger("It's empty."))

/obj/machinery/nuclearbomb/beer/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		W.afterattack(keg, user, TRUE) // redirect refillable containers to the keg, allowing them to be filled
		return TRUE // pretend we handled the attack, too.
	if(istype(W, /obj/item/nuke_core_container))
		to_chat(user, span_notice("[src] has had its plutonium core removed as a part of being decommissioned."))
		return TRUE
	return ..()

/obj/machinery/nuclearbomb/beer/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm()
		return
	if(is_station_level(bomb_location.z))
		addtimer(CALLBACK(src, .proc/really_actually_explode), 110)
	else
		visible_message(span_notice("[src] fizzes ominously."))
		addtimer(CALLBACK(src, .proc/local_foam), 110)

/obj/machinery/nuclearbomb/beer/proc/disarm()
	detonation_timer = null
	exploding = FALSE
	exploded = TRUE
	set_security_level(previous_level)
	for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
		S.switch_mode_to(initial(S.mode))
		S.alert = FALSE
	countdown.stop()
	update_appearance()

/obj/machinery/nuclearbomb/beer/proc/local_foam()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(200, get_turf(src), R)
	foam.start()
	disarm()

/obj/machinery/nuclearbomb/beer/proc/stationwide_foam()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")

	for (var/obj/machinery/atmospherics/components/unary/vent_scrubber/vent in GLOB.machines)
		var/turf/vent_turf = get_turf(vent)
		if (!vent_turf || !is_station_level(vent_turf.z) || vent.welded)
			continue

		var/datum/reagents/beer = new /datum/reagents(1000)
		beer.my_atom = vent
		beer.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)
		beer.create_foam(/datum/effect_system/foam_spread, 200)

		CHECK_TICK

/obj/machinery/nuclearbomb/beer/really_actually_explode()
	disarm()
	stationwide_foam()

/proc/KillEveryoneOnStation()
	for(var/mob/living/victim as anything in GLOB.mob_living_list)
		if(victim.stat != DEAD && is_station_level(victim.z))
			to_chat(victim, span_userdanger("You are shredded to atoms!"))
			victim.gib()

/proc/KillEveryoneOnZLevel(z)
	if(!z)
		return
	for(var/_victim in GLOB.mob_living_list)
		var/mob/living/victim = _victim
		if(victim.stat != DEAD && victim.z == z)
			to_chat(victim, span_userdanger("You are shredded to atoms!"))
			victim.gib()

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
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/fake = FALSE
	var/turf/lastlocation
	var/last_disk_move

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 6, -6, 0)

	if(!fake)
		SSpoints_of_interest.make_point_of_interest(src)
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
		/// How comfy is our disk?
		var/disk_comfort_level = 0

		//Go through and check for items that make disk comfy
		for(var/obj/comfort_item in loc)
			if(istype(comfort_item, /obj/item/bedsheet) || istype(comfort_item, /obj/structure/bed))
				disk_comfort_level++

		if(last_disk_move < world.time - 5000 && prob((world.time - 5000 - last_disk_move)*0.0001))
			var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
			if(istype(loneop) && loneop.occurrences < loneop.max_occurrences)
				loneop.weight += 1
				if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
					if(disk_comfort_level >= 2)
						visible_message(span_notice("[src] sleeps soundly. Sleep tight, disky."))
					message_admins("[src] is stationary in [ADMIN_VERBOSEJMP(newturf)]. The weight of Lone Operative is now [loneop.weight].")
				log_game("[src] is stationary for too long in [loc_name(newturf)], and has increased the weight of the Lone Operative event to [loneop.weight].")

	else
		lastlocation = newturf
		last_disk_move = world.time
		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
		if(istype(loneop) && loneop.occurrences < loneop.max_occurrences && prob(loneop.weight))
			loneop.weight = max(loneop.weight - 1, 0)
			if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
				message_admins("[src] is on the move (currently in [ADMIN_VERBOSEJMP(newturf)]). The weight of Lone Operative is now [loneop.weight].")
			log_game("[src] being on the move has reduced the weight of the Lone Operative event to [loneop.weight].")

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || HAS_TRAIT(user, TRAIT_DISK_VERIFIER) || (user.mind && HAS_TRAIT(user.mind, TRAIT_DISK_VERIFIER)))
		. += span_warning("The serial numbers on [src] are incorrect.")

/*
 * You can't accidentally eat the nuke disk, bro
 */
/obj/item/disk/nuclear/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	M.visible_message(span_warning("[M] looks like [M.p_theyve()] just bitten into something important."), \
						span_warning("Wait, is this the nuke disk?"))

	return discover_after

/obj/item/disk/nuclear/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/H = I
		if(H.nuke_disk)
			to_chat(user, span_notice("Wait... what?"))
			qdel(H.nuke_disk)
			H.nuke_disk = null
			return
		user.visible_message(span_warning("[user] captures [src]!"), span_userdanger("You've got the disk! Defend it with your life!"))
		forceMove(H)
		H.nuke_disk = src
		return TRUE
	return ..()

/obj/item/disk/nuclear/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, /atom/proc/add_atom_colour, (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message(span_suicide("[user] is destroyed by the nuclear blast!"))
	user.adjustOxyLoss(200)
	user.death(0)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
