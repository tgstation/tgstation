/client/proc/add_admin_verbs()
	control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	SSadmin_verbs.assosciate_client(src)

/client/proc/remove_admin_verbs()
	control_freak = initial(control_freak)
	SSadmin_verbs.deassosciate_client(src)

ADMIN_VERB(hide_verbs, "AdminVerbs - Hide All", "Hide all of your admin verbs, but remain an admin.", NONE, VERB_CATEGORY_ADMIN)
	user.remove_admin_verbs()
	add_verb(user, /client/proc/show_verbs)
	to_chat(user, span_interface("Almost all of your adminverbs have been hidden."))

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(admin_ghost, "AGhost", "Become an observer but better.", R_ADMIN, VERB_CATEGORY_GAME)
	var/mob/holder = user.mob
	if(isnewplayer(holder))
		to_chat(holder, span_red("You cannot admin-ghost while in the lobby. Join the game first."))
		return FALSE

	if(isobserver(holder))
		var/mob/dead/observer/ghost = holder
		if(isnull(ghost.mind?.current))
			return FALSE

		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(user)] re-entered corpse.")
			message_admins("[key_name_admin(user)] re-entered corpse.")
			ghost.can_reenter_corpse = TRUE

		ghost.reenter_corpse()
		return TRUE

	log_admin("[key_name(user)] admin ghosted.")
	message_admins("[key_name_admin(user)] admin ghosted.")
	holder.ghostize(TRUE)
	user.init_verbs()
	holder.key = "@[user.key]"
	return TRUE

ADMIN_VERB(invisimin, "Invisimin", "Toggles true invisibility.", R_ADMIN, VERB_CATEGORY_GAME)
	var/mob/holder = user.mob

	var/toggled_to
	if(holder.invisibility == INVISIBILITY_ABSTRACT)
		toggled_to = FALSE
		holder.invisibility = initial(holder.invisibility)
		to_chat(user, span_notice("You are no longer invisible to players."))
	else
		toggled_to = TRUE
		holder.invisibility = INVISIBILITY_ABSTRACT
		to_chat(user, span_notice("You are now invisible to players."))

	log_admin("[key_name(user)] toggled their invisimin [toggled_to ? "on" : "off"].")
	message_admins("[key_name_admin(user)] toggled their invisimin [toggled_to ? "on" : "off"].")

ADMIN_VERB(check_antagonists, "Check Antagonists", "See all alive, and dead, antagonists for the round.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.check_antagonists()
	log_admin("[key_name(user)] checked antagonists.")
	if(!isobserver(user.mob))
		message_admins("[key_name_admin(user)] checked antagonists while in-game.")

ADMIN_VERB(list_bombers, "List Bombers", "See a list of all bombs and their origin.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.list_bombers()

ADMIN_VERB(list_signalers, "List Signalers", "See a list of all signallers.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.list_signalers()

ADMIN_VERB(list_law_changes, "List Law Changes", "See a list of all law changes.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.list_law_changes()

ADMIN_VERB(show_manifst, "Show Manifest", "See the manifest for the station.", R_ADMIN, VERB_CATEGORY_DEBUG)
	user.holder.show_manifest()

ADMIN_VERB(list_dna, "List DNA", "See all DNA datums in the world.", R_ADMIN, VERB_CATEGORY_DEBUG)
	user.holder.list_dna()

ADMIN_VERB(list_fingerprints, "List Fingerprints", "See all fingerprints in the world.", R_ADMIN, VERB_CATEGORY_DEBUG)
	user.holder.list_fingerprints()

ADMIN_VERB(ban_panel, "Banning Panel", "View and create bans.", R_BAN, VERB_CATEGORY_ADMIN)
	user.holder.ban_panel()

ADMIN_VERB(unban_panel, "Unbanning Panel", "Remove bans.", R_BAN, VERB_CATEGORY_ADMIN)
	user.holder.unban_panel()

ADMIN_VERB(game_panel, "Game Panel", "View, manage, and modify the game state.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.Game()

ADMIN_VERB(poll_panel, "Server Poll Management", "See, edit, delete, and create polls.", R_POLL, VERB_CATEGORY_ADMIN)
	user.holder.poll_list_panel()

/// Returns this client's stealthed ckey
/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/// Takes a stealthed ckey as input, returns the true key it represents
/proc/findTrueKey(stealth_key)
	if(!stealth_key)
		return
	for(var/potentialKey in GLOB.stealthminID)
		if(GLOB.stealthminID[potentialKey] == stealth_key)
			return potentialKey

/// Hands back a stealth ckey to use, guarenteed to be unique
/proc/generateStealthCkey()
	var/guess = rand(0, 1000)
	var/text_guess
	var/valid_found = FALSE
	while(valid_found == FALSE)
		valid_found = TRUE
		text_guess = "@[num2text(guess)]"
		// We take a guess at some number, and if it's not in the existing stealthmin list we exit
		for(var/key in GLOB.stealthminID)
			// If it is in the list tho, we up one number, and redo the loop
			if(GLOB.stealthminID[key] == text_guess)
				guess += 1
				valid_found = FALSE
				break

	return text_guess

/client/proc/createStealthKey()
	GLOB.stealthminID["[ckey]"] = generateStealthCkey()

ADMIN_VERB(stealth, "Stealth Mode", "Toggles stealth mode, hiding your ckey and online presence.", R_STEALTH, VERB_CATEGORY_ADMIN)
	if(user.holder.fakekey)
		user.disable_stealth_mode()
	else
		user.enable_stealth_mode()

#define STEALTH_MODE_TRAIT "stealth_mode"

/client/proc/enable_stealth_mode()
	var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
	if(!new_key)
		return
	holder.fakekey = new_key
	createStealthKey()
	if(isobserver(mob))
		mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
		mob.alpha = 0 //JUUUUST IN CASE
		mob.name = " "
		mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	ADD_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)
	QDEL_NULL(mob.orbiters)

	log_admin("[key_name(usr)] has turned stealth mode ON")
	message_admins("[key_name_admin(usr)] has turned stealth mode ON")

/client/proc/disable_stealth_mode()
	holder.fakekey = null
	if(isobserver(mob))
		mob.invisibility = initial(mob.invisibility)
		mob.alpha = initial(mob.alpha)
		if(mob.mind)
			if(mob.mind.ghostname)
				mob.name = mob.mind.ghostname
			else
				mob.name = mob.mind.name
		else
			mob.name = mob.real_name
		mob.mouse_opacity = initial(mob.mouse_opacity)

	REMOVE_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)

	log_admin("[key_name(usr)] has turned stealth mode OFF")
	message_admins("[key_name_admin(usr)] has turned stealth mode OFF")

#undef STEALTH_MODE_TRAIT

ADMIN_VERB(drop_bomb, "Drop Bomb", "Cause an explosion of varying strength at your location.", R_FUN|R_DEBUG, VERB_CATEGORY_FUN)
	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(
		user,
		"What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap",
		"Drop Bomb",
		choices,
		)
	if(isnull(choice))
		return
	var/turf/epicenter = user.mob.loc

	switch(choice)
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Maxcap")
			explosion(epicenter, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
		if("Custom Bomb")
			var/range_devastation = input(user, "Devastation range (in tiles):") as null|num
			if(range_devastation == null)
				return
			var/range_heavy = input(user, "Heavy impact range (in tiles):") as null|num
			if(range_heavy == null)
				return
			var/range_light = input(user, "Light impact range (in tiles):") as null|num
			if(range_light == null)
				return
			var/range_flash = input(user, "Flash range (in tiles):") as null|num
			if(range_flash == null)
				return
			if(range_devastation > GLOB.MAX_EX_DEVESTATION_RANGE || range_heavy > GLOB.MAX_EX_HEAVY_RANGE || range_light > GLOB.MAX_EX_LIGHT_RANGE || range_flash > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(user, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = user.mob.loc //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash, adminlog = TRUE, ignorecap = TRUE, explosion_cause = user.mob)
	message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(user)] created an admin explosion at [epicenter.loc].")

ADMIN_VERB(drop_bomb_dynex, "Drop DynEx Bomb", "Cause an advanced explosion of varying strength at your location.", R_FUN|R_DEBUG, VERB_CATEGORY_FUN)
	var/ex_power = input(user, "Explosive Power:") as null|num
	if(!ex_power)
		return

	var/turf/epicenter = get_turf(user.mob)
	dyn_explosion(epicenter, ex_power)
	message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(user)] created an admin explosion at [epicenter.loc].")

ADMIN_VERB(dynex_range, "Get DynEx Range", "Get the estimated range of a bomb, using explosive power.", R_FUN|R_DEBUG, VERB_CATEGORY_DEBUG)
	var/ex_power = input(user, "Explosive Power:") as null|num
	if(!ex_power)
		return

	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(user, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])")

ADMIN_VERB(dynex_power, "Get DynEx Power", "Get the estimated required power of a bomb, to reach the given range.", R_FUN|R_DEBUG, VERB_CATEGORY_DEBUG)
	var/ex_range = input(user, "Light Explosion Range:") as null|num
	if(!ex_range)
		return

	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(user, "Estimated Explosive Power: [power]")

ADMIN_VERB(dynex_set_scale, "Set DynEx Scale", "Set the scale multiplier for DynEx explosions. Defaults to 0.5.", R_FUN|R_DEBUG, VERB_CATEGORY_DEBUG)
	var/ex_scale = input(user, "New DynEx Scale:") as null|num
	if(!ex_scale)
		return

	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(user)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(user)] has  modified Dynamic Explosion Scale: [ex_scale]")

ADMIN_VERB(atmos_control, "Atmos Control Panel", "Open the atmos control panel.", R_DEBUG, VERB_CATEGORY_DEBUG)
	SSair.ui_interact(user.mob)

ADMIN_VERB(reload_cards, "Reload Cards", "Reloads all cards.", R_DEBUG, VERB_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	SStrading_card_game.reloadAllCardFiles()

ADMIN_VERB(validate_cards, "Validate Cards", "Checks all cards for errors.", R_DEBUG, VERB_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return

	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	if(message)
		message_admins(message)
	else
		message_admins("No errors found in card rarities or overrides.")

ADMIN_VERB(test_cardpack_distribution, "Test Cardpack Distribution", "Opens a cardpack a bunch of times and shows the distribution of cards.", R_DEBUG, VERB_CATEGORY_DEBUG)
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/pack = tgui_input_list(user, "Which pack should we test?", "You fucked it didn't you", sort_list(SStrading_card_game.card_packs))
	if(!pack)
		return
	var/batch_count = tgui_input_number(user, "How many times should we open it?", "Don't worry, I understand")
	var/batch_size = tgui_input_number(user, "How many cards per batch?", "I hope you remember to check the validation")
	var/guar = tgui_input_number(user, "Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system")
	SStrading_card_game.check_card_distribution(pack, batch_size, batch_count, guar)

ADMIN_VERB(print_cards, "Print Cards", "View all valid cards.", R_DEBUG, VERB_CATEGORY_DEBUG)
	SStrading_card_game.printAllCards()

ADMIN_VERB_CONTEXT_MENU(give_spell, "Give Spell", R_ADMIN, mob/target in world)
	var/which = tgui_alert(user, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return

	if(QDELETED(target))
		to_chat(user, span_warning("The intended spell recipient no longer exists."))
		return

	var/list/spell_list = list()
	for(var/datum/action/cooldown/spell/to_add as anything in subtypesof(/datum/action/cooldown/spell))
		var/spell_name = initial(to_add.name)
		if(spell_name == "Spell") // abstract or un-named spells should be skipped.
			continue

		if(which == "Name")
			spell_list[spell_name] = to_add
		else
			spell_list += to_add

	var/chosen_spell = tgui_input_list(user, "Choose the spell to give to [target]", "ABRAKADABRA", sort_list(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(user, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(target))
		to_chat(user, span_warning("The intended spell recipient no longer exists."))
		return

	log_admin("[key_name(user)] gave [key_name(target)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(user)] gave [key_name_admin(target)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")

	var/datum/action/cooldown/spell/new_spell = new spell_path(target.mind || target)
	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	new_spell.Grant(target)
	if(!target.mind)
		to_chat(usr, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))

ADMIN_VERB_CONTEXT_MENU(remove_spell, "Remove Spell", R_ADMIN, mob/target in world)
	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(user, "Choose the spell to remove from [target]", "ABRAKADABRA", sort_list(target_spell_list))
	if(isnull(chosen_spell))
		return

	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(user)] removed the spell [chosen_spell] from [key_name(target)].")
	message_admins("[key_name_admin(user)] removed the spell [chosen_spell] from [key_name_admin(target)].")

ADMIN_VERB_CONTEXT_MENU(give_disease, "Give Disease", R_ADMIN, mob/living/target in world)
	var/list/diseases = list()
	for(var/datum/disease/disease as anything in sort_list(SSdisease.diseases, GLOBAL_PROC_REF(cmp_typepaths_asc)))
		diseases[initial(disease.name)] = disease

	var/choice = tgui_input_list(user, "Choose the disease.", "Give Disease", diseases)
	if(isnull(choice))
		return

	var/chosen = diseases[choice]
	target.ForceContractDisease(new chosen, FALSE, TRUE)
	log_admin("[key_name(usr)] gave [key_name(target)] the disease '[choice]'.")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(target)] the disease '[choice]'."))

ADMIN_VERB_CONTEXT_MENU(object_say, "OSay", R_FUN, obj/sayer in world)
	var/message = tgui_input_text(user, "What do you want the message to be?", "Make Sound", encode = FALSE)
	if(!message)
		return
	sayer.say(message, sanitize = FALSE)
	log_admin("[key_name(user)] made [sayer] at [AREACOORD(sayer)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(user)] made [sayer] at [AREACOORD(sayer)]. say \"[message]\""))

ADMIN_VERB(buildmode, "Toggle Build Mode Self", "Toggles build mode for your client.", R_BUILD, VERB_CATEGORY_EVENTS)
	togglebuildmode(user.mob)

ADMIN_VERB(check_ai_laws, "Check AI Laws", "View the laws for an AI.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.output_ai_laws()

ADMIN_VERB(deadmin, "DeAdmin", "Shed your admin powers.", NONE, VERB_CATEGORY_ADMIN)
	user.holder.deactivate()
	to_chat(user, span_interface("You are now a normal player."))
	var/message = "[key_name(user)] has deadminned themselves."
	log_admin(message)
	message_admins(message)
	add_verb(user, /client/proc/readmin)

/client/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now an admin."), confidential = TRUE)
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Readmin")

ADMIN_VERB(populate_world, "Populate World", "Populate the world with test mobs.", R_DEBUG, VERB_CATEGORY_ADMIN, amount = 50 as num)
	var/static/list/outfits
	if(isnull(outfits))
		outfits = subtypesof(/datum/outfit)

	while(amount--)
		var/turf/spawn_location = get_safe_random_station_turf()
		var/mob/living/carbon/human/dummy = new(spawn_location)
		dummy.equipOutfit(pick(outfits))
		testing("Spawned Test Dummy at [get_area_name(spawn_location, TRUE)] ([spawn_location.x],[spawn_location.y],[spawn_location.z])")

ADMIN_VERB(ai_interaction, "Toggle Admin AI Interact", "Allows you to interact with most machines as an AI would, as a ghost.", R_ADMIN, VERB_CATEGORY_GAME)
	user.ai_interact = !user.ai_interact
	if(user.mob && isAdminGhostAI(user.mob))
		user.mob.has_unlimited_silicon_privilege = user.ai_interact

	log_admin("[key_name(user)] has [user.ai_interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(user)] has [user.ai_interact ? "activated" : "deactivated"] their AI interaction")

ADMIN_VERB(load_lazy_template, "Load/Jump Lazy Template", "View possible lazy templates and load one.", R_ADMIN, VERB_CATEGORY_EVENTS)
	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(user, "Key?", "Lazy Loader", choices)
	if(!choice)
		return

	choice = choices[choice]
	if(!choice)
		to_chat(user, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(user, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(user, span_boldwarning("Failed to load template!"))
		return

	if(!isobserver(user.mob))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb_holder/admin_ghost)

	user.mob.forceMove(coords2turf(reservation.bottom_left_coords))

	message_admins("[key_name_admin(user)] has loaded lazy template '[choice]'")
	to_chat(user, span_boldnicegreen("Template loaded, you have been moved to the bottom left of the reservation."))

ADMIN_VERB(player_panel_global, "Player Panel", "Views the global player panel.", R_ADMIN, VERB_CATEGORY_GAME)
	user.holder.player_panel_new()

/client/proc/admin_2fa_verify()
	set name = "Verify Admin"
	set category = "Admin"

	var/datum/admins/admin = GLOB.admin_datums[ckey]
	admin?.associate(src)
