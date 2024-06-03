/obj/item/cyberlink_connector
	name = "Wireless personal connector"
	desc = "Allows you to connect to incompatible implants and hack them."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "connector"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/organ/internal/cyberimp/cyberlink/parent_cyberlink
	var/list/datum/hacking_minigame/game_list = list()
	var/current_timer_id = FALSE
	var/obj/item/organ/internal/cyberimp/cybernetic
	var/mob/living/current_user
	var/mob/living/linked_target

/obj/item/cyberlink_connector/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/cyberlink_connector/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(linked_target)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Rip out cyberlink connection"

	return CONTEXTUAL_SCREENTIP_SET

/obj/item/cyberlink_connector/Destroy()
	. = ..()
	parent_cyberlink = null
	if(!QDELETED(linked_target))
		qdel(linked_target.GetComponent(/datum/component/leash))
		linked_target = null
	cleanup()

///We dont open the tgui when we click on this.
/obj/item/cyberlink_connector/interact(mob/user)
	add_fingerprint(user)

/obj/item/cyberlink_connector/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return

	if(ishuman(target))
		if(!QDELETED(linked_target) && (target != linked_target))
			return
		if(target != user)
			return

		var/mob/living/carbon/human/human = target
		var/list/implants = list()
		for(var/obj/item/organ/internal/cyberimp/imp as anything in human.organs)
			if(!istype(imp))
				continue

			if(istype(imp, /obj/item/organ/internal/cyberimp/cyberlink))
				continue

			implants += imp
		if(!length(implants))
			return
		var/choice = tgui_input_list(user, "Choose an implant you wish to hack.", "Internal Implants", implants)
		if(!choice)
			return
		target = choice

	else
		if(!istype(target,/obj/item/organ/internal/cyberimp) || istype(target,/obj/item/organ/internal/cyberimp/cyberlink))
			return

	if(QDELETED(parent_cyberlink))
		var/obj/item/organ/internal/cyberimp/cyberlink/link = user.get_organ_slot(ORGAN_SLOT_LINK)
		if(QDELETED(link))
			to_chat(user, span_notice("NO CYBERLINK DETECTED") )
			return
		parent_cyberlink = link

	game_list = list()

	var/diffrences = 3
	current_user = user
	cybernetic = target

	for(var/info in cybernetic.encode_info)
		if(cybernetic.encode_info[info] == NO_PROTOCOL)
			continue
		var/list/encrypted_information = cybernetic.encode_info[info]

		for(var/protocol in encrypted_information)
			if(protocol in parent_cyberlink.encode_info[info])
				diffrences--
				break

	if(diffrences == 0)
		to_chat(current_user,span_notice("Cyberlink beeps: [uppertext(cybernetic.name)] ALREADY COMPATIBLE."))
		cleanup()
		return

	var/size = 8
	if(cybernetic.encode_info == AUGMENT_NT_LOWLEVEL)
		size = 4
	if(cybernetic.encode_info == AUGMENT_NT_HIGHLEVEL)
		size = 6

	if(HAS_TRAIT(user, TRAIT_BETTER_CYBERCONNECTOR))
		size = max(4, size--)

	diffrences = max(1, diffrences--)
	if(!length(game_list))
		for(var/i in 1 to diffrences)
			var/datum/hacking_minigame/game = new/datum/hacking_minigame(size)
			game.generate()
			game_list += game

	ui_interact(user)

/obj/item/cyberlink_connector/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(user) || !isliving(target))
		return
	var/mob/living/target_living = target
	var/obj/item/organ/internal/cyberimp/cyberlink/link = target_living.get_organ_slot(ORGAN_SLOT_LINK)
	if(!link)
		to_chat(user, span_notice("[target] doesn't have a cyberlink."))
		return
	user.visible_message(span_notice("[user] begins to start plugging "))
	if(!do_after(user, 2 SECONDS, target))
		return
	linked_target = target_living
	target_living.AddComponent(/datum/component/leash, src, 3, beam_icon_state = "razorwire", beam_icon = 'icons/effects/beam.dmi', force_teleports = FALSE, break_callback = CALLBACK(src, PROC_REF(clear_target_link)))
	parent_cyberlink = link

/obj/item/cyberlink_connector/AltClick(mob/user)
	. = ..()
	if(QDELETED(linked_target))
		return
	clear_target_link()

/obj/item/cyberlink_connector/proc/clear_target_link()
	if(!QDELETED(linked_target))
		qdel(linked_target.GetComponent(/datum/component/leash))
		linked_target = null

/obj/item/cyberlink_connector/proc/cleanup()
	current_user = null
	cybernetic = null
	QDEL_LIST(game_list)
	deltimer(current_timer_id)
	current_timer_id = FALSE

/obj/item/cyberlink_connector/proc/hack_success(success as num)
	var/mob/living/to_display = current_user
	if(!QDELETED(linked_target))
		to_display = linked_target
	for(var/info in cybernetic.encode_info)
		if(cybernetic.encode_info[info] == NO_PROTOCOL)
			continue
		//Not a += because we want to avoid having duplicate entries in either encode_info
		cybernetic.encode_info[info] |= parent_cyberlink.encode_info[info]
	current_user.mind.adjust_experience(/datum/skill/implant_hacking, success * 25)
	to_chat(to_display, span_notice("Cyberlink beeps: HACKING [uppertext(cybernetic.name)] SUCCESS. COMPATIBILITY ACHIEVED."))
	say("Successfully hacked augment.")
	playsound(src, 'sound/machines/terminal_success.ogg', 50)
	ui_close(current_user)
	cleanup()


/obj/item/cyberlink_connector/proc/hack_failure(failed as num)
	var/chance = rand(0, 40*failed)
	var/mob/living/to_damage = current_user
	if(!QDELETED(linked_target))
		to_damage = linked_target
	switch(chance)
		if(0 to 25)
			to_chat(to_damage,span_warning(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MINOR FAILURE. COMPATIBILITY NOT ACHIEVED. NO DAMAGE DETECTED.") )
		if(26 to 40)
			to_chat(to_damage,span_warning(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MEDIUM FAILURE. COMPATIBILITY NOT ACHIEVED. SMALL AMOUNT OF DAMAGE DETECTED.") )
			to_damage.adjustFireLoss(10)
			to_damage.emote("scream")
		if(41 to 50)
			to_chat(to_damage,span_warning(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MEDIUM FAILURE. COMPATIBILITY NOT ACHIEVED. PROTOCOL SCRAMBILING DETECTED.") )
			cybernetic.random_encode()
		if(51 to 75)
			to_chat(to_damage,span_danger(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MAJOR FAILURE. COMPATIBILITY NOT ACHIEVED. MINOR ELECTROMAGNETIC PULSE DETECTED.") )
			to_damage.emp_act(1)
		if(76 to 99)
			to_chat(to_damage,span_danger(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] MAJOR FAILURE. COMPATIBILITY NOT ACHIEVED. MAJOR ELECTROMAGNETIC PULSE DETECTED.") )
			to_damage.emp_act(2)
		if(100 to INFINITY)
			to_chat(to_damage,span_danger(" Cyberlink beeps: HACKING [uppertext(cybernetic.name)] CRITICAL FAILURE. COMPATIBILITY NOT ACHIEVED. IMPLANT OVERHEATING IN 5 SECONDS.") )
			cybernetic.visible_message(span_danger("[cybernetic.name] begins to flare and twitch as the electronics fry and sizzle!") )
			addtimer(CALLBACK(src, PROC_REF(explode)), 5 SECONDS)

	cybernetic.failed_count++
	current_user.mind.adjust_experience(/datum/skill/implant_hacking,(4 - failed)*2)
	say("Failed to hack augment.")
	playsound(src, 'sound/machines/terminal_error.ogg', 50)
	ui_close(current_user)
	cleanup()

/obj/item/cyberlink_connector/proc/explode()
	SIGNAL_HANDLER

	dyn_explosion(get_turf(cybernetic),2,1)
	qdel(src)

/obj/item/cyberlink_connector/proc/game_update(end_game = FALSE)
	var/finished = TRUE
	var/failed = 0

	for(var/datum/hacking_minigame/game in game_list)
		if(!game.finished)
			finished = FALSE
			failed++

	if(finished)
		hack_success(length(game_list))

	if(end_game)
		hack_failure(failed)

/obj/item/cyberlink_connector/ui_data(mob/user)
	var/list/data = list()
	data["timeleft"] = current_timer_id ? timeleft(current_timer_id) : 0

	for(var/datum/hacking_minigame/game in game_list)
		data["games"] += list(game.get_simplified_image())
		data["finished_states"] += list(game.finished)

	return data

/obj/item/cyberlink_connector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(!current_timer_id)
			var/time_left = (length(game_list) * 10  - 2 * (length(game_list)-1) + user.mind.get_skill_modifier(/datum/skill/implant_hacking, SKILL_TIME_MODIFIER) + (cybernetic.failed_count * 2 * (length(game_list)))) SECONDS
			current_timer_id = addtimer(CALLBACK(src, PROC_REF(game_update), TRUE),time_left,TIMER_STOPPABLE)
			START_PROCESSING(SSprocessing,src)
		ui = new(user, src, "Hacking", name)
		ui.open()

/obj/item/cyberlink_connector/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/hacking)

/obj/item/cyberlink_connector/ui_act(action,list/params,datum/tgui/ui)
	. = ..()
	if(action == "click")
		var/xcord = text2num(params["xcord"])+1
		var/ycord = text2num(params["ycord"])+1 //we need to slightly offset these so they work properly
		var/minigame_id = text2num(params["id"])+1
		if(game_list[minigame_id] && !game_list[minigame_id].finished)
			game_list[minigame_id].board[xcord][ycord].rotate()
			game_list[minigame_id].game_check()
			game_update()
		return TRUE
