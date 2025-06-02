GLOBAL_LIST_EMPTY(global_pet_updates)
GLOBAL_LIST_EMPTY(virtual_pets_list)

#define MAX_UPDATE_LENGTH 50
#define PET_MAX_LEVEL 3
#define PET_MAX_STEPS_RECORD 50000
#define PET_EAT_BONUS 500
#define PET_CLEAN_BONUS 250
#define PET_PLAYMATE_BONUS 500
#define PET_STATE_HUNGRY "hungry"
#define PET_STATE_ASLEEP "asleep"
#define PET_STATE_HAPPY "happy"
#define PET_STATE_NEUTRAL "neutral"

/datum/computer_file/program/virtual_pet
	filename = "virtualpet"
	filedesc = "Virtual Pet"
	downloader_category = PROGRAM_CATEGORY_GAMES
	extended_desc = "Download your very own Orbie today!"
	program_open_overlay = "generic"
	program_flags = PROGRAM_ON_NTNET_STORE
	size = 3
	tgui_id = "NtosVirtualPet"
	program_icon = "paw"
	can_run_on_flags = PROGRAM_PDA
	detomatix_resistance = DETOMATIX_RESIST_MALUS
	///how many steps have we walked
	var/steps_counter = 0
	///the pet hologram
	var/mob/living/pet
	///the type of our pet
	var/pet_type = /mob/living/basic/orbie
	///our current happiness
	var/happiness = 0
	///our max happiness
	var/max_happiness = 1750
	///our current level
	var/level = 1
	///required exp to get to next level
	var/to_next_level = 1000
	///how much exp we currently have
	var/current_level_progress = 0
	///our current hunger
	var/hunger = 0
	///maximum hunger threshold
	var/max_hunger = 500
	///pet icon for each state
	var/static/list/pet_state_icons = list(
		PET_STATE_HUNGRY = list("icon" = 'icons/ui/virtualpet/pet_state.dmi', "icon_state" = "pet_hungry"),
		PET_STATE_HAPPY = list("icon" = 'icons/ui/virtualpet/pet_state.dmi', "icon_state" = "pet_happy"),
		PET_STATE_ASLEEP = list("icon" = 'icons/ui/virtualpet/pet_state.dmi', "icon_state" = "pet_asleep"),
		PET_STATE_NEUTRAL = list("icon" = 'icons/ui/virtualpet/pet_state.dmi', "icon_state" = "pet_neutral"),
	)
	///hat options and what level they will be unlocked at
	var/static/list/hat_selections = list(
		/obj/item/clothing/head/hats/tophat = 1,
		/obj/item/clothing/head/fedora = 1,
		/obj/item/clothing/head/soft/fishing_hat = 1,
		/obj/item/cigarette/dart = 1,
		/obj/item/clothing/head/hats/bowler = 2,
		/obj/item/clothing/head/hats/warden/police = 2,
		/obj/item/clothing/head/wizard/tape = 2,
		/obj/item/clothing/head/utility/hardhat/cakehat/energycake = 2,
		/obj/item/clothing/head/cowboy/bounty = 2,
		/obj/item/clothing/head/hats/warden/red = 3,
		/obj/item/clothing/head/hats/caphat = 3,
		/obj/item/clothing/head/costume/crown/fancy = 3,
	)
	///hat options that are locked behind achievements
	var/static/list/cheevo_hats = list(
		/obj/item/clothing/head/soft/fishing_hat = /datum/award/achievement/skill/legendary_fisher,
		/obj/item/cigarette/dart = /datum/award/achievement/misc/cigarettes,
		/obj/item/clothing/head/wizard/tape = /datum/award/achievement/misc/grand_ritual_finale,
		/obj/item/clothing/head/utility/hardhat/cakehat/energycake = /datum/award/achievement/misc/cayenne_disk,
		/obj/item/clothing/head/cowboy/bounty = /datum/award/achievement/misc/hot_damn,
		/obj/item/clothing/head/costume/crown/fancy = /datum/award/achievement/misc/debt_extinguished,
	)
	///A list of hats that override the hat offsets and transform variable
	var/static/list/special_hat_placement = list(
		/obj/item/cigarette/dart = list(
			"west" = list(2,-1),
			"east" = list(-2,-1),
			"north" = list(0,0),
			"south" = list(0, -3),
			"transform" = list(1, 1),
		),
	)
	///hologram hat we have selected for our pet
	var/list/selected_hat = list()
	///manage hat offsets for when we turn directions
	var/static/list/hat_offsets = list(
		"west" = list(0,1),
		"east" = list(0,1),
		"north" = list(1,1),
		"south" = list(1,1),
	)
	///area we have picked as dropoff location for petfeed
	var/area/selected_area
	///possible colors our pet can have
	var/static/list/possible_colors= list(
		"white" = null, //default color state
		"light blue" = "#c3ecf3",
		"light green" = "#b1ffe8",
	)
	///areas we wont drop the chocolate in
	var/static/list/restricted_areas = typecacheof(list(
		/area/station/security,
		/area/station/command,
		/area/station/ai_monitored,
		/area/station/maintenance,
		/area/station/solars,
	))
	///our profile picture
	var/icon/profile_picture
	///cooldown till we can reroll the pet feed dropzone
	COOLDOWN_DECLARE(area_reroll)
	///cooldown till our pet gains happiness again from being cleaned
	COOLDOWN_DECLARE(on_clean_cooldown)
	///cooldown till we can release/recall our pet
	COOLDOWN_DECLARE(summon_cooldown)
	///cooldown till we can alter our pet's appearance again
	COOLDOWN_DECLARE(alter_appearance_cooldown)

/datum/computer_file/program/virtual_pet/on_install()
	. = ..()
	profile_picture = getFlatIcon(image(icon = 'icons/ui/virtualpet/pet_state.dmi', icon_state = "pet_preview"))
	GLOB.virtual_pets_list += src
	pet = new pet_type(computer)
	pet.forceMove(computer)
	pet.AddComponent(/datum/component/leash, computer, 9, force_teleport_out_effect = /obj/effect/temp_visual/guardian/phase/out)
	RegisterSignal(pet, COMSIG_QDELETING, PROC_REF(remove_pet))
	RegisterSignal(pet, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated)) //hologramic hat management
	RegisterSignal(pet, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_change_dir))
	RegisterSignal(pet, COMSIG_MOVABLE_MOVED, PROC_REF(after_pet_move))
	RegisterSignal(pet, COMSIG_MOB_ATE, PROC_REF(after_pet_eat)) // WE ATEEE
	RegisterSignal(pet, COMSIG_ATOM_PRE_CLEAN, PROC_REF(pet_pre_clean))
	RegisterSignal(pet, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(pet, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(post_cleaned))
	RegisterSignal(pet, COMSIG_AI_BLACKBOARD_KEY_SET(BB_NEARBY_PLAYMATE), PROC_REF(on_playmate_find))
	RegisterSignal(computer, COMSIG_ATOM_ENTERED, PROC_REF(on_pet_entered))
	RegisterSignal(computer, COMSIG_ATOM_EXITED, PROC_REF(on_pet_exit))

/datum/computer_file/program/virtual_pet/Destroy()
	GLOB.virtual_pets_list -= src
	if(!QDELETED(pet))
		QDEL_NULL(pet)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/computer_file/program/virtual_pet/proc/on_death(datum/source)
	SIGNAL_HANDLER

	pet.forceMove(computer)


/datum/computer_file/program/virtual_pet/proc/on_message_receive(datum/source, sender_title, inbound_message, photo_message)
	SIGNAL_HANDLER

	var/message_to_display = "[sender_title] has sent you a message [photo_message ? "with a photo attached" : ""]: [inbound_message]!"
	pet.ai_controller?.set_blackboard_key(BB_LAST_RECEIVED_MESSAGE, message_to_display)

/datum/computer_file/program/virtual_pet/proc/pet_pre_clean(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, on_clean_cooldown))
		source.balloon_alert(user, "already clean!")
		return COMSIG_ATOM_CANCEL_CLEAN

/datum/computer_file/program/virtual_pet/proc/on_playmate_find(datum/source)
	SIGNAL_HANDLER

	happiness = min(happiness + PET_PLAYMATE_BONUS, max_happiness)
	START_PROCESSING(SSprocessing, src)

/datum/computer_file/program/virtual_pet/proc/post_cleaned(mob/source, mob/user)
	SIGNAL_HANDLER

	. = NONE
	source.spin(spintime = 2 SECONDS, speed = 1) //celebrate!
	happiness = min(happiness + PET_CLEAN_BONUS, max_happiness)
	COOLDOWN_START(src, on_clean_cooldown, 1 MINUTES)
	START_PROCESSING(SSprocessing, src)
	. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

///manage the pet's hat offsets when he changes direction
/datum/computer_file/program/virtual_pet/proc/on_change_dir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(!length(selected_hat))
		return
	set_hat_offsets(new_dir)

/datum/computer_file/program/virtual_pet/proc/on_photo_captured(datum/source, atom/target, atom/user, datum/picture/photo)
	SIGNAL_HANDLER

	if(isnull(photo))
		return
	computer.store_file(new /datum/computer_file/picture(photo))

/datum/computer_file/program/virtual_pet/proc/set_hat_offsets(new_dir)
	var/direction_text = dir2text(new_dir)
	var/hat_type = selected_hat["type"]
	var/list/offsets_list = special_hat_placement[hat_type]?[direction_text] || hat_offsets[direction_text]
	var/mutable_appearance/hat_appearance = selected_hat["appearance"]
	hat_appearance.pixel_w = offsets_list[1]
	hat_appearance.pixel_z = offsets_list[2] + selected_hat["worn_offset"]
	pet.update_appearance(UPDATE_OVERLAYS)

///give our pet his hologram hat
/datum/computer_file/program/virtual_pet/proc/on_overlays_updated(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!length(selected_hat))
		return
	overlays += selected_hat["appearance"]

/datum/computer_file/program/virtual_pet/proc/alter_profile_picture()
	var/image/pet_preview = image(icon = 'icons/ui/virtualpet/pet_state.dmi', icon_state = "pet_preview")
	if(pet.cached_color_filter)
		pet_preview.color = apply_matrix_to_color(COLOR_WHITE, pet.cached_color_filter["color"], pet.cached_color_filter["space"] || COLORSPACE_RGB)
	else if (pet.color)
		pet_preview.color = pet.color

	if(length(selected_hat))
		var/mutable_appearance/our_selected_hat = selected_hat["appearance"]
		var/mutable_appearance/hat_preview = mutable_appearance(our_selected_hat.icon, our_selected_hat.icon_state, appearance_flags = RESET_COLOR|KEEP_APART)
		hat_preview.pixel_z = -9 + selected_hat["worn_offset"]
		var/list/spec_hat = special_hat_placement[selected_hat["type"]]?["south"]
		if(spec_hat)
			hat_preview.pixel_w += spec_hat[1]
			hat_preview.pixel_z += spec_hat[2]
		pet_preview.add_overlay(hat_preview)

	profile_picture = getFlatIcon(pet_preview, no_anim = TRUE)
	COOLDOWN_START(src, alter_appearance_cooldown, 10 SECONDS)


///decrease the pet's hunger after it eats
/datum/computer_file/program/virtual_pet/proc/after_pet_eat(datum/source)
	SIGNAL_HANDLER

	hunger = min(hunger + PET_EAT_BONUS, max_hunger)
	happiness = min(happiness + PET_EAT_BONUS, max_happiness)
	START_PROCESSING(SSprocessing, src)

///start processing if we enter the pda and need healing
/datum/computer_file/program/virtual_pet/proc/on_pet_entered(atom/movable/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(arrived != pet)
		return
	ADD_TRAIT(pet, TRAIT_AI_PAUSED, REF(src))
	if((datum_flags & DF_ISPROCESSING))
		return
	if(pet.health < pet.maxHealth) //if we're in the pda, heal up
		START_PROCESSING(SSprocessing, src)

/datum/computer_file/program/virtual_pet/proc/on_pet_exit(atom/movable/source, atom/movable/exited)
	SIGNAL_HANDLER

	if(exited != pet)
		return
	REMOVE_TRAIT(pet, TRAIT_AI_PAUSED, REF(src))
	if((datum_flags & DF_ISPROCESSING))
		return
	if(hunger > 0 || happiness > 0) //if were outside the pda, we become hungry and happiness decreases
		START_PROCESSING(SSprocessing, src)

/datum/computer_file/program/virtual_pet/process()
	if(pet.loc == computer)
		if(pet.health >= pet.maxHealth)
			return PROCESS_KILL
		if(pet.stat == DEAD)
			pet.revive(ADMIN_HEAL_ALL)
		pet.heal_overall_damage(5)
		return

	if(hunger > 0)
		hunger--

	if(happiness > 0)
		happiness--

	if(hunger <=0 && happiness <= 0)
		return PROCESS_KILL

/datum/computer_file/program/virtual_pet/proc/after_pet_move(atom/movable/movable, atom/old_loc)
	SIGNAL_HANDLER

	if(!isturf(pet.loc) || !isturf(old_loc))
		return
	steps_counter = min(steps_counter + 1, PET_MAX_STEPS_RECORD)
	increment_exp()
	if(steps_counter % 2000 == 0) //every 2000 steps, announce the milestone to the world!
		announce_global_updates(message = "has walked [steps_counter] steps!")

/datum/computer_file/program/virtual_pet/proc/increment_exp()
	var/modifier = 1
	var/hunger_happiness = hunger + happiness
	var/max_hunger_happiness = max_hunger + max_happiness

	switch(hunger_happiness / max_hunger_happiness)
		if(0.8 to 1)
			modifier = 3
		if(0.5 to 0.8)
			modifier = 2

	current_level_progress = min(current_level_progress + modifier, to_next_level)
	if(current_level_progress >= to_next_level)
		handle_level_up()

/datum/computer_file/program/virtual_pet/proc/handle_level_up()
	current_level_progress = 0
	level++
	grant_level_abilities()
	pet.ai_controller?.set_blackboard_key(BB_VIRTUAL_PET_LEVEL, level)
	playsound(computer.loc, 'sound/mobs/non-humanoids/orbie/orbie_level_up.ogg', 50)
	to_next_level += (level**2) + 500
	SEND_SIGNAL(pet, COMSIG_VIRTUAL_PET_LEVEL_UP, level) //its a signal so different path types of virtual pets can handle leveling up differently
	announce_global_updates(message = "has reached level [level]!")

/datum/computer_file/program/virtual_pet/proc/grant_level_abilities()
	switch(level)
		if(2)
			RegisterSignal(computer, COMSIG_COMPUTER_RECEIVED_MESSAGE, PROC_REF(on_message_receive)) // we will now read out PDA messages
			var/datum/action/cooldown/mob_cooldown/lights/lights = new(pet)
			lights.Grant(pet)
			pet.ai_controller?.set_blackboard_key(BB_LIGHTS_ABILITY, lights)
		if(3)
			var/datum/action/cooldown/mob_cooldown/capture_photo/photo_ability = new(pet)
			photo_ability.Grant(pet)
			pet.ai_controller?.set_blackboard_key(BB_PHOTO_ABILITY, photo_ability)
			RegisterSignal(photo_ability.ability_camera, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_photo_captured))

/datum/computer_file/program/virtual_pet/proc/announce_global_updates(message)
	if(isnull(message))
		return
	var/list/message_to_announce = list(
		"name" = pet.name,
		"pet_picture" =  icon2base64(profile_picture),
		"message" = message,
		"likers" = list(REF(src))
	)
	if(length(GLOB.global_pet_updates) >= MAX_UPDATE_LENGTH)
		GLOB.global_pet_updates.Cut(1,2)

	GLOB.global_pet_updates += list(message_to_announce)
	playsound(computer.loc, 'sound/mobs/non-humanoids/orbie/orbie_notification_sound.ogg', 50)

/datum/computer_file/program/virtual_pet/proc/remove_pet(datum/source)
	SIGNAL_HANDLER
	pet = null
	if(QDELETED(src))
		return
	computer.remove_file(src) //all is lost we no longer have a reason to exist

/datum/computer_file/program/virtual_pet/kill_program(mob/user)
	if(pet && pet.loc != computer)
		pet.forceMove(computer) //recall the hologram back to the pda
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/computer_file/program/virtual_pet/proc/get_pet_state()
	if(isnull(pet))
		return

	if(pet.loc == computer)
		return PET_STATE_ASLEEP

	if(happiness/max_happiness > 0.8)
		return PET_STATE_HAPPY

	if(hunger/max_hunger < 0.5)
		return PET_STATE_HUNGRY

	return PET_STATE_NEUTRAL

/datum/computer_file/program/virtual_pet/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/hat_type = selected_hat?["type"]
	data["currently_summoned"] = (pet.loc != computer)
	data["selected_area"] = (selected_area ? selected_area.name : "No location set")
	data["pet_state"] = get_pet_state()
	data["hunger"] = hunger
	data["maximum_hunger"] = max_hunger
	data["pet_hat"] = (hat_type ? initial(hat_type.name) : "none")
	data["can_reroll"] = COOLDOWN_FINISHED(src, area_reroll)
	data["can_summon"] = COOLDOWN_FINISHED(src, summon_cooldown)
	data["can_alter_appearance"] = COOLDOWN_FINISHED(src, alter_appearance_cooldown)
	data["pet_name"] = pet.name
	data["steps_counter"] = steps_counter
	data["in_dropzone"] = (istype(get_area(computer), selected_area))
	data["pet_area"] = (pet.loc != computer ? get_area_name(pet) : "Sleeping in PDA")
	data["current_exp"] = current_level_progress
	data["required_exp"] = to_next_level
	data["happiness"] = happiness
	data["maximum_happiness"] = max_happiness
	data["level"] = level
	data["pet_color"] = ""

	var/color_value = LAZYACCESS(pet.atom_colours, FIXED_COLOUR_PRIORITY)
	for(var/index in possible_colors)
		if(possible_colors[index] == color_value)
			data["pet_color"] = index
			break

	data["pet_gender"] = pet.gender

	data["pet_updates"] = list()

	for(var/i in length(GLOB.global_pet_updates) to 1 step -1)
		var/list/update = GLOB.global_pet_updates[i]

		if(isnull(update))
			continue

		data["pet_updates"] += list(list(
			"update_id" = i,
			"update_name" = update["name"],
			"update_picture" = update["pet_picture"],
			"update_message" = update["message"],
			"update_likers" = length(update["likers"]),
			"update_already_liked" = ((REF(src)) in update["likers"]),
		))

	data["all_pets"] = list()
	for(var/datum/computer_file/program/virtual_pet/program as anything in GLOB.virtual_pets_list)
		data["all_pets"] += list(list(
			"other_pet_name" = program.pet.name,
			"other_pet_picture" = icon2base64(program.profile_picture),
		))
	return data

/datum/computer_file/program/virtual_pet/ui_static_data(mob/user)
	var/list/data = list()
	data["pet_state_icons"] = list()
	for(var/list_index as anything in pet_state_icons)
		var/list/sprite_location = pet_state_icons[list_index]
		data["pet_state_icons"] += list(list(
			"name" = list_index,
			"icon" = icon2base64(getFlatIcon(image(icon = sprite_location["icon"], icon_state = sprite_location["icon_state"]), no_anim=TRUE))
		))

	data["hat_selections"] = list(list(
		"hat_id" = null,
		"hat_name" = "none",
	))

	for(var/type_index as anything in hat_selections)
		if(level >= hat_selections[type_index])
			var/obj/item/hat = type_index
			var/hat_name = initial(hat.name)
			if(length(SSachievements.achievements)) // The Achievements subsystem is active.
				var/datum/award/required_cheevo = cheevo_hats[hat]
				if(required_cheevo && !user.client.get_award_status(required_cheevo))
					hat_name = "LOCKED"
			data["hat_selections"] += list(list(
				"hat_id" = type_index,
				"hat_name" = hat_name,
			))

	data["possible_colors"] = list()
	for(var/color in possible_colors)
		data["possible_colors"] += list(list(
			"color_name" = color,
			"color_value" = possible_colors[color],
		))

	var/static/list/possible_emotes = list(
		/datum/emote/flip,
		/datum/emote/jump,
		/datum/emote/living/shiver,
		/datum/emote/spin,
		/datum/emote/silicon/beep,
	)
	data["possible_emotes"] = list("none")
	for(var/datum/emote/target_emote as anything in possible_emotes)
		data["possible_emotes"] += target_emote.key

	data["preview_icon"] = icon2base64(profile_picture)
	return data

/datum/computer_file/program/virtual_pet/ui_act(action, params, datum/tgui/ui)
	. = ..()
	switch(action)

		if("summon_pet")
			if(!COOLDOWN_FINISHED(src, summon_cooldown))
				return TRUE
			if(pet.loc == computer)
				release_pet(ui.user)
			else
				recall_pet(ui.user)
			COOLDOWN_START(src, summon_cooldown, 10 SECONDS)

		if("apply_customization")
			if(!COOLDOWN_FINISHED(src, alter_appearance_cooldown))
				return TRUE
			var/obj/item/chosen_type = text2path(params["chosen_hat"])
			if(isnull(chosen_type))
				selected_hat.Cut()

			else if(hat_selections[chosen_type])
				var/datum/award/required_cheevo = cheevo_hats[chosen_type]
				if(length(SSachievements.achievements) && required_cheevo && !ui.user.client.get_award_status(required_cheevo))
					to_chat(ui.user, span_info("This customization requires the \"[span_bold(initial(required_cheevo.name))]\ achievement to be unlocked."))
				else
					selected_hat["type"] = chosen_type
					var/state_to_use = initial(chosen_type.worn_icon_state) || initial(chosen_type.icon_state)
					var/mutable_appearance/selected_hat_appearance = mutable_appearance(initial(chosen_type.worn_icon), state_to_use, appearance_flags = RESET_COLOR|KEEP_APART)
					selected_hat["worn_offset"] = initial(chosen_type.worn_y_offset)
					var/list/scale_list = special_hat_placement[chosen_type]?["scale"]
					if(scale_list)
						selected_hat_appearance.transform = selected_hat_appearance.transform.Scale(scale_list[1], scale_list[2])
					else
						selected_hat_appearance.transform = selected_hat_appearance.transform.Scale(0.8, 1)
					selected_hat["appearance"] = selected_hat_appearance
					set_hat_offsets(pet.dir)

			var/chosen_color = params["chosen_color"]
			if(isnull(chosen_color))
				pet.remove_atom_colour(FIXED_COLOUR_PRIORITY)
			else
				pet.add_atom_colour(chosen_color, FIXED_COLOUR_PRIORITY)

			var/input_name = sanitize_name(params["chosen_name"], allow_numbers = TRUE)
			pet.name = (input_name ? input_name : initial(pet.name))
			new /obj/effect/temp_visual/guardian/phase(pet.loc)

			switch(params["chosen_gender"])
				if("male")
					pet.gender = MALE
				if("female")
					pet.gender = FEMALE
				if("neuter")
					pet.gender = NEUTER

			pet.update_appearance()
			alter_profile_picture()
			update_static_data(ui.user, ui)

		if("get_feed_location")
			generate_petfeed_area()

		if("drop_feed")
			drop_feed()

		if("like_update")
			var/index = params["update_reference"]
			var/list/update_message = GLOB.global_pet_updates[index]
			if(isnull(update_message))
				return TRUE
			var/our_reference = REF(src)
			if(our_reference in update_message["likers"])
				update_message["likers"] -= our_reference
			else
				update_message["likers"] += our_reference

		if("teach_tricks")
			var/trick_name = params["trick_name"]
			var/list/trick_sequence = params["tricks"]
			if(isnull(pet.ai_controller))
				return TRUE
			if(!isnull(trick_name))
				pet.ai_controller.set_blackboard_key(BB_TRICK_NAME, trick_name)
			for (var/trick_move in trick_sequence)
				if (!length(GLOB.emote_list[LOWER_TEXT(trick_move)]))
					trick_sequence -= trick_move
			pet.ai_controller.override_blackboard_key(BB_TRICK_SEQUENCE, trick_sequence)
			playsound(computer.loc, 'sound/mobs/non-humanoids/orbie/orbie_trick_learned.ogg', 50)

	return TRUE

/datum/computer_file/program/virtual_pet/proc/generate_petfeed_area()
	if(!COOLDOWN_FINISHED(src, area_reroll))
		return
	var/list/filter_area_list = typecache_filter_list(GLOB.the_station_areas, restricted_areas)
	var/list/target_area_list = GLOB.the_station_areas.Copy() - filter_area_list
	if(!length(target_area_list))
		return
	selected_area = pick(target_area_list)
	COOLDOWN_START(src, area_reroll, 2 MINUTES)

/datum/computer_file/program/virtual_pet/proc/drop_feed()
	if(!istype(get_area(computer), selected_area))
		return
	announce_global_updates(message = "has found a chocolate at [selected_area.name]")
	selected_area = null
	var/obj/item/food/virtual_chocolate/chocolate = new(get_turf(computer))
	chocolate.fade_into_nothing(life_time = 30 SECONDS) //we cant maintain its existence for too long!

/datum/computer_file/program/virtual_pet/proc/recall_pet(mob/living/friend)
	animate(pet, transform = matrix().Scale(0.3, 0.3), time = 1.5 SECONDS)
	addtimer(CALLBACK(pet, TYPE_PROC_REF(/atom/movable, forceMove), computer), 1.5 SECONDS)
	SEND_SIGNAL(pet, COMSIG_VIRTUAL_PET_RECALLED, friend)

/datum/computer_file/program/virtual_pet/proc/release_pet(mob/living/our_user)
	var/turf/drop_zone
	var/list/turfs_list = get_adjacent_open_turfs(computer.drop_location())
	for(var/turf/possible_turf as anything in turfs_list)
		if(possible_turf.is_blocked_turf())
			continue
		drop_zone = possible_turf
		break
	var/turf/final_turf = isnull(drop_zone) ? computer.drop_location() : drop_zone
	pet.befriend(our_user) //befriend whoever set us out
	animate(pet, transform = matrix(), time = 1.5 SECONDS)
	pet.forceMove(final_turf)
	playsound(computer.loc, 'sound/mobs/non-humanoids/orbie/orbie_send_out.ogg', 20)
	SEND_SIGNAL(pet, COMSIG_VIRTUAL_PET_SUMMONED, our_user)
	new /obj/effect/temp_visual/guardian/phase(pet.loc)

#undef PET_MAX_LEVEL
#undef PET_MAX_STEPS_RECORD
#undef PET_EAT_BONUS
#undef PET_CLEAN_BONUS
#undef PET_PLAYMATE_BONUS
#undef PET_STATE_HUNGRY
#undef PET_STATE_ASLEEP
#undef PET_STATE_HAPPY
#undef PET_STATE_NEUTRAL
#undef MAX_UPDATE_LENGTH
