
////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins, msg)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">RELAY:</span> <span class=\"message\">[msg]</span></span>"
	to_chat(GLOB.admins, msg)


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!check_rights())
		return

	if(!isobserver(usr))
		log_game("[key_name_admin(usr)] checked the player panel while in game.")

	if(!M)
		to_chat(usr, "You seem to be selecting a mob that doesn't exist anymore.")
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<A href='?_src_=holder;editrights=rank;ckey=[M.ckey]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"

	if(isnewplayer(M))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?_src_=holder;revive=\ref[M]'>Heal</A>\] "

	if(M.client)
		body += "<br>\[<b>First Seen:</b> [M.client.player_join_date]\]\[<b>Byond account registered on:</b> [M.client.account_join_date]\]"
		body += "<br><br><b>Show related accounts by:</b> "
		body += "\[ <a href='?_src_=holder;showrelatedacc=cid;client=\ref[M.client]'>CID</a> | "
		body += "<a href='?_src_=holder;showrelatedacc=ip;client=\ref[M.client]'>IP</a> \]"


	body += "<br><br>\[ "
	body += "<a href='?_src_=vars;Vars=\ref[M]'>VV</a> - "
	body += "<a href='?_src_=holder;traitor=\ref[M]'>TP</a> - "
	body += "<a href='?priv_msg=[M.ckey]'>PM</a> - "
	body += "<a href='?_src_=holder;subtlemessage=\ref[M]'>SM</a> - "
	body += "<a href='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</a> - "
	body += "<a href='?_src_=holder;individuallog=\ref[M]'>LOGS</a>\] <br>"

	body += "<b>Mob type</b> = [M.type]<br><br>"

	body += "<A href='?_src_=holder;boot2=\ref[M]'>Kick</A> | "
	body += "<A href='?_src_=holder;newban=\ref[M]'>Ban</A> | "
	body += "<A href='?_src_=holder;jobban2=\ref[M]'>Jobban</A> | "
	body += "<A href='?_src_=holder;appearanceban=\ref[M]'>Identity Ban</A> | "
	if(jobban_isbanned(M, "OOC"))
		body+= "<A href='?_src_=holder;jobban3=OOC;jobban4=\ref[M]'><font color=red>OOCBan</font></A> | "
	else
		body+= "<A href='?_src_=holder;jobban3=OOC;jobban4=\ref[M]'>OOCBan</A> | "
	if(jobban_isbanned(M, "emote"))
		body+= "<A href='?_src_=holder;jobban3=emote;jobban4=\ref[M]'><font color=red>EmoteBan</font></A> | "
	else
		body+= "<A href='?_src_=holder;jobban3=emote;jobban4=\ref[M]'>Emoteban</A> | "

	body += "<A href='?_src_=holder;showmessageckey=[M.ckey]'>Notes | Messages | Watchlist</A> | "
	if(M.client)
		body += "| <A href='?_src_=holder;sendtoprison=\ref[M]'>Prison</A> | "
		body += "\ <A href='?_src_=holder;sendbacktolobby=\ref[M]'>Send back to Lobby</A> | "
		var/muted = M.client.prefs.muted
		body += "<br><b>Mute: </b> "
		body += "\[<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC)?"red":"blue"]'>IC</font></a> | "
		body += "<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC)?"red":"blue"]'>OOC</font></a> | "
		body += "<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY)?"red":"blue"]'>PRAY</font></a> | "
		body += "<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP)?"red":"blue"]'>ADMINHELP</font></a> | "
		body += "<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT)?"red":"blue"]'>DEADCHAT</font></a>\]"
		body += "(<A href='?_src_=holder;mute=[M.ckey];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL)?"red":"blue"]'>toggle all</font></a>)"

	body += "<br><br>"
	body += "<A href='?_src_=holder;jumpto=\ref[M]'><b>Jump to</b></A> | "
	body += "<A href='?_src_=holder;getmob=\ref[M]'>Get</A> | "
	body += "<A href='?_src_=holder;sendmob=\ref[M]'>Send To</A>"

	body += "<br><br>"
	body += "<A href='?_src_=holder;traitor=\ref[M]'>Traitor panel</A> | "
	body += "<A href='?_src_=holder;narrateto=\ref[M]'>Narrate to</A> | "
	body += "<A href='?_src_=holder;subtlemessage=\ref[M]'>Subtle message</A> | "
	body += "<A href='?_src_=holder;languagemenu=\ref[M]'>Language Menu</A>"

	if (M.client)
		if(!isnewplayer(M))
			body += "<br><br>"
			body += "<b>Transformation:</b>"
			body += "<br>"

			//Human
			if(ishuman(M))
				body += "<B>Human</B> | "
			else
				body += "<A href='?_src_=holder;humanone=\ref[M]'>Humanize</A> | "

			//Monkey
			if(ismonkey(M))
				body += "<B>Monkeyized</B> | "
			else
				body += "<A href='?_src_=holder;monkeyone=\ref[M]'>Monkeyize</A> | "

			//Corgi
			if(iscorgi(M))
				body += "<B>Corgized</B> | "
			else
				body += "<A href='?_src_=holder;corgione=\ref[M]'>Corgize</A> | "

			//AI / Cyborg
			if(isAI(M))
				body += "<B>Is an AI</B> "
			else if(ishuman(M))
				body += "<A href='?_src_=holder;makeai=\ref[M]'>Make AI</A> | "
				body += "<A href='?_src_=holder;makerobot=\ref[M]'>Make Robot</A> | "
				body += "<A href='?_src_=holder;makealien=\ref[M]'>Make Alien</A> | "
				body += "<A href='?_src_=holder;makeslime=\ref[M]'>Make Slime</A> | "
				body += "<A href='?_src_=holder;makeblob=\ref[M]'>Make Blob</A> | "

			//Simple Animals
			if(isanimal(M))
				body += "<A href='?_src_=holder;makeanimal=\ref[M]'>Re-Animalize</A> | "
			else
				body += "<A href='?_src_=holder;makeanimal=\ref[M]'>Animalize</A> | "

			body += "<br><br>"
			body += "<b>Rudimentary transformation:</b><font size=2><br>These transformations only create a new mob type and copy stuff over. They do not take into account MMIs and similar mob-specific things. The buttons in 'Transformations' are preferred, when possible.</font><br>"
			body += "<A href='?_src_=holder;simplemake=observer;mob=\ref[M]'>Observer</A> | "
			body += "\[ Alien: <A href='?_src_=holder;simplemake=drone;mob=\ref[M]'>Drone</A>, "
			body += "<A href='?_src_=holder;simplemake=hunter;mob=\ref[M]'>Hunter</A>, "
			body += "<A href='?_src_=holder;simplemake=sentinel;mob=\ref[M]'>Sentinel</A>, "
			body += "<A href='?_src_=holder;simplemake=praetorian;mob=\ref[M]'>Praetorian</A>, "
			body += "<A href='?_src_=holder;simplemake=queen;mob=\ref[M]'>Queen</A>, "
			body += "<A href='?_src_=holder;simplemake=larva;mob=\ref[M]'>Larva</A> \] "
			body += "<A href='?_src_=holder;simplemake=human;mob=\ref[M]'>Human</A> "
			body += "\[ slime: <A href='?_src_=holder;simplemake=slime;mob=\ref[M]'>Baby</A>, "
			body += "<A href='?_src_=holder;simplemake=adultslime;mob=\ref[M]'>Adult</A> \] "
			body += "<A href='?_src_=holder;simplemake=monkey;mob=\ref[M]'>Monkey</A> | "
			body += "<A href='?_src_=holder;simplemake=robot;mob=\ref[M]'>Cyborg</A> | "
			body += "<A href='?_src_=holder;simplemake=cat;mob=\ref[M]'>Cat</A> | "
			body += "<A href='?_src_=holder;simplemake=runtime;mob=\ref[M]'>Runtime</A> | "
			body += "<A href='?_src_=holder;simplemake=corgi;mob=\ref[M]'>Corgi</A> | "
			body += "<A href='?_src_=holder;simplemake=ian;mob=\ref[M]'>Ian</A> | "
			body += "<A href='?_src_=holder;simplemake=crab;mob=\ref[M]'>Crab</A> | "
			body += "<A href='?_src_=holder;simplemake=coffee;mob=\ref[M]'>Coffee</A> | "
			//body += "<A href='?_src_=holder;simplemake=parrot;mob=\ref[M]'>Parrot</A> | "
			//body += "<A href='?_src_=holder;simplemake=polyparrot;mob=\ref[M]'>Poly</A> | "
			body += "\[ Construct: <A href='?_src_=holder;simplemake=constructarmored;mob=\ref[M]'>Juggernaut</A> , "
			body += "<A href='?_src_=holder;simplemake=constructbuilder;mob=\ref[M]'>Artificer</A> , "
			body += "<A href='?_src_=holder;simplemake=constructwraith;mob=\ref[M]'>Wraith</A> \] "
			body += "<A href='?_src_=holder;simplemake=shade;mob=\ref[M]'>Shade</A>"
			body += "<br>"

	if (M.client)
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<A href='?_src_=holder;forcespeech=\ref[M]'>Forcesay</A> | "
		body += "<A href='?_src_=holder;tdome1=\ref[M]'>Thunderdome 1</A> | "
		body += "<A href='?_src_=holder;tdome2=\ref[M]'>Thunderdome 2</A> | "
		body += "<A href='?_src_=holder;tdomeadmin=\ref[M]'>Thunderdome Admin</A> | "
		body += "<A href='?_src_=holder;tdomeobserve=\ref[M]'>Thunderdome Observer</A> | "

	body += "<br>"
	body += "</body></html>"

	usr << browse(body, "window=adminplayeropts-\ref[M];size=550x515")
	SSblackbox.add_details("admin_verb","Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/access_news_network() //MARKER
	set category = "Fun"
	set name = "Access Newscaster Network"
	set desc = "Allows you to view, add and edit news feeds."

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return
	var/dat
	dat = text("<HEAD><TITLE>Admin Newscaster</TITLE></HEAD><H3>Admin Newscaster Unit</H3>")

	switch(admincaster_screen)
		if(0)
			dat += "Welcome to the admin newscaster.<BR> Here you can add, edit and censor every newspiece on the network."
			dat += "<BR>Feed channels and stories entered through here will be uneditable and handled as official news by the rest of the units."
			dat += "<BR>Note that this panel allows full freedom over the news network, there are no constrictions except the few basic ones. Don't break things!</FONT>"
			if(GLOB.news_network.wanted_issue.active)
				dat+= "<HR><A href='?src=\ref[src];ac_view_wanted=1'>Read Wanted Issue</A>"
			dat+= "<HR><BR><A href='?src=\ref[src];ac_create_channel=1'>Create Feed Channel</A>"
			dat+= "<BR><A href='?src=\ref[src];ac_view=1'>View Feed Channels</A>"
			dat+= "<BR><A href='?src=\ref[src];ac_create_feed_story=1'>Submit new Feed story</A>"
			dat+= "<BR><BR><A href='?src=\ref[usr];mach_close=newscaster_main'>Exit</A>"
			var/wanted_already = 0
			if(GLOB.news_network.wanted_issue.active)
				wanted_already = 1
			dat+="<HR><B>Feed Security functions:</B><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_censor_story=1'>Censor Feed Stories</A>"
			dat+="<BR><A href='?src=\ref[src];ac_menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice (disables and locks the channel).</A>"
			dat+="<BR><HR><A href='?src=\ref[src];ac_set_signature=1'>The newscaster recognises you as:<BR> <FONT COLOR='green'>[src.admin_signature]</FONT></A>"
		if(1)
			dat+= "Station Feed Channels<HR>"
			if( isemptylist(GLOB.news_network.network_channels) )
				dat+="<I>No active channels found...</I>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					if(CHANNEL.is_admin_channel)
						dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen'><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
					else
						dat+="<B><A href='?src=\ref[src];ac_show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR></B>"
			dat+="<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(2)
			dat+="Creating new Feed Channel..."
			dat+="<HR><B><A href='?src=\ref[src];ac_set_channel_name=1'>Channel Name</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_signature=1'>Channel Author</A>:</B> <FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.admincaster_feed_channel.locked) ? ("NO") : ("YES")]<BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A><BR>"
		if(3)
			dat+="Creating new Feed Message..."
			dat+="<HR><B><A href='?src=\ref[src];ac_set_channel_receiving=1'>Receiving Channel</A>:</B> [src.admincaster_feed_channel.channel_name]<BR>" //MARK
			dat+="<B>Message Author:</B> <FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<B><A href='?src=\ref[src];ac_set_new_message=1'>Message Body</A>:</B> [src.admincaster_feed_message.returnBody(-1)] <BR>"
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
				dat+="<FONT COLOR='maroon'>Invalid receiving channel name.</FONT><BR>"
			if(src.admincaster_feed_message.returnBody(-1) == "" || src.admincaster_feed_message.returnBody(-1) == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid message body.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[3]'>Return</A><BR>"
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
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[2]'>Return</A><BR>"
		if(9)
			dat+="<B>[admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[admincaster_feed_channel.returnAuthor(-1)]</FONT>\]</FONT><HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
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
			dat+="<BR><HR><A href='?src=\ref[src];ac_refresh=1'>Refresh</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[1]'>Back</A>"
		if(10)
			dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
			dat+="<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>"
			dat+="Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>"
			dat+="<HR>Select Feed channel to get Stories from:<BR>"
			if(isemptylist(GLOB.news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(11)
			dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
			dat+="<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's"
			dat+="morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed"
			dat+="stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"
			if(isemptylist(GLOB.news_network.network_channels))
				dat+="<I>No feed channels found active...</I><BR>"
			else
				for(var/datum/newscaster/feed_channel/CHANNEL in GLOB.news_network.network_channels)
					dat+="<A href='?src=\ref[src];ac_pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"

			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A>"
		if(12)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
			dat+="<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_author=\ref[src.admincaster_feed_channel]'>[(src.admincaster_feed_channel.authorCensor) ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"

			if( isemptylist(src.admincaster_feed_channel.messages) )
				dat+="<I>No feed messages found in channel...</I><BR>"
			else
				for(var/datum/newscaster/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
					dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
					dat+="<FONT SIZE=2><A href='?src=\ref[src];ac_censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.bodyCensor) ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];ac_censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.authorCensor) ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"
					dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]: <a href='?src=\ref[src];ac_lock_comment=\ref[MESSAGE]'>[MESSAGE.locked ? "Unlock" : "Lock"]</a><br>"
					for(var/datum/newscaster/feed_comment/comment in MESSAGE.comments)
						dat+="[comment.body] <a href='?src=\ref[src];ac_del_comment=\ref[comment];ac_del_comment_msg=\ref[MESSAGE]'>X</a><br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[10]'>Back</A>"
		if(13)
			dat+="<B>[src.admincaster_feed_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.admincaster_feed_channel.returnAuthor(-1)]</FONT> \]</FONT><BR>"
			dat+="Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];ac_toggle_d_notice=\ref[src.admincaster_feed_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"
			if(src.admincaster_feed_channel.censored)
				dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
				dat+="No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"
			else
				if( isemptylist(src.admincaster_feed_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/newscaster/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						dat+="-[MESSAGE.returnBody(-1)] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.returnAuthor(-1)]</FONT>\]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[11]'>Back</A>"
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
			dat+="<A href='?src=\ref[src];ac_set_wanted_name=1'>Criminal Name</A>: [src.admincaster_wanted_message.criminal] <BR>"
			dat+="<A href='?src=\ref[src];ac_set_wanted_desc=1'>Description</A>: [src.admincaster_wanted_message.body] <BR>"
			if(wanted_already)
				dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'>[GLOB.news_network.wanted_issue.scannedUser]</FONT><BR>"
			else
				dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'>[src.admin_signature]</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
			if(wanted_already)
				dat+="<BR><A href='?src=\ref[src];ac_cancel_wanted=1'>Take down Issue</A>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Cancel</A>"
		if(15)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_wanted_message.criminal] is now in Network Circulation.</FONT><BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(16)
			dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
			if(src.admincaster_wanted_message.criminal =="" || src.admincaster_wanted_message.criminal == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid name for person wanted.</FONT><BR>"
			if(src.admincaster_wanted_message.body == "" || src.admincaster_wanted_message.body == "\[REDACTED\]")
				dat+="<FONT COLOR='maroon'>Invalid description.</FONT><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		if(17)
			dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
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
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Back</A><BR>"
		if(19)
			dat+="<FONT COLOR='green'>Wanted issue for [src.admincaster_wanted_message.criminal] successfully edited.</FONT><BR><BR>"
			dat+="<BR><A href='?src=\ref[src];ac_setScreen=[0]'>Return</A><BR>"
		else
			dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

	//to_chat(world, "Channelname: [src.admincaster_feed_channel.channel_name] [src.admincaster_feed_channel.author]")
	//to_chat(world, "Msg: [src.admincaster_feed_message.author] [src.admincaster_feed_message.body]")
	usr << browse(dat, "window=admincaster_main;size=400x600")
	onclose(usr, "admincaster_main")


/datum/admins/proc/Game()
	if(!check_rights(0))
		return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(GLOB.master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		"}

	if(marked_datum && istype(marked_datum, /atom))
		dat += "<A href='?src=\ref[src];dupe_marked_datum=1'>Duplicate Marked Datum</A><br>"

	usr << browse(dat, "window=admin2;size=210x200")
	return

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Reboot World"
	set desc="Restarts the world immediately"
	if (!usr.client.holder)
		return

	var/list/options = list("Regular Restart", "Hard Restart (No Delay/Feeback Reason)", "Hardest Restart (No actions, just reboot)")
	if(world.RunningService())
		options += "Service Restart (Force restart DD)";
	var result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options
	if(result)
		SSblackbox.add_details("admin_verb","Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		switch(result)
			if("Regular Restart")
				SSticker.Reboot("Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key].", "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", 10)
			if("Hard Restart (No Delay, No Feeback Reason)")
				world.Reboot()
			if("Hardest Restart (No actions, just reboot)")
				world.Reboot(fast_track = TRUE)
			if("Service Restart (Force restart DD)")
				GLOB.reboot_mode = REBOOT_MODE_HARD
				world.ServiceReboot()

/datum/admins/proc/end_round()
	set category = "Server"
	set name = "End Round"
	set desc = "Attempts to produce a round end report and then restart the server organically."

	if (!usr.client.holder)
		return
	var/confirm = alert("End the round and  restart the game world?", "End Round", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		SSticker.force_ending = 1
		SSblackbox.add_details("admin_verb","End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	if(!check_rights(0))
		return

	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		to_chat(world, "<span class='adminnotice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b></span>\n \t [message]")
		log_admin("Announce: [key_name(usr)] : [message]")
	SSblackbox.add_details("admin_verb","Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/set_admin_notice()
	set category = "Special Verbs"
	set name = "Set Admin Notice"
	set desc ="Set an announcement that appears to everyone who joins the server. Only lasts this round"
	if(!check_rights(0))
		return

	var/new_admin_notice = input(src,"Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):","Set Notice",GLOB.admin_notice) as message|null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] removed the admin notice.")
		log_admin("[key_name(usr)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(usr)] set the admin notice.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, "<span class ='adminnotice'><b>Admin Notice:</b>\n \t [new_admin_notice]</span>")
	SSblackbox.add_details("admin_verb","Set Admin Notice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.admin_notice = new_admin_notice
	return

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")
	SSblackbox.add_details("admin_toggle","Toggle OOC|[GLOB.ooc_allowed]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	GLOB.dooc_allowed = !( GLOB.dooc_allowed )

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")
	SSblackbox.add_details("admin_toggle","Toggle Dead OOC|[GLOB.dooc_allowed]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (The server is still setting up, but the round will be \
				started as soon as possible.)"
		message_admins("<font color='blue'>\
			[usr.key] has started the game.[msg]</font>")
		SSblackbox.add_details("admin_verb","Start Now") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<font color='red'>Error: Start Now: Game has already started.</font>")

	return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="People can't enter"
	set name="Toggle Entering"
	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if (!( GLOB.enter_allowed ))
		to_chat(world, "<B>New players may no longer enter the game.</B>")
	else
		to_chat(world, "<B>New players may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled new player game entering.</span>")
	world.update_status()
	SSblackbox.add_details("admin_toggle","Toggle Entering|[GLOB.enter_allowed]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		to_chat(world, "<B>The AI job is no longer chooseable.</B>")
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	SSblackbox.add_details("admin_toggle","Toggle AI|[config.allow_ai]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Respawn basically"
	set name="Toggle Respawn"
	GLOB.abandon_allowed = !( GLOB.abandon_allowed )
	if (GLOB.abandon_allowed)
		to_chat(world, "<B>You may now respawn.</B>")
	else
		to_chat(world, "<B>You may no longer respawn :(</B>")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled respawn to [GLOB.abandon_allowed ? "On" : "Off"].</span>")
	log_admin("[key_name(usr)] toggled respawn to [GLOB.abandon_allowed ? "On" : "Off"].")
	world.update_status()
	SSblackbox.add_details("admin_toggle","Toggle Respawn|[GLOB.abandon_allowed]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start"
	set name="Delay pre-game"

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!")
	if(newtime)
		SSticker.SetTimeLeft(newtime * 10)
		if(newtime < 0)
			to_chat(world, "<b>The game start has been delayed.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<b>The game will start in [newtime] seconds.</b>")
			world << 'sound/ai/attention.ogg'
			log_admin("[key_name(usr)] set the pre-game delay to [newtime] seconds.")
		SSblackbox.add_details("admin_verb","Delay Game Start") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == ZLEVEL_CENTCOM)
		SSjob.SendToLateJoin(M)
		message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
	else
		alert("[M.name] is not prisoned.")
	SSblackbox.add_details("admin_verb","Unprison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

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
				if(Monkey.z == ZLEVEL_STATION)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"
*/
/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		var/atom/A = new chosen(usr.loc)
		A.admin_spawned = TRUE

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	SSblackbox.add_details("admin_verb","Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "This can only be used on instances of type /mob")
		return
	if(!M.mind)
		to_chat(usr, "This mob has no mind!")
		return

	M.mind.edit_memory()
	SSblackbox.add_details("admin_verb","Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Reduces view range when wearing welding helmets"
	set name="Toggle tinted welding helmes"
	GLOB.tinted_weldhelh = !( GLOB.tinted_weldhelh )
	if (GLOB.tinted_weldhelh)
		to_chat(world, "<B>The tinted_weldhelh has been enabled!</B>")
	else
		to_chat(world, "<B>The tinted_weldhelh has been disabled!</B>")
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.")
	SSblackbox.add_details("admin_toggle","Toggle Tinted Welding Helmets|[GLOB.tinted_weldhelh]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Guests can't enter"
	set name="Toggle guests"
	GLOB.guests_allowed = !( GLOB.guests_allowed )
	if (!( GLOB.guests_allowed ))
		to_chat(world, "<B>Guests may no longer enter the game.</B>")
	else
		to_chat(world, "<B>Guests may now enter the game.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [GLOB.guests_allowed?"":"dis"]allowed.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled guests game entering [GLOB.guests_allowed?"":"dis"]allowed.</span>")
	SSblackbox.add_details("admin_toggle","Toggle Guests|[GLOB.guests_allowed]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/mob/living/silicon/S in GLOB.mob_list)
		ai_number++
		if(isAI(S))
			to_chat(usr, "<b>AI [key_name(S, usr)]'s laws:</b>")
		else if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			to_chat(usr, "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(Slaved to: [R.connected_ai])":"(Independent)"]: laws:</b>")
		else if (ispAI(S))
			to_chat(usr, "<b>pAI [key_name(S, usr)]'s laws:</b>")
		else
			to_chat(usr, "<b>SOMETHING SILICON [key_name(S, usr)]'s laws:</b>")

		if (S.laws == null)
			to_chat(usr, "[key_name(S, usr)]'s laws are null?? Contact a coder.")
		else
			S.laws.show_laws(usr)
	if(!ai_number)
		to_chat(usr, "<b>No AIs located</b>" )

/datum/admins/proc/output_all_devil_info()
	var/devil_number = 0
	for(var/D in SSticker.mode.devils)
		devil_number++
		to_chat(usr, "Devil #[devil_number]:<br><br>" + SSticker.mode.printdevilinfo(D))
	if(!devil_number)
		to_chat(usr, "<b>No Devils located</b>" )

/datum/admins/proc/output_devil_info(mob/living/M)
	if(is_devil(M))
		to_chat(usr, SSticker.mode.printdevilinfo(M.mind))
	else
		to_chat(usr, "<b>[M] is not a devil.")

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return
	var/dat = "<html><head><title>Manage Free Slots</title></head><body>"
	var/count = 0

	if(SSticker && !SSticker.mode)
		alert(usr, "You cannot manage jobs before the round starts!")
		return

	if(SSjob)
		for(var/datum/job/job in SSjob.occupations)
			count++
			var/J_title = html_encode(job.title)
			var/J_opPos = html_encode(job.total_positions - (job.total_positions - job.current_positions))
			var/J_totPos = html_encode(job.total_positions)
			if(job.total_positions < 0)
				dat += "[J_title]: [J_opPos]   (unlimited)"
			else
				dat += "[J_title]: [J_opPos]/[J_totPos]"

			if(job.title == "AI" || job.title == "Cyborg")
				dat += "   (Cannot Late Join)<br>"
				continue
			if(job.total_positions >= 0)
				dat += "   <A href='?src=\ref[src];addjobslot=[job.title]'>Add</A>  |  "
				if(job.total_positions > job.current_positions)
					dat += "<A href='?src=\ref[src];removejobslot=[job.title]'>Remove</A>  |  "
				else
					dat += "Remove  |  "
				dat += "<A href='?src=\ref[src];unlimitjobslot=[job.title]'>Unlimit</A>"
			else
				dat += "   <A href='?src=\ref[src];limitjobslot=[job.title]'>Limit</A>"
			dat += "<br>"

	dat += "</body>"
	var/winheight = 100 + (count * 20)
	winheight = min(winheight, 690)
	usr << browse(dat, "window=players;size=375x[winheight]")

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//

//RIP ferry snowflakes

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.ckey]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/living/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return 0

	if (!frommob.ckey)
		return 0

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return 1

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1

	tomob.ghostize(0)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has put [frommob.ckey] in control of [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.ckey] into [tomob.name].")
	SSblackbox.add_details("admin_verb","Ghost Drag Control")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1

/client/proc/adminGreet(logout)
	if(SSticker.HasRoundStarted())
		var/string
		if(logout && config && config.announce_admin_logout)
			string = pick(
				"Admin logout: [key_name(src)]")
		else if(!logout && config && config.announce_admin_login && (prefs.toggles & ANNOUNCE_LOGIN))
			string = pick(
				"Admin login: [key_name(src)]")
		if(string)
			message_admins("[string]")
