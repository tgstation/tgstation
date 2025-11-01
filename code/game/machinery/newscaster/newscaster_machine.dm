#define ALERT_DELAY (50 SECONDS)

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "newscaster_off"
	base_icon_state = "newscaster"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor_type = /datum/armor/machinery_newscaster
	max_integrity = 200
	integrity_failure = 0.25
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_LITERACY
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///Name of the logged in user.
	var/newscaster_username
	///How much paper is contained within the newscaster?
	var/paper_remaining = 0
	///The access required to access D-notices.
	var/admin_access = ACCESS_LIBRARY
	///The access required to submit & remove wanted issues.
	var/security_access = ACCESS_SECURITY

	///What newscaster channel is currently being viewed by the player?
	var/datum/feed_channel/current_channel
	///What newscaster feed_message is currently having a comment written for it?
	var/datum/feed_message/current_message
	///The message that's currently being written for a feed story.
	var/feed_channel_message
	///The current image that will be submitted with the newscaster story.
	var/datum/picture/current_image
	///Is there currently an alert on this newscaster that hasn't been seen yet?
	var/alert = FALSE
	///Is the current user editing or viewing a new wanted issue at the moment?
	var/viewing_wanted  = FALSE
	///Is the current user creating a new channel at the moment?
	var/creating_channel = FALSE
	///Is the current user creating a new comment at the moment?
	var/creating_comment = FALSE
	///Are we currently locked and awaiting approval for the new cross-sector channel?
	var/awaiting_approval = FALSE
	///What is the user submitted, criminal name for the new wanted issue?
	var/criminal_name
	///What is the user submitted, crime description for the new wanted issue?
	var/crime_description
	///What is the current, in-creation channel's name going to be?
	var/channel_name
	///What is the current, in-creation channel's description going to be?
	var/channel_desc
	///What is the current, in-creation comment's body going to be?
	var/comment_text
	///Timer ID for creation of cross-sector channels
	var/channel_approval_timer

	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Value of the currently bounty input
	var/bounty_value = 1
	///Text of the currently written bounty
	var/bounty_text = ""

/datum/armor/machinery_newscaster
	melee = 50
	fire = 50
	acid = 30

/obj/machinery/newscaster/pai/ui_state(mob/user)
	return GLOB.deep_inventory_state

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/newscaster, 30)

/obj/machinery/newscaster/Initialize(mapload)
	. = ..()
	GLOB.allCasters += src
	GLOB.allbountyboards += src
	update_appearance()
	if(mapload)
		find_and_hang_on_wall()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	GLOB.allbountyboards -= src
	current_channel = null
	current_image = null
	active_request = null
	current_user = null
	newscaster_username = null
	return ..()

/obj/machinery/newscaster/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(1.5, 0.7, "#34D352") // green light

/obj/machinery/newscaster/update_overlays()
	. = ..()


	if(!(machine_stat & (NOPOWER|BROKEN)))
		var/state = "[base_icon_state]_[GLOB.news_network.wanted_issue.active ? "wanted" : "normal"]"
		. += mutable_appearance(icon, state)
		. += emissive_appearance(icon, state, src, alpha = src.alpha)

		if(GLOB.news_network.wanted_issue.active && alert)
			. += mutable_appearance(icon, "[base_icon_state]_alert")
			. += emissive_appearance(icon, "[base_icon_state]_alert", src, alpha = src.alpha,)

	var/hp_percent = atom_integrity * 100 / max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			. += "crack1"
			. += emissive_blocker(icon, "crack1", src, alpha = src.alpha)
		if(25 to 50)
			. += "crack2"
			. += emissive_blocker(icon, "crack2", src, alpha = src.alpha)
		else
			. += "crack3"
			. += emissive_blocker(icon, "crack3", src, alpha = src.alpha)

/obj/machinery/newscaster/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PhysicalNewscaster", name)
		ui.open()
	alert = FALSE //We're checking our messages!
	update_icon()

/obj/machinery/newscaster/ui_data(mob/user)
	var/list/data = list()
	var/list/message_list = list()

	//Code displaying name and Job Information, taken from the player mob's ID card if one exists.
	var/obj/item/card/id/card
	if(issilicon(user))
		newscaster_username = user.name
	else if(isliving(user))
		var/mob/living/living_user = user
		card = living_user.get_idcard(hand_first = TRUE)
		newscaster_username = card?.registered_account.account_holder

	if(card)
		current_user = card.registered_account
		data["user"] = list()
		data["user"]["name"] = card.registered_account.account_holder
		if(card?.registered_account.account_job)
			data["user"]["job"] = card.registered_account.account_job.title
			data["user"]["department"] = card.registered_account.account_job.paycheck_department
		else
			data["user"]["job"] = "No Job"
			data["user"]["department"] = DEPARTMENT_UNASSIGNED
	else if(issilicon(user))
		var/mob/living/silicon/silicon_user = user
		data["user"] = list()
		data["user"]["name"] = silicon_user.name
		data["user"]["job"] = silicon_user.job
		data["user"]["department"] = "N/A"
	else
		data["user"] = list()
		data["user"]["name"] = user.name
		data["user"]["job"] = "N/A"
		data["user"]["department"] = "N/A"

	data["admin_mode"] = (admin_access in card?.GetAccess())
	data["security_mode"] = (security_access in card?.GetAccess())
	data["photo_data"] = !isnull(current_image)
	data["creating_channel"] = creating_channel
	data["awaiting_approval"] = awaiting_approval
	data["creating_comment"] = creating_comment
	data["viewing_wanted"] = viewing_wanted

	//Here is all the UI_data sent about the current wanted issue, as well as making a new one in the UI.
	data["making_wanted_issue"] = !(GLOB.news_network.wanted_issue?.active)
	data["criminal_name"] = criminal_name
	data["crime_description"] = crime_description
	var/list/wanted_info = list()
	if(GLOB.news_network.wanted_issue)
		var/has_wanted_issue = !isnull(GLOB.news_network.wanted_issue.img)
		if(has_wanted_issue)
			user << browse_rsc(GLOB.news_network.wanted_issue.img, "wanted_photo.png")
		wanted_info = list(list(
			"active" = GLOB.news_network.wanted_issue.active,
			"criminal" = GLOB.news_network.wanted_issue.criminal,
			"crime" = GLOB.news_network.wanted_issue.body,
			"author" = GLOB.news_network.wanted_issue.scanned_user,
			"image" = (has_wanted_issue ? "wanted_photo.png" : null)
		))

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	if(current_channel)
		for(var/datum/feed_message/feed_message as anything in current_channel.messages)
			var/photo_id = null
			var/list/comment_list
			if(feed_message.img)
				user << browse_rsc(feed_message.img, "tmp_photo[feed_message.message_id].png")
				photo_id = "tmp_photo[feed_message.message_id].png"
			for(var/datum/feed_comment/comment_message as anything in feed_message.comments)
				comment_list += list(list(
					"auth" = comment_message.author,
					"body" = comment_message.body,
					"time" = comment_message.time_stamp,
				))
			message_list += list(list(
				"auth" = feed_message.author,
				"body" = feed_message.body,
				"time" = feed_message.time_stamp,
				"channel_num" = feed_message.parent_id,
				"censored_message" = feed_message.body_censor,
				"censored_author" = feed_message.author_censor,
				"ID" = feed_message.message_id,
				"photo" = photo_id,
				"comments" = comment_list
			))


	data["viewing_channel"] = current_channel?.channel_id
	data["paper"] = paper_remaining
	//Here we display all the information about the current channel.
	data["channelName"] = current_channel?.channel_name
	data["channelAuthor"] = current_channel?.author

	if(!current_channel)
		data["channelAuthor"] = "Nanotrasen Inc"
		data["channelDesc"] = "Welcome to Newscaster Net. Interface & News networks Operational."
		data["channelLocked"] = TRUE
		data["receivingCrossSector"] = FALSE
	else
		data["channelDesc"] = current_channel.channel_desc
		data["channelLocked"] = current_channel.locked
		data["channelCensored"] = current_channel.censored
		data["receivingCrossSector"] = current_channel.receiving_cross_sector

	//We send all the information about all messages in existence.
	data["messages"] = message_list
	data["wanted"] = wanted_info

	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	for (var/datum/station_request/request as anything in GLOB.request_list)
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/applicant_bank_account as anything in request.applicants)
				formatted_applicants += list(list("name" = applicant_bank_account.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = applicant_bank_account.account_id))
	data["requests"] = formatted_requests
	data["applicants"] = formatted_applicants
	data["bountyValue"] = bounty_value
	data["bountyText"] = bounty_text

	return data

/obj/machinery/newscaster/ui_static_data(mob/user)
	var/list/data = list()
	var/list/channel_list = list()
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_id,
		))

	data["channels"] = channel_list
	return data


/obj/machinery/newscaster/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	var/current_ref_num = params["request"]
	var/current_app_num = params["applicant"]
	var/datum/bank_account/request_target
	if(current_ref_num)
		for(var/datum/station_request/iterated_station_request as anything in GLOB.request_list)
			if(iterated_station_request.req_number == current_ref_num)
				active_request = iterated_station_request
				break
	if(active_request)
		for(var/datum/bank_account/iterated_bank_account as anything in active_request.applicants)
			if(iterated_bank_account.account_id == current_app_num)
				request_target = iterated_bank_account
				break

	switch(action)
		if("setChannel")
			var/selected_channel_id = params["channel"]
			if(isnull(selected_channel_id))
				return TRUE
			var/datum/feed_channel/potential_channel = GLOB.news_network.network_channels_by_id["[selected_channel_id]"]
			if(isnull(potential_channel))
				return TRUE
			current_channel = potential_channel

		if("createStory")
			if(!current_channel)
				balloon_alert(user, "select a channel first!")
				return TRUE
			var/current_channel_id = params["current"]
			create_story(user, channel_id = current_channel_id)

		if("togglePhoto")
			toggle_photo(user)
			return TRUE

		if("startCreateChannel")
			start_create_channel(user)
			return TRUE

		if("setChannelName")
			var/pre_channel_name = reject_bad_text(params["channeltext"], max_length = MAX_NAME_LEN)
			if(!pre_channel_name)
				return TRUE
			channel_name = pre_channel_name

		if("setChannelDesc")
			var/pre_channel_desc = reject_bad_text(params["channeldesc"], max_length = MAX_BROADCAST_LEN)
			if(!pre_channel_desc)
				return TRUE
			channel_desc = pre_channel_desc

		if("createChannel")
			var/locked = params["lockedmode"]
			var/cross_sector = params["cross_sector"]
			create_channel(user, locked, cross_sector)
			return TRUE

		if("cancelCreation")
			creating_channel = FALSE
			creating_comment = FALSE
			awaiting_approval = FALSE
			viewing_wanted = FALSE
			criminal_name = null
			crime_description = null
			return TRUE

		if("storyCensor")
			var/obj/item/card/id/id_card
			if(isliving(user))
				var/mob/living/living_user = user
				id_card = living_user.get_idcard(hand_first = TRUE)
			if(!(admin_access in id_card?.GetAccess()))
				say("Clearance not found.")
				return TRUE
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message as anything in current_channel.messages)
				if(iterated_feed_message.message_id == questionable_message)
					iterated_feed_message.toggle_censor_body()
					break

		if("authorCensor")
			var/obj/item/card/id/id_card
			if(isliving(user))
				var/mob/living/living_user = user
				id_card = living_user.get_idcard(hand_first = TRUE)
			if(!(admin_access in id_card?.GetAccess()))
				say("Clearance not found.")
				return TRUE
			var/questionable_message = params["messageID"]
			for(var/datum/feed_message/iterated_feed_message in current_channel.messages)
				if(iterated_feed_message.message_id == questionable_message)
					iterated_feed_message.toggle_censor_author()
					break

		if("channelDNotice")
			var/obj/item/card/id/id_card
			if(isliving(user))
				var/mob/living/living_user = user
				id_card = living_user.get_idcard(hand_first = TRUE)
			if(!(admin_access in id_card?.GetAccess()))
				say("Clearance not found.")
				return TRUE
			var/selected_channel_id = (params["channel"])
			if(isnull(selected_channel_id))
				return TRUE
			var/datum/feed_channel/potential_channel = GLOB.news_network.network_channels_by_id["[selected_channel_id]"]
			if(isnull(potential_channel))
				return TRUE
			current_channel = potential_channel
			current_channel.toggle_censor_D_class()

		if("startComment")
			if(!newscaster_username)
				creating_comment = FALSE
				return TRUE
			creating_comment = TRUE
			var/commentable_message = params["messageID"]
			if(!commentable_message)
				return TRUE
			for(var/datum/feed_message/iterated_feed_message as anything in current_channel.messages)
				if(iterated_feed_message.message_id == commentable_message)
					current_message = iterated_feed_message
			return TRUE

		if("setCommentBody")
			var/pre_comment_text = params["commenttext"]
			if(!pre_comment_text)
				return TRUE
			comment_text = pre_comment_text
			return TRUE

		if("createComment")
			create_comment(user)
			return TRUE

		if("toggleWanted")
			alert = FALSE
			viewing_wanted = TRUE
			update_appearance()
			return TRUE

		if("setCriminalName")
			var/temp_name = tgui_input_text(user, "Write the Criminal's Name", "Warrent Alert Handler", "John Doe", max_length = MAX_NAME_LEN, multiline = FALSE)
			if(!temp_name)
				return TRUE
			criminal_name = temp_name
			return TRUE

		if("setCrimeData")
			var/temp_desc = tgui_input_text(user, "Write the Criminal's Crimes", "Warrent Alert Handler", "Unknown", max_length = MAX_BROADCAST_LEN, multiline = TRUE)
			if(!temp_desc)
				return TRUE
			crime_description = temp_desc
			return TRUE

		if("submitWantedIssue")
			if(!crime_description || !criminal_name)
				return TRUE
			GLOB.news_network.submit_wanted(criminal_name, crime_description, newscaster_username, current_image, adminMsg = FALSE, newMessage = TRUE)
			current_image = null
			return TRUE

		if("clearWantedIssue")
			clear_wanted_issue(user)
			for(var/obj/machinery/newscaster/other_newscaster in GLOB.allCasters)
				other_newscaster.update_appearance()
				return TRUE

		if("printNewspaper")
			print_paper(user)
			return TRUE

		if("createBounty")
			create_bounty()
			return TRUE

		if("apply")
			apply_to_bounty()
			return TRUE

		if("payApplicant")
			pay_applicant(payment_target = request_target)
			return TRUE

		if("clear")
			if(current_user || newscaster_username)
				current_user = null
				newscaster_username = null
				say("Account Reset.")
				return TRUE

		if("deleteRequest")
			delete_bounty_request()
			return TRUE

		if("bountyVal")
			bounty_value = text2num(params["bountyval"])
			if(!bounty_value)
				bounty_value = 1
			bounty_value = clamp(bounty_value, 1, 1000)

		if("bountyText")
			var/pre_bounty_text = params["bountytext"]
			if(!pre_bounty_text)
				return
			bounty_text = pre_bounty_text
	return TRUE

/obj/machinery/newscaster/on_set_machine_stat(old_value)
	. = ..()
	update_appearance()

/obj/machinery/newscaster/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/paper))
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return
		paper_remaining++
		to_chat(user, span_notice("You insert [attacking_item] into [src]! It now holds [paper_remaining] sheet\s of paper."))
		qdel(attacking_item)
		return
	return ..()

///returns (machine_stat & broken)
/obj/machinery/newscaster/proc/needs_repair()
	return (machine_stat & BROKEN)

/obj/machinery/newscaster/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	. = ITEM_INTERACT_SUCCESS
	if(!(machine_stat & BROKEN))
		to_chat(user, span_notice("[src] does not need repairs."))
		return
	if(!tool.tool_start_check(user, amount=1))
		return
	user.balloon_alert_to_viewers("started welding...", "started repairing...")
	audible_message(span_hear("You hear welding."))
	if(!tool.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, PROC_REF(needs_repair))))
		user.balloon_alert_to_viewers("stopped welding!", "interrupted the repair!")
		return
	user.balloon_alert_to_viewers("repaired [src]")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)

/obj/machinery/newscaster/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [src]..."))
	if(!tool.use_tool(src, user, 60, volume=50))
		return
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	if((machine_stat & BROKEN))
		to_chat(user, span_warning("The broken remains of [src] fall on the ground."))
		new /obj/item/stack/sheet/iron(loc, 5)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	else
		to_chat(user, span_notice("You [anchored ? "un" : ""]secure [src]."))
		new /obj/item/wallframe/newscaster(loc)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, TRUE)
			else
				playsound(loc, 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)


/obj/machinery/newscaster/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/iron(loc, 2)
	new /obj/item/shard(loc)
	new /obj/item/shard(loc)

/obj/machinery/newscaster/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)


/obj/machinery/newscaster/attack_paw(mob/living/user, list/modifiers)
	if(!user.combat_mode)
		to_chat(user, span_warning("The newscaster controls are far too complicated for your tiny brain!"))
	else
		take_damage(5, BRUTE, MELEE)

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_appearance()

/**
 * Sends photo data to build the newscaster article.
 */
/obj/machinery/newscaster/proc/send_photo_data()
	if(!current_image)
		return null
	return current_image

/**
 * This takes a held photograph, and updates the current_image variable with that of the held photograph's image.
 * *user: The mob who is being checked for a held photo object.
 */
/obj/machinery/newscaster/proc/attach_photo(mob/user)
	var/obj/item/photo/photo = user.is_holding_item_of_type(/obj/item/photo)
	if(photo)
		current_image = photo.picture
	if(issilicon(user))
		var/obj/item/camera/siliconcam/targetcam
		if(isAI(user))
			var/mob/living/silicon/ai/R = user
			targetcam = R.aicamera
		else if(ispAI(user))
			var/mob/living/silicon/pai/R = user
			if(R.aicamera)
				targetcam = R.aicamera
		else if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			if(R.connected_ai)
				targetcam = R.connected_ai.aicamera
			else
				targetcam = R.aicamera
		else
			to_chat(user, span_warning("You cannot interface with silicon photo uploading!"))
		if(!targetcam.stored.len)
			to_chat(user, span_bolddanger("No images saved."))
			return
		var/datum/picture/selection = targetcam.selectpicture(user)
		if(selection)
			current_image = selection

/**
 * This takes all current feed stories and messages, and prints them onto a newspaper, after checking that the newscaster has been loaded with paper.
 * The newscaster then prints the paper to the floor.
 */
/obj/machinery/newscaster/proc/print_paper(mob/user)
	if(paper_remaining <= 0)
		balloon_alert_to_viewers("out of paper!")
		return TRUE
	SSblackbox.record_feedback("amount", "newspapers_printed", 1)
	var/obj/item/newspaper/new_newspaper = new(loc)
	playsound(loc, SFX_PAGE_TURN, 50, TRUE)
	try_put_in_hand(new_newspaper, user)
	paper_remaining--

/**
 * This clears alerts on the newscaster from a new message being published and updates the newscaster's appearance.
 */
/obj/machinery/newscaster/proc/remove_alert()
	alert = FALSE
	update_appearance()

/**
 * When a new feed message is made that will alert all newscasters, this causes the newscasters to sent out a spoken message as well as create a sound.
 */
/obj/machinery/newscaster/proc/news_alert(channel, update_alert = TRUE)
	if(channel)
		if(update_alert)
			say("Breaking news from [channel]!")
			playsound(loc, 'sound/machines/beep/twobeep_high.ogg', 75, TRUE)
		alert = TRUE
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(remove_alert)), ALERT_DELAY, TIMER_UNIQUE|TIMER_OVERRIDE)

	else if(!channel && update_alert)
		say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)

/**
 * Performs a series of sanity checks before giving the user confirmation to create a new feed_channel using channel_name, and channel_desc.
 * *channel_locked: This variable determines if other users than the author can make comments and new feed_stories on this channel.
 *
 */
/obj/machinery/newscaster/proc/create_channel(mob/user, channel_locked, cross_sector)
	if(!channel_name)
		return
	if(cross_sector)
		channel_locked = TRUE

	if(!channel_desc)
		return TRUE

	if(isnull(channel_locked))
		return TRUE

	var/datum/feed_channel/potential_channel = GLOB.news_network.network_channels_by_name[channel_name]
	if(potential_channel)
		tgui_alert(user, "ERROR: Feed channel with that name already exists on the Network.", list("Okay"))
		return TRUE

	var/list/hard_filter_result = is_ic_filtered(channel_name)
	if(hard_filter_result)
		tgui_alert(user, "Your channel name contains: (\"[hard_filter_result[CHAT_FILTER_INDEX_WORD]]\"), which is not allowed on this server.")
		return TRUE

	var/choice = tgui_alert(user, "Please confirm feed channel creation","Network Channel Handler", list("Confirm", "Cancel"))
	creating_channel = FALSE
	if(choice != "Confirm")
		update_static_data(user)
		return

	var/approval_time = CROSS_SECTOR_CANCEL_TIME
	var/list/soft_filter_result = is_soft_ooc_filtered(channel_name)
	if(soft_filter_result)
		if(tgui_alert(user,"Your channel name contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \
			They may be using a disallowed term for a cross-station newscaster channel. Increasing delay time to reject.\n\n Channel name: \"[channel_name]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \
			They may be using a disallowed term for a cross-station newscaster channel. Increasing delay time to reject.\n\n Channel name: \"[channel_name]\"")
		approval_time = EXTENDED_CROSS_SECTOR_CANCEL_TIME

	if(!cross_sector)
		finish_channel_creation(user, channel_locked, FALSE)
		return

	awaiting_approval = TRUE
	update_static_data(user)
	user.log_message("is about to create a cross-sector newscaster channel with the following name: [channel_name]", LOG_GAME)
	to_chat(
		GLOB.admins,
		span_adminnotice( \
			"<b color='orange'>Cross-sector channel creation (OUTGOING):</b> [ADMIN_LOOKUPFLW(user)] is about to create a cross-sector \
			newscaster channel \"[channel_name]\" (will autoapprove in [DisplayTimeText(approval_time)]): \
			<b><a href='byond://?src=[REF(src)];reject_channel_creation=1'>REJECT</a></b>"\
		)
	)
	channel_approval_timer = addtimer(CALLBACK(src, PROC_REF(finish_channel_creation), user, channel_locked, TRUE, approval_time), approval_time, TIMER_STOPPABLE)

/obj/machinery/newscaster/proc/finish_channel_creation(mob/user, channel_locked, cross_sector, cross_sector_delay)
	channel_approval_timer = null
	awaiting_approval = FALSE
	GLOB.news_network.create_feed_channel(channel_name, newscaster_username, channel_desc, locked = channel_locked, author_ckey = user.ckey, cross_sector = cross_sector, cross_sector_delay = cross_sector_delay)
	SSblackbox.record_feedback("text", "newscaster_channels", 1, "[channel_name]")
	update_static_data(user)

/obj/machinery/newscaster/Topic(href, href_list)
	if (!href_list["reject_channel_creation"])
		return ..()

	if (!usr.client?.holder)
		usr.log_message("tried to reject the creation of a cross-sector newscaster channel without being an admin.", LOG_ADMIN)
		message_admins("[key_name(usr)] tried to reject the creation of a cross-sector newscaster channel without being an admin.")
		return

	if (isnull(channel_approval_timer))
		to_chat(usr, span_warning("It's too late!"))
		return

	deltimer(channel_approval_timer)
	channel_approval_timer = null

	log_admin("[key_name(usr)] has cancelled the creation of a cross-sector newscaster channel.")
	message_admins("[key_name(usr)] has cancelled the creation of a cross-sector newscaster channel.")
	return TRUE

/**
 * Constructs a comment to attach to the currently selected feed_message of choice, assuming that a user can be found and that a message body has been written.
 */
/obj/machinery/newscaster/proc/create_comment(mob/user)
	if(!comment_text)
		creating_comment = FALSE
		return TRUE
	if(!newscaster_username)
		creating_comment = FALSE
		return TRUE
	GLOB.news_network.submit_comment(user, comment_text, newscaster_username, current_message)
	creating_comment = FALSE

/**
 * This proc performs checks before enabling the creating_channel var on the newscaster, such as preventing a user from having multiple channels,
 * preventing an un-ID'd user from making a channel, and preventing censored authors from making a channel.
 * Otherwise, sets creating_channel to TRUE.
 */
/obj/machinery/newscaster/proc/start_create_channel(mob/user)
	//This first block checks for pre-existing reasons to prevent you from making a new channel, like being censored, or if you have a channel already.
	var/list/existing_authors = list()
	for(var/datum/feed_channel/iterated_feed_channel as anything in GLOB.news_network.network_channels)
		if(iterated_feed_channel.author_censor)
			existing_authors += GLOB.news_network.redacted_text
		else
			existing_authors += iterated_feed_channel.author
	if(!newscaster_username || (newscaster_username in existing_authors))
		creating_channel = FALSE
		tgui_alert(user, "ERROR: User cannot be found or already has an owned feed channel.", list("Okay"))
		return TRUE
	creating_channel = TRUE
	return TRUE

/**
 * Creates a new feed story to the global newscaster network.
 * Verifies that the message is being written to a real feed_channel, then provides a text input for the feed story to be written into.
 * Finally, it submits the message to the network, is logged globally, and clears all message-specific variables from the machine.
 */
/obj/machinery/newscaster/proc/create_story(mob/user, channel_id)
	var/datum/feed_channel/potential_channel = GLOB.news_network.network_channels_by_id["[channel_id]"]
	if(isnull(potential_channel))
		return
	current_channel = potential_channel

	if(current_channel.receiving_cross_sector)
		return

	var/temp_message = tgui_input_text(user, "Write your Feed story", "Network Channel Handler", feed_channel_message, max_length = MAX_MESSAGE_LEN, multiline = TRUE)
	if(length(temp_message) <= 1)
		return TRUE

	if(temp_message)
		feed_channel_message = temp_message

	GLOB.news_network.submit_article("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, user)]</font>", newscaster_username, current_channel.channel_name, send_photo_data(), adminMessage = FALSE, allow_comments = TRUE, author_mob = user)
	SSblackbox.record_feedback("amount", "newscaster_stories", 1)
	feed_channel_message = ""
	current_image = null

/**
 * Selects a currently held photo from the user's hand and makes it the current_image held by the newscaster.
 * If a photo is still held in the newscaster, it will otherwise clear it from the machine.
 */
/obj/machinery/newscaster/proc/toggle_photo(mob/user)
	if(current_image)
		balloon_alert(user, "current photo cleared.")
		current_image = null
		return TRUE

	attach_photo(user)
	if(current_image)
		balloon_alert(user, "photo selected.")
	else
		balloon_alert(user, "no photo identified.")

/obj/machinery/newscaster/proc/clear_wanted_issue(mob/user)
	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/living_user = user
		id_card = living_user.get_idcard(hand_first = TRUE)
	if(!(security_access in id_card?.GetAccess()))
		say("Clearance not found.")
		return TRUE
	GLOB.news_network.wanted_issue.active = FALSE
	return TRUE

/**
 * This proc removes a station_request from the global list of requests, after checking that the owner of that request is the one who is trying to remove it.
 */
/obj/machinery/newscaster/proc/delete_bounty_request()
	if(!active_request || !current_user)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	if(active_request?.owner != current_user.account_holder)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	say("Deleted current request.")
	GLOB.request_list.Remove(active_request)

/**
 * This creates a new bounty to the global list of bounty requests, alongisde the provided value of the request, and the owner of the request.
 * For more info, see datum/station_request.
 */
/obj/machinery/newscaster/proc/create_bounty()
	if(!current_user || !bounty_text)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	for(var/datum/station_request/iterated_station_request as anything in GLOB.request_list)
		if(iterated_station_request.req_number == current_user.account_id)
			say("Account already has active bounty.")
			return TRUE
	var/datum/station_request/curr_request = new /datum/station_request(current_user.account_holder, bounty_value,bounty_text,current_user.account_id, current_user)
	GLOB.request_list += list(curr_request)
	for(var/obj/iterated_bounty_board as anything in GLOB.allbountyboards)
		iterated_bounty_board.say("New bounty added!")
		playsound(iterated_bounty_board.loc, 'sound/effects/cashregister.ogg', 30, TRUE)
/**
 * This sorts through the current list of bounties, and confirms that the intended request found is correct.
 * Then, adds the current user to the list of applicants to that bounty.
 */
/obj/machinery/newscaster/proc/apply_to_bounty()
	if(!current_user)
		say("No ID detected.")
		return TRUE
	if(current_user.account_holder == active_request.owner)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
		return TRUE
	for(var/new_apply in active_request?.applicants)
		if(current_user.account_holder == active_request?.applicants[new_apply])
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 20, TRUE)
			return TRUE
	active_request.applicants += list(current_user)

/**
 * This pays out the current request_target the amount held by the active request's assigned value, and then clears the active request from the global list.
 */
/obj/machinery/newscaster/proc/pay_applicant(datum/bank_account/payment_target)
	if(!current_user)
		return TRUE
	if(!current_user.has_money(active_request.value) || (current_user.account_holder != active_request.owner))
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return TRUE
	payment_target.transfer_money(current_user, active_request.value, "Bounty Request")
	say("Paid out [active_request.value] credits.")
	GLOB.request_list.Remove(active_request)
	qdel(active_request)

/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster_assembly"
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 7)
	result_path = /obj/machinery/newscaster
	pixel_shift = 30

#undef ALERT_DELAY
