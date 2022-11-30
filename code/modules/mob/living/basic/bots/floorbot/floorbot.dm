//Floorbot
/mob/living/basic/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	health = 25
	maxHealth = 25

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_CONSTRUCTION)
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
	hackables = "floor construction protocols"
	ai_controller = /datum/ai_controller/basic_controller/bot/floorbot

	//path_image_color = "#FFA500"

	var/floorbot_mode_flags = FLOORBOT_FIX_FLOORS
	var/targetdirection = NONE

	var/maxtiles = 100
	var/obj/item/stack/tile/tilestack
	var/toolbox = /obj/item/storage/toolbox/mechanical
	var/toolbox_color = ""

/mob/living/basic/bot/floorbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	toolbox_color = new_toolbox_color
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/engi_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/station_engineer]
	access_card.add_access(engi_trim.access + engi_trim.wildcard_access)
	base_access = access_card.access.Copy()

	if(toolbox_color == "s")
		health = 100
		maxHealth = 100

/mob/living/basic/bot/floorbot/Exited(atom/movable/gone, direction)
	if(tilestack == gone)
		if(tilestack && tilestack.max_amount < tilestack.amount) //split the stack if it exceeds its normal max_amount
			var/iterations = round(tilestack.amount/tilestack.max_amount) //round() without second arg floors the value
			for(var/a in 1 to iterations)
				if(a == iterations)
					tilestack.split_stack(null, tilestack.amount - tilestack.max_amount)
				else
					tilestack.split_stack(null, tilestack.max_amount)
		tilestack = null


/mob/living/basic/bot/floorbot/reset_bot(caller, turf/waypoint, message)
	. = ..()
	toggle_magnet(FALSE)

/mob/living/basic/bot/floorbot/attackby(obj/item/W , mob/user, params)
	if(istype(W, /obj/item/stack/tile/iron))
		to_chat(user, span_notice("The floorbot can produce normal tiles itself."))
		return
	if(istype(W, /obj/item/stack/tile))
		var/old_amount = tilestack ? tilestack.amount : 0
		var/obj/item/stack/tile/tiles = W
		if(tilestack)
			if(!tiles.can_merge(tilestack))
				to_chat(user, span_warning("Different custom tiles are already inside the floorbot."))
				return
			if(tilestack.amount >= maxtiles)
				to_chat(user, span_warning("The floorbot can't hold any more custom tiles."))
				return
			tiles.merge(tilestack, maxtiles)
		else
			if(tiles.amount > maxtiles)
				tilestack = tilestack.split_stack(null, maxtiles)
			else
				tilestack = W
			tilestack.forceMove(src)
		to_chat(user, span_notice("You load [tilestack.amount - old_amount] tiles into the floorbot. It now contains [tilestack.amount] tiles."))
		return
	else
		..()

/mob/living/basic/bot/floorbot/emag_act(mob/user)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		to_chat(user, span_danger("[src] buzzes and beeps."))

///mobs should use move_resist instead of anchored.
/mob/living/basic/bot/floorbot/proc/toggle_magnet(engage = TRUE, change_icon = TRUE)
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

// Variables sent to TGUI
/mob/living/basic/bot/floorbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["tile_hull"] = (floorbot_mode_flags & FLOORBOT_AUTO_TILE)
		data["custom_controls"]["place_tiles"] =  (floorbot_mode_flags & FLOORBOT_PLACE_TILES)
		data["custom_controls"]["place_custom"] = (floorbot_mode_flags & FLOORBOT_REPLACE_TILES)
		data["custom_controls"]["repair_damage"] = (floorbot_mode_flags & FLOORBOT_FIX_FLOORS)
		data["custom_controls"]["traction_magnets"] = !!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		data["custom_controls"]["tile_stack"] = 0
		data["custom_controls"]["line_mode"] = FALSE
		if(tilestack)
			data["custom_controls"]["tile_stack"] = tilestack.amount
		if(targetdirection)
			data["custom_controls"]["line_mode"] = dir2text(targetdirection)
	return data

// Actions received from TGUI
/mob/living/basic/bot/floorbot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("place_custom")
			floorbot_mode_flags ^=  FLOORBOT_REPLACE_TILES
		if("place_tiles")
			floorbot_mode_flags ^=  FLOORBOT_PLACE_TILES
		if("repair_damage")
			floorbot_mode_flags ^=  FLOORBOT_FIX_FLOORS
		if("tile_hull")
			floorbot_mode_flags ^=  FLOORBOT_AUTO_TILE
		if("traction_magnets")
			toggle_magnet(!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT), FALSE)
		if("eject_tiles")
			if(tilestack)
				tilestack.forceMove(drop_location())
		if("line_mode")
			var/setdir = tgui_input_list(usr, "Select construction direction", "Direction", list("north", "east", "south", "west", "disable"))
			if(isnull(setdir))
				return
			switch(setdir)
				if("north")
					targetdirection = NORTH
				if("south")
					targetdirection = SOUTH
				if("east")
					targetdirection = EAST
				if("west")
					targetdirection = WEST
				if("disable")
					targetdirection = NONE

/mob/living/basic/bot/floorbot/update_icon_state()
	. = ..()
	icon_state = "[toolbox_color]floorbot[(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/floorbot/explode()
	var/atom/Tsec = drop_location()

	drop_part(toolbox, Tsec)

	new /obj/item/assembly/prox_sensor(Tsec)

	if(tilestack)
		tilestack.forceMove(drop_location())

	new /obj/item/stack/tile/iron/base(Tsec, 1)
	return ..()


/mob/living/basic/bot/floorbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(A))
		repair(A)
	else
		..()


/mob/living/basic/bot/floorbot/proc/grief(var/turf/open/floor/griefed_floor)
	if(isplatingturf(griefed_floor))
		griefed_floor.ReplaceWithLattice()
	else
		griefed_floor.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	audible_message(span_danger("[src] makes an excited booping sound."))


/mob/living/basic/bot/floorbot/proc/repair(turf/target_turf)
	if(isspaceturf(target_turf)) //If we are fixing an area not part of pure space, it is
		toggle_magnet()
		visible_message(span_notice("[targetdirection ? "[src] begins installing a bridge plating." : "[src] begins to repair the hole."] "))
		if(!do_after(src, 50, target = target_turf))
			return FALSE
		if(floorbot_mode_flags & FLOORBOT_AUTO_TILE) //Build the floor and include a tile.
			if(floorbot_mode_flags & FLOORBOT_REPLACE_TILES && tilestack)
				target_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)	//make sure a hull is actually below the floor tile
				tilestack.place_tile(target_turf, src)
				if(!tilestack)
					speak("Requesting refill of custom floor tiles to continue replacing.")
				return TRUE
			else
				target_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)	//make sure a hull is actually below the floor tile
				target_turf.PlaceOnTop(/turf/open/floor/iron, flags = CHANGETURF_INHERIT_AIR)
				return TRUE
		else //Build a hull plating without a floor tile.
			target_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE

	else
		var/turf/open/floor/target_floor = target_turf
		var/success = FALSE
		var/was_replacing = floorbot_mode_flags & FLOORBOT_REPLACE_TILES //It could change in the meantime, so cache it.

		if(target_floor.broken || target_floor.burnt || isplatingturf(target_floor))
			toggle_magnet()
			visible_message(span_notice("[src] begins [(target_floor.broken || target_floor.burnt) ? "repairing the floor" : "placing a floor tile"]."))
			if(do_after(src, 50, target = target_floor) && mode == BOT_REPAIRING)
				success = TRUE

		else if(was_replacing && tilestack && target_floor.type != tilestack.turf_type)
			toggle_magnet()
			visible_message(span_notice("[src] begins replacing the floor tiles."))
			if(do_after(src, 50, target = target_turf) && mode == BOT_REPAIRING && tilestack)
				success = TRUE

		if(success)
			var/area/is_this_maints = get_area(target_floor)
			if(was_replacing && tilestack)	//turn the tile into plating (if needed), then replace it
				target_floor = target_floor.make_plating(TRUE) || target_floor
				tilestack.place_tile(target_floor, src)
				if(!tilestack)
					speak("Requesting refill of custom floor tiles to continue replacing.")
			else if(target_floor.broken || target_floor.burnt)	//repair the tile and reset it to be undamaged (rather than replacing it)
				target_floor.broken = FALSE
				target_floor.burnt = FALSE
				target_floor.update_appearance()
			else if(istype(is_this_maints, /area/station/maintenance))	//place catwalk if it's plating and we're in maints
				target_floor.PlaceOnTop(/turf/open/floor/catwalk_floor, flags = CHANGETURF_INHERIT_AIR)
			else	//place normal tile if it's plating anywhere else
				target_floor = target_floor.make_plating(TRUE) || target_floor
				target_floor.PlaceOnTop(/turf/open/floor/iron, flags = CHANGETURF_INHERIT_AIR)
			return TRUE

