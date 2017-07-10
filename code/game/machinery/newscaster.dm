GLOBAL_DATUM_INIT(news_network, /datum/newscaster/feed_network, new)
GLOBAL_LIST_EMPTY(allCasters)

/datum/newscaster

/datum/newscaster/feed_comment
	var/author = ""
	var/body = ""
	var/time_stamp = ""

/datum/newscaster/feed_message
	var/author =""
	var/body =""
	var/list/authorCensorTime = list()
	var/list/bodyCensorTime = list()
	var/is_admin_message = 0
	var/icon/img = null
	var/time_stamp = ""
	var/list/datum/newscaster/feed_comment/comments = list()
	var/locked = FALSE
	var/caption = ""
	var/creationTime
	var/authorCensor
	var/bodyCensor

/datum/newscaster/feed_message/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_message/proc/returnBody(censor)
	if(censor == -1)
		censor = bodyCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = body
	return txt

/datum/newscaster/feed_message/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_message/proc/toggleCensorBody()
	if(bodyCensor)
		bodyCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		bodyCensorTime.Add(GLOB.news_network.lastAction)
	bodyCensor = !bodyCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel
	var/channel_name = ""
	var/list/datum/newscaster/feed_message/messages = list()
	var/locked = FALSE
	var/author = ""
	var/censored = 0
	var/list/authorCensorTime = list()
	var/list/DclassCensorTime = list()
	var/authorCensor
	var/is_admin_channel = 0

/datum/newscaster/feed_channel/proc/returnAuthor(censor)
	if(censor == -1)
		censor = authorCensor
	var/txt = "[GLOB.news_network.redactedText]"
	if(!censor)
		txt = author
	return txt

/datum/newscaster/feed_channel/proc/toggleCensorDclass()
	if(censored)
		DclassCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		DclassCensorTime.Add(GLOB.news_network.lastAction)
	censored = !censored
	GLOB.news_network.lastAction ++

/datum/newscaster/feed_channel/proc/toggleCensorAuthor()
	if(authorCensor)
		authorCensorTime.Add(GLOB.news_network.lastAction*-1)
	else
		authorCensorTime.Add(GLOB.news_network.lastAction)
	authorCensor = !authorCensor
	GLOB.news_network.lastAction ++

/datum/newscaster/wanted_message
	var/active
	var/criminal
	var/body
	var/scannedUser
	var/isAdminMsg
	var/icon/img

/datum/newscaster/feed_network
	var/list/datum/newscaster/feed_channel/network_channels = list()
	var/datum/newscaster/wanted_message/wanted_issue
	var/lastAction
	var/redactedText = "\[REDACTED\]"

/datum/newscaster/feed_network/New()
	CreateFeedChannel("Station Announcements", "SS13", 1)
	wanted_issue = new /datum/newscaster/wanted_message

/datum/newscaster/feed_network/proc/CreateFeedChannel(channel_name, author, locked, adminChannel = 0)
	var/datum/newscaster/feed_channel/newChannel = new /datum/newscaster/feed_channel
	newChannel.channel_name = channel_name
	newChannel.author = author
	newChannel.locked = locked
	newChannel.is_admin_channel = adminChannel
	network_channels += newChannel

/datum/newscaster/feed_network/proc/SubmitArticle(msg, author, channel_name, obj/item/weapon/photo/photo, adminMessage = 0, allow_comments = 1)
	var/datum/newscaster/feed_message/newMsg = new /datum/newscaster/feed_message
	newMsg.author = author
	newMsg.body = msg
	newMsg.time_stamp = "[worldtime2text()]"
	newMsg.is_admin_message = adminMessage
	newMsg.locked = !allow_comments
	if(photo)
		newMsg.img = photo.img
		newMsg.caption = photo.scribble
	for(var/datum/newscaster/feed_channel/FC in network_channels)
		if(FC.channel_name == channel_name)
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.newsAlert(channel_name)
	lastAction ++
	newMsg.creationTime = lastAction

/datum/newscaster/feed_network/proc/submitWanted(criminal, body, scanned_user, obj/item/weapon/photo/photo, adminMsg = 0, newMessage = 0)
	wanted_issue.active = 1
	wanted_issue.criminal = criminal
	wanted_issue.body = body
	wanted_issue.scannedUser = scanned_user
	wanted_issue.isAdminMsg = adminMsg
	if(photo)
		wanted_issue.img = photo.img
	if(newMessage)
		for(var/obj/machinery/newscaster/N in GLOB.allCasters)
			N.newsAlert()
			N.update_icon()

/datum/newscaster/feed_network/proc/deleteWanted()
	wanted_issue.active = 0
	wanted_issue.criminal = null
	wanted_issue.body = null
	wanted_issue.scannedUser = null
	wanted_issue.img = null
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		NEWSCASTER.update_icon()



/obj/item/wallframe/newscaster
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	materials = list(MAT_METAL=14000, MAT_GLASS=8000)
	result_path = /obj/machinery/newscaster


/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	armor = list(melee = 50, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 30)
	max_integrity = 200
	integrity_failure = 50
	var/screen = 0
	var/paper_remaining = 15
	var/securityCaster = 0
	var/unit_no = 0
	var/alert_delay = 500
	var/alert = FALSE
	var/scanned_user = "Unknown"
	var/msg = ""
	var/obj/item/weapon/photo/photo = null
	var/channel_name = ""
	var/c_locked=0
	var/datum/newscaster/feed_channel/viewing_channel = null
	var/allow_comments = 1
	anchored = TRUE

/obj/machinery/newscaster/security_unit
	name = "security newscaster"
	securityCaster = 1

/obj/machinery/newscaster/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0

	GLOB.allCasters += src
	for(var/obj/machinery/newscaster/NEWSCASTER in GLOB.allCasters)
		unit_no++
	update_icon()

/obj/machinery/newscaster/Destroy()
	GLOB.allCasters -= src
	viewing_channel = null
	photo = null
	return ..()

/obj/machinery/newscaster/update_icon()
	cut_overlays()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "newscaster_off"
	else
		if(GLOB.news_network.wanted_issue.active)
			icon_state = "newscaster_wanted"
		else
			icon_state = "newscaster_normal"
			if(alert)
				add_overlay("newscaster_alert")
	var/hp_percent = obj_integrity * 100 /max_integrity
	switch(hp_percent)
		if(75 to 100)
			return
		if(50 to 75)
			add_overlay("crack1")
		if(25 to 50)
			add_overlay("crack2")
		else
			add_overlay("crack3")


/obj/machinery/newscaster/power_change()
	if(stat & BROKEN)
		return
	if(powered())
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/newscaster/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/machinery/newscaster/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/newscaster/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(ishuman(user) || issilicon(user))
		var/mob/living/human_or_robot_user = user
		var/dat
		scan_user(human_or_robot_user)
		switch(screen)
			if(0)
				dat += "Welcome to Newscasting Unit #[unit_no].<BR> Interface & News networks Operational."
				dat += "<BR><FONT SIZE=1>Property of Nanotrasen Inc</FONT>"
				if(GLOB.news_network.wanted_issue.active)
					dat+= "<HR><A href='?src=\ref[src];view_wanted=1'>Read Wanted Issue</A>"
				dat+= "<HR><BR><A href='?src=\ref[src];create_channel=1'>Create Feed Channel</A>"
				dat+= "<BR><A href='?src=\ref[src];view=1'>View Feed Channels</A>"
				dat+= "<BR><A href='?src=\ref[src];create_feed_story=1'>Submit new Feed story</A>"
				dat+= "<BR><A href='?src=\ref[src];menu_paper=1'>Print newspaper</A>"
				dat+= "<BR><A href='?src=\ref[src];refresh=1'>Re-scan User</A>"
				dat+= "<BR><BR><A href='?src=\ref[human_or_robot_user];mach_close=newscaster_main'>Exit</A>"
				if(securityCaster)
					var/wanted_already = 0
					if(GLOB.news_network.wanted_issue.active)
						wanted_already = 1
					dat+="<HR><B>Feed Security functions:</B><BR>"
					dat+="<BR><A href='?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_story=1'>Censor Feed Stories</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice</A>"
				dat+="<BR><HR>The newscaster recognises you as: <FONT COLOR='green'>[scanned_user]</FONT>"
			if(1)
				dat+= "Station Feed Channels<HR>"
				if( isemptylist(GLOB.news_network.network_channels) )
					dat+="<I>No active channels found...</I>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen '><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
						else
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR></B>"
				dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"
			if(2)
				dat+="Creating new Feed Channel..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_name=1'>Channel Name</A>:</B> [channel_name]<BR>"
				dat+="<B>Channel Author:</B> <FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(c_locked) ? ("NO") : ("YES")]<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(3)
				dat+="Creating new Feed Message..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_receiving=1'>Receiving Channel</A>:</B> [channel_name]<BR>"
				dat+="<B>Message Author:</B> <FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_new_message=1'>Message Body</A>:</B> <BR><font face=\"[PEN_FONT]\">[parsepencode(msg, user, SIGNFONT)]</font><BR>"
				dat+="<B><A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>:</B>  [(photo ? "Photo Attached" : "No Photo")]</BR>"
				dat+="<B><A href='?src=\ref[src];set_comment=1'>Comments [allow_comments ? "Enabled" : "Disabled"]</A></B><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"
			if(4)
				dat+="Feed story successfully submitted to [channel_name].<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(5)
				dat+="Feed Channel [channel_name] created successfully.<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(6)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
				if(channel_name=="")
					dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[3]'>Return</A><BR>"
			if(7)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
				var/list/existing_authors = list()
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(FC.authorCensor)
						existing_authors += GLOB.news_network.redactedText
					else
						existing_authors += FC.author
				if(scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>There is already a Feed channel under your name.</FONT><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
				var/check = 0
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(FC.channel_name == channel_name)
						check = 1
						break
				if(check)
					dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Channel author unverified.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[2]'>Return</A><BR>"
			if(8)
				var/total_num=length(GLOB.news_network.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)
					else
						active_num--
				dat+="Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories."
				dat+="<BR><BR><B>Liquid Paper remaining:</B> [(paper_remaining) *100 ] cm^3"
				dat+="<BR><BR><A href='?src=\ref[src];print_paper=[0]'>Print Paper</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(9)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT>\]</FONT><HR>"
				if(viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
				else
					if( isemptylist(viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						var/i = 0
						for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
							i++
							dat+="-[MESSAGE.returnBody(-1)] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
								if(MESSAGE.caption)
									dat+="[MESSAGE.caption]<BR>"
								dat+="<BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)] </FONT>\] - ([MESSAGE.time_stamp])</FONT><BR>"
							dat+="<b><font size=1>[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]</font></b><br>"
							for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
								dat+="<font size=1><small>[comment.body]</font><br><font size=1><small><small><small>[comment.author] [comment.time_stamp]</small></small></small></small></font><br>"
							if(MESSAGE.locked)
								dat+="<b>Comments locked</b><br>"
							else
								dat+="<a href='?src=\ref[src];new_comment=\ref[MESSAGE]'>Comment</a><br>"
				dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[1]'>Back</A>"
			if(10)
				dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
				dat+="<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>"
				dat+="Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>"
				dat+="<HR>Select Feed channel to get Stories from:<BR>"
				if(isemptylist(GLOB.news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(11)
				dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
				dat+="<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's"
				dat+="morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed"
				dat+="stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"
				if(isemptylist(GLOB.news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"
			if(12)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
				dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_channel_author=\ref[viewing_channel]'>[(viewing_channel.authorCensor) ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"
				if(isemptylist(viewing_channel.messages))
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
						dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
						dat+="<FONT SIZE=2><A href='?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.bodyCensor) ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.authorCensor) ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"
						dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]: <a href='?src=\ref[src];lock_comment=\ref[MESSAGE]'>[MESSAGE.locked ? "Unlock" : "Lock"]</a><br>"
						for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
							dat+="[comment.body] <a href='?src=\ref[src];del_comment=\ref[comment];del_comment_msg=\ref[MESSAGE]'>X</a><br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[10]'>Back</A>"
			if(13)
				dat+="<B>[viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[viewing_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
				dat+="Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];toggle_d_notice=\ref[viewing_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"
				if(viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
				else
					if(isemptylist(viewing_channel.messages))
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						for(var/datum/newscaster/feed_message/MESSAGE in viewing_channel.messages)
							dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[11]'>Back</A>"
			if(14)
				dat+="<B>Wanted Issue Handler:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(GLOB.news_network.wanted_issue.active)
					wanted_already = 1
					end_param = 2
				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
				dat+="<HR>"
				dat+="<A href='?src=\ref[src];set_wanted_name=1'>Criminal Name</A>: [channel_name] <BR>"
				dat+="<A href='?src=\ref[src];set_wanted_desc=1'>Description</A>: [msg] <BR>"
				dat+="<A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>: [(photo ? "Photo Attached" : "No Photo")]</BR>"
				if(wanted_already)
					dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT><BR>"
				else
					dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'>[scanned_user]</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='?src=\ref[src];cancel_wanted=1'>Take down Issue</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(15)
				dat+="<FONT COLOR='green'>Wanted issue for [channel_name] is now in Network Circulation.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(16)
				dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
				if(channel_name=="" || channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
				if(scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Issue author unverified.</FONT><BR>"
				if(msg == "" || msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(17)
				dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(18)
				if(GLOB.news_network.wanted_issue.active)
					dat+="<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT>\]</FONT><HR>"
					dat+="<B>Criminal</B>: [GLOB.news_network.wanted_issue.criminal]<BR>"
					dat+="<B>Description</B>: [GLOB.news_network.wanted_issue.body]<BR>"
					dat+="<B>Photo:</B>: "
					if(GLOB.news_network.wanted_issue.img)
						usr << browse_rsc(GLOB.news_network.wanted_issue.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="No current wanted issue found.<BR><BR>"
				dat+="<BR><BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>"
			if(19)
				dat+="<FONT COLOR='green'>Wanted issue for [channel_name] successfully edited.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(20)
				dat+="<FONT COLOR='green'>Printing successful. Please receive your newspaper from the bottom of the machine.</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Return</A>"
			if(21)
				dat+="<FONT COLOR='maroon'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnel to refill machine storage.</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Return</A>"
		var/datum/browser/popup = new(human_or_robot_user, "newscaster_main", "Newscaster Unit #[unit_no]", 400, 600)
		popup.set_content(dat)
		popup.set_title_image(human_or_robot_user.browse_rsc_icon(icon, icon_state))
		popup.open()

/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && isturf(loc))) || issilicon(usr))
		usr.set_machine(src)
		scan_user(usr)
		if(href_list["set_channel_name"])
			channel_name = stripped_input(usr, "Provide a Feed Channel Name", "Network Channel Handler", "", MAX_NAME_LEN)
			while (findtext(channel_name," ") == 1)
				channel_name = copytext(channel_name,2,lentext(channel_name)+1)
			updateUsrDialog()
		else if(href_list["set_channel_lock"])
			c_locked = !c_locked
			updateUsrDialog()
		else if(href_list["submit_new_channel"])
			var/list/existing_authors = list()
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.authorCensor)
					existing_authors += GLOB.news_network.redactedText
				else
					existing_authors += FC.author
			var/check = 0
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == channel_name)
					check = 1
					break
			if(channel_name == "" || channel_name == "\[REDACTED\]" || scanned_user == "Unknown" || check || (scanned_user in existing_authors) )
				screen=7
			else
				var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
				if(choice=="Confirm")
					scan_user(usr)
					GLOB.news_network.CreateFeedChannel(channel_name, scanned_user, c_locked)
					SSblackbox.inc("newscaster_channels",1)
					screen=5
			updateUsrDialog()
		else if(href_list["set_channel_receiving"])
			var/list/available_channels = list()
			for(var/datum/newscaster/feed_channel/F in GLOB.news_network.network_channels)
				if( (!F.locked || F.author == scanned_user) && !F.censored)
					available_channels += F.channel_name
			channel_name = input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels
			updateUsrDialog()
		else if(href_list["set_new_message"])
			var/temp_message = trim(stripped_multiline_input(usr, "Write your Feed story", "Network Channel Handler", msg))
			if(temp_message)
				msg = temp_message
				updateUsrDialog()
		else if(href_list["set_attachment"])
			AttachPhoto(usr)
			updateUsrDialog()
		else if(href_list["submit_new_message"])
			if(msg =="" || msg=="\[REDACTED\]" || scanned_user == "Unknown" || channel_name == "" )
				screen=6
			else
				GLOB.news_network.SubmitArticle("<font face=\"[PEN_FONT]\">[parsepencode(msg, usr, SIGNFONT)]</font>", scanned_user, channel_name, photo, 0, allow_comments)
				SSblackbox.inc("newscaster_stories",1)
				screen=4
				msg = ""
			updateUsrDialog()
		else if(href_list["create_channel"])
			screen=2
			updateUsrDialog()
		else if(href_list["create_feed_story"])
			screen=3
			updateUsrDialog()
		else if(href_list["menu_paper"])
			screen=8
			updateUsrDialog()
		else if(href_list["print_paper"])
			if(!paper_remaining)
				screen=21
			else
				print_paper()
				screen = 20
			updateUsrDialog()
		else if(href_list["menu_censor_story"])
			screen=10
			updateUsrDialog()
		else if(href_list["menu_censor_channel"])
			screen=11
			updateUsrDialog()
		else if(href_list["menu_wanted"])
			var/already_wanted = 0
			if(GLOB.news_network.wanted_issue.active)
				already_wanted = 1
			if(already_wanted)
				channel_name = GLOB.news_network.wanted_issue.criminal
				msg = GLOB.news_network.wanted_issue.body
			screen = 14
			updateUsrDialog()
		else if(href_list["set_wanted_name"])
			channel_name = trim(stripped_input(usr, "Provide the name of the Wanted person", "Network Security Handler"))
			updateUsrDialog()
		else if(href_list["set_wanted_desc"])
			msg = trim(stripped_input(usr, "Provide a description of the Wanted person and any other details you deem important", "Network Security Handler"))
			updateUsrDialog()
		else if(href_list["submit_wanted"])
			var/input_param = text2num(href_list["submit_wanted"])
			if(msg == "" || channel_name == "" || scanned_user == "Unknown")
				screen = 16
			else
				var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
				if(choice=="Confirm")
					scan_user(usr)
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one.
						GLOB.news_network.submitWanted(channel_name, msg, scanned_user, photo, 0 , 1)
						screen = 15
					else
						if(GLOB.news_network.wanted_issue.isAdminMsg)
							alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.","Ok")
							return
						GLOB.news_network.submitWanted(channel_name, msg, scanned_user, photo)
						screen = 19
			updateUsrDialog()
		else if(href_list["cancel_wanted"])
			if(GLOB.news_network.wanted_issue.isAdminMsg)
				alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.","Ok")
				return
			var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				GLOB.news_network.deleteWanted()
				screen=17
			updateUsrDialog()
		else if(href_list["view_wanted"])
			screen=18
			updateUsrDialog()
		else if(href_list["censor_channel_author"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["censor_channel_author"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			FC.toggleCensorAuthor()
			updateUsrDialog()
		else if(href_list["censor_channel_story_author"])
			var/datum/newscaster/feed_message/MSG = locate(href_list["censor_channel_story_author"])
			if(MSG.is_admin_message)
				alert("This message was created by a Nanotrasen Officer. You cannot censor its author.","Ok")
				return
			MSG.toggleCensorAuthor()
			updateUsrDialog()
		else if(href_list["censor_channel_story_body"])
			var/datum/newscaster/feed_message/MSG = locate(href_list["censor_channel_story_body"])
			if(MSG.is_admin_message)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			MSG.toggleCensorBody()
			updateUsrDialog()
		else if(href_list["pick_d_notice"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["pick_d_notice"])
			viewing_channel = FC
			screen=13
			updateUsrDialog()
		else if(href_list["toggle_d_notice"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["toggle_d_notice"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.","Ok")
				return
			FC.toggleCensorDclass()
			updateUsrDialog()
		else if(href_list["view"])
			screen=1
			updateUsrDialog()
		else if(href_list["setScreen"])
			screen = text2num(href_list["setScreen"])
			if (screen == 0)
				scanned_user = "Unknown";
				msg = "";
				c_locked=0;
				channel_name="";
				viewing_channel = null
			updateUsrDialog()
		else if(href_list["show_channel"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["show_channel"])
			viewing_channel = FC
			screen = 9
			updateUsrDialog()
		else if(href_list["pick_censor_channel"])
			var/datum/newscaster/feed_channel/FC = locate(href_list["pick_censor_channel"])
			viewing_channel = FC
			screen = 12
			updateUsrDialog()
		else if(href_list["new_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["new_comment"])
			var/cominput = copytext(stripped_input(usr, "Write your message:", "New comment", null),1,141)
			if(cominput)
				scan_user(usr)
				var/datum/newscaster/feed_comment/FC = new/datum/newscaster/feed_comment
				FC.author = scanned_user
				FC.body = cominput
				FC.time_stamp = worldtime2text()
				FM.comments += FC
				log_talk(usr,"[key_name(usr)] as [scanned_user] commented on message [FM.returnBody(-1)] -- [FC.body]",LOGCOMMENT)
			updateUsrDialog()
		else if(href_list["del_comment"])
			var/datum/newscaster/feed_comment/FC = locate(href_list["del_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["del_comment_msg"])
			FM.comments -= FC
			qdel(FC)
			updateUsrDialog()
		else if(href_list["lock_comment"])
			var/datum/newscaster/feed_message/FM = locate(href_list["lock_comment"])
			FM.locked ^= 1
			updateUsrDialog()
		else if(href_list["set_comment"])
			allow_comments ^= 1
			updateUsrDialog()
		else if(href_list["refresh"])
			updateUsrDialog()

/obj/machinery/newscaster/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
		playsound(loc, I.usesound, 50, 1)
		if(do_after(user, 60*I.toolspeed, target = src))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			if(stat & BROKEN)
				to_chat(user, "<span class='warning'>The broken remains of [src] fall on the ground.</span>")
				new /obj/item/stack/sheet/metal(loc, 5)
				new /obj/item/weapon/shard(loc)
				new /obj/item/weapon/shard(loc)
			else
				to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
				new /obj/item/wallframe/newscaster(loc)
			qdel(src)
	else if(istype(I, /obj/item/weapon/weldingtool) && user.a_intent != INTENT_HARM)
		var/obj/item/weapon/weldingtool/WT = I
		if(stat & BROKEN)
			if(WT.remove_fuel(0,user))
				user.visible_message("[user] is repairing [src].", \
								"<span class='notice'>You begin repairing [src]...</span>", \
								"<span class='italics'>You hear welding.</span>")
				playsound(loc, WT.usesound, 40, 1)
				if(do_after(user,40*WT.toolspeed, 1, target = src))
					if(!WT.isOn() || !(stat & BROKEN))
						return
					to_chat(user, "<span class='notice'>You repair [src].</span>")
					playsound(loc, 'sound/items/welder2.ogg', 50, 1)
					obj_integrity = max_integrity
					stat &= ~BROKEN
					update_icon()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
	else
		return ..()

/obj/machinery/newscaster/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 100, 1)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/newscaster/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
	qdel(src)

/obj/machinery/newscaster/obj_break()
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		stat |= BROKEN
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
		update_icon()


/obj/machinery/newscaster/attack_paw(mob/user)
	if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>The newscaster controls are far too complicated for your tiny brain!</span>")
	else
		take_damage(5, BRUTE, "melee")

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
	if(photo)
		if(!photo.sillynewscastervar)
			photo.loc = loc
			if(!issilicon(user))
				user.put_in_inactive_hand(photo)
		else
			qdel(photo)
		photo = null
	if(istype(user.get_active_held_item(), /obj/item/weapon/photo))
		photo = user.get_active_held_item()
		if(!user.drop_item())
			return
		photo.loc = src
	if(issilicon(user))
		var/list/nametemp = list()
		var/find
		var/datum/picture/selection
		var/obj/item/device/camera/siliconcam/targetcam = null
		if(isAI(user))
			var/mob/living/silicon/ai/R = user
			targetcam = R.aicamera
		else if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			if(R.connected_ai)
				targetcam = R.connected_ai.aicamera
			else
				targetcam = R.aicamera
		else
			to_chat(user, "<span class='warning'>You cannot interface with silicon photo uploading!</span>")
		if(targetcam.aipictures.len == 0)
			to_chat(usr, "<span class='boldannounce'>No images saved</span>")
			return
		for(var/datum/picture/t in targetcam.aipictures)
			nametemp += t.fields["name"]
		find = input("Select image (numbered in order taken)") in nametemp
		var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
		for(var/datum/picture/q in targetcam.aipictures)
			if(q.fields["name"] == find)
				selection = q
				break
		P.photocreate(selection.fields["icon"], selection.fields["img"], selection.fields["desc"])
		P.sillynewscastervar = 1
		photo = P
		qdel(P)

/obj/machinery/newscaster/proc/scan_user(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)
			if(istype(human_user.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				scanned_user ="Unknown"
		else
			scanned_user ="Unknown"
	else if(issilicon(user))
		var/mob/living/silicon/ai_user = user
		scanned_user = "[ai_user.name] ([ai_user.job])"
	else
		throw EXCEPTION("Invalid user for this proc")
		return

/obj/machinery/newscaster/proc/print_paper()
	SSblackbox.inc("newscaster_newspapers_printed",1)
	var/obj/item/weapon/newspaper/NEWSPAPER = new /obj/item/weapon/newspaper
	for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(GLOB.news_network.wanted_issue.active)
		NEWSPAPER.wantedAuthor = GLOB.news_network.wanted_issue.scannedUser
		NEWSPAPER.wantedCriminal = GLOB.news_network.wanted_issue.criminal
		NEWSPAPER.wantedBody = GLOB.news_network.wanted_issue.body
		if(GLOB.news_network.wanted_issue.img)
			NEWSPAPER.wantedPhoto = GLOB.news_network.wanted_issue.img
	NEWSPAPER.loc = get_turf(src)
	NEWSPAPER.creationTime = GLOB.news_network.lastAction
	paper_remaining--

/obj/machinery/newscaster/proc/newsAlert(channel)
	if(channel)
		say("Breaking news from [channel]!")
		alert ++
		update_icon()
		spawn(alert_delay)
			alert --
			update_icon()
		playsound(loc, 'sound/machines/twobeep.ogg', 75, 1)
	else
		say("Attention! Wanted issue distributed!")
		playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, 1)


/obj/item/weapon/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/newscaster/feed_channel/news_content = list()
	var/scribble=""
	var/scribble_page = null
	var/wantedAuthor
	var/wantedCriminal
	var/wantedBody
	var/wantedPhoto
	var/creationTime

/obj/item/weapon/newspaper/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is focusing intently on [src]! It looks like [user.p_theyre()] trying to commit sudoku... until [user.p_their()] eyes light up with realization!</span>")
	user.say(";JOURNALISM IS MY CALLING! EVERYBODY APPRECIATES UNBIASED REPORTI-GLORF")
	var/mob/living/carbon/human/H = user
	var/obj/W = new /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(H.loc)
	playsound(H.loc, 'sound/items/drink.ogg', rand(10,50), 1)
	W.reagents.trans_to(H, W.reagents.total_volume)
	user.visible_message("<span class='suicide'>[user] downs the contents of [W.name] in one gulp! Shoulda stuck to sudoku!</span>")

	return(TOXLOSS)

/obj/item/weapon/newspaper/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
				dat+="<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen? Space Facilities</FONT></div><HR>"
				if(isemptylist(news_content))
					if(wantedAuthor)
						dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/newscaster/feed_channel/NP in news_content)
						pages++
					if(wantedAuthor)
						dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/newscaster/feed_channel/NP in news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=\ref[human_user];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/newscaster/feed_channel/NP in news_content)
					pages++
				var/datum/newscaster/feed_channel/C = news_content[curr_page]
				dat += "<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.returnAuthor(notContent(C.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
				if(notContent(C.DclassCensorTime))
					dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(isemptylist(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						var/i = 0
						for(var/datum/newscaster/feed_message/MESSAGE in C.messages)
							if(MESSAGE.creationTime > creationTime)
								if(i == 0)
									dat+="No Feed stories stem from this channel..."
								break
							if(i == 0)
								dat+="<ul>"
							i++
							dat+="-[MESSAGE.returnBody(notContent(MESSAGE.bodyCensorTime))] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(notContent(MESSAGE.authorCensorTime))]</FONT>\]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/newscaster/feed_channel/NP in news_content)
					pages++
				if(wantedAuthor!=null)
					dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
					dat+="<B>Criminal name</B>: <FONT COLOR='maroon'>[wantedCriminal]</FONT><BR>"
					dat+="<B>Description</B>: [wantedBody]<BR>"
					dat+="<B>Photo:</B>: "
					if(wantedPhoto)
						user << browse_rsc(wantedPhoto, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
		dat+="<BR><HR><div align='center'>[curr_page+1]</div>"
		human_user << browse(dat, "window=newspaper_main;size=300x400")
		onclose(human_user, "newspaper_main")
	else
		to_chat(user, "The paper is full of unintelligible symbols!")

/obj/item/weapon/newspaper/proc/notContent(list/L)
	if(!L.len)
		return 0
	for(var/i=L.len;i>0;i--)
		var/num = abs(L[i])
		if(creationTime <= num)
			continue
		else
			if(L[i] > 0)
				return 1
			else
				return 0
	return 0

/obj/item/weapon/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if((src in U.contents) || (isturf(loc) && in_range(src, U)))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page == pages+1)
				return //Don't need that at all, but anyway.
			if(curr_page == pages) //We're at the middle, get to the end
				screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					screen=1
			curr_page++
			playsound(loc, "pageturn", 50, 1)
		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				screen = 0
			else
				if(curr_page == pages+1) //we're at the end, let's go back to the middle.
					screen = 1
			curr_page--
			playsound(loc, "pageturn", 50, 1)
		if(ismob(loc))
			attack_self(loc)

/obj/item/weapon/newspaper/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		if(scribble_page == curr_page)
			to_chat(user, "<span class='notice'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</span>")
		else
			var/s = stripped_input(user, "Write something", "Newspaper")
			if (!s)
				return
			if (!in_range(src, usr) && loc != usr)
				return
			scribble_page = curr_page
			scribble = s
			attack_self(user)
	else
		return ..()
