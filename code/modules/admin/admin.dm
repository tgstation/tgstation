
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(var/text, var/admin_ref = 0, var/admin_holder_ref = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	log_adminwarn(rendered)
	for (var/client/C in admin_list)
		if (C)
			if (C.holder.level >= 1)
				var/msg = rendered
				if (admin_ref)
					msg = dd_replacetext(msg, "%admin_ref%", "\ref[C]")
				if (admin_holder_ref && C.holder)
					msg = dd_replacetext(msg, "%holder_ref%", "\ref[C.holder]")
				C << msg


/proc/msg_admin_attack(var/text) //Toggleable Attack Messages
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	log_adminwarn(rendered)
	for (var/client/C in admin_list)
		if (C)
			if (C.holder.level >= 1)
				if(!C.STFU_atklog)
					var/msg = rendered
					C << msg

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!M)
		usr << "You seem to be selecting a mob that doesn't exist anymore."
		return
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		if(M.client.holder)
			body += "\[<A href='?src=\ref[src];prom_demot=\ref[M.client]'>[M.client.holder.rank]</A>\]"
		else
			body += "\[<A href='?src=\ref[src];prom_demot=\ref[M.client]'>Player</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?src=\ref[src];revive=\ref[M]'>Heal</A>\] "

	body += "<br><br>\[ "
	body += "<a href='?src=\ref[src];adminplayervars=\ref[M]'>VV</a> - "
	body += "<a href='?src=\ref[src];traitor_panel_pp=\ref[M]'>TP</a> - "
	body += "<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a> - "
	body += "<a href='?src=\ref[src];adminplayersubtlemessage=\ref[M]'>SM</a> - "
	body += "<a href='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</a>\] </b><br>"

	body += "<b>Mob type</b> = [M.type]<br><br>"

	body += "<A href='?src=\ref[src];boot2=\ref[M]'>Kick</A> | "
	body += "<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> | "
	body += "<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> | "
	body += "<A href='?src=\ref[src];notes=show;mob=\ref[M]'>Notes</A> "

	if(M.client)
		body += "| <A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | "
		body += "<br><b>Mute: </b> "
		body += "\[<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_IC]'><font color='[(M.client.muted & MUTE_IC)?"red":"blue"]'>IC</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_OOC]'><font color='[(M.client.muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_PRAY]'><font color='[(M.client.muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ADMINHELP]'><font color='[(M.client.muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> | "
		body += "<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_DEADCHAT]'><font color='[(M.client.muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]"
		body += "(<A href='?src=\ref[src];mute=\ref[M];mute_type=[MUTE_ALL]'><font color='[(M.client.muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)"

	body += "<br><br>"
	body += "<A href='?src=\ref[src];jumpto=\ref[M]'><b>Jump to</b></A> | "
	body += "<A href='?src=\ref[src];getmob=\ref[M]'>Get</A>"

	body += "<br><br>"
	body += "<A href='?src=\ref[src];traitor=\ref[M]'>Traitor panel</A> | "
	body += "<A href='?src=\ref[src];narrateto=\ref[M]'>Narrate to</A> | "
	body += "<A href='?src=\ref[src];subtlemessage=\ref[M]'>Subtle message</A>"

	if (M.client)
		if(!istype(M, /mob/new_player))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?src=\ref[src];corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += "<A href='?src=\ref[src];makeai=\ref[M]'>Make AI</A> | "
				body += "<A href='?src=\ref[src];makerobot=\ref[M]'>Make Robot</A> | "
				body += "<A href='?src=\ref[src];makealien=\ref[M]'>Make Alien</A> | "
				body += "<A href='?src=\ref[src];makemetroid=\ref[M]'>Make Metroid</A> "

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Re-Animalize</A> | "
			else
				body += "<A href='?src=\ref[src];makeanimal=\ref[M]'>Animalize</A> | "

			body += "<br><br>"
			body += "<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>"
			body += "<A href='?src=\ref[src];simplemake=observer;mob=\ref[M]'>Observer</A> | "
			body += "\[ Alien: <A href='?src=\ref[src];simplemake=drone;mob=\ref[M]'>Drone</A>, "
			body += "<A href='?src=\ref[src];simplemake=hunter;mob=\ref[M]'>Hunter</A>, "
			body += "<A href='?src=\ref[src];simplemake=queen;mob=\ref[M]'>Queen</A>, "
			body += "<A href='?src=\ref[src];simplemake=sentinel;mob=\ref[M]'>Sentinel</A>, "
			body += "<A href='?src=\ref[src];simplemake=larva;mob=\ref[M]'>Larva</A> \] "
			body += "<A href='?src=\ref[src];simplemake=human;mob=\ref[M]'>Human</A> "
			body += "\[ Metroid: <A href='?src=\ref[src];simplemake=metroid;mob=\ref[M]'>Baby</A>, "
			body += "<A href='?src=\ref[src];simplemake=adultmetroid;mob=\ref[M]'>Adult</A> \] "
			body += "<A href='?src=\ref[src];simplemake=monkey;mob=\ref[M]'>Monkey</A> | "
			body += "<A href='?src=\ref[src];simplemake=robot;mob=\ref[M]'>Cyborg</A> | "
			body += "<A href='?src=\ref[src];simplemake=cat;mob=\ref[M]'>Cat</A> | "
			body += "<A href='?src=\ref[src];simplemake=runtime;mob=\ref[M]'>Runtime</A> | "
			body += "<A href='?src=\ref[src];simplemake=corgi;mob=\ref[M]'>Corgi</A> | "
			body += "<A href='?src=\ref[src];simplemake=ian;mob=\ref[M]'>Ian</A> | "
			body += "<A href='?src=\ref[src];simplemake=crab;mob=\ref[M]'>Crab</A> | "
			body += "<A href='?src=\ref[src];simplemake=coffee;mob=\ref[M]'>Coffee</A> | "
			//body += "<A href='?src=\ref[src];simplemake=parrot;mob=\ref[M]'>Parrot</A> | "
			//body += "<A href='?src=\ref[src];simplemake=polyparrot;mob=\ref[M]'>Poly</A> | "
			body += "\[ Construct: <A href='?src=\ref[src];simplemake=constructarmoured;mob=\ref[M]'>Armoured</A> , "
			body += "<A href='?src=\ref[src];simplemake=constructbuilder;mob=\ref[M]'>Builder</A> , "
			body += "<A href='?src=\ref[src];simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \] "
			body += "<A href='?src=\ref[src];simplemake=shade;mob=\ref[M]'>Shade</A>"
			body += "<br>"

	if (M.client)
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<A href='?src=\ref[src];forcespeech=\ref[M]'>Forcesay</A> | "
		body += "<A href='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> | "
		body += "<A href='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> | "
		body += "<A href='?src=\ref[src];tdomeadmin=\ref[M]'>Thunderdome Admin</A> | "
		body += "<A href='?src=\ref[src];tdomeobserve=\ref[M]'>Thunderdome Observer</A> | "

	body += "<br>"
	body += "</body></html>"

	usr << browse(body, "window=adminplayeropts;size=550x515")
	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying

/datum/admins/proc/PlayerNotes()
	set category = "Admin"
	set name = "Player Notes"
	var/dat = "<B>Player notes</B><HR><table>"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	var/savefile/S=new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	if(!note_keys)
		dat += "No notes found."
	else
		sortList(note_keys)
		for(var/t in note_keys)
			dat += "<tr><td><a href='?src=\ref[src];notes=show;ckey=[t]'>[t]</a></td></tr>"
	dat += "</table>"
	usr << browse(dat, "window=player_notes;size=400x400")


/datum/admins/proc/player_has_info(var/key as text)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || !infos.len) return 0
	else return 1


/datum/admins/proc/show_player_info(var/key as text)
	set category = "Admin"
	set name = "Show Player Info"
	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
			if(I.author == usr.key)
				dat += "<A href='?src=\ref[src];remove_player_info=[key];remove_index=[i]'>Remove</A>"
			dat += "<br><br>"
		if(update_file) info << infos

	dat += "<br>"
	dat += "<A href='?src=\ref[src];add_player_info=[key]'>Add Comment</A><br>"

	dat += "</body></html>"
	usr << browse(dat, "window=adminplayerinfo;size=480x480")



/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return
	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += "Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network."
			dat += "<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units."
			dat += "<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!</FONT>"
			if(news_network.wanted_issue)
				dat+= "<HR><A href='?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"
			dat+= "<HR><BR><A href='?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>"
			dat+= "<BR><A href='?src=\ref[src];ac_view=1'>View Feed Channels</A>"
			dat+= "<BR><A href='?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>"
			dat+= "<BR><BR><A href='?src=\ref[usr];mach_close=newscaster_main'>Exit</A>"
			var/wanted_already = 0
			if(news_network.wanted_issue)
				wanted_already = 1
			dat+="<HR><B>Feed Security functions:</B><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice (disables and locks the channel.</A>"
			dat+="<BR><HR><A href='?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admincaster_signature]</FONT></A>"
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR></B>"
			dat+="<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(2)
			dat+="Creating new Feed Channel..."
			dat+="<HR><B><A href='?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>"
		if(3)
			dat+="Creating new Feed Message..."
			dat+="<HR><B><A href='?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
			dat+="<B>Message Author:</B> <FONT COLOR='green'>[src.admincaster_signature]</FONT><BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.body] <BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>"
		if(4)
			dat+="Feed story successfully submitted to [src.admincaster_feed_channel.channel_name].<BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(5)
			dat+="Feed Channel [src.admincaster_feed_channel.channel_name] created successfully.<BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(6)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name=="")
				dat+="<FONT COLOR='maroon'>•Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>•Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
		if(7)
			dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_channel.channel_name =="" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>•Invalid channel name.</FONT><BR>"
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					check = 1
					break
			if(check)
				dat+="<FONT COLOR='maroon'>•Channel name already in use.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR><BR>"
			dat+="<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[1]'>Back</A>"
		if(10)
			dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
			dat+="<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>"
			dat+="Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>"
			dat+="<HR>Select Feed channel to get Stories from:<BR>"
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
			dat+="<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's"
			dat+="morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed"
			dat+="stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"
			if(isemptylist(news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>"
			dat+="<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"

			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
					dat+="<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.author]</FONT> \]</FONT><BR>"
			dat+="Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[11]'>Back</A>"
		if(14)
			dat+="<B>Wanted Issue Handler:</B>"
			var/wanted_already = 0
			var/end_param = 1
			if(news_network.wanted_issue)
				wanted_already = 1
				end_param = 2
			if(wanted_already)
				dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"
			dat+="<HR>"
			dat+="<A href='?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_feed_message.author] <BR>"
			dat+="<A href='?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_feed_message.body] <BR>"
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.admincaster_signature]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] is now in Network Circulation.</FONT><BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_feed_message.author =="" || src.admincaster_feed_message.author == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>•Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_feed_message.body == "" || src.admincaster_feed_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>•Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(18)
			dat+="<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>"
			dat+="<B>Criminal</B>: [news_network.wanted_issue.author]<BR>"
			dat+="<B>Description</B>: [news_network.wanted_issue.body]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_feed_message.author] successfully edited.</FONT><BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//world << "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]"
	//world << "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]"
	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")



/datum/admins/proc/Jobbans()

	if ((src.rank in list( "Game Admin", "Game Master"  )))
		var/dat = "<B>Job Bans!</B><HR><table>"
		for(var/t in jobban_keylist)
			var/r = t
			if( findtext(r,"##") )
				r = copytext( r, 1, findtext(r,"##") )//removes the description
			dat += text("<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
		dat += "</table>"
		usr << browse(dat, "window=ban;size=400x400")

/datum/admins/proc/Game()

	var/dat
	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Temporary Admin")
			lvl = 2
		if("Admin Candidate")
			lvl = 3
		if("Trial Admin")
			lvl = 4
		if("Badmin")
			lvl = 5
		if("Game Admin")
			lvl = 6
		if("Game Master")
			lvl = 7

	dat += "<center><B>Game Panel</B></center><hr>\n"

	if(lvl > 0)

//			if(lvl >= 2 )
		dat += "<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>"

	if(lvl > 0 && master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += "<BR>"

	if(lvl >= 3 )
		dat += "<A href='?src=\ref[src];create_object=1'>Create Object</A><br>"
		dat += "<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>"
		dat += "<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>"
	if(lvl >= 5)
		dat += "<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>"
	if(lvl >= 3 )
		dat += "<br><A href='?src=\ref[src];vsc=airflow'>Edit Airflow Settings</A><br>"
		dat += "<A href='?src=\ref[src];vsc=plasma'>Edit Plasma Settings</A><br>"
		dat += "<A href='?src=\ref[src];vsc=default'>Choose a default ZAS setting</A><br>"
//			if(lvl == 6 )
	usr << browse(dat, "window=admin2;size=210x180")
	return
/*
/datum/admins/proc/goons()
	var/dat = "<HR><B>GOOOOOOONS</B><HR><table cellspacing=5><tr><th>Key</th><th>SA Username</th></tr>"
	for(var/t in goon_keylist)
		dat += text("<tr><td><A href='?src=\ref[src];remove=[ckey(t)]'><B>[t]</B></A></td><td>[goon_keylist[ckey(t)]]</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=300x400")

/datum/admins/proc/beta_testers()
	var/dat = "<HR><B>Beta testers</B><HR><table cellspacing=5><tr><th>Key</th></tr>"
	for(var/t in beta_tester_keylist)
		dat += text("<tr><td>[t]</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=300x400")
*/
/datum/admins/proc/Secrets()
	if (!usr.client.holder)
		return

	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Temporary Admin")
			lvl = 2
		if("Admin Candidate")
			lvl = 3
		if("Trial Admin")
			lvl = 4
		if("Badmin")
			lvl = 5
		if("Game Admin")
			lvl = 6
		if("Game Master")
			lvl = 7

	var/dat = {"
<B>Choose a secret, any secret at all.</B><HR>
<B>Admin Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsadmin=clear_bombs'>Remove all bombs currently in existence</A><BR>
<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR><BR>
<BR>"}
	if(lvl > 2)
		dat += {"
<B>'Random' Events</B><BR>
<BR>
<A href='?src=\ref[src];secretsfun=wave'>Spawn a wave of meteors</A><BR>
<A href='?src=\ref[src];secretsfun=gravanomalies'>Spawn a gravitational anomaly (Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=timeanomalies'>Spawn wormholes (Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=goblob'>Spawn blob(Untested)</A><BR>
<A href='?src=\ref[src];secretsfun=aliens'>Trigger an Alien infestation</A><BR>
<A href='?src=\ref[src];secretsfun=spaceninja'>Send in a space ninja</A><BR>
<A href='?src=\ref[src];secretsfun=carp'>Trigger an Carp migration</A><BR>
<A href='?src=\ref[src];secretsfun=radiation'>Irradiate the station</A><BR>
<A href='?src=\ref[src];secretsfun=prison_break'>Trigger a Prison Break</A><BR>
<A href='?src=\ref[src];secretsfun=virus'>Trigger a Virus Outbreak</A><BR>
<A href='?src=\ref[src];secretsfun=immovable'>Spawn an Immovable Rod</A><BR>
<A href='?src=\ref[src];secretsfun=lightsout'>Toggle a "lights out" event</A><BR>
<A href='?src=\ref[src];secretsfun=ionstorm'>Spawn an Ion Storm</A><BR>
<A href='?src=\ref[src];secretsfun=spacevines'>Spawn Space-Vines</A><BR>
<A href='?src=\ref[src];secretsfun=comms_blackout'>Trigger a communication blackout</A><BR>
<BR>
<B>Fun Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A><BR>
<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
<A href='?src=\ref[src];secretsfun=toxic'>Toxic Air (WARNING: dangerous)</A><BR>
<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
<A href='?src=\ref[src];secretsfun=quickpower'>Power all SMES</A><BR>
<A href='?src=\ref[src];secretsfun=toggleprisonstatus'>Toggle Prison Shuttle Status(Use with S/R)</A><BR>
<A href='?src=\ref[src];secretsfun=activateprison'>Send Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=deactivateprison'>Return Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A><BR>
<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A><BR>
<A href='?src=\ref[src];secretsfun=moveadminshuttle'>Move Administration Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=moveferry'>Move Ferry</A><BR>
<A href='?src=\ref[src];secretsfun=movealienship'>Move Alien Dinghy</A><BR>
<A href='?src=\ref[src];secretsfun=moveminingshuttle'>Move Mining Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>
<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
<A href='?src=\ref[src];secretsfun=friendai'>Best Friend AI</A><BR>
<A href='?src=\ref[src];secretsfun=floorlava'>The floor is lava! (DANGEROUS)</A><BR>"}
//<A href='?src=\ref[src];secretsfun=shockwave'>Station Shockwave</A><BR>

	if(lvl >= 6)
		dat += {"
<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>
		"}

	dat += "<BR>"

	if(lvl >= 5)
		dat += {"
<B>Security Level Elevated</B><BR>
<BR>
<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A><BR>
<BR>
<B>Coder Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsadmin=list_job_debug'>Show Job Debug</A><BR>
<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
<BR>
"}
	usr << browse(dat, "window=secrets")
	return



/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Restart"
	set desc="Restarts the world"
	if (!usr.client.holder)
		return
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		world << "\red <b>Restarting world!</b> \blue Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!"
		log_admin("[key_name(usr)] initiated a reboot.")

		feedback_set_details("end_error","admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
		feedback_add_details("admin_verb","R") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		if(blackbox)
			blackbox.save_all_data_to_sql()

		sleep(50)
		world.Reboot()


/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!usr.client.holder)	return
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Game Admin" && usr.client.holder.rank != "Game Master")
			message = adminscrub(message,500)
		world << "\blue <b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b>\n \t [message]"
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.", 1)
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.", 1)
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		log_admin("[usr.key] has started the game.")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		feedback_add_details("admin_verb","SN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		usr << "<font color='red'>Error: Start Now: Game has already started.</font>"
		return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		world << "<B>New players may no longer enter the game.</B>"
	else
		world << "<B>New players may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("\blue [key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()
	feedback_add_details("admin_verb","TE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		world << "<B>The AI job is no longer chooseable.</B>"
	else
		world << "<B>The AI job is chooseable now.</B>"
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	feedback_add_details("admin_verb","TAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		world << "<B>You may now respawn.</B>"
	else
		world << "<B>You may no longer respawn :(</B>"
	message_admins("\blue [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_aliens()
	set category = "Server"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	aliens_allowed = !aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [aliens_allowed ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggle_space_ninja()
	set category = "Server"
	set desc="Toggle space ninjas spawning."
	set name="Toggle Space Ninjas"
	toggle_space_ninja = !toggle_space_ninja
	log_admin("[key_name(usr)] toggled Space Ninjas to [toggle_space_ninja].")
	message_admins("[key_name_admin(usr)] toggled Space Ninjas [toggle_space_ninja ? "on" : "off"].", 1)
	feedback_add_details("admin_verb","TSN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start"
	set name="Delay"
	if (!ticker || ticker.current_state != GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!", null, null, null, null, null)
	going = !( going )
	if (!( going ))
		world << "<b>The game start has been delayed.</b>"
		log_admin("[key_name(usr)] delayed the game.")
	else
		world << "<b>The game will start soon.</b>"
		log_admin("[key_name(usr)] removed the delay.")
	feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adjump()
	set category = "Server"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("\blue Toggled admin jumping to [config.allow_admin_jump].")
	feedback_add_details("admin_verb","TJ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adspawn()
	set category = "Server"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("\blue Toggled admin item spawning to [config.allow_admin_spawning].")
	feedback_add_details("admin_verb","TAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/adrev()
	set category = "Server"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("\blue Toggled reviving to [config.allow_admin_rev].")
	feedback_add_details("admin_verb","TAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	world << "\red <b>Rebooting world!</b> \blue Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!"
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot()

/client/proc/deadchat()
	set category = "Admin"
	set desc="Toggles Deadchat Visibility"
	set name="Deadchat Visibility"
	if(deadchat == 0)
		deadchat = 1
		usr << "Deadchat turned on"
	else
		deadchat = 0
		usr << "Deadchat turned off"
	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set category = "Admin"
	set desc="Toggles Prayer Visibility"
	set name="Prayer Visibility"
	if(seeprayers == 0)
		seeprayers = 1
		usr << "Prayer visibility turned on"
	else
		seeprayers = 0
		usr << "Prayer visibility turned off"
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == 2)
		if (config.allow_admin_jump)
			M.loc = pick(latejoin)
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/is_special_character(mob/M as mob) // returns 1 for specail characters and 2 for heroes of gamemode
	if(!ticker || !ticker.mode)
		return 0
	if (!istype(M))
		return 0
	if((M.mind in ticker.mode.head_revolutionaries) || (M.mind in ticker.mode.revolutionaries))
		if (ticker.mode.config_tag == "revolution")
			return 2
		return 1
	if(M.mind in ticker.mode.cult)
		if (ticker.mode.config_tag == "cult")
			return 2
		return 1
	if(M.mind in ticker.mode.malf_ai)
		if (ticker.mode.config_tag == "malfunction")
			return 2
		return 1
	if(M.mind in ticker.mode.syndicates)
		if (ticker.mode.config_tag == "nuclear")
			return 2
		return 1
	if(M.mind in ticker.mode.wizards)
		if (ticker.mode.config_tag == "wizard")
			return 2
		return 1
	if(M.mind in ticker.mode.changelings)
		if (ticker.mode.config_tag == "changeling")
			return 2
		return 1

	for(var/datum/disease/D in M.viruses)
		if(istype(D, /datum/disease/jungle_fever))
			if (ticker.mode.config_tag == "monkey")
				return 2
			return 1
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.emagged)
			return 1
	if(M.mind&&M.mind.special_role)//If they have a mind and special role, they are some type of traitor or antagonist.
		return 1

	return 0

/*
/datum/admins/proc/get_sab_desc(var/target)
	switch(target)
		if(1)
			return "Destroy at least 70% of the plasma canisters on the station"
		if(2)
			return "Destroy the AI"
		if(3)
			var/count = 0
			for(var/mob/living/carbon/monkey/Monkey in world)
				if(Monkey.z == 1)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"
*/
/datum/admins/proc/spawn_atom(var/object as text)
	set category = "Debug"
	set desc= "(atom path) Spawn an atom"
	set name= "Spawn"

	if(usr.client.holder.level >= 5)
		var/list/types = typesof(/atom)

		var/list/matches = new()

		for(var/path in types)
			if(findtext("[path]", object))
				matches += path

		if(matches.len==0)
			return

		var/chosen
		if(matches.len==1)
			chosen = matches[1]
		else
			chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
			if(!chosen)
				return

		new chosen(usr.loc)

		log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(var/mob/M in sortmobs())
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if (!M.mind)
		usr << "Sorry, this mob has no mind!"
		return
	M.mind.edit_memory()
	feedback_add_details("admin_verb","STP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	tinted_weldhelh = !( tinted_weldhelh )
	if (tinted_weldhelh)
		world << "<B>The tinted_weldhelh has been enabled!</B>"
	else
		world << "<B>The tinted_weldhelh has been disabled!</B>"
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.", 1)
	feedback_add_details("admin_verb","TTWH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	guests_allowed = !( guests_allowed )
	if (!( guests_allowed ))
		world << "<B>Guests may no longer enter the game.</B>"
	else
		world << "<B>Guests may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.")
	message_admins("\blue [key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.", 1)
	feedback_add_details("admin_verb","TGU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unjobban_panel()
	set name = "Unjobban Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.unjobbanpanel()
	feedback_add_details("admin_verb","UJBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in mob_list)
		ai_number++
		if(isAI(S))
			usr << "<b>AI [key_name(S, usr)]'s laws:</b>"
		else if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			usr << "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independant)"]: laws:</b>"
		else if (ispAI(S))
			usr << "<b>pAI [key_name(S, usr)]'s laws:</b>"
		else
			usr << "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>"

		if (S.laws == null)
			usr << "[key_name(S, usr)]'s laws are null?? Contact a coder."
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		usr << "<b>No AIs located</b>" //Just so you know the thing is actually working and not just ignoring you.

/datum/admins/proc/show_skills(var/mob/living/carbon/human/M as mob in world)
	set category = "Admin"
	set name = "Show Skills"

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		usr << "Error: you are not an admin!"
		return

	show_skill_window(usr, M)

	return

/client/proc/update_mob_sprite(mob/living/carbon/human/H as mob)
	set category = "Admin"
	set name = "Update Mob Sprite"
	set desc = "Should fix any mob sprite update errors."

	if (!holder)
		src << "Only administrators may use this command."
		return

	if(istype(H))
		H.regenerate_icons()

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//


/**********************Administration Shuttle**************************/

var/admin_shuttle_location = 0 // 0 = centcom 13, 1 = station

proc/move_admin_shuttle()
	var/area/fromArea
	var/area/toArea
	if (admin_shuttle_location == 1)
		fromArea = locate(/area/shuttle/administration/station)
		toArea = locate(/area/shuttle/administration/centcom)
	else
		fromArea = locate(/area/shuttle/administration/centcom)
		toArea = locate(/area/shuttle/administration/station)
	fromArea.move_contents_to(toArea)
	if (admin_shuttle_location)
		admin_shuttle_location = 0
	else
		admin_shuttle_location = 1
	return

/**********************Centcom Ferry**************************/

var/ferry_location = 0 // 0 = centcom , 1 = station

proc/move_ferry()
	var/area/fromArea
	var/area/toArea
	if (ferry_location == 1)
		fromArea = locate(/area/shuttle/transport1/station)
		toArea = locate(/area/shuttle/transport1/centcom)
	else
		fromArea = locate(/area/shuttle/transport1/centcom)
		toArea = locate(/area/shuttle/transport1/station)
	fromArea.move_contents_to(toArea)
	if (ferry_location)
		ferry_location = 0
	else
		ferry_location = 1
	return

/**********************Alien ship**************************/

var/alien_ship_location = 1 // 0 = base , 1 = mine

proc/move_alien_ship()
	var/area/fromArea
	var/area/toArea
	if (alien_ship_location == 1)
		fromArea = locate(/area/shuttle/alien/mine)
		toArea = locate(/area/shuttle/alien/base)
	else
		fromArea = locate(/area/shuttle/alien/base)
		toArea = locate(/area/shuttle/alien/mine)
	fromArea.move_contents_to(toArea)
	if (alien_ship_location)
		alien_ship_location = 0
	else
		alien_ship_location = 1
	return