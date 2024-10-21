/**
 * Newspapers
 * A static version of the newscaster, that won't update as new stories are added.
 * Can be scribbed upon to add extra text for future readers.
 */
/obj/item/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "newspaper"
	inhand_icon_state = "newspaper"
	lefthand_file = 'icons/mob/inhands/items/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/books_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("baps")
	attack_verb_simple = list("bap")
	resistance_flags = FLAMMABLE

	///List of news feeed channels the newspaper can see.
	var/list/datum/feed_channel/news_content = list()
	///The time the newspaper was made in terms of newscaster's last action, used to tell the newspaper whether a story should be in it.
	var/creation_time
	///The page in the newspaper currently being read. 0 is the title screen while the last is the security screen.
	var/current_page = 0
	///The currently scribbled text written in scribble_page
	var/scribble_text
	///The page with something scribbled on it, can only have one at a time.
	var/scribble_page

	///Stored information of the wanted criminal's name, if one existed at the time of creation.
	var/saved_wanted_criminal
	///Stored information of the wanted criminal's description, if one existed at the time of creation.
	var/saved_wanted_body
	///Stored icon of the wanted criminal, if one existed at the time of creation.
	var/icon/saved_wanted_icon

/obj/item/newspaper/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(\
		/datum/component/two_handed,\
		wield_callback = CALLBACK(src, PROC_REF(on_wielded)),\
		unwield_callback = CALLBACK(src, PROC_REF(on_unwielded)),\
	)
	creation_time = GLOB.news_network.last_action
	for(var/datum/feed_channel/iterated_feed_channel in GLOB.news_network.network_channels)
		news_content += iterated_feed_channel

	if(!GLOB.news_network.wanted_issue.active)
		return
	saved_wanted_criminal = GLOB.news_network.wanted_issue.criminal
	saved_wanted_body = GLOB.news_network.wanted_issue.body
	if(GLOB.news_network.wanted_issue.img)
		saved_wanted_icon = GLOB.news_network.wanted_issue.img

/obj/item/newspaper/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item)
		if(IS_WRITING_UTENSIL(held_item))
			context[SCREENTIP_CONTEXT_LMB] = "Scribble"
			return CONTEXTUAL_SCREENTIP_SET
		if(held_item.get_temperature())
			context[SCREENTIP_CONTEXT_LMB] = "Burn"
			return CONTEXTUAL_SCREENTIP_SET

/obj/item/newspaper/suicide_act(mob/living/user)
	user.visible_message(span_suicide(\
		"[user] is focusing intently on [src]! It looks like [user.p_theyre()] trying to commit sudoku... \
		until [user.p_their()] eyes light up with realization!"\
	))
	user.say(";JOURNALISM IS MY CALLING! EVERYBODY APPRECIATES UNBIASED REPORTI-GLORF", forced = "newspaper suicide")
	var/obj/item/reagent_containers/cup/glass/bottle/whiskey/last_drink = new(user.loc)
	playsound(user, 'sound/items/drink.ogg', vol = rand(10, 50), vary = TRUE)
	last_drink.reagents.trans_to(user, last_drink.reagents.total_volume, transferred_by = user)
	user.visible_message(span_suicide("[user] downs the contents of [last_drink.name] in one gulp! Shoulda stuck to sudoku!"))
	return TOXLOSS

/obj/item/newspaper/attackby(obj/item/attacking_item, mob/user, params)
	if(burn_paper_product_attackby_check(attacking_item, user))
		SStgui.close_uis(src)
		return

	if(!user.can_write(attacking_item))
		return ..()
	if(scribble_page == current_page)
		user.balloon_alert(user, "already scribbled!")
		return
	var/new_scribble_text = tgui_input_text(user, "What do you want to scribble?", "Write something", max_length = MAX_MESSAGE_LEN)
	if(isnull(new_scribble_text))
		return
	add_fingerprint(user)
	user.balloon_alert(user, "scribbling...")
	if(!do_after(user, 2 SECONDS, src))
		return
	user.balloon_alert(user, "scribbled!")
	scribble_page = current_page
	scribble_text = new_scribble_text

///Checks the creation time of the newspaper and compares it to list to see if the list is meant to be censored at the time of printing.
/obj/item/newspaper/proc/censored_check(list/times_censored)
	if(!times_censored.len)
		return FALSE
	for(var/i = times_censored.len; i > 0; i--)
		var/num = abs(times_censored[i])
		if(creation_time <= num)
			continue
		else
			if(times_censored[i] > 0)
				return TRUE
			else
				return FALSE
	return FALSE

/// Called when you start reading the paper with both hands
/obj/item/newspaper/proc/on_wielded(obj/item/source, mob/user)
	RegisterSignal(user, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(holder_updated_overlays))
	RegisterSignal(user, COMSIG_HUMAN_GET_VISIBLE_NAME, PROC_REF(holder_checked_name))
	user.update_appearance(UPDATE_OVERLAYS)
	user.name = user.get_visible_name()

/// Called when you stop doing that
/obj/item/newspaper/proc/on_unwielded(obj/item/source, mob/user)
	UnregisterSignal(user, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_HUMAN_GET_VISIBLE_NAME))
	user.update_appearance(UPDATE_OVERLAYS)
	user.name = user.get_visible_name()

/// Called when we're being read and overlays are updated, we should show a big newspaper over the reader
/obj/item/newspaper/proc/holder_updated_overlays(atom/reader, list/overlays)
	SIGNAL_HANDLER
	overlays += mutable_appearance(icon, "newspaper_held_over", ABOVE_MOB_LAYER)
	overlays += mutable_appearance(icon, "newspaper_held_under", BELOW_MOB_LAYER)

/// Called when someone tries to figure out what our identity is, but they can't see it because of the newspaper
/obj/item/newspaper/proc/holder_checked_name(mob/living/carbon/human/source, list/identity)
	SIGNAL_HANDLER

	var/newspaper_obscurity_priority = 100 // how powerful obscuring your appearance with a newspaper is
	if(identity[VISIBLE_NAME_FORCED])
		if(identity[VISIBLE_NAME_FORCED] > newspaper_obscurity_priority) // the other set forced name is forcier than breaking news
			return
		else if(identity[VISIBLE_NAME_FORCED] == newspaper_obscurity_priority)
			stack_trace("A name-setting signal operation ([identity[VISIBLE_NAME_FACE]]) has a priority collision with [src].")
		else
			identity[VISIBLE_NAME_FORCED] = newspaper_obscurity_priority
	identity[VISIBLE_NAME_FACE] = ""
	identity[VISIBLE_NAME_ID] = ""

/obj/item/newspaper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "Newspaper", name)
	ui.open()

/obj/item/newspaper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("next_page")
			//We're at the very end, nowhere else to go.
			if(current_page == news_content.len + 1)
				return TRUE
			current_page++
		if("prev_page")
			//We haven't started yet, nowhere else to go.
			if(!current_page)
				return TRUE
			current_page--
		else
			return TRUE
	SStgui.update_uis(src)
	playsound(src, SFX_PAGE_TURN, 50, TRUE)
	return TRUE

/obj/item/newspaper/ui_static_data(mob/user)
	var/list/data = list()
	data["channels"] = list()
	for(var/datum/feed_channel/news_channels as anything in news_content)
		data["channels"] += list(list(
			"name" = news_channels.channel_name,
			"page_number" = news_content.Find(news_channels),
		))
	return data

/obj/item/newspaper/ui_data(mob/user)
	var/list/data = list()
	data["current_page"] = current_page
	data["scribble_message"] = (scribble_page == current_page) ? scribble_text : null
	if(saved_wanted_icon)
		user << browse_rsc(saved_wanted_icon, "wanted_photo.png")
	data["wanted_criminal"] = saved_wanted_criminal
	data["wanted_body"] = saved_wanted_body
	data["wanted_photo"] = (saved_wanted_icon ? "wanted_photo.png" : null)

	var/list/channel_data = list()
	if(!current_page || (current_page == news_content.len + 1))
		channel_data["channel_name"] = null
		channel_data["author_name"] = null
		channel_data["is_censored"] = null
		channel_data["channel_messages"] = list()
		data["channel_data"] = list(channel_data)
		return data
	var/datum/feed_channel/current_channel = news_content[current_page]
	if(istype(current_channel))
		channel_data["channel_name"] = current_channel.channel_name
		channel_data["author_name"] = current_channel.return_author(censored_check(current_channel.author_censor_time))
		channel_data["is_censored"] = censored_check(current_channel.D_class_censor_time)
		channel_data["channel_messages"] = list()
		for(var/datum/feed_message/feed_messages as anything in current_channel.messages)
			if(feed_messages.creation_time > creation_time)
				data["channel_has_messages"] = FALSE
				break
			data["channel_has_messages"] = TRUE
			var/has_image = FALSE
			if(feed_messages.img)
				has_image = TRUE
				user << browse_rsc(feed_messages.img, "tmp_photo[feed_messages.message_ID].png")
			channel_data["channel_messages"] += list(list(
				"message" = "-[feed_messages.return_body(censored_check(feed_messages.body_censor_time))]",
				"photo" = (has_image ? "tmp_photo[feed_messages.message_ID].png" : null),
				"author" = feed_messages.return_author(censored_check(feed_messages.author_censor_time)),
			))
	data["channel_data"] = list(channel_data)
	return data
