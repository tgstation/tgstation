// Admin Tab - Event Verbs

/client/proc/cmd_admin_subtle_message(mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN))
		return

	message_admins("[key_name_admin(src)] has started answering [ADMIN_LOOKUPFLW(M)]'s prayer.")
	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text|null

	if(!msg)
		message_admins("[key_name_admin(src)] decided not to answer [ADMIN_LOOKUPFLW(M)]'s prayer")
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, "<i>You hear a voice in your head... <b>[msg]</i></b>", confidential = TRUE)

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	msg = span_adminnotice("<b> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] :</b> [msg]")
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential = TRUE)
		return
	if(!istype(H.ears, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset.", confidential = TRUE)
		return

	if (!sender)
		sender = input("Who is the message from?", "Sender") as null|anything in list(RADIO_CHANNEL_CENTCOM,RADIO_CHANNEL_SYNDICATE)
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(H)]'s [sender] request.")
	var/input = input("Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from [sender]", "") as text|null
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(H)]'s [sender] request.")
		return

	log_directed_talk(mob, H, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(H)]'s [sender] message with: \"[input]\"")
	to_chat(H, span_hear("You hear something crackle in your ears for a moment before a voice speaks. \"Please stand by for a message from [sender == "Syndicate" ? "your benefactor" : "Central Command"]. Message as follows[sender == "Syndicate" ? ", agent." : ":"] <b>[input].</b> Message ends.\""), confidential = TRUE)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate()
	set category = "Admin.Events"
	set name = "Global Narrate"

	if(!check_rights(R_ADMIN))
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text|null

	if (!msg)
		return
	to_chat(world, "[msg]", confidential = TRUE)
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(usr)] Sent a global narrate"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(atom/A)
	set category = "Admin.Events"
	set name = "Local Narrate"

	if(!check_rights(R_ADMIN))
		return
	if(!A)
		return
	var/range = input("Range:", "Narrate to mobs within how many tiles:", 7) as num|null
	if(!range)
		return
	var/msg = input("Message:", text("Enter the text you wish to appear to everyone within view:")) as text|null
	if (!msg)
		return
	for(var/mob/M in view(range,A))
		to_chat(M, msg, confidential = TRUE)

	log_admin("LocalNarrate: [key_name(usr)] at [AREACOORD(A)]: [msg]")
	message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(usr)] at [ADMIN_VERBOSEJMP(A)]:</b> [msg]<BR>"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)
	set category = "Admin.Events"
	set name = "Direct Narrate"

	if(!check_rights(R_ADMIN))
		return

	if(!M)
		M = input("Direct narrate to whom?", "Active Players") as null|anything in GLOB.player_list

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text|null

	if( !msg )
		return

	to_chat(M, msg, confidential = TRUE)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	msg = span_adminnotice("<b> DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]):</b> [msg]<BR>")
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Admin.Events"
	set name = "Add Custom AI law"

	if(!check_rights(R_ADMIN))
		return

	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = tgui_alert(usr, "Show ion message?", "Message", list("Yes", "No"))
	var/announce_ion_laws = (show_log == "Yes" ? 100 : 0)

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announceChance = announce_ion_laws
	ion.ionMessage = input

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()
	set category = "Admin.Events"
	set name = "Call Shuttle"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		return

	var/confirm = tgui_alert(usr, "You sure?", "Confirm", list("Yes", "Yes (No Recall)", "No"))
	switch(confirm)
		if(null, "No")
			return
		if("Yes (No Recall)")
			SSshuttle.adminEmergencyNoRecall = TRUE
			SSshuttle.emergency.mode = SHUTTLE_IDLE

	SSshuttle.emergency.request()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-called the emergency shuttle[confirm == "Yes (No Recall)" ? " (non-recallable)" : ""]."))
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin.Events"
	set name = "Cancel Shuttle"
	if(!check_rights(0))
		return
	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(SSshuttle.adminEmergencyNoRecall)
		SSshuttle.adminEmergencyNoRecall = FALSE

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Shuttle") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-recalled the emergency shuttle."))

	return

/client/proc/admin_disable_shuttle()
	set category = "Admin.Events"
	set name = "Disable Shuttle"

	if(!check_rights(R_ADMIN))
		return

	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle is already disabled."))
		return

	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] disabled the shuttle."))

	SSshuttle.lastMode = SSshuttle.emergency.mode
	SSshuttle.lastCallTime = SSshuttle.emergency.timeLeft(1)
	SSshuttle.adminEmergencyNoRecall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce("Warning: Emergency Shuttle uplink failure, shuttle disabled until further notice.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

/client/proc/admin_enable_shuttle()
	set category = "Admin.Events"
	set name = "Enable Shuttle"

	if(!check_rights(R_ADMIN))
		return

	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle not disabled."))
		return

	if(tgui_alert(usr, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	message_admins(span_adminnotice("[key_name_admin(usr)] enabled the emergency shuttle."))
	SSshuttle.adminEmergencyNoRecall = FALSE
	SSshuttle.emergencyNoRecall = FALSE
	if(SSshuttle.lastMode == SHUTTLE_DISABLED) //If everything goes to shit, fix it.
		SSshuttle.lastMode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.lastMode
	if(SSshuttle.lastCallTime < 10 SECONDS && SSshuttle.lastMode != SHUTTLE_IDLE)
		SSshuttle.lastCallTime = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.lastCallTime)
	priority_announce("Warning: Emergency Shuttle uplink reestablished, shuttle enabled.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

/client/proc/toggle_nuke(obj/machinery/nuclearbomb/N in GLOB.nuke_list)
	set category = "Admin.Events"
	set name = "Toggle Nuke"
	set popup_menu = FALSE
	if(!check_rights(R_DEBUG))
		return

	if(!N.timing)
		var/newtime = input(usr, "Set activation timer.", "Activate Nuke", "[N.timer_set]") as num|null
		if(!newtime)
			return
		N.timer_set = newtime
	N.set_safety()
	N.set_active()

	log_admin("[key_name(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(N)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(N)].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Nuke", "[N.timing]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/access_news_network() //MARKER
	set category = "Admin.Events"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src, /datum/admins))
		src = usr.client.holder
	if (!istype(src, /datum/admins))
		to_chat(usr, "Error: you are not an admin!", confidential = TRUE)
		return
	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += "Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network."
			dat += "<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units."
			dat += "<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!</FONT>"
			if(GLOB.news_network.wanted_issue.active)
				dat+= "<HR><A href='?src=[REF(src)];[HrefToken()];ac_view_wanted=1'>Read Wanted Issue</A>"
			dat+= "<HR><BR><A href='?src=[REF(src)];[HrefToken()];ac_create_channel=1'>Create Feed Channel</A>"
			dat+= "<BR><A href='?src=[REF(src)];[HrefToken()];ac_view=1'>View Feed Channels</A>"
			dat+= "<BR><A href='?src=[REF(src)];[HrefToken()];ac_create_feed_story=1'>Submit new Feed story</A>"
			dat+= "<BR><BR><A href='?src=[REF(usr)];[HrefToken()];mach_close=newscaster_main'>Exit</A>"
			var/wanted_already = 0
			if(GLOB.news_network.wanted_issue.active)
				wanted_already = 1
			dat+="<HR><B>Feed Security functions:</B><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_menu_censor_story=1'>Censor Feed Stories</A>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice (disables and locks the channel).</A>"
			dat+="<BR><HR><A href='?src=[REF(src)];[HrefToken()];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admin_signature]</FONT></A>"
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( !length(GLOB.news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=[REF(src)];ac_show_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=[REF(src)];[HrefToken()];ac_show_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR></B>"
			dat+="<BR><HR><A href='?src=[REF(src)];[HrefToken()];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Back</A>"
		if(2)
			dat+="Creating new Feed Channel..."
			dat+="<HR><B><A href='?src=[REF(src)];[HrefToken()];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>"
			dat+="<B><A href='?src=[REF(src)];[HrefToken()];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<B><A href='?src=[REF(src)];[HrefToken()];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Cancel</A><BR>"
		if(3)
			dat+="Creating new Feed Message..."
			dat+="<HR><B><A href='?src=[REF(src)];[HrefToken()];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
			dat+="<B>Message Author:</B> <FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<B><A href='?src=[REF(src)];[HrefToken()];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.returnBody(-1)] <BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_submit_new_message=1'>Submit</A><BR><BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Cancel</A><BR>"
		if(4)
			dat+="Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(5)
			dat+="Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.returnBody(-1) == "" || src.admincaster_feed_message.returnBody(-1) == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/newscaster/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[admincaster_feed_channel.returnAuthor(-1)]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( !length(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					var/i = 0
					for(var/datum/newscaster/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.returnBody(-1)] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
						dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]:<br>"
						for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
							dat+="[comment.body]<br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
						dat+="<br>"
			dat+="<BR><HR><A href='?src=[REF(src)];[HrefToken()];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[1]'>Back</A>"
		if(10)
			dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
			dat+="<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>"
			dat+="Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>"
			dat+="<HR>Select Feed channel to get Stories from:<BR>"
			if(!length(GLOB.news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					dat+="<A href='?src=[REF(src)];[HrefToken()];ac_pick_censor_channel=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
			dat+="<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's"
			dat+="morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed"
			dat+="stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"
			if(!length(GLOB.news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					dat+="<A href='?src=[REF(src)];[HrefToken()];ac_pick_d_notice=[REF(CHANNEL)]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ""]<BR>"

			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
			dat+="<FONT SIZE=2><A href='?src=[REF(src)];[HrefToken()];ac_censor_channel_author=[REF(src.admincaster_feed_channel)]'>[(src.admincaster_feed_channel.authorCensor) ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"

			if( !length(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/newscaster/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
					dat+="<FONT SIZE=2><A href='?src=[REF(src)];[HrefToken()];ac_censor_channel_story_body=[REF(MESSAGE)]'>[(MESSAGE.bodyCensor) ? ("Undo story censorship") : ("Censor story")]</A> - <A href='?src=[REF(src)];[HrefToken()];ac_censor_channel_story_author=[REF(MESSAGE)]'>[(MESSAGE.authorCensor) ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"
					dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]: <a href='?src=[REF(src)];[HrefToken()];ac_lock_comment=[REF(MESSAGE)]'>[MESSAGE.locked ? "Unlock" : "Lock"]</a><br>"
					for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
						dat+="[comment.body] <a href='?src=[REF(src)];[HrefToken()];ac_del_comment=[REF(comment)];ac_del_comment_msg=[REF(MESSAGE)]'>X</a><br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
			dat+="Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=[REF(src)];[HrefToken()];ac_toggle_d_notice=[REF(src.admincaster_feed_channel)]'>Bestow a D-Notice upon the channel</A>.<HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( !length(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/newscaster/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[11]'>Back</A>"
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
			dat+="<A href='?src=[REF(src)];[HrefToken()];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_wanted_message.criminal] <BR>"
			dat+="<A href='?src=[REF(src)];[HrefToken()];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_wanted_message.body] <BR>"
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_wanted_message.criminal] is now in Network Circulation.</FONT><BR><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_wanted_message.criminal =="" || src.admincaster_wanted_message.criminal == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_wanted_message.body == "" || src.admincaster_wanted_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		if(18)
			dat+="<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT>\]</FONT><HR>"
			dat+="<B>Criminal</B>: [GLOB.news_network.wanted_issue.criminal]<BR>"
			dat+="<B>Description</B>: [GLOB.news_network.wanted_issue.body]<BR>"
			dat+="<B>Photo:</B>: "
			if(GLOB.news_network.wanted_issue.img)
				usr << browse_rsc(GLOB.news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_wanted_message.criminal] successfully edited.</FONT><BR><BR>"
			dat+="<BR><A href='?src=[REF(src)];[HrefToken()];ac_setScreen=[0]'>Return</A><BR>"
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")

/client/proc/admin_change_sec_level()
	set category = "Admin.Events"
	set name = "Set Security Level"
	set desc = "Changes the security level. Announcement only, i.e. setting to Delta won't activate nuke"

	if(!check_rights(R_ADMIN))
		return

	var/level = input("Select security level to change to","Set Security Level") as null|anything in list("green","blue","red","delta")
	if(level)
		set_security_level(level)

		log_admin("[key_name(usr)] changed the security level to [level]")
		message_admins("[key_name_admin(usr)] changed the security level to [level]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Security Level [capitalize(level)]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/run_weather()
	set category = "Admin.Events"
	set name = "Run Weather"
	set desc = "Triggers a weather on the z-level you choose."

	if(!holder)
		return

	var/weather_type = input("Choose a weather", "Weather")  as null|anything in sort_list(subtypesof(/datum/weather), /proc/cmp_typepaths_asc)
	if(!weather_type)
		return

	var/turf/T = get_turf(mob)
	var/z_level = input("Z-Level to target?", "Z-Level", T?.z) as num|null
	if(!isnum(z_level))
		return

	SSweather.run_weather(weather_type, z_level)

	message_admins("[key_name_admin(usr)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(usr)] started weather of type [weather_type] on the z-level [z_level].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Run Weather")
