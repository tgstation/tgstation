//Floorbot
/mob/living/simple_animal/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	health = 25
	maxHealth = 25

	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
	model = "Floorbot"
	bot_core = /obj/machinery/bot_core/floorbot
	window_id = "autofloor"
	window_name = "Automatic Station Floor Repairer v1.1"
	path_image_color = "#FFA500"

	var/process_type //Determines what to do when process_scan() receives a target. See process_scan() for details.
	var/targetdirection
	var/replacetiles = FALSE
	var/placetiles = FALSE
	var/maxtiles = 100
	var/obj/item/stack/tile/tilestack
	var/fixfloors = TRUE
	var/autotile = FALSE
	var/max_targets = 50
	var/turf/target
	var/oldloc = null
	var/toolbox = /obj/item/storage/toolbox/mechanical
	var/toolbox_color = ""

	#define HULL_BREACH		1
	#define LINE_SPACE_MODE		2
	#define FIX_TILE		3
	#define AUTO_TILE		4
	#define PLACE_TILE		5
	#define REPLACE_TILE		6
	#define TILE_EMAG		7

/mob/living/simple_animal/bot/floorbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	toolbox_color = new_toolbox_color
	update_icon()
	var/datum/job/engineer/J = new/datum/job/engineer
	access_card.access += J.get_access()
	prev_access = access_card.access
	if(toolbox_color == "s")
		health = 100
		maxHealth = 100

/mob/living/simple_animal/bot/floorbot/Exited(atom/movable/A, atom/newloc)
	if(A == tilestack)
		if(tilestack && tilestack.max_amount < tilestack.amount) //split the stack if it exceeds its normal max_amount
			var/iterations = round(tilestack.amount/tilestack.max_amount) //round() without second arg floors the value
			for(var/a in 1 to iterations)
				if(a == iterations)
					tilestack.split_stack(null, tilestack.amount - tilestack.max_amount)
				else
					tilestack.split_stack(null, tilestack.max_amount)
		tilestack = null

/mob/living/simple_animal/bot/floorbot/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/floorbot/turn_off()
	..()
	update_icon()

/mob/living/simple_animal/bot/floorbot/bot_reset()
	..()
	target = null
	oldloc = null
	ignore_list = list()
	toggle_magnet(FALSE)

/mob/living/simple_animal/bot/floorbot/set_custom_texts()
	text_hack = "You corrupt [name]'s construction protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/floorbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Floor Repairer Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Special tiles: "
	if(tilestack)
		dat += "<A href='?src=[REF(src)];operation=eject'>Loaded \[[tilestack.amount]/[maxtiles]\]</a><BR>"
	else
		dat += "None Loaded<BR>"

	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user) || isAdminGhostAI(user))
		dat += "Add tiles to new hull plating: <A href='?src=[REF(src)];operation=autotile'>[autotile ? "Yes" : "No"]</A><BR>"
		dat += "Place floor tiles: <A href='?src=[REF(src)];operation=place'>[placetiles ? "Yes" : "No"]</A><BR>"
		dat += "Replace existing floor tiles with custom tiles: <A href='?src=[REF(src)];operation=replace'>[replacetiles ? "Yes" : "No"]</A><BR>"
		dat += "Repair damaged tiles and platings: <A href='?src=[REF(src)];operation=fix'>[fixfloors ? "Yes" : "No"]</A><BR>"
		dat += "Traction Magnets: <A href='?src=[REF(src)];operation=magnet'>[HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT) ? "Engaged" : "Disengaged"]</A><BR>"
		dat += "Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"
		var/bmode
		if(targetdirection)
			bmode = dir2text(targetdirection)
		else
			bmode = "disabled"
		dat += "Line Mode : <A href='?src=[REF(src)];operation=linemode'>[bmode]</A><BR>"

	return dat

/mob/living/simple_animal/bot/floorbot/attackby(obj/item/W , mob/user, params)
	if(istype(W, /obj/item/stack/tile/plasteel))
		to_chat(user, "<span class='notice'>The floorbot can produce normal tiles itself.</span>")
		return
	if(istype(W, /obj/item/stack/tile))
		var/old_amount = tilestack ? tilestack.amount : 0
		var/obj/item/stack/tile/tiles = W
		if(tilestack)
			if(!tiles.can_merge(tilestack))
				to_chat(user, "<span class='warning'>Different custom tiles are already inside the floorbot.</span>")
				return
			if(tilestack.amount >= maxtiles)
				to_chat(user, "<span class='warning'>The floorbot can't hold any more custom tiles.</span>")
				return
			tiles.merge(tilestack, maxtiles)
		else
			if(tiles.amount > maxtiles)
				tilestack = tilestack.split_stack(null, maxtiles)
			else
				tilestack = W
			tilestack.forceMove(src)
		to_chat(user, "<span class='notice'>You load [tilestack.amount - old_amount] tiles into the floorbot. It now contains [tilestack.amount] tiles.</span>")
		return
	else
		..()

/mob/living/simple_animal/bot/floorbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

///mobs should use move_resist instead of anchored.
/mob/living/simple_animal/bot/floorbot/proc/toggle_magnet(engage = TRUE, change_icon = TRUE)
	if(engage)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		move_resist = INFINITY
		if(change_icon)
			icon_state = "[toolbox_color]floorbot-c"
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		move_resist = initial(move_resist)
		if(change_icon)
			update_icon()

/mob/living/simple_animal/bot/floorbot/Topic(href, href_list)
	if(..())
		return TRUE

	switch(href_list["operation"])
		if("replace")
			replacetiles = !replacetiles
		if("place")
			placetiles = !placetiles
		if("fix")
			fixfloors = !fixfloors
		if("autotile")
			autotile = !autotile
		if("magnet")
			toggle_magnet(!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT), FALSE)
		if("eject")
			if(tilestack)
				tilestack.forceMove(drop_location())

		if("linemode")
			var/setdir = input("Select construction direction:") as null|anything in list("north","east","south","west","disable")
			switch(setdir)
				if("north")
					targetdirection = 1
				if("south")
					targetdirection = 2
				if("east")
					targetdirection = 4
				if("west")
					targetdirection = 8
				if("disable")
					targetdirection = null
	update_controls()

/mob/living/simple_animal/bot/floorbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_REPAIRING)
		return

	if(prob(5))
		audible_message("[src] makes an excited booping beeping sound!")

	//Normal scanning procedure. We have tiles loaded, are not emagged.
	if(!target && emagged < 2)
		if(targetdirection != null) //The bot is in line mode.
			var/turf/T = get_step(src, targetdirection)
			if(isspaceturf(T)) //Check for space
				target = T
				process_type = LINE_SPACE_MODE
			if(isfloorturf(T)) //Check for floor
				target = T
		if(!target)
			process_type = HULL_BREACH //Ensures the floorbot does not try to "fix" space areas or shuttle docking zones.
			target = scan(/turf/open/space)

		if(!target && placetiles) //Finds a floor without a tile and gives it one.
			process_type = PLACE_TILE //The target must be the floor and not a tile. The floor must not already have a floortile.
			target = scan(/turf/open/floor)

		if(!target && fixfloors) //Repairs damaged floors and tiles.
			process_type = FIX_TILE
			target = scan(/turf/open/floor)

		if(!target && replacetiles && tilestack) //Replace a floor tile with custom tile
			process_type = REPLACE_TILE //The target must be a tile. The floor must already have a floortile.
			target = scan(/turf/open/floor)

	if(!target && emagged == 2) //We are emagged! Time to rip up the floors!
		process_type = TILE_EMAG
		target = scan(/turf/open/floor)


	if(!target)

		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == target || loc == get_turf(target))
			if(check_bot(target))	//Target is not defined at the parent
				shuffle = TRUE
				if(prob(50))	//50% chance to still try to repair so we dont end up with 2 floorbots failing to fix the last breach
					target = null
					path = list()
					return
			if(isturf(target) && emagged < 2)
				repair(target)
			else if(emagged == 2 && isfloorturf(target))
				var/turf/open/floor/F = target
				toggle_magnet()
				mode = BOT_REPAIRING
				if(isplatingturf(F))
					F.ReplaceWithLattice()
				else
					F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
				audible_message("<span class='danger'>[src] makes an excited booping sound.</span>")
				addtimer(CALLBACK(src, .proc/go_idle), 0.5 SECONDS)
			path = list()
			return
		if(path.len == 0)
			if(!isturf(target))
				var/turf/TL = get_turf(target)
				path = get_path_to(src, TL, /turf/proc/Distance_cardinal, 0, 30, id=access_card,simulated_only = FALSE)
			else
				path = get_path_to(src, target, /turf/proc/Distance_cardinal, 0, 30, id=access_card,simulated_only = FALSE)

			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				mode = BOT_IDLE
				return
		else if( !bot_move(target) )
			target = null
			mode = BOT_IDLE
			return



	oldloc = loc

/mob/living/simple_animal/bot/floorbot/proc/go_idle()
	toggle_magnet(FALSE)
	mode = BOT_IDLE
	target = null

/mob/living/simple_animal/bot/floorbot/proc/is_hull_breach(turf/t) //Ignore space tiles not considered part of a structure, also ignores shuttle docking areas.
	var/area/t_area = get_area(t)
	if(t_area && (t_area.name == "Space" || findtext(t_area.name, "huttle")))
		return FALSE
	else
		return TRUE

//Floorbots, having several functions, need sort out special conditions here.
/mob/living/simple_animal/bot/floorbot/process_scan(scan_target)
	var/result
	var/turf/open/floor/F
	move_resist = initial(move_resist)
	switch(process_type)
		if(HULL_BREACH) //The most common job, patching breaches in the station's hull.
			if(is_hull_breach(scan_target)) //Ensure that the targeted space turf is actually part of the station, and not random space.
				result = scan_target
				move_resist = INFINITY //Prevent the floorbot being blown off-course while trying to reach a hull breach.
		if(LINE_SPACE_MODE) //Space turfs in our chosen direction are considered.
			if(get_dir(src, scan_target) == targetdirection)
				result = scan_target
				move_resist = INFINITY
		if(PLACE_TILE)
			F = scan_target
			if(isplatingturf(F)) //The floor must not already have a tile.
				result = F
		if(REPLACE_TILE)
			F = scan_target
			if(isfloorturf(F) && !isplatingturf(F)) //The floor must already have a tile.
				result = F
		if(FIX_TILE)	//Selects only damaged floors.
			F = scan_target
			if(istype(F) && (F.broken || F.burnt))
				result = F
		if(TILE_EMAG) //Emag mode! Rip up the floor and cause breaches to space!
			F = scan_target
			if(!isplatingturf(F))
				result = F
		else //If no special processing is needed, simply return the result.
			result = scan_target
	return result

/mob/living/simple_animal/bot/floorbot/proc/repair(turf/target_turf)
	if(check_bot_working(target_turf))
		add_to_ignore(target_turf)
		target = null
		playsound(src, 'sound/effects/whistlereset.ogg', 50, TRUE)
		return
	if(isspaceturf(target_turf))
		//Must be a hull breach or in line mode to continue.
		if(!is_hull_breach(target_turf) && !targetdirection)
			target = null
			return
	else if(!isfloorturf(target_turf))
		return
	if(isspaceturf(target_turf)) //If we are fixing an area not part of pure space, it is
		toggle_magnet()
		visible_message("<span class='notice'>[targetdirection ? "[src] begins installing a bridge plating." : "[src] begins to repair the hole."] </span>")
		mode = BOT_REPAIRING
		if(do_after(src, 50, target = target_turf) && mode == BOT_REPAIRING)
			if(autotile) //Build the floor and include a tile.
				if(replacetiles && tilestack)
					tilestack.place_tile(target_turf)
					if(!tilestack)
						speak("Requesting refill of custom floor tiles to continue replacing.")
				else
					target_turf.PlaceOnTop(/turf/open/floor/plasteel, flags = CHANGETURF_INHERIT_AIR)
			else //Build a hull plating without a floor tile.
				target_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)

	else
		var/turf/open/floor/F = target_turf
		var/success = FALSE
		var/was_replacing = replacetiles

		if(F.broken || F.burnt || isplatingturf(F))
			toggle_magnet()
			mode = BOT_REPAIRING
			visible_message("<span class='notice'>[src] begins [(F.broken || F.burnt) ? "repairing the floor" : "placing a floor tile"].</span>")
			if(do_after(src, 50, target = F) && mode == BOT_REPAIRING)
				success = TRUE

		else if(replacetiles && tilestack && F.type != tilestack.turf_type)
			toggle_magnet()
			mode = BOT_REPAIRING
			visible_message("<span class='notice'>[src] begins replacing the floor tiles.</span>")
			if(do_after(src, 50, target = target_turf) && mode == BOT_REPAIRING && tilestack)
				success = TRUE

		if(success)
			F = F.make_plating(TRUE) || F
			if(was_replacing && tilestack)
				tilestack.place_tile(F)
				if(!tilestack)
					speak("Requesting refill of custom floor tiles to continue replacing.")
			else
				F.PlaceOnTop(/turf/open/floor/plasteel, flags = CHANGETURF_INHERIT_AIR)

	if(!QDELETED(src))
		go_idle()

/mob/living/simple_animal/bot/floorbot/update_icon()
	icon_state = "[toolbox_color]floorbot[on]"

/mob/living/simple_animal/bot/floorbot/explode()
	on = FALSE
	target = null
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/atom/Tsec = drop_location()

	drop_part(toolbox, Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	if(tilestack)
		tilestack.forceMove(drop_location())

	if(prob(50))
		drop_part(robot_arm, Tsec)

	new /obj/item/stack/tile/plasteel(Tsec, 1)

	do_sparks(3, TRUE, src)
	..()

/obj/machinery/bot_core/floorbot
	req_one_access = list(ACCESS_CONSTRUCTION, ACCESS_ROBOTICS)

/mob/living/simple_animal/bot/floorbot/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(A))
		repair(A)
	else
		..()

/**
 * Checks a given turf to see if another floorbot is there, working as well.
 */
/mob/living/simple_animal/bot/floorbot/proc/check_bot_working(turf/active_turf)
	if(isturf(active_turf))
		for(var/mob/living/simple_animal/bot/floorbot/robot in active_turf)
			if(robot.mode == BOT_REPAIRING)
				return TRUE
	return FALSE
