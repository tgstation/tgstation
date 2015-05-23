
var/global/BSACooldown = 0
var/global/floorIsLava = 0


////////////////////////////////
/proc/message_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	admins << msg


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edit player (respawn, ban, heal, etc)"

	if(!check_rights())
		return

	if(!M)
		usr << "You seem to be selecting a mob that doesn't exist anymore."
		return

	var/body = "<html><head><title>Options for [M.key]</title></head>"
	body += "<body>Options panel for <b>[M]</b>"
	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += "\[<A href='?_src_=holder;editrights=rank;ckey=[M.ckey]'>[M.client.holder ? M.client.holder.rank : "Player"]</A>\]"

	if(istype(M, /mob/new_player))
		body += " <B>Hasn't Entered Game</B> "
	else
		body += " \[<A href='?_src_=holder;revive=\ref[M]'>Heal</A>\] "

	body += "<br><br>\[ "
	body += "<a href='?_src_=vars;Vars=\ref[M]'>VV</a> - "
	body += "<a href='?_src_=holder;traitor=\ref[M]'>TP</a> - "
	body += "<a href='?priv_msg=[M.ckey]'>PM</a> - "
	body += "<a href='?_src_=holder;subtlemessage=\ref[M]'>SM</a> - "
	body += "<a href='?_src_=holder;adminplayerobservejump=\ref[M]'>JMP</a>\] </b><br>"

	body += "<b>Mob type</b> = [M.type]<br><br>"

	body += "<A href='?_src_=holder;boot2=\ref[M]'>Kick</A> | "
	body += "<A href='?_src_=holder;newban=\ref[M]'>Ban</A> | "
	body += "<A href='?_src_=holder;jobban2=\ref[M]'>Jobban</A> | "
	body += "<A href='?_src_=holder;appearanceban=\ref[M]'>Identity Ban</A> | "
	body += "<A href='?_src_=holder;notes=show;ckey=[M.ckey]'>Notes</A> "

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
	body += "<A href='?_src_=holder;subtlemessage=\ref[M]'>Subtle message</A>"

	if (M.client)
		if(!istype(M, /mob/new_player))
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
			body += "<A href='?_src_=holder;simplemake=queen;mob=\ref[M]'>Queen</A>, "
			body += "<A href='?_src_=holder;simplemake=sentinel;mob=\ref[M]'>Sentinel</A>, "
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
			body += "\[ Construct: <A href='?_src_=holder;simplemake=constructarmored;mob=\ref[M]'>Armored</A> , "
			body += "<A href='?_src_=holder;simplemake=constructbuilder;mob=\ref[M]'>Builder</A> , "
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
	feedback_add_details("admin_verb","SPP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


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
					var/i = 0
					for(var/datum/feed_message/MESSAGE in src.admincaster_feed_channel.messages)
						i++
						dat+="-[MESSAGE.body] <BR>"
						if(MESSAGE.img)
							usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
							dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
						dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
						dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]:<br>"
						for(var/datum/feed_comment/comment in MESSAGE.comments)
							dat+="[comment.body]<br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
						dat+="<br>"
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
					dat+="[MESSAGE.comments.len] comment[MESSAGE.comments.len > 1 ? "s" : ""]: <a href='?src=\ref[src];ac_lock_comment=\ref[MESSAGE]'>[MESSAGE.locked ? "Unlock" : "Lock"]</a><br>"
					for(var/datum/feed_comment/comment in MESSAGE.comments)
						dat+="[comment.body] <a href='?src=\ref[src];ac_del_comment=\ref[comment];ac_del_comment_msg=\ref[MESSAGE]'>X</a><br><font size=1>[comment.author] [comment.time_stamp]</font><br>"
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
			dat+="<B>Photo:</B>: "
			if(news_network.wanted_issue.img)
				usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
				dat+="<BR><img src='tmp_photow.png' width = '180'>"
			else
				dat+="None"
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
	if(!check_rights(R_BAN))	return

	var/dat = "<B>Job Bans!</B><HR><table>"
	for(var/t in jobban_keylist)
		var/r = t
		if( findtext(r,"##") )
			r = copytext( r, 1, findtext(r,"##") )//removes the description
		dat += text("<tr><td>[t] (<A href='?src=\ref[src];removejobban=[r]'>unban</A>)</td></tr>")
	dat += "</table>"
	usr << browse(dat, "window=ban;size=400x400")

/datum/admins/proc/Game()
	if(!check_rights(0))	return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		"}
	if(master_mode == "secret")
		dat += "<A href='?src=\ref[src];f_secret=1'>(Force Secret Mode)</A><br>"

	dat += {"
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		"}

	usr << browse(dat, "window=admin2;size=210x180")
	return

/datum/admins/proc/Secrets()
	if(!check_rights(0))	return

	var/dat = "<B>The first rule of adminbuse is: you don't talk about the adminbuse.</B><HR>"

	dat +={"
			<B>General Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsgeneral=list_job_debug'>Show Job Debug</A><BR>
			<A href='?src=\ref[src];secretsgeneral=spawn_objects'>Admin Log</A><BR>
			<A href='?src=\ref[src];secretsgeneral=show_admins'>Show Admin List</A><BR>
			<BR>
			"}

	if(check_rights(R_ADMIN,0))
		dat += {"
			<B>Admin Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsadmin=clear_virus'>Cure all diseases currently in existence</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
			<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
			<A href='?src=\ref[src];secretsadmin=list_lawchanges'>Show last [length(lawchanges)] law changes</A><BR>
			<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
			<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
			<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
			<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
			<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR><BR>
			<BR>
			<B>Shuttles</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsadmin=moveferry'>Move Ferry</A><BR>
			<A href='?src=\ref[src];secretsadmin=moveminingshuttle'>Move Mining Shuttle</A><BR>
			<A href='?src=\ref[src];secretsadmin=movelaborshuttle'>Move Labor Shuttle</A><BR>
			<BR>
			"}

	if(check_rights(R_FUN,0))
		dat += {"
			<B>Fun Secrets</B><BR>
			<BR>
			<A href='?src=\ref[src];secretsfun=tdomereset'>Reset Thunderdome to default state</A><BR>
			<A href='?src=\ref[src];secretsfun=virus'>Trigger a Virus Outbreak</A><BR>
			<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkeys</A><BR>
			<A href='?src=\ref[src];secretsfun=allspecies'>Change the species of all humans</A><BR>
			<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
			<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
			<A href='?src=\ref[src];secretsfun=quickpower'>Power all SMES</A><BR>
			<A href='?src=\ref[src];secretsfun=tripleAI'>Triple AI mode (needs to be used in the lobby)</A><BR>
			<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
			<A href='?src=\ref[src];secretsfun=guns'>Summon Guns</A><BR>
			<A href='?src=\ref[src];secretsfun=magic'>Summon Magic</A><BR>
			<A href='?src=\ref[src];secretsfun=events'>Summon Events (Toggle)</A><BR>
			<A href='?src=\ref[src];secretsfun=onlyone'>There can only be one!</A><BR>
			<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
			<A href='?src=\ref[src];secretsfun=eagles'>Egalitarian Station Mode</A><BR>
			<A href='?src=\ref[src];secretsfun=blackout'>Break all lights</A><BR>
			<A href='?src=\ref[src];secretsfun=whiteout'>Fix all lights</A><BR>
			<A href='?src=\ref[src];secretsfun=floorlava'>The floor is lava! (DANGEROUS: extremely lame)</A><BR>
			<BR>
			"}

/* DEATH SQUADS
<A href='?src=\ref[src];secretsfun=striketeam'>Send in a strike team</A><BR>
*/
	if(check_rights(R_SERVER,0))
		dat += "<A href='?src=\ref[src];secretsfun=togglebombcap'>Toggle bomb cap</A><BR>"

	dat += "<BR>"

	if(check_rights(R_DEBUG,0))
		dat += {"
			<B>Security Level Elevated</B><BR>
			<BR>
			<A href='?src=\ref[src];secretscoder=maint_access_engiebrig'>Change all maintenance doors to engie/brig access only</A><BR>
			<A href='?src=\ref[src];secretscoder=maint_access_brig'>Change all maintenance doors to brig access only</A><BR>
			<A href='?src=\ref[src];secretscoder=infinite_sec'>Remove cap on security officers</A><BR>
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
		world << "<span class='boldannounce'>Restarting world!</span> <span class='adminnotice'> Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span>"
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
	if(!check_rights(0))	return

	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		world << "<span class='adminnotice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b></span>\n \t [message]"
		log_admin("Announce: [key_name(usr)] : [message]")
	feedback_add_details("admin_verb","A") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/set_admin_notice()
	set category = "Special Verbs"
	set name = "Set Admin Notice"
	set desc ="Set an announcement that appears to everyone who joins the server. Only lasts this round"
	if(!check_rights(0))	return

	var/new_admin_notice = input(src,"Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):","Set Notice",admin_notice) as message|null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] removed the admin notice.")
		log_admin("[key_name(usr)] removed the admin notice:\n[admin_notice]")
	else
		message_admins("[key_name(usr)] set the admin notice.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		world << "<span class ='adminnotice'><b>Admin Notice:</b>\n \t [new_admin_notice]</span>"
	feedback_add_details("admin_verb","SAN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	admin_notice = new_admin_notice
	return

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Toggle dis bitch"
	set name="Toggle Dead OOC"
	dooc_allowed = !( dooc_allowed )

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")
	feedback_add_details("admin_verb","TDOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/datum/admins/proc/toggletraitorscaling()
	set category = "Server"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].")
	feedback_add_details("admin_verb","TTS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
*/
/datum/admins/proc/startnow()
	set category = "Server"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.can_fire = 1
		ticker.timeLeft = 0
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
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled new player game entering.</span>")
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
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].</span>")
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()
	feedback_add_details("admin_verb","TR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Server"
	set desc="Delay the game start"
	set name="Delay pre-game"

	var/newtime = input("Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(ticker.timeLeft/10)) as num|null
	if(ticker.current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!")
	if(newtime)
		ticker.timeLeft = newtime * 10
		if(newtime < 0)
			world << "<b>The game start has been delayed.</b>"
			log_admin("[key_name(usr)] delayed the round start.")
		else
			world << "<b>The game will start in [newtime] seconds.</b>"
			world << 'sound/ai/attention.ogg'
			log_admin("[key_name(usr)] set the pre-game delay to [newtime] seconds.")
		feedback_add_details("admin_verb","DELAY") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/immreboot()
	set category = "Server"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if(!usr.client.holder)	return
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	world << "<span class='boldannounce'>Rebooting world!</span> <span class='adminnotice'>Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]!</span>"
	log_admin("[key_name(usr)] initiated an immediate reboot.")

	feedback_set_details("end_error","immediate admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]")
	feedback_add_details("admin_verb","IR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	if(blackbox)
		blackbox.save_all_data_to_sql()

	world.Reboot()

/datum/admins/proc/unprison(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (M.z == ZLEVEL_CENTCOM)
		M.loc = pick(latejoin)
		message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
	else
		alert("[M.name] is not prisoned.")
	feedback_add_details("admin_verb","UP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	set desc = "(atom path) Spawn an atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))	return

	var/list/matches = get_fancy_list_of_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]

	if(ispath(chosen,/turf))
		var/turf/T = get_turf(usr.loc)
		T.ChangeTurf(chosen)
	else
		new chosen(usr.loc)

	log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","SA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(var/mob/M in mob_list)
	set category = "Admin"
	set desc = "Edit mobs's memory and role"
	set name = "Show Traitor Panel"

	if(!istype(M))
		usr << "This can only be used on instances of type /mob"
		return
	if(!M.mind)
		usr << "This mob has no mind!"
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
	message_admins("[key_name_admin(usr)] toggled tinted_weldhelh.")
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
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] toggled guests game entering [guests_allowed?"":"dis"]allowed.</span>")
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

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return
	var/dat = "<html><head><title>Manage Free Slots</title></head><body>"
	var/count = 0

	if(ticker && !ticker.mode)
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
proc/kick_clients_in_lobby(var/message, var/kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in clients)
		if(istype(C.mob, /mob/new_player))
			if(kick_only_afk && !C.is_afk())	//Ignore clients who are not afk
				continue
			if(message)
				C << message
			kicked_client_names.Add("[C.ckey]")
			del(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(var/mob/dead/observer/frommob, var/mob/living/tomob)

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
	feedback_add_details("admin_verb","CGD")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1