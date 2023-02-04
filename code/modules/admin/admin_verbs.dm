/client/proc/add_admin_verbs()
	if(!holder)
		CRASH("called add_admin_verbs on a client without a holder?")
	control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	SSadmin_verbs.assosciate_admin(src)

/client/proc/remove_admin_verbs()
	SSadmin_verbs.deassosciate_admin(src)

ADMIN_VERB(admin, hide_all_verbs, "Hide all of your Admin Verbs", NONE)
	usr.client.remove_admin_verbs()
	add_verb(usr.client, /client/proc/show_verbs)
	to_chat(usr, span_admin("Almost all of your adminverbs have been hidden."))

/client/proc/show_verbs() // This is not an ADMIN_VERB for a reason
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

ADMIN_VERB(game, aghost, "Observe without leaving the game", R_ADMIN)
	if(isnewplayer(usr))
		to_chat(usr, span_red("Error: AGhost: Cannot admin-ghost wile in the lobby. Join or Observe first."))
		return

	if(isobserver(usr))
		var/mob/dead/observer/admin_ghost = usr
		if(!admin_ghost.mind?.current)
			to_chat(usr, span_red("Error: AGhost: You do not have a body to return to!"))
			return
		if(!admin_ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] re-entered corpse")
			admin_ghost.can_reenter_corpse = TRUE
		admin_ghost.reenter_corpse()
		return

	log_admin("[key_name(usr)] admin ghosted.")
	message_admins("[key_name_admin(usr)] admin ghosted.")
	usr.ghostize(TRUE)
	if(usr && !usr.key)
		usr.key = "@[key]" // If the key starts with '@' it designates an admin ghost

ADMIN_VERB(game, invisimin, "Toggles ghost-like invisibility", R_ADMIN)
	if(initial(usr.invisibility) == INVISIBILITY_OBSERVER)
		to_chat(usr, span_boldannounce("Invisimin toggle failed. You are already an invisible mob like a ghost."), confidential = TRUE)
		return
	if(usr.invisibility == INVISIBILITY_OBSERVER)
		usr.invisibility = initial(usr.invisibility)
		to_chat(usr, span_boldannounce("Invisimin off. Invisibility reset."), confidential = TRUE)
	else
		usr.invisibility = INVISIBILITY_OBSERVER
		to_chat(usr, span_adminnotice("<b>Invisimin on. You are now as invisible as a ghost.</b>"), confidential = TRUE)

ADMIN_VERB(game, check_antagonists, "", R_ADMIN)
	usr.client.holder.check_antagonists()
	log_admin("[key_name(usr)] checked antagonists.") //for tsar~ get a room you two
	if(!isobserver(usr) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(usr)] checked antagonists.")

ADMIN_VERB(game, list_bombers, "", R_ADMIN)
	usr.client.holder.list_bombers()

ADMIN_VERB(game, list_signalers, "", R_ADMIN)
	usr.client.holder.list_signalers()

ADMIN_VERB(game, list_law_changes, "", R_ADMIN)
	usr.client.holder.list_law_changes()

ADMIN_VERB(game, show_manifest, "", R_ADMIN)
	usr.client.holder.show_manifest()

ADMIN_VERB(game, list_dna, "", R_ADMIN)
	usr.client.holder.list_dna()

ADMIN_VERB(game, list_fingerprints, "", R_ADMIN)
	usr.client.holder.list_fingerprints()

ADMIN_VERB(admin, banning_panel, "", R_BAN)
	usr.client.holder.ban_panel()

ADMIN_VERB(admin, unbanning_panel, "", R_BAN)
	usr.client.holder.unban_panel()

ADMIN_VERB(game, game_panel, "", NONE)
	usr.client.holder.Game()

ADMIN_VERB(admin, server_poll_management, "", R_POLL)
	usr.client.holder.poll_list_panel()

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

ADMIN_VERB(admin, stealth_mode, "Makes you unable to be seen through most means", R_STEALTH)
	if(usr.client.holder.fakekey)
		usr.client.disable_stealth_mode()
	else
		usr.client.enable_stealth_mode()

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

ADMIN_VERB(fun, drop_bomb, "Cause an explosion of varying strength at your location", R_FUN)
	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(usr, "What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap", "Drop Bomb", choices)
	if(isnull(choice))
		return
	var/turf/epicenter = get_turf(usr)

	switch(choice)
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Maxcap")
			explosion(epicenter, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
		if("Custom Bomb")
			var/range_devastation = input("Devastation range (in tiles):") as null|num
			if(range_devastation == null)
				return
			var/range_heavy = input("Heavy impact range (in tiles):") as null|num
			if(range_heavy == null)
				return
			var/range_light = input("Light impact range (in tiles):") as null|num
			if(range_light == null)
				return
			var/range_flash = input("Flash range (in tiles):") as null|num
			if(range_flash == null)
				return
			if(range_devastation > GLOB.MAX_EX_DEVESTATION_RANGE || range_heavy > GLOB.MAX_EX_HEAVY_RANGE || range_light > GLOB.MAX_EX_LIGHT_RANGE || range_flash > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(usr, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = get_turf(usr) //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash, adminlog = TRUE, ignorecap = TRUE, explosion_cause = usr)
	message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")

ADMIN_VERB(fun, drop_dynex_bomb, "Cause an explosion of varting strength at your location", R_FUN)
	var/ex_power = input(usr, "Explosive Power:") as null|num
	var/turf/epicenter = get_turf(usr)
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")

ADMIN_VERB(debug, get_dynex_range, "Get the estimated range of a bomb, using explosive power", R_FUN)
	var/ex_power = input(usr, "Explosive Power:") as null|num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])")

ADMIN_VERB(debug, get_dynex_power, "Get the estimated power of a bomb, to reach the specific range", R_FUN)
	var/ex_range = input(usr, "Light Explosion Range:") as null|num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Power: [power]")

ADMIN_VERB(debug, set_dynex_scale, "Set the scale multiplier on dynex explosions. Default of 0.5", R_FUN)
	var/ex_scale = input("New DynEx Scale:") as null|num
	if(isnull(ex_scale))
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

ADMIN_VERB(debug, atmos_control_panel, "", R_DEBUG)
	SSair.ui_interact(usr)

ADMIN_VERB(trading_card_game, reload_cards, "", R_DEBUG)
	if(!SStrading_card_game.loaded)
		to_chat(usr, span_admin("The card subsystem is not currently loaded!"))
		return
	message_admins("[key_name_admin(usr)] manually reloaded SStrading_card_game.")
	SStrading_card_game.reloadAllCardFiles()

ADMIN_VERB(trading_card_game, validate_cards, "", R_DEBUG)
	if(!SStrading_card_game.loaded)
		to_chat(usr, span_admin("The card subsystem is not currently loaded!"))
		return

	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	if(message)
		to_chat(usr, span_admin(message))
	else
		to_chat(usr, span_admin("No errors found in card rarities or overrides."))

ADMIN_VERB(trading_card_game, test_cardpack_distribution, "", R_DEBUG)
	if(!SStrading_card_game.loaded)
		to_chat(usr, span_admin("The card subsystem is not currently loaded!"))
		return

	var/pack = tgui_input_list(usr, "Which pack should we test?", "You fucked it didn't you", sort_list(SStrading_card_game.card_packs))
	if(!pack)
		return

	var/batch_count = tgui_input_number(usr, "How many times should we open it?", "Don't worry, I understand")
	var/batch_size = tgui_input_number(usr, "How many cards per batch?", "I hope you remember to check the validation")
	var/guar = tgui_input_number(usr, "Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system")
	SStrading_card_game.check_card_distribution(pack, batch_size, batch_count, guar)

ADMIN_VERB(trading_card_game, print_cards, "", R_DEBUG)
	if(!SStrading_card_game.loaded)
		to_chat(usr, span_admin("The card subsystem is not currently loaded!"))
		return

	SStrading_card_game.printAllCards()

ADMIN_VERB(fun, give_mob_spell, "", R_FUN, mob/spell_recipient in GLOB.mob_list)
	var/which = tgui_alert(usr, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return
	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
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

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to give to [spell_recipient]", "ABRAKADABRA", sort_list(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(usr, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	log_admin("[key_name(usr)] gave [key_name(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(usr)] gave [key_name_admin(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	var/datum/action/cooldown/spell/new_spell = new spell_path(spell_recipient.mind || spell_recipient)
	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	new_spell.Grant(spell_recipient)
	if(!spell_recipient.mind)
		to_chat(usr, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))

ADMIN_VERB(fun, remove_spell, "", R_FUN, mob/removal_target in GLOB.mob_list)
	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in removal_target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to remove from [removal_target]", "ABRAKADABRA", sort_list(target_spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(usr)] removed the spell [chosen_spell] from [key_name(removal_target)].")
	message_admins("[key_name_admin(usr)] removed the spell [chosen_spell] from [key_name_admin(removal_target)].")

ADMIN_VERB(fun, give_disease, "Give Disease", R_FUN, mob/living/victim in GLOB.mob_living_list)
	var/datum/disease/disease_type = input(usr, "Choose the disease to give to that guy", "ACHOO") as null|anything in sort_list(SSdisease.diseases, GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!disease_type)
		return
	victim.ForceContractDisease(new disease_type, FALSE, TRUE)

	log_admin("[key_name(usr)] gave [key_name(victim)] the disease [disease_type].")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(victim)] the disease [disease_type]."))

ADMIN_CONTEXT_ENTRY(context_object_say, "Object Say", R_FUN, obj/target in world)
	var/message = tgui_input_text(usr, "What do you want the message to be?", "Make Sound", encode = FALSE)
	if(!message)
		return
	target.say(message, sanitize = FALSE)
	log_admin("[key_name(usr)] made [target] at [AREACOORD(target)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(usr)] made [target] at [AREACOORD(target)]. say \"[message]\""))

ADMIN_VERB(build_mode, toggle_build_mode_self, "", R_BUILD)
	togglebuildmode(usr)

ADMIN_VERB(game, check_ai_laws, "", R_ADMIN)
	var/law_bound_entities = 0
	for(var/mob/living/silicon/subject as anything in GLOB.silicon_mobs)
		law_bound_entities++

		var/message = ""

		if(isAI(subject))
			message += "<b>AI [key_name(subject, usr)]'s laws:</b>"
		else if(iscyborg(subject))
			var/mob/living/silicon/robot/borg = subject
			message += "<b>CYBORG [key_name(subject, usr)] [borg.connected_ai?"(Slaved to: [key_name(borg.connected_ai)])":"(Independent)"]: laws:</b>"
		else if (ispAI(subject))
			message += "<b>pAI [key_name(subject, usr)]'s laws:</b>"
		else
			message += "<b>SOMETHING SILICON [key_name(subject, usr)]'s laws:</b>"

		message += "<br>"

		if (!subject.laws)
			message += "[key_name(subject, usr)]'s laws are null?? Contact a coder."
		else
			message += jointext(subject.laws.get_law_list(include_zeroth = TRUE), "<br>")

		to_chat(usr, message, confidential = TRUE)

	if(!law_bound_entities)
		to_chat(usr, "<b>No law bound entities located</b>", confidential = TRUE)

/client/proc/readmin() // not an ADMIN_VERB for a reason
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

ADMIN_VERB(debug, populate_world, "Populate the world with the given number of test mobs", R_DEBUG, amount = 50 as num)
	for (var/i in 1 to amount)
		var/turf/tile = get_safe_random_station_turf()
		var/mob/living/carbon/human/hooman = new(tile)
		hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
		testing("Spawned test mob at [get_area_name(tile, TRUE)] ([tile.x],[tile.y],[tile.z])")

ADMIN_VERB(game, toggle_admin_ai_interaction, "Allows you to interact with most machines as an AI would as a ghost", R_ADMIN)
	usr.client.AI_Interact = !usr.client.AI_Interact
	if(usr && isAdminGhostAI(usr))
		usr.has_unlimited_silicon_privilege = usr.client.AI_Interact

	log_admin("[key_name(usr)] has [usr.client.AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [usr.client.AI_Interact ? "activated" : "deactivated"] their AI interaction")

/client/proc/admin_2fa_verify() // not an ADMIN_VERB for a reason
	set name = "Verify Admin"
	set category = "Admin"

	var/datum/admins/admin = GLOB.admin_datums[ckey]
	admin?.associate(src)

ADMIN_VERB(debug, send_maps_profile, "", R_DEBUG)
	usr.client << link("?debug=profile&type=sendmaps&window=test")

/**
 * Debug verb that spawns human crewmembers
 * of each job type, gives them a mind and assigns the role,
 * and injects them into the manifest, as if they were a "player".
 *
 * This spawns humans with minds and jobs, but does NOT make them 'players'.
 * They're all clientles mobs with minds / jobs.
 */

ADMIN_VERB(debug, spawn_debug_full_crew, "Creates a full crew for the station, filling the datacore and assigning them all minds/jobs. Don't do this on live", R_DEBUG)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "You should only be using this after a round has setup and started.")
		return

	// Two input checks here to make sure people are certain when they're using this.
	if(tgui_alert(usr, "This command will create a bunch of dummy crewmembers with minds, job, and datacore entries, which will take a while and fill the manifest.", "Spawn Crew", list("Yes", "Cancel")) != "Yes")
		return

	if(tgui_alert(usr, "I sure hope you aren't doing this on live. Are you sure?", "Spawn Crew (Be certain)", list("Yes", "Cancel")) != "Yes")
		return

	// Find the observer spawn, so we have a place to dump the dummies.
	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	var/turf/destination = get_turf(observer_point)
	if(!destination)
		to_chat(usr, "Failed to find the observer spawn to send the dummies.")
		return

	// Okay, now go through all nameable occupations.
	// Pick out all jobs that have JOB_CREW_MEMBER set.
	// Then, spawn a human and slap a person into it.
	var/number_made = 0
	for(var/rank in SSjob.name_occupations)
		var/datum/job/job = SSjob.GetJob(rank)

		// JOB_CREW_MEMBER is all jobs that pretty much aren't silicon
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue

		// Create our new_player for this job and set up its mind.
		var/mob/dead/new_player/new_guy = new()
		new_guy.mind_initialize()
		new_guy.mind.name = "[rank] Dummy"

		// Assign the rank to the new player dummy.
		if(!SSjob.AssignRole(new_guy, job))
			qdel(new_guy)
			to_chat(usr, "[rank] wasn't able to be spawned.")
			continue

		// It's got a job, spawn in a human and shove it in the human.
		var/mob/living/carbon/human/character = new(destination)
		character.name = new_guy.mind.name
		new_guy.mind.transfer_to(character)
		qdel(new_guy)

		// Then equip up the human with job gear.
		SSjob.EquipRank(character, job)
		job.after_latejoin_spawn(character)

		// Finally, ensure the minds are tracked and in the manifest.
		SSticker.minds += character.mind
		if(ishuman(character))
			GLOB.manifest.inject(character)

		number_made++
		CHECK_TICK

	to_chat(usr, "[number_made] crewmembers have been created.")

/// Debug verb for seeing at a glance what all spells have as set requirements

ADMIN_VERB(debug, show_spell_requirements, "seeing at a glance what all spells have as set requirements", R_DEBUG)
	var/header = "<tr><th>Name</th> <th>Requirements</th>"
	var/all_requirements = list()
	for(var/datum/action/cooldown/spell/spell as anything in typesof(/datum/action/cooldown/spell))
		if(initial(spell.name) == "Spell")
			continue

		var/list/real_reqs = list()
		var/reqs = initial(spell.spell_requirements)
		if(reqs & SPELL_CASTABLE_AS_BRAIN)
			real_reqs += "Castable as brain"
		if(reqs & SPELL_CASTABLE_WHILE_PHASED)
			real_reqs += "Castable phased"
		if(reqs & SPELL_REQUIRES_HUMAN)
			real_reqs += "Must be human"
		if(reqs & SPELL_REQUIRES_MIME_VOW)
			real_reqs += "Must be miming"
		if(reqs & SPELL_REQUIRES_MIND)
			real_reqs += "Must have a mind"
		if(reqs & SPELL_REQUIRES_NO_ANTIMAGIC)
			real_reqs += "Must have no antimagic"
		if(reqs & SPELL_REQUIRES_OFF_CENTCOM)
			real_reqs += "Must be off central command z-level"
		if(reqs & SPELL_REQUIRES_WIZARD_GARB)
			real_reqs += "Must have wizard clothes"

		all_requirements += "<tr><td>[initial(spell.name)]</td> <td>[english_list(real_reqs, "No requirements")]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(all_requirements, "")]</table>"
	var/datum/browser/popup = new(usr, "spellreqs", "Spell Requirements", 600, 400)
	popup.set_content(page_contents)
	popup.open()

ADMIN_VERB(events, load_jump_lazy_template, "", R_ADMIN)
	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(usr, "Key?", "Lazy Loader", choices)
	if(!choice)
		return

	choice = choices[choice]
	if(!choice)
		to_chat(usr, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(usr, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(usr, span_boldwarning("Failed to load template!"))
		return

	if(!isobserver(usr))
		SSadmin_verbs.dynamic_invoke_admin_verb(usr.client, /mob/admin_module_holder/game/aghost)
	usr.forceMove(coords2turf(reservation.bottom_left_coords))

	message_admins("[key_name_admin(usr)] has loaded lazy template '[choice]'")
	to_chat(usr, span_boldnicegreen("Template loaded, you have been moved to the bottom left of the reservation."))
