#define CLEANBOT_CLEANING_TIME (1 SECONDS)

//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "cleanbot0"
	pass_flags = PASSMOB | PASSFLAPS
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service //true
	bot_type = CLEAN_BOT
	hackables = "cleaning software"
	path_image_color = "#993299"
	greyscale_config = /datum/greyscale_config/buckets_cleanbot
	possessed_message = "You are a cleanbot! Clean the station to the best of your ability!"
	///the bucket used to build us.
	var/obj/item/reagent_containers/cup/bucket/build_bucket

	///Flags indicating what kind of cleanables we should scan for to set as our target to clean.
	var/janitor_mode_flags = CLEANBOT_CLEAN_BLOOD
//	Selections: CLEANBOT_CLEAN_BLOOD | CLEANBOT_CLEAN_TRASH | CLEANBOT_CLEAN_PESTS | CLEANBOT_CLEAN_DRAWINGS

	///the base icon state, used in updating icons.
	var/base_icon = "cleanbot"
	///List of things cleanbots can target for cleaning.
	var/list/target_types
	///The current bot's target.
	var/atom/target

	///Currently attached weapon, usually a knife.
	var/obj/item/weapon

	/// if we have all the top titles, grant achievements to living mobs that gaze upon our cleanbot god
	var/ascended = FALSE
	///List of all stolen names the cleanbot currently has.
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

	///What ranks are prefixes to the name.
	var/static/list/prefixes = list(
		command_titles,
		security_titles,
		engineering_titles,
	)
	///What ranks are suffixes to the name.
	var/static/list/suffixes = list(
		research_titles,
		medical_titles,
		legal_titles,
	)

/mob/living/simple_animal/bot/cleanbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT

/mob/living/simple_animal/bot/cleanbot/medbay
	name = "Scrubs, MD"
	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_MEDICAL)
	bot_mode_flags = ~(BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED)

/mob/living/simple_animal/bot/cleanbot/Initialize(mapload, obj/item/reagent_containers/cup/bucket/bucket_obj)
	if(!bucket_obj)
		bucket_obj = new()
	bucket_obj.forceMove(src)

	. = ..()

	AddComponent(/datum/component/cleaner, CLEANBOT_CLEANING_TIME, \
		on_cleaned_callback = CALLBACK(src, TYPE_PROC_REF(/atom/, update_appearance), UPDATE_ICON))

	get_targets()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	GLOB.janitor_devices += src

/mob/living/simple_animal/bot/cleanbot/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /obj/item/reagent_containers/cup/bucket))
		if(build_bucket && build_bucket != arrived)
			qdel(build_bucket)
		build_bucket = arrived
		set_greyscale(build_bucket.greyscale_colors)
	return ..()

/mob/living/simple_animal/bot/cleanbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == build_bucket)
		build_bucket = null
	if(gone == weapon)
		weapon = null
		update_appearance(UPDATE_ICON)

/mob/living/simple_animal/bot/cleanbot/Destroy()
	QDEL_NULL(build_bucket)
	GLOB.janitor_devices -= src
	if(weapon)
		var/atom/drop_loc = drop_location()
		weapon.force = initial(weapon.force)
		drop_part(weapon, drop_loc)
	return ..()

/mob/living/simple_animal/bot/cleanbot/examine(mob/user)
	. = ..()
	if(!weapon)
		return .
	. += "[span_warning("Is that \a [weapon] taped to it...?")]"

	if(ascended && user.stat == CONSCIOUS && user.client)
		user.client.give_award(/datum/award/achievement/misc/cleanboss, user)

/mob/living/simple_animal/bot/cleanbot/update_icon_state()
	. = ..()
	switch(mode)
		if(BOT_CLEANING)
			icon_state = "[base_icon]-c"
		else
			icon_state = "[base_icon][get_bot_flag(bot_mode_flags, BOT_MODE_ON)]"

/mob/living/simple_animal/bot/cleanbot/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, base_icon))
		update_appearance(UPDATE_ICON)

/mob/living/simple_animal/bot/cleanbot/proc/deputize(obj/item/knife, mob/user)
	if(!in_range(src, user) || !user.transferItemToLoc(knife, src))
		balloon_alert(user, "couldn't attach!")
		return FALSE
	balloon_alert(user, "attached!")
	weapon = knife
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		weapon.force = weapon.force / 2
	add_overlay(image(icon = weapon.lefthand_file, icon_state = weapon.inhand_icon_state))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	return TRUE

/mob/living/simple_animal/bot/cleanbot/proc/update_titles()
	name = initial(name) //reset the name
	ascended = TRUE

	for(var/title in (prefixes + suffixes))
		for(var/title_name in title)
			if(!(title_name in stolen_valor))
				ascended = FALSE
				continue

			if(title_name in officers_titles)
				commissioned = TRUE
			if(title in prefixes)
				name = title[title_name] + " [name]"
			if(title in suffixes)
				name = "[name] " + title[title_name]

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	. = ..()
	target = null

/mob/living/simple_animal/bot/cleanbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!weapon || !has_gravity() || !iscarbon(AM))
		return

	var/mob/living/carbon/stabbed_carbon = AM
	if(stabbed_carbon.mind && !(stabbed_carbon.mind.assigned_role.title in stolen_valor))
		stolen_valor += stabbed_carbon.mind.assigned_role.title
		update_titles()

	zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	INVOKE_ASYNC(weapon, TYPE_PROC_REF(/obj/item, attack), stabbed_carbon, src)
	stabbed_carbon.Knockdown(20)

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/knife) && !user.combat_mode)
		balloon_alert(user, "attaching knife...")
		if(!do_after(user, 2.5 SECONDS, target = src))
			return
		deputize(attacking_item, user)
		return
	return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return

	if(weapon)
		weapon.force = initial(weapon.force)
	balloon_alert(user, "safeties disabled")
	audible_message(span_danger("[src] buzzes oddly!"))
	get_targets() //recalibrate target list
	return TRUE

/mob/living/simple_animal/bot/cleanbot/process_scan(atom/scan_target)
	if(iscarbon(scan_target))
		var/mob/living/carbon/scan_carbon = scan_target
		if(!(scan_carbon in view(DEFAULT_SCAN_RANGE, src)))
			return null
		if(scan_carbon.stat == DEAD)
			return null
		if(scan_carbon.body_position != LYING_DOWN)
			return null
		return scan_carbon
	if(is_type_in_typecache(scan_target, target_types))
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
			UnarmedAttack(victim, proximity_flag = TRUE) // Acid spray
		if(isopenturf(loc) && prob(15)) // Wets floors and spawns foam randomly
			UnarmedAttack(src, proximity_flag = TRUE)
	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(ismob(target) && isnull(process_scan(target)))
		target = null
	if(!target)
		target = scan(target_types)

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

		if(get_dist(src, target) <= 1)
			UnarmedAttack(target, proximity_flag = TRUE) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
			if(QDELETED(target)) //We done here.
				target = null
				mode = BOT_IDLE
				return

		if(target && path.len == 0 && (get_dist(src,target) > 1))
			path = get_path_to(src, target, max_distance=30, mintargetdist=1, id=access_card)
			mode = BOT_MOVING
			if(length(path) == 0)
				add_to_ignore(target)
				target = null

		if(path.len > 0 && target)
			if(!bot_move(path[path.len]))
				target = null
				mode = BOT_IDLE
			return

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	if(bot_cover_flags & BOT_COVER_EMAGGED) // When emagged, ignore cleanables and scan humans first.
		target_types = list(/mob/living/carbon)
		return

	//main targets
	target_types = list(
		/obj/effect/decal/cleanable/oil,
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/robot_debris,
		/obj/effect/decal/cleanable/molten_object,
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/ash,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/dirt,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/generic,
		/obj/effect/decal/cleanable/shreds,
		/obj/effect/decal/cleanable/glass,
		/obj/effect/decal/cleanable/wrapping,
		/obj/effect/decal/cleanable/glitter,
		/obj/effect/decal/cleanable/confetti,
		/obj/effect/decal/remains,
	)

	if(janitor_mode_flags & CLEANBOT_CLEAN_BLOOD)
		target_types += list(
			/obj/effect/decal/cleanable/xenoblood,
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/trail_holder,
		)

	if(janitor_mode_flags & CLEANBOT_CLEAN_PESTS)
		target_types += list(
			/mob/living/basic/cockroach,
			/mob/living/basic/mouse,
			/obj/effect/decal/cleanable/ants,
		)

	if(janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS)
		target_types += list(/obj/effect/decal/cleanable/crayon)

	if(janitor_mode_flags & CLEANBOT_CLEAN_TRASH)
		target_types += list(
			/obj/item/trash,
			/obj/item/food/deadmouse,
		)

	target_types = typecacheof(target_types)

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(ismopable(attack_target))
		mode = BOT_CLEANING
		update_icon_state()
		. = ..()
		target = null
		mode = BOT_IDLE

	else if(isitem(attack_target) || istype(attack_target, /obj/effect/decal))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [attack_target]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		attack_target.acid_act(75, 10)
		target = null
	else if(istype(attack_target, /mob/living/basic/cockroach) || ismouse(attack_target))
		var/mob/living/living_target = attack_target
		if(!living_target.stat)
			visible_message(span_danger("[src] smashes [living_target] with its mop!"))
			living_target.death()
		target = null

	else if(bot_cover_flags & BOT_COVER_EMAGGED) //Emag functions
		if(iscarbon(attack_target))
			var/mob/living/carbon/victim = attack_target
			if(victim.stat == DEAD)//cleanbots always finish the job
				target = null
				return

			victim.visible_message(
				span_danger("[src] sprays hydrofluoric acid at [victim]!"),
				span_userdanger("[src] sprays you with hydrofluoric acid!"))
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
		else if(attack_target == src) // Wets floors and spawns foam randomly
			if(prob(75))
				var/turf/open/current_floor = loc
				if(istype(current_floor))
					current_floor.MakeSlippery(TURF_WET_WATER, min_wet_time = 20 SECONDS, wet_time_to_add = 15 SECONDS)
			else
				visible_message(span_danger("[src] whirs and bubbles violently, before releasing a plume of froth!"))
				var/datum/effect_system/fluid_spread/foam/foam = new
				foam.set_up(2, holder = src, location = loc)
				foam.start()

/mob/living/simple_animal/bot/cleanbot/explode()
	var/atom/drop_loc = drop_location()
	build_bucket.forceMove(drop_loc)
	new /obj/item/assembly/prox_sensor(drop_loc)
	return ..()

// Variables sent to TGUI
/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()

	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["clean_blood"] = janitor_mode_flags & CLEANBOT_CLEAN_BLOOD
		data["custom_controls"]["clean_trash"] = janitor_mode_flags & CLEANBOT_CLEAN_TRASH
		data["custom_controls"]["clean_graffiti"] = janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS
		data["custom_controls"]["pest_control"] = janitor_mode_flags & CLEANBOT_CLEAN_PESTS
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("clean_blood")
			janitor_mode_flags ^= CLEANBOT_CLEAN_BLOOD
		if("pest_control")
			janitor_mode_flags ^= CLEANBOT_CLEAN_PESTS
		if("clean_trash")
			janitor_mode_flags ^= CLEANBOT_CLEAN_TRASH
		if("clean_graffiti")
			janitor_mode_flags ^= CLEANBOT_CLEAN_DRAWINGS
	get_targets()

#undef CLEANBOT_CLEANING_TIME
