#define NEWSPAPER_SCREEN_COVER 0
#define NEWSPAPER_SCREEN_CHANNEL 1
#define NEWSPAPER_SCREEN_END 2

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
	///The screen in the newspaper currently being viewed.
	var/current_screen = NEWSPAPER_SCREEN_COVER
	///The page in the newspaper currently being read, used when the screen is on NEWSPAPER_SCREEN_CHANNEL.
	var/current_page = 0
	///The currently scribbled text written in scribble_page
	var/scribble = ""
	///The page with something scribbled on it, can only have one at a time.
	var/scribble_page = null

	///List of information related to a wanted issue, if one existed at the time of creation.
	var/list/wanted_information

/obj/item/newspaper/Initialize(mapload)
	. = ..()
	creation_time = GLOB.news_network.last_action
	for(var/datum/feed_channel/iterated_feed_channel in GLOB.news_network.network_channels)
		news_content += iterated_feed_channel

	if(!GLOB.news_network.wanted_issue.active)
		return
	wanted_information = list(
		"wanted_criminal" = GLOB.news_network.wanted_issue.criminal,
		"wanted_body" = GLOB.news_network.wanted_issue.body,
		"wanted_photo" = GLOB.news_network.wanted_issue.img || null,
	)

/obj/item/newspaper/attackby(obj/item/attacking_item, mob/user, params)
	if(burn_paper_product_attackby_check(attacking_item, user))
		return

	if(!istype(attacking_item, /obj/item/pen))
		return ..()
	if(!user.can_write(attacking_item))
		return
	if(scribble_page == current_page)
		user.balloon_alert(user, "already scribbled!")
		return
	var/new_scribble_text = tgui_input_text(user, "What do you want to scribble?", "Write something")
	if(isnull(new_scribble_text))
		return
	add_fingerprint(user)
	if(!do_after(user, 2 SECONDS, src))
		return
	user.balloon_alert(user, "scribbled!")
	scribble_page = current_page
	scribble = new_scribble_text

/obj/item/newspaper/suicide_act(mob/living/user)
	user.visible_message(span_suicide(
		"[user] is focusing intently on [src]! It looks like [user.p_theyre()] trying to commit sudoku... \
		until [user.p_their()] eyes light up with realization!",
	))
	user.say(";JOURNALISM IS MY CALLING! EVERYBODY APPRECIATES UNBIASED REPORTI-GLORF", forced = "newspaper suicide")
	var/obj/item/reagent_containers/cup/glass/bottle/whiskey/last_drink = new(user.loc)
	playsound(user.loc, 'sound/items/drink.ogg', vol = rand(10, 50), vary = TRUE)
	last_drink.reagents.trans_to(user, last_drink.reagents.total_volume, transferred_by = user)
	user.visible_message(span_suicide("[user] downs the contents of [last_drink.name] in one gulp! Shoulda stuck to sudoku!"))
	return TOXLOSS

/obj/item/newspaper/attack_self(mob/user)
	if(!istype(user) || !user.can_read(src))
		return
	var/dat
	switch(current_screen)
		if(NEWSPAPER_SCREEN_COVER)
			dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
			dat+="<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen? Space Facilities</FONT></div><HR>"
			if(!length(news_content))
				if(!isnull(wanted_information))
					dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [news_content.len + 2]\]</FONT><BR></ul>"
				else
					dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
			else
				dat+="Contents:<BR><ul>"
				if(!isnull(wanted_information))
					dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [news_content.len + 2]\]</FONT><BR>"
				var/temp_page=0
				for(var/datum/feed_channel/NP in news_content)
					temp_page++
					dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
				dat+="</ul>"
			if(scribble_page == current_page)
				dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
			dat+= "<HR><DIV STYLE='float:right;'><A href='?src=[REF(src)];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=[REF(user)];mach_close=newspaper_main'>Done reading</A></DIV>"
		if(NEWSPAPER_SCREEN_CHANNEL)
			var/datum/feed_channel/C = news_content[current_page]
			dat += "<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.return_author(notContent(C.author_censor_time))]</FONT>\]</FONT><BR><BR>"
			if(notContent(C.D_class_censor_time))
				dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
			else
				if(!length(C.messages))
					dat+="No Feed stories stem from this channel..."
				else
					var/i = 0
					for(var/datum/feed_message/MESSAGE in C.messages)
						if(MESSAGE.creation_time > creation_time)
							if(i == 0)
								dat+="No Feed stories stem from this channel..."
							break
						if(i == 0)
							dat+="<ul>"
						i++
						dat+="-[MESSAGE.return_body(notContent(MESSAGE.body_censor_time))] <BR>"
						if(MESSAGE.img)
							user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.return_author(notContent(MESSAGE.author_censor_time))]</FONT>\]</FONT><BR><BR>"
					dat+="</ul>"
			if(scribble_page == current_page)
				dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
			dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=[REF(src)];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=[REF(src)];next_page=1'>Next Page</A></DIV>"
		if(NEWSPAPER_SCREEN_END)
			if(!isnull(wanted_information))
				dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
				dat+="<B>Criminal name</B>: <FONT COLOR='maroon'>[wanted_information["wanted_criminal"]]</FONT><BR>"
				dat+="<B>Description</B>: [wanted_information["wanted_body"]]<BR>"
				dat+="<B>Photo:</B> "
				if(wanted_information["wanted_photo"])
					user << browse_rsc(wanted_information["wanted_photo"], "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="None"
			else
				dat+="<I>Apart from some uninteresting classified ads, there's nothing on this page...</I>"
			if(scribble_page == current_page)
				dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
			dat+= "<HR><DIV STYLE='float:left;'><A href='?src=[REF(src)];prev_page=1'>Previous Page</A></DIV>"
	dat+="<BR><HR><div align='center'>[current_page+1]</div>"
	user << browse(dat, "window=newspaper_main;size=300x400")
	onclose(user, "newspaper_main")

/obj/item/newspaper/proc/notContent(list/L)
	if(!L.len)
		return FALSE
	for(var/i = L.len; i > 0; i--)
		var/num = abs(L[i])
		if(creation_time <= num)
			continue
		else
			if(L[i] > 0)
				return TRUE
			else
				return FALSE
	return FALSE

/obj/item/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	. = ..()
	if((src in U.contents) || (isturf(loc) && in_range(src, U)))
		U.set_machine(src)
		if(href_list["next_page"])
			if(current_page == news_content.len + 1)
				return //Don't need that at all, but anyway.
			if(current_page == news_content.len) //We're at the middle, get to the end
				current_screen = NEWSPAPER_SCREEN_END
			else
				if(current_page == 0) //We're at the start, get to the middle
					current_screen = NEWSPAPER_SCREEN_CHANNEL
			current_page++
			playsound(loc, SFX_PAGE_TURN, 50, TRUE)
		else if(href_list["prev_page"])
			if(current_page == 0)
				return
			if(current_page == 1)
				current_screen = NEWSPAPER_SCREEN_COVER
			else
				if(current_page == news_content.len + 1) //we're at the end, let's go back to the middle.
					current_screen = NEWSPAPER_SCREEN_CHANNEL
			current_page--
			playsound(loc, SFX_PAGE_TURN, 50, TRUE)
		if(ismob(loc))
			attack_self(loc)

#undef NEWSPAPER_SCREEN_END
#undef NEWSPAPER_SCREEN_CHANNEL
#undef NEWSPAPER_SCREEN_COVER
