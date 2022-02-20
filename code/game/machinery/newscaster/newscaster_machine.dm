#define ALERT_DELAY = 50 SECONDS

/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_off"
	base_icon_state = "newscaster"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	max_integrity = 200
	integrity_failure = 0.25
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///How much paper is contained within the newscaster?
	var/paper_remaining = 0

	///What newscaster channel is currently being viewed by the player?
	var/datum/newscaster/feed_channel/current_channel
	///The message that's currently being written for a feed story.
	var/feed_channel_message
	///The current image that will be submitted with the newscaster story.
	var/obj/item/photo/current_image
	///Is there currently an alert on this newscaster that hasn't been seen yet?
	var/alert = FALSE

	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Value of the currently bounty input
	var/bounty_value = 1
	///Text of the currently written bounty
	var/bounty_text = ""

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/newscaster, 30)

/obj/machinery/newscaster/Initialize(mapload, ndir, building)
	. = ..()

	GLOB.allCasters += src
	update_appearance()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	current_channel = null
	current_image = null
	active_request = null
	current_user = null
	return ..()

/obj/machinery/newscaster/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		set_light(0)
		return
	set_light(1.4,0.7,"#34D352") // green light

/obj/machinery/newscaster/update_overlays()
	. = ..()

	if(!(machine_stat & (NOPOWER|BROKEN)))
		var/state = "[base_icon_state]_[GLOB.news_network.wanted_issue.active ? "wanted" : "normal"]"
		. += mutable_appearance(icon, state)
		. += emissive_appearance(icon, state, alpha = src.alpha)

		if(!GLOB.news_network.wanted_issue.active && alert)
			. += mutable_appearance(icon, "[base_icon_state]_alert")
			. += emissive_appearance(icon, "[base_icon_state]_alert", alpha = src.alpha)

	var/hp_percent = atom_integrity * 100 /max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			. += "crack1"
			. += emissive_blocker(icon, "crack1", alpha = src.alpha)
		if(25 to 50)
			. += "crack2"
			. += emissive_blocker(icon, "crack2", alpha = src.alpha)
		else
			. += "crack3"
			. += emissive_blocker(icon, "crack3", alpha = src.alpha)

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_appearance()

/obj/machinery/newscaster/proc/send_photo_data()
	if(current_image)
		return current_image?.picture
	return null

/obj/machinery/newscaster/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Newscaster", name)
		ui.open()

/obj/machinery/newscaster/ui_data(mob/user)
	. = ..()
	//**************************
	//		Newscaster Data
	//**************************
	var/list/data = list()
	var/list/channel_list = list()
	var/list/message_list = list()

	//Code displaying name and Job Information, taken from the player mob's ID card if one exists.
	var/obj/item/card/id/Card
	if(isliving(user))
		var/mob/living/L = user
		Card = L.get_idcard(TRUE)
	if(Card?.registered_account)
		current_user = Card.registered_account
		data["user"] = list()
		data["user"]["name"] = Card.registered_account.account_holder
		data["user"]["cash"] = Card.registered_account.account_balance
		if(Card?.registered_account.account_job)
			data["user"]["job"] = Card.registered_account.account_job.title
			data["user"]["department"] = Card.registered_account.account_job.paycheck_department
		else
			data["user"]["job"] = "No Job"
			data["user"]["department"] = "No Department"

	data["security_mode"] = FALSE
	if(Card && (ACCESS_ARMORY in Card?.GetAccess()))
		data["security_mode"] = TRUE

	data["photo_data"] = FALSE
	if(current_image)
		data["photo_data"] = TRUE

	//Code breaking down the channels that have been made on-station thus far. ha
	//Then, breaks down the messages that have been made on those channels.
	for(var/datum/newscaster/feed_channel/channel in GLOB.news_network.network_channels)
		channel_list += list(list(
			"name" = channel.channel_name,
			"author" = channel.author,
			"censored" = channel.censored,
			"locked" = channel.locked,
			"ID" = channel.channel_ID,
			))
		for(var/datum/newscaster/feed_message/comment_message in channel.messages)
			var/photo_ID = null
			if(comment_message.img)
				user << browse_rsc(comment_message.img, "tmp_photo[comment_message.message_ID].png")
				photo_ID = "tmp_photo[comment_message.message_ID].png"
			message_list += list(list(
			"auth" = comment_message.author,
			"body" = comment_message.body,
			"time" = comment_message.time_stamp,
			"channel_num" = comment_message.parent_ID,
			"censored_message" = comment_message.bodyCensor,
			"censored_author" = comment_message.authorCensor,
			"ID" = comment_message.message_ID,
			"Photo" = photo_ID,
			))
	data["viewing_channel"] = current_channel?.channel_ID

	//Here we display all the information about the current channel.
	data["channelName"] = current_channel?.channel_name
	data["channelAuthor"] = current_channel?.author
	data["channelDesc"] = current_channel?.channel_desc
	data["channelBlocked"] = current_channel?.locked || current_channel?.censored
	data["channelCensored"] = current_channel?.censored

	//We send all the information about all channels and all messages in existance.
	data["channel"] = channel_list
	data["messages"] = message_list

	//**************************
	//	  Bounty Board Data
	//**************************
	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	for(var/i in GLOB.request_list)
		if(!i)
			continue
		var/datum/station_request/request = i
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/j in request.applicants)
				formatted_applicants += list(list("name" = j.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = j.account_id))
	if(Card?.registered_account) //work out current user.
		data["accountName"] = Card.registered_account.account_holder
	data["requests"] = formatted_requests
	data["applicants"] = formatted_applicants
	data["bountyValue"] = bounty_value
	data["bountyText"] = bounty_text

	return data

/obj/machinery/newscaster/ui_act(action, params)
	. = ..()
	if(.)
		return
	//**************************
	//	  Bounty Board Data
	//**************************
	var/current_ref_num = params["request"]
	var/current_app_num = params["applicant"]
	var/datum/bank_account/request_target
	if(current_ref_num)
		for(var/datum/station_request/i in GLOB.request_list)
			if("[i.req_number]" == "[current_ref_num]")
				active_request = i
				break
	if(active_request)
		for(var/datum/bank_account/j in active_request.applicants)
			if("[j.account_id]" == "[current_app_num]")
				request_target = j
				break

	switch(action)
		//**************************
		//		Newscaster Acts
		//**************************
		if("setChannel")
			if(isnull(params["channels"]))
				return
			var/proto_chan = (params["channels"])
			for(var/datum/newscaster/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(proto_chan == potential_channel.channel_ID)
					current_channel = potential_channel

		if("createStory")
			if(!current_channel)
				balloon_alert(usr, "Please select a channel first!")
				return
			var/proto_chan = (params["current"])
			for(var/datum/newscaster/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(proto_chan == potential_channel.channel_ID)
					current_channel = potential_channel
					break
			var/temp_message = tgui_input_text(usr, "Write your Feed story", "Network Channel Handler", feed_channel_message, multiline = TRUE)
			if(length(temp_message) <= 1)
				return
			if(temp_message)
				feed_channel_message = temp_message
			GLOB.news_network.SubmitArticle("<font face=\"[PEN_FONT]\">[parsemarkdown(feed_channel_message, usr)]</font>", current_user?.account_holder, current_channel.channel_name, send_photo_data() , 0, FALSE)
			SSblackbox.record_feedback("amount", "newscaster_stories", 1)
			feed_channel_message = ""

		if("togglePhoto")
			if(current_image)
				balloon_alert(usr,"Current photo cleared.")
				current_image = null
				return
			else
				AttachPhoto(usr)

		if("createChannel")
			//This first block checks for pre-existing reasons to prevent you from making a new channel, like being censored, or if you have a channel already.
			var/list/existing_authors = list()
			for(var/datum/newscaster/feed_channel/FeedC in GLOB.news_network.network_channels)
				if(FeedC.authorCensor)
					existing_authors += GLOB.news_network.redactedText
				else
					existing_authors += FeedC.author
			if(current_user?.account_holder == ("Unknown" || null) || (current_user.account_holder in existing_authors))
				tgui_alert(usr, "ERROR: User cannot be found or already has an owned feed channel.", list("Okay"))
				return

			//This is where we set the feed channel name. We break for duplicates.
			var/channel_name = tgui_input_text(usr, "Provide a Feed Channel Name", "Network Channel Handler", max_length = MAX_NAME_LEN)
			if(!channel_name)
				return
			for(var/datum/newscaster/feed_channel/FeedC in GLOB.news_network.network_channels)
				if(FeedC.channel_name == channel_name)
					tgui_alert(usr, "ERROR: Feed Channel with that name already exists on the Network.", list("Okay"))
					return

			var/channel_desc = tgui_input_text(usr, "Provide a Feed Channel Description", "Network Channel Handler", max_length = MAX_BROADCAST_LEN)
			if(!channel_desc)
				return
			var/choice = tgui_alert(usr, "Public or Private?", "Should the feed be public or private? Public feeds can accept new articles from all crew.", list("Public", "Private"))
			var/locked = FALSE
			if(choice == "Private")
				locked = TRUE
			choice = tgui_alert(usr, "Please confirm Feed channel creation","Network Channel Handler", list("Confirm","Cancel"))
			if(choice=="Confirm")
				GLOB.news_network.CreateFeedChannel(channel_name, current_user.account_holder, channel_desc , locked)
				SSblackbox.record_feedback("text", "newscaster_channels", 1, "[channel_name]")

		if("storyCensor")
			if (!params["secure"])
				say("Secure was not found.")
				return
			var/questionable_message = params["messageID"]
			for(var/datum/newscaster/feed_message/mess in current_channel.messages)
				if(mess.message_ID == questionable_message)
					say("[mess.body]")
					mess.toggleCensorBody()
					break

		if("authorCensor")
			if (!params["secure"])
				return
			var/questionable_message = params["messageID"]
			for(var/datum/newscaster/feed_message/mess in current_channel.messages)
				if(mess.message_ID == questionable_message)
					say("[mess.body]")
					mess.toggleCensorAuthor()
					break

		if("channelDNotice")
			if (!params["secure"])
				return
			var/proto_chan = (params["channel"])
			for(var/datum/newscaster/feed_channel/potential_channel in GLOB.news_network.network_channels)
				if(proto_chan == potential_channel.channel_ID)
					current_channel = potential_channel
					break
			current_channel.toggleCensorDclass()

		//**************************
		//	  Bounty Board Acts
		//**************************
		if("createBounty")
			if(!current_user || !bounty_text)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			for(var/datum/station_request/i in GLOB.request_list)
				if("[i.req_number]" == "[current_user.account_id]")
					say("Account already has active bounty.")
					return
			var/datum/station_request/curr_request = new /datum/station_request(current_user.account_holder, bounty_value,bounty_text,current_user.account_id, current_user)
			GLOB.request_list += list(curr_request)
			for(var/obj/i in GLOB.allbountyboards)
				i.say("New bounty has been added!")
				playsound(i.loc, 'sound/effects/cashregister.ogg', 30, TRUE)
		if("apply")
			if(!current_user)
				say("Please equip a valid ID first.")
				return TRUE
			if(current_user.account_holder == active_request.owner)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			for(var/new_apply in active_request?.applicants)
				if(current_user.account_holder == active_request?.applicants[new_apply])
					playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
					return TRUE
			active_request.applicants += list(current_user)
		if("payApplicant")
			if(!current_user)
				return
			if(!current_user.has_money(active_request.value) || (current_user.account_holder != active_request.owner))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
				return
			request_target.transfer_money(current_user, active_request.value)
			say("Paid out [active_request.value] credits.")
			return TRUE
		if("clear")
			if(current_user)
				current_user = null
				say("Account Reset.")
				return TRUE
		if("deleteRequest")
			if(!active_request || !current_user)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return FALSE
			if(active_request?.owner != current_user?.account_holder)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			say("Deleted current request.")
			GLOB.request_list.Remove(active_request)
			return TRUE
		if("bountyVal")
			bounty_value = text2num(params["bountyval"])
			if(!bounty_value)
				bounty_value = 1
		if("bountyText")
			bounty_text = (params["bountytext"])
	. = TRUE


/obj/machinery/newscaster/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You start [anchored ? "un" : ""]securing [name]..."))
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 60))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(machine_stat & BROKEN)
				to_chat(user, span_warning("The broken remains of [src] fall on the ground."))
				new /obj/item/stack/sheet/iron(loc, 5)
				new /obj/item/shard(loc)
				new /obj/item/shard(loc)
			else
				to_chat(user, span_notice("You [anchored ? "un" : ""]secure [name]."))
				new /obj/item/wallframe/newscaster(loc)
			qdel(src)
	else if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(machine_stat & BROKEN)
			if(!I.tool_start_check(user, amount=0))
				return
			user.visible_message(span_notice("[user] is repairing [src]."), \
							span_notice("You begin repairing [src]..."), \
							span_hear("You hear welding."))
			if(I.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, span_notice("You repair [src]."))
				atom_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				update_appearance()
		else
			to_chat(user, span_notice("[src] does not need repairs."))

	else if(istype(I, /obj/item/paper))
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		else
			to_chat(user, span_notice("You insert the [I] into \the [src]! It now holds [paper_remaining] sheets of paper."))
			qdel(I)
		return ..()

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, TRUE)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/machinery/newscaster/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 2)
		new /obj/item/shard(loc)
		new /obj/item/shard(loc)
	qdel(src)

/obj/machinery/newscaster/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)


/obj/machinery/newscaster/attack_paw(mob/living/user, list/modifiers)
	if(!user.combat_mode)
		to_chat(user, span_warning("The newscaster controls are far too complicated for your tiny brain!"))
	else
		take_damage(5, BRUTE, MELEE)

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
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
			to_chat(usr, span_boldannounce("No images saved."))
			return
		var/datum/picture/selection = targetcam.selectpicture(user)
		if(selection)
			current_image = selection

/obj/machinery/newscaster/proc/print_paper()
	SSblackbox.record_feedback("amount", "newspapers_printed", 1)
	var/obj/item/newspaper/NEWSPAPER = new /obj/item/newspaper
	for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(GLOB.news_network.wanted_issue.active)
		NEWSPAPER.wantedAuthor = GLOB.news_network.wanted_issue.scannedUser
		NEWSPAPER.wantedCriminal = GLOB.news_network.wanted_issue.criminal
		NEWSPAPER.wantedBody = GLOB.news_network.wanted_issue.body
		if(GLOB.news_network.wanted_issue.img)
			NEWSPAPER.wantedPhoto = GLOB.news_network.wanted_issue.img
	NEWSPAPER.forceMove(drop_location())
	NEWSPAPER.creationTime = GLOB.news_network.lastAction
	paper_remaining--


/obj/machinery/newscaster/proc/remove_alert()
	alert = FALSE
	update_appearance()

/obj/machinery/newscaster/proc/newsAlert(channel, update_alert = TRUE)
	if(channel)
		if(update_alert)
			say("Breaking news from [channel]!")
			playsound(loc, 'sound/machines/twobeep_high.ogg', 75, TRUE)
		alert = TRUE
		update_appearance()
		addtimer(CALLBACK(src, .proc/remove_alert), ALERT_DELAY, TIMER_UNIQUE|TIMER_OVERRIDE)

	else if(!channel && update_alert)
		say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)


/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/newscaster
	pixel_shift = 30

#undef ALERT_DELAY
