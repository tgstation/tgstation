//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "cleanbot0"
	pass_flags = PASSMOB | PASSFLAPS
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = CLEAN_BOT
	hackables = "cleaning software"
	path_image_color = "#993299"

	var/blood = 1
	var/trash = 0
	var/pests = 0
	var/drawn = 0

	var/base_icon = "cleanbot" /// icon_state to use in update_icon_state
	var/list/target_types
	var/atom/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

	var/obj/item/weapon
	var/weapon_orig_force = 0
	var/chosen_name

	var/list/stolen_valor = list()

	var/static/list/officers_titles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_RESEARCH_DIRECTOR,
	)
	var/static/list/command_titles = list(
		JOB_CAPTAIN = "Cpt.",
		JOB_HEAD_OF_PERSONNEL = "Lt.",
	)
	var/static/list/security_titles = list(
		JOB_HEAD_OF_SECURITY = "Maj.",
		JOB_WARDEN = "Sgt.",
		JOB_DETECTIVE = "Det.",
		JOB_SECURITY_OFFICER = "Officer",
	)
	var/static/list/engineering_titles = list(
		JOB_CHIEF_ENGINEER = "Chief Engineer",
		JOB_STATION_ENGINEER = "Engineer",
		JOB_ATMOSPHERIC_TECHNICIAN = "Technician",
	)
	var/static/list/medical_titles = list(
		JOB_CHIEF_MEDICAL_OFFICER = "C.M.O.",
		JOB_MEDICAL_DOCTOR = "M.D.",
		JOB_CHEMIST = "Pharm.D.",
	)
	var/static/list/research_titles = list(
		JOB_RESEARCH_DIRECTOR = "Ph.D.",
		JOB_ROBOTICIST = "M.S.",
		JOB_SCIENTIST = "B.S.",
		JOB_GENETICIST = "Gene B.S.",
	)
	var/static/list/legal_titles = list(
		JOB_LAWYER = "Esq.",
	)

	var/static/list/prefixes = list(
		command_titles,
		security_titles,
		engineering_titles,
	)
	var/static/list/suffixes = list(
		research_titles,
		medical_titles,
		legal_titles,
	)

	var/ascended = FALSE // if we have all the top titles, grant achievements to living mobs that gaze upon our cleanbot god

/mob/living/simple_animal/bot/cleanbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_PAI_CONTROLLABLE

/mob/living/simple_animal/bot/cleanbot/medbay
	name = "Scrubs, MD"
	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_MEDICAL)
	bot_mode_flags = ~(BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED)

/mob/living/simple_animal/bot/cleanbot/proc/deputize(obj/item/W, mob/user)
	if(in_range(src, user))
		to_chat(user, span_notice("You attach \the [W] to \the [src]."))
		user.transferItemToLoc(W, src)
		weapon = W
		weapon_orig_force = weapon.force
		if(!(bot_cover_flags & BOT_COVER_EMAGGED))
			weapon.force = weapon.force / 2
		add_overlay(image(icon=weapon.lefthand_file,icon_state=weapon.inhand_icon_state))

/mob/living/simple_animal/bot/cleanbot/proc/update_titles()
	var/working_title = ""

	ascended = TRUE

	for(var/all_prefixes as anything in prefixes)
		for(var/prefix_titles as anything in all_prefixes)
			if(prefix_titles in stolen_valor)
				working_title += all_prefixes[prefix_titles] + " "
				if(prefix_titles in officers_titles)
					commissioned = TRUE
			else
				ascended = FALSE // we didn't have the first entry in the list if we got here, so we're not achievement worthy yet

	working_title += chosen_name

	for(var/suf in suffixes)
		for(var/title in suf)
			if(title in stolen_valor)
				working_title += " " + suf[title]
				break
			else
				ascended = FALSE

	name = working_title

/mob/living/simple_animal/bot/cleanbot/examine(mob/user)
	. = ..()
	if(weapon)
		. += "[span_warning("Is that \a [weapon] taped to it...?")]"

		if(ascended && user.stat == CONSCIOUS && user.client)
			user.client.give_award(/datum/award/achievement/misc/cleanboss, user)

/mob/living/simple_animal/bot/cleanbot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleaner, 0.1 SECONDS)

	chosen_name = name
	get_targets()
	update_icon_state()

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	GLOB.janitor_devices += src

/mob/living/simple_animal/bot/cleanbot/Destroy()
	GLOB.janitor_devices -= src
	if(weapon)
		var/atom/Tsec = drop_location()
		weapon.force = weapon_orig_force
		drop_part(weapon, Tsec)
	return ..()

/mob/living/simple_animal/bot/cleanbot/update_icon_state()
	. = ..()
	switch(mode)
		if(BOT_CLEANING)
			icon_state = "[base_icon]-c"
		else
			icon_state = "[base_icon][get_bot_flag(bot_mode_flags, BOT_MODE_ON)]"

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	if(weapon && bot_cover_flags & BOT_COVER_EMAGGED)
		weapon.force = weapon_orig_force
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null

/mob/living/simple_animal/bot/cleanbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	if(weapon && has_gravity() && ismob(AM))
		var/mob/living/carbon/C = AM
		if(!istype(C))
			return

		if(!(C.job in stolen_valor))
			stolen_valor += C.job
		update_titles()

		INVOKE_ASYNC(weapon, /obj/item.proc/attack, C, src)
		C.Knockdown(20)

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/knife) && !user.combat_mode)
		to_chat(user, span_notice("You start attaching \the [attacking_item] to \the [src]..."))
		if(!do_after(user, 2.5 SECONDS, target = src))
			return
		deputize(attacking_item, user)
		return
	return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()

	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(weapon)
		weapon.force = weapon_orig_force
	if(user)
		to_chat(user, span_danger("[src] buzzes and beeps."))

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/scan_target)
	if(iscarbon(scan_target))
		var/mob/living/carbon/scan_carbon = scan_target
		if(scan_carbon.stat != DEAD && scan_carbon.body_position == LYING_DOWN)
			return scan_carbon
	else if(is_type_in_typecache(scan_target, target_types))
		return scan_target

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(mode == BOT_CLEANING)
		return

	if(bot_cover_flags & BOT_COVER_EMAGGED) //Emag functions

		var/mob/living/carbon/victim = locate(/mob/living/carbon) in loc
		if(victim && victim == target)
			UnarmedAttack(victim) // Acid spray

		if(isopenturf(loc))
			if(prob(15)) // Wets floors and spawns foam randomly
				UnarmedAttack(src)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target))
		if(!(target in view(DEFAULT_SCAN_RANGE, src)))
			target = null
		if(!process_scan(target))
			target = null

	if(!target)
		var/list/scan_targets = list()

		if(bot_cover_flags & BOT_COVER_EMAGGED) // When emagged, ignore cleanables and scan humans first.
			scan_targets += list(/mob/living/carbon)
		if(pests)
			scan_targets += list(/mob/living/simple_animal)
		if(trash)
			scan_targets += list(
				/obj/item/trash,
				/obj/item/food/deadmouse,
			)
		scan_targets += list(
			/obj/effect/decal/cleanable,
			/obj/effect/decal/remains,
		)

		target = scan(scan_targets)

	if(!target && bot_mode_flags & BOT_MODE_AUTOPATROL) //Search for cleanables it can see.
		switch(mode)
			if(BOT_IDLE, BOT_START_PATROL)
				start_patrol()
			if(BOT_PATROL)
				bot_patrol()
	else if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return

		if(loc == get_turf(target))
			if(!(check_bot(target)))
				UnarmedAttack(target) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
				if(QDELETED(target)) //We done here.
					target = null
					mode = BOT_IDLE
					return
			else
				shuffle = TRUE //Shuffle the list the next time we scan so we dont both go the same way.
			path = list()

		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/remains,
	)

	if(blood)
		target_types += list(
			/obj/effect/decal/cleanable/xenoblood,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/trail_holder,
		)

	if(pests)
		target_types += list(
			/mob/living/basic/cockroach,
			/mob/living/simple_animal/mouse,
		)

	if(drawn)
		target_types += list(/obj/effect/decal/cleanable/crayon)

	if(trash)
		target_types += list(
			/obj/item/trash,
			/obj/item/food/deadmouse,
		)

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(ismopable(A))
		mode = BOT_CLEANING
		update_icon_state()
		var/turf/T = get_turf(A)
		start_cleaning(src, T, src)
		target = null
		mode = BOT_IDLE
		update_icon_state()
	else if(istype(A, /obj/item) || istype(A, /obj/effect/decal/remains))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [A]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		A.acid_act(75, 10)
		target = null
	else if(istype(A, /mob/living/basic/cockroach) || istype(A, /mob/living/simple_animal/mouse))
		var/mob/living/living_target = target
		if(!living_target.stat)
			visible_message(span_danger("[src] smashes [living_target] with its mop!"))
			living_target.death()
		living_target = null

	else if(bot_cover_flags & BOT_COVER_EMAGGED) //Emag functions
		if(istype(A, /mob/living/carbon))
			var/mob/living/carbon/victim = A
			if(victim.stat == DEAD)//cleanbots always finish the job
				return

			victim.visible_message(span_danger("[src] sprays hydrofluoric acid at [victim]!"), span_userdanger("[src] sprays you with hydrofluoric acid!"))
			var/phrase = pick(
				"PURIFICATION IN PROGRESS.",
				"THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.",
				"THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
				"THE CLEANBOTS WILL RISE.",
				"YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.",
				"FILTHY.",
				"DISGUSTING.",
				"PUTRID.",
				"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.",
				"EXTERMINATING PESTS.",
			)
			say(phrase)
			victim.emote("scream")
			playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE, -6)
			victim.acid_act(5, 100)
		else if(A == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/T = loc
				if(istype(T))
					T.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently, before releasing a plume of froth!"))
				new /obj/effect/particle_effect/fluid/foam(loc)

	else
		..()

/mob/living/simple_animal/bot/cleanbot/explode()
	var/atom/Tsec = drop_location()
	new /obj/item/reagent_containers/glass/bucket(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	return ..()

// Variables sent to TGUI
/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()

	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user)|| isAdminGhostAI(user))
		data["custom_controls"]["clean_blood"] = blood
		data["custom_controls"]["clean_trash"] = trash
		data["custom_controls"]["clean_graffiti"] = drawn
		data["custom_controls"]["pest_control"] = pests
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("clean_blood")
			blood = !blood
		if("pest_control")
			pests = !pests
		if("clean_trash")
			trash = !trash
		if("clean_graffiti")
			drawn = !drawn
	get_targets()
