///Hygiene bot, chases dirty people!
/mob/living/basic/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon_state = "hygienebot"
	pass_flags = PASSMOB | PASSFLAPS
	layer = MOB_UPPER_LAYER
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	ai_controller = /datum/ai_controller/basic_controller/bot/clean
	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = CLEAN_BOT
	hackables = "cleaning software"


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

/mob/living/basic/bot/cleanbot/autopatrol
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED | BOT_MODE_PAI_CONTROLLABLE

/mob/living/basic/bot/cleanbot/medbay
	name = "Scrubs, MD"
	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_MEDICAL)
	bot_mode_flags = ~(BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED)


/mob/living/basic/bot/cleanbot/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/cleaner, 1 SECONDS, \
		on_cleaned_callback = CALLBACK(src, .proc/finish_cleaning))

	update_targets()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	base_access = access_card.access.Copy()

	GLOB.janitor_devices += src

/mob/living/basic/bot/cleanbot/Destroy()
	GLOB.janitor_devices -= src
	if(weapon)
		var/atom/drop_loc = drop_location()
		weapon.force = initial(weapon.force)
		drop_part(weapon, drop_loc)
	return ..()

/mob/living/basic/bot/cleanbot/explode()
	var/atom/drop_loc = drop_location()
	new /obj/item/reagent_containers/cup/bucket(drop_loc)
	new /obj/item/assembly/prox_sensor(drop_loc)
	return ..()

/mob/living/basic/bot/cleanbot/proc/update_targets()
	if(bot_cover_flags & BOT_COVER_EMAGGED) // When emagged, ignore cleanables and scan humans first.
		target_types = list(/mob/living/carbon)

	else
		//main targets
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

		if(janitor_mode_flags & CLEANBOT_CLEAN_BLOOD)
			target_types += list(
				/obj/effect/decal/cleanable/xenoblood,
				/obj/effect/decal/cleanable/blood,
				/obj/effect/decal/cleanable/trail_holder,
			)

		if(janitor_mode_flags & CLEANBOT_CLEAN_PESTS)
			target_types += list(
				/mob/living/basic/cockroach,
				/mob/living/simple_animal/mouse,
			)

		if(janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS)
			target_types += list(/obj/effect/decal/cleanable/crayon)

		if(janitor_mode_flags & CLEANBOT_CLEAN_TRASH)
			target_types += list(
				/obj/item/trash,
				/obj/item/food/deadmouse,
			)

	if(istype(ai_controller, /datum/ai_controller/basic_controller/bot/clean))
		var/datum/ai_controller/basic_controller/bot/clean/cleanbot = ai_controller
		cleanbot.set_valid_targets(typecacheof(target_types))

/mob/living/basic/bot/cleanbot/examine(mob/user)
	. = ..()
	if(!weapon)
		return .
	. += "[span_warning("Is that \a [weapon] taped to it...?")]"

	if(ascended && user.stat == CONSCIOUS && user.client)
		user.client.give_award(/datum/award/achievement/misc/cleanboss, user)

/mob/living/basic/bot/cleanbot/update_icon_state()
	. = ..()
	switch(mode)
		if(BOT_CLEANING)
			icon_state = "[base_icon]-c"
		else
			icon_state = "[base_icon][(bot_mode_flags & BOT_MODE_ON)]"

/mob/living/basic/bot/cleanbot/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, base_icon))
		update_appearance(UPDATE_ICON)

/mob/living/basic/bot/cleanbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/knife) && !user.combat_mode)
		balloon_alert(user, "attaching knife...")
		if(!do_after(user, 2.5 SECONDS, target = src))
			return
		deputize(attacking_item, user)
		return
	return ..()

/mob/living/basic/bot/cleanbot/proc/deputize(obj/item/knife, mob/user)
	if(!in_range(src, user) || !user.transferItemToLoc(knife, src))
		balloon_alert(user, "couldn't attach!")
		return FALSE
	balloon_alert(user, "attached!")
	weapon = knife
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		weapon.force = weapon.force / 2
	add_overlay(image(icon = weapon.lefthand_file, icon_state = weapon.inhand_icon_state))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	return TRUE

/mob/living/basic/bot/cleanbot/proc/update_titles()
	name = initial(name) //reset the name
	ascended = TRUE

	for(var/title in (prefixes + suffixes))
		for(var/title_name in title)
			if(!(title_name in stolen_valor))
				ascended = FALSE
				continue

			if(title_name in officers_titles)
				if(istype(ai_controller, /datum/ai_controller/basic_controller/bot/clean))
					ai_controller.blackboard[BB_BOT_IS_COMMISSIONED] = TRUE
			if(title in prefixes)
				name = title[title_name] + " [name]"
			if(title in suffixes)
				name = "[name] " + title[title_name]

/mob/living/basic/bot/cleanbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!weapon || !has_gravity() || !iscarbon(AM))
		return

	var/mob/living/carbon/stabbed_carbon = AM
	if(!(stabbed_carbon.mind.assigned_role.title in stolen_valor))
		stolen_valor += stabbed_carbon.mind.assigned_role.title
		update_titles()

	zone_selected = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	INVOKE_ASYNC(weapon, /obj/item.proc/attack, stabbed_carbon, src)
	stabbed_carbon.Knockdown(20)


/mob/living/basic/bot/cleanbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return

	if(weapon)
		weapon.force = initial(weapon.force)
	if(user)
		to_chat(user, span_danger("[src] buzzes and beeps."))
	update_targets() //recalibrate target list

/mob/living/basic/bot/cleanbot/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == weapon)
		weapon = null
		update_appearance(UPDATE_ICON)
	return ..()

/mob/living/basic/bot/cleanbot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(ismopable(attack_target))
		update_icon_state()
		. = ..()

	else if(isitem(attack_target) || istype(attack_target, /obj/effect/decal))
		visible_message(span_danger("[src] sprays hydrofluoric acid at [attack_target]!"))
		playsound(src, 'sound/effects/spray2.ogg', 50, TRUE, -6)
		attack_target.acid_act(75, 10)
		finish_cleaning()
	else if(istype(attack_target, /mob/living/basic/cockroach) || ismouse(attack_target))
		var/mob/living/living_target = attack_target
		if(!living_target.stat)
			melee_attack(living_target)
			visible_message(span_danger("[src] smashes [living_target] with its mop!"))
			if(!living_target || living_target.stat == DEAD)//cleanbots always finish the job
				finish_cleaning()

	else if(bot_cover_flags & BOT_COVER_EMAGGED) //Emag functions
		if(iscarbon(attack_target))
			var/mob/living/carbon/victim = attack_target

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
			finish_cleaning()

// Variables sent to TGUI
/mob/living/basic/bot/cleanbot/ui_data(mob/user)
	var/list/data = ..()

	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user)|| isAdminGhostAI(user))
		data["custom_controls"]["clean_blood"] = janitor_mode_flags & CLEANBOT_CLEAN_BLOOD
		data["custom_controls"]["clean_trash"] = janitor_mode_flags & CLEANBOT_CLEAN_TRASH
		data["custom_controls"]["clean_graffiti"] = janitor_mode_flags & CLEANBOT_CLEAN_DRAWINGS
		data["custom_controls"]["pest_control"] = janitor_mode_flags & CLEANBOT_CLEAN_PESTS
	return data

// Actions received from TGUI
/mob/living/basic/bot/cleanbot/ui_act(action, params)
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
	update_targets()


/mob/living/basic/bot/cleanbot/proc/finish_cleaning()
	update_appearance(UPDATE_ICON)
	SEND_SIGNAL(src, COMSIG_AINOTIFY_CLEANBOT_FINISH_CLEANING, ai_controller)
