//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

/datum/feed_message
	var/author =""
	var/body =""
	//var/parent_channel
	var/backup_body =""
	var/backup_author =""
	var/is_admin_message = 0
	var/icon/img = null
	var/icon/backup_img

/datum/feed_channel
	var/channel_name=""
	var/list/datum/feed_message/messages = list()
	//var/message_count = 0
	var/locked=0
	var/author=""
	var/backup_author=""
	var/censored=0
	var/is_admin_channel=0
	//var/page = null //For newspapers

/datum/feed_message/proc/clear()
	src.author = ""
	src.body = ""
	src.backup_body = ""
	src.backup_author = ""
	src.img = null
	src.backup_img = null

/datum/feed_channel/proc/clear()
	src.channel_name = ""
	src.messages = list()
	src.locked = 0
	src.author = ""
	src.backup_author = ""
	src.censored = 0
	src.is_admin_channel = 0

/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue

var/datum/feed_network/news_network = new /datum/feed_network     //The global news-network, which is coincidentally a global list.

var/list/obj/machinery/newscaster/allCasters = list() //Global list that will contain reference to all newscasters in existence.


/obj/machinery/newscaster
	name = "newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"

	// Allow ghosts to send Topic()s.
	ghost_write=1
	custom_aghost_alerts=1 // We handle our own logging.

	var/isbroken = 0  //1 if someone banged it with something heavy
	var/ispowered = 1 //starts powered, changes with power_change()
	//var/list/datum/feed_channel/channel_list = list() //This list will contain the names of the feed channels. Each name will refer to a data region where the messages of the feed channels are stored.
	//OBSOLETE: We're now using a global news network
	var/screen = 0                  //Or maybe I'll make it into a list within a list afterwards... whichever I prefer, go fuck yourselves :3
		// 0 = welcome screen - main menu
		// 1 = view feed channels
		// 2 = create feed channel
		// 3 = create feed story
		// 4 = feed story submited sucessfully
		// 5 = feed channel created successfully
		// 6 = ERROR: Cannot create feed story
		// 7 = ERROR: Cannot create feed channel
		// 8 = print newspaper
		// 9 = viewing channel feeds
		// 10 = censor feed story
		// 11 = censor feed channel
		//Holy shit this is outdated, made this when I was still starting newscasters :3
	var/paper_remaining = 0
	var/securityCaster = 0
		// 0 = Caster cannot be used to issue wanted posters
		// 1 = the opposite
	var/unit_no = 0 //Each newscaster has a unit number
	//var/datum/feed_message/wanted //We're gonna use a feed_message to store data of the wanted person because fields are similar
	//var/wanted_issue = 0          //OBSOLETE
		// 0 = there's no WANTED issued, we don't need a special icon_state
		// 1 = Guess what.
	var/alert_delay = 500
	var/alert = 0
		// 0 = there hasn't been a news/wanted update in the last alert_delay
		// 1 = there has
	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/mob/masterController = null // Mob with control over the newscaster.
	var/msg = "";                //Feed message
	var/obj/item/weapon/photo/photo = null
	var/channel_name = ""; //the feed channel which will be receiving the feed, or being created
	var/c_locked=0;        //Will our new channel be locked to public submissions?
	var/hitstaken = 0      //Death at 3 hits from an item with force>=15
	var/datum/feed_channel/viewing_channel = list()
	luminosity = 0
	anchored = 1


/obj/machinery/newscaster/security_unit                   //Security unit
	name = "Security Newscaster"
	securityCaster = 1

/obj/machinery/newscaster/New()         //Constructor, ho~
	allCasters += src
	src.paper_remaining = 15            // Will probably change this to something better
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters) // Let's give it an appropriate unit number
		src.unit_no++
	src.update_icon() //for any custom ones on the map...
	..()                                //I just realised the newscasters weren't in the global machines list. The superconstructor call will tend to that

/obj/machinery/newscaster/Destroy()
	allCasters -= src
	..()

/obj/machinery/newscaster/update_icon()
	if(!ispowered || isbroken)
		icon_state = "newscaster_off"
		if(isbroken) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			src.overlays.Cut()
			src.overlays += image(src.icon, "crack3")
		return

	src.overlays.Cut() //reset overlays

	if(news_network.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
		icon_state = "newscaster_wanted"
		return

	if(alert) //new message alert overlay
		src.overlays += "newscaster_alert"

	if(hitstaken > 0) //Cosmetic damage overlay
		src.overlays += image(src.icon, "crack[hitstaken]")

	icon_state = "newscaster_normal"
	return

/obj/machinery/newscaster/power_change()
	if(isbroken) //Broken shit can't be powered.
		return
	if( src.powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		src.update_icon()
	else
		spawn(rand(0, 15))
			src.ispowered = 0
			stat |= NOPOWER
			src.update_icon()


/obj/machinery/newscaster/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			src.isbroken=1
			if(prob(50))
				qdel(src)
			else
				src.update_icon() //can't place it above the return and outside the if-else. or we might get runtimes of null.update_icon() if(prob(50)) goes in.
			return
		else
			if(prob(50))
				src.isbroken=1
			src.update_icon()
			return
	return

/obj/machinery/newscaster/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/newscaster/attack_hand(mob/user as mob)            //########### THE MAIN BEEF IS HERE! And in the proc below this...############
	if(!src.ispowered || src.isbroken)
		return
	if(istype(user, /mob/living/carbon/human) || istype(user,/mob/living/silicon) || isobserver(user))
		var/mob/M = user
		var/dat
		dat = text("<HEAD><TITLE>Newscaster</TITLE></HEAD><H3>Newscaster Unit #[src.unit_no]</H3>")

		src.scan_user(M) //Newscaster scans you

		switch(screen)
			if(0)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:187: dat += "Welcome to Newscasting Unit #[src.unit_no].<BR> Interface & News networks Operational."
				dat += {"Welcome to Newscasting Unit #[src.unit_no].<BR> Interface & News networks Operational.
					<BR><FONT SIZE=1>Property of Nanotransen Inc</FONT>"}
				// END AUTOFIX
				if(news_network.wanted_issue)
					dat+= "<HR><A href='?src=\ref[src];view_wanted=1'>Read Wanted Issue</A>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:191: dat+= "<HR><BR><A href='?src=\ref[src];create_channel=1'>Create Feed Channel</A>"
				dat += {"<HR><BR><A href='?src=\ref[src];create_channel=1'>Create Feed Channel</A>
					<BR><A href='?src=\ref[src];view=1'>View Feed Channels</A>
					<BR><A href='?src=\ref[src];create_feed_story=1'>Submit new Feed story</A>
					<BR><A href='?src=\ref[src];menu_paper=1'>Print newspaper</A>
					<BR><A href='?src=\ref[src];refresh=1'>Re-scan User</A>
					<BR><BR><A href='?src=\ref[M];mach_close=newscaster_main'>Exit</A>"}
				// END AUTOFIX
				if(src.securityCaster)
					var/wanted_already = 0
					if(news_network.wanted_issue)
						wanted_already = 1


					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:202: dat+="<HR><B>Feed Security functions:</B><BR>"
					dat += {"<HR><B>Feed Security functions:</B><BR>
						<BR><A href='?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Manage") : ("Publish")] \"Wanted\" Issue</A>
						<BR><A href='?src=\ref[src];menu_censor_story=1'>Censor Feed Stories</A>
						<BR><A href='?src=\ref[src];menu_censor_channel=1'>Mark Feed Channel with Nanotrasen D-Notice</A>"}
				// END AUTOFIX
				dat+="<BR><HR>The newscaster recognises you as: <FONT COLOR='green'>[src.scanned_user]</FONT>"
			if(1)
				dat+= "Station Feed Channels<HR>"
				if( isemptylist(news_network.network_channels) )
					dat+="<I>No active channels found...</I>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><FONT style='BACKGROUND-COLOR: LightGreen '><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></FONT></B><BR>"
						else
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR></B>"
					/*for(var/datum/feed_channel/CHANNEL in src.channel_list)
						dat+="<B>[CHANNEL.channel_name]: </B> <BR><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[CHANNEL.author]</FONT>\]</FONT><BR><BR>"
						if( isemptylist(CHANNEL.messages) )
							dat+="<I>No feed messages found in channel...</I><BR><BR>"
						else
							for(var/datum/feed_message/MESSAGE in CHANNEL.messages)
								dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"*/


				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:225: dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat += {"<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"}
				// END AUTOFIX
			if(2)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:228: dat+="Creating new Feed Channel..."
				dat += {"Creating new Feed Channel...
					<HR><B><A href='?src=\ref[src];set_channel_name=1'>Channel Name</A>:</B> [src.channel_name]<BR>
					<B>Channel Author:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>
					<B><A href='?src=\ref[src];set_channel_lock=1'>Will Accept Public Feeds</A>:</B> [(src.c_locked) ? ("NO") : ("YES")]<BR><BR>
					<BR><A href='?src=\ref[src];submit_new_channel=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"}
				// END AUTOFIX
			if(3)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:234: dat+="Creating new Feed Message..."
				dat += {"Creating new Feed Message...
					<HR><B><A href='?src=\ref[src];set_channel_receiving=1'>Receiving Channel</A>:</B> [src.channel_name]<BR>"
					<B>Message Author:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>
					<B><A href='?src=\ref[src];set_new_message=1'>Message Body</A>:</B> [src.msg] <BR>
					<B><A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>:</B>  [(src.photo ? "Photo Attached" : "No Photo")]</BR>
					<BR><A href='?src=\ref[src];submit_new_message=1'>Submit</A><BR><BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A><BR>"}
				// END AUTOFIX
			if(4)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:241: dat+="Feed story successfully submitted to [src.channel_name].<BR><BR>"
				dat += {"Feed story successfully submitted to [src.channel_name].<BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"}
				// END AUTOFIX
			if(5)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:244: dat+="Feed Channel [src.channel_name] created successfully.<BR><BR>"
				dat += {"Feed Channel [src.channel_name] created successfully.<BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"}
				// END AUTOFIX
			if(6)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed story to Network.</B></FONT><HR><BR>"
				if(src.channel_name=="")
					dat+="<FONT COLOR='maroon'>•Invalid receiving channel name.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>•Channel author unverified.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>•Invalid message body.</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[3]'>Return</A><BR>"
			if(7)
				dat+="<B><FONT COLOR='maroon'>ERROR: Could not submit Feed Channel to Network.</B></FONT><HR><BR>"
				//var/list/existing_channels = list()            //Let's get dem existing channels - OBSOLETE
				var/list/existing_authors = list()
				for(var/datum/feed_channel/FC in news_network.network_channels)
					//existing_channels += FC.channel_name       //OBSOLETE
					if(FC.author == "\[REDACTED\]")
						existing_authors += FC.backup_author
					else
						existing_authors += FC.author
				if(src.scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>•There already exists a Feed channel under your name.</FONT><BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>•Invalid channel name.</FONT><BR>"
				var/check = 0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == src.channel_name)
						check = 1
						break
				if(check)
					dat+="<FONT COLOR='maroon'>•Channel name already in use.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>•Channel author unverified.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[2]'>Return</A><BR>"
			if(8)
				var/total_num=length(news_network.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)    //Dont forget, datum/feed_channel's var messages is a list of datum/feed_message
					else
						active_num--

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:289: dat+="Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories." //TODO: CONTINUE
				dat += {"Network currently serves a total of [total_num] Feed channels, [active_num] of which are active, and a total of [message_num] Feed Stories." //TODO: CONTINU
					<BR><BR><B>Liquid Paper remaining:</B> [(src.paper_remaining) *100 ] cm^3
					<BR><BR><A href='?src=\ref[src];print_paper=[0]'>Print Paper</A>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"}
				// END AUTOFIX
			if(9)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT>\]</FONT><HR>"
				if(src.viewing_channel.censored)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:296: dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat += {"<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
						No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"}
					// END AUTOFIX
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:310: dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
				dat += {"<BR><HR><A href='?src=\ref[src];refresh=1'>Refresh</A>
					<BR><A href='?src=\ref[src];setScreen=[1]'>Back</A>"}
				// END AUTOFIX
			if(10)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:313: dat+="<B>Nanotrasen Feed Censorship Tool</B><BR>"
				dat += {"<B>Nanotrasen Feed Censorship Tool</B><BR>
					<FONT SIZE=1>NOTE: Due to the nature of news Feeds, total deletion of a Feed Story is not possible.<BR>
					Keep in mind that users attempting to view a censored feed will instead see the \[REDACTED\] tag above it.</FONT>
					<HR>Select Feed channel to get Stories from:<BR>"}
				// END AUTOFIX
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(11)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:324: dat+="<B>Nanotrasen D-Notice Handler</B><HR>"
				dat += {"<B>Nanotrasen D-Notice Handler</B><HR>
					<FONT SIZE=1>A D-Notice is to be bestowed upon the channel if the handling Authority deems it as harmful for the station's
					morale, integrity or disciplinary behaviour. A D-Notice will render a channel unable to be updated by anyone, without deleting any feed
					stories it might contain at the time. You can lift a D-Notice if you have the required access at any time.</FONT><HR>"}
				// END AUTOFIX
				if(isemptylist(news_network.network_channels))
					dat+="<I>No feed channels found active...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : ()]<BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Back</A>"
			if(12)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:336: dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>"
				dat += {"<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>
					<FONT SIZE=2><A href='?src=\ref[src];censor_channel_author=\ref[src.viewing_channel]'>[(src.viewing_channel.author=="\[REDACTED\]") ? ("Undo Author censorship") : ("Censor channel Author")]</A></FONT><HR>"}
				// END AUTOFIX
				if( isemptylist(src.viewing_channel.messages) )
					dat+="<I>No feed messages found in channel...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)

						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:344: dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
						dat += {"-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>
							<FONT SIZE=2><A href='?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[(MESSAGE.body == "\[REDACTED\]") ? ("Undo story censorship") : ("Censor story")]</A>  -  <A href='?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'>[(MESSAGE.author == "\[REDACTED\]") ? ("Undo Author Censorship") : ("Censor message Author")]</A></FONT><BR>"}
						// END AUTOFIX
				dat+="<BR><A href='?src=\ref[src];setScreen=[10]'>Back</A>"
			if(13)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:348: dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>"
				dat += {"<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[ created by: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>
					Channel messages listed below. If you deem them dangerous to the station, you can <A href='?src=\ref[src];toggle_d_notice=\ref[src.viewing_channel]'>Bestow a D-Notice upon the channel</A>.<HR>"}
				// END AUTOFIX
				if(src.viewing_channel.censored)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:351: dat+="<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>"
					dat += {"<FONT COLOR='red'><B>ATTENTION: </B></FONT>This channel has been deemed as threatening to the welfare of the station, and marked with a Nanotrasen D-Notice.<BR>
						No further feed story additions are allowed while the D-Notice is in effect.</FONT><BR><BR>"}
					// END AUTOFIX
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>No feed messages found in channel...</I><BR>"
					else
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[11]'>Back</A>"
			if(14)
				dat+="<B>Wanted Issue Handler:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(news_network.wanted_issue)
					wanted_already = 1
					end_param = 2

				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>A wanted issue is already in Feed Circulation. You can edit or cancel it below.</FONT></I>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:371: dat+="<HR>"
				dat += {"<HR>
					<A href='?src=\ref[src];set_wanted_name=1'>Criminal Name</A>: [src.channel_name] <BR>
					<A href='?src=\ref[src];set_wanted_desc=1'>Description</A>: [src.msg] <BR>
					<A href='?src=\ref[src];set_attachment=1'>Attach Photo</A>: [(src.photo ? "Photo Attached" : "No Photo")]</BR>"}
				// END AUTOFIX
				if(wanted_already)
					dat+="<B>Wanted Issue created by:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
				else
					dat+="<B>Wanted Issue will be created under prosecutor:</B><FONT COLOR='green'> [src.scanned_user]</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Edit Issue") : ("Submit")]</A>"
				if(wanted_already)
					dat+="<BR><A href='?src=\ref[src];cancel_wanted=1'>Take down Issue</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Cancel</A>"
			if(15)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:384: dat+="<FONT COLOR='green'>Wanted issue for [src.channel_name] is now in Network Circulation.</FONT><BR><BR>"
				dat += {"<FONT COLOR='green'>Wanted issue for [src.channel_name] is now in Network Circulation.</FONT><BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"}
				// END AUTOFIX
			if(16)
				dat+="<B><FONT COLOR='maroon'>ERROR: Wanted Issue rejected by Network.</B></FONT><HR><BR>"
				if(src.channel_name=="" || src.channel_name == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>•Invalid name for person wanted.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>•Issue author unverified.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[REDACTED\]")
					dat+="<FONT COLOR='maroon'>•Invalid description.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"
			if(17)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:396: dat+="<B>Wanted Issue successfully deleted from Circulation</B><BR>"
				dat += {"<B>Wanted Issue successfully deleted from Circulation</B><BR>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"}
				// END AUTOFIX
			if(18)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:399: dat+="<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>"
				dat += {"<B><FONT COLOR ='maroon'>-- STATIONWIDE WANTED ISSUE --</B></FONT><BR><FONT SIZE=2>\[Submitted by: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>
					<B>Criminal</B>: [news_network.wanted_issue.author]<BR>
					<B>Description</B>: [news_network.wanted_issue.body]<BR>
					<B>Photo:</B>: "}
				// END AUTOFIX
				if(news_network.wanted_issue.img)
					usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="None"
				dat+="<BR><BR><A href='?src=\ref[src];setScreen=[0]'>Back</A><BR>"
			if(19)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:410: dat+="<FONT COLOR='green'>Wanted issue for [src.channel_name] successfully edited.</FONT><BR><BR>"
				dat += {"<FONT COLOR='green'>Wanted issue for [src.channel_name] successfully edited.</FONT><BR><BR>
					<BR><A href='?src=\ref[src];setScreen=[0]'>Return</A><BR>"}
				// END AUTOFIX
			if(20)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:413: dat+="<FONT COLOR='green'>Printing successfull. Please receive your newspaper from the bottom of the machine.</FONT><BR><BR>"
				dat += {"<FONT COLOR='green'>Printing successfull. Please receive your newspaper from the bottom of the machine.</FONT><BR><BR>
					<A href='?src=\ref[src];setScreen=[0]'>Return</A>"}
				// END AUTOFIX
			if(21)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:416: dat+="<FONT COLOR='maroon'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnell to refill machine storage.</FONT><BR><BR>"
				dat += {"<FONT COLOR='maroon'>Unable to print newspaper. Insufficient paper. Please notify maintenance personnell to refill machine storage.</FONT><BR><BR>
					<A href='?src=\ref[src];setScreen=[0]'>Return</A>"}
				// END AUTOFIX
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"


		M << browse(dat, "window=newscaster_main;size=400x600")
		onclose(M, "newscaster_main")

	/*if(src.isbroken) //debugging shit
		return
	src.hitstaken++
	if(src.hitstaken==3)
		src.isbroken = 1
	src.update_icon()*/


/obj/machinery/newscaster/Topic(href, href_list)
	if(..())
		return
	if(masterController && !isobserver(masterController) && get_dist(masterController,src)<=1 && usr!=masterController)
		usr << "\red You must wait for [masterController] to finish and move away."
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon) || isobserver(usr)))
		usr.set_machine(src)
		if(href_list["set_channel_name"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set a channel's name"))
				usr << "\red You can't do that."
				return
			src.channel_name = strip_html_simple(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
			while (findtext(src.channel_name," ") == 1)
				src.channel_name = copytext(src.channel_name,2,length(src.channel_name)+1)
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["set_channel_lock"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"locked a channel"))
				usr << "\red You can't do that."
				return
			src.c_locked = !src.c_locked
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["submit_new_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a new channel"))
				usr << "\red You can't do that."
				return
			//var/list/existing_channels = list() //OBSOLETE
			var/list/existing_authors = list()
			for(var/datum/feed_channel/FC in news_network.network_channels)
				//existing_channels += FC.channel_name
				if(FC.author == "\[REDACTED\]")
					existing_authors += FC.backup_author
				else
					existing_authors  +=FC.author
			var/check = 0
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.channel_name)
					check = 1
					break
			if(src.channel_name == "" || src.channel_name == "\[REDACTED\]" || src.scanned_user == "Unknown" || check || (src.scanned_user in existing_authors) )
				src.screen=7
			else
				var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
				if(choice=="Confirm")
					var/datum/feed_channel/newChannel = new /datum/feed_channel
					newChannel.channel_name = src.channel_name
					newChannel.author = src.scanned_user
					newChannel.locked = c_locked
					feedback_inc("newscaster_channels",1)
					/*for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)    //Let's add the new channel in all casters.
						NEWSCASTER.channel_list += newChannel*/                     //Now that it is sane, get it into the list. -OBSOLETE
					news_network.network_channels += newChannel                        //Adding channel to the global network
					src.screen=5
			src.updateUsrDialog()
			//src.update_icon()

		else if(href_list["set_channel_receiving"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the receiving channel"))
				usr << "\red You can't do that."
				return
			//var/list/datum/feed_channel/available_channels = list()
			var/list/available_channels = list()
			for(var/datum/feed_channel/F in news_network.network_channels)
				if( (!F.locked || F.author == scanned_user) && !F.censored)
					available_channels += F.channel_name
			src.channel_name = strip_html_simple(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
			src.updateUsrDialog()

		else if(href_list["set_new_message"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"set the message of a new feed story"))
				usr << "\red You can't do that."
				return
			if(isnull(src.msg))
				src.msg = ""
			src.msg = strip_html(input(usr, "Write your Feed story", "Network Channel Handler", src.msg))
			while (findtext(src.msg," ") == 1)
				src.msg = copytext(src.msg,2,length(src.msg)+1)
			src.updateUsrDialog()

		else if(href_list["set_attachment"])
			if(isobserver(usr))
				usr << "\red You can't do that."
				return
			AttachPhoto(usr)
			src.updateUsrDialog()

		else if(href_list["submit_new_message"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"added a new story"))
				usr << "\red You can't do that."
				return
			if(src.msg =="" || src.msg=="\[REDACTED\]" || src.scanned_user == "Unknown" || src.channel_name == "" )
				src.screen=6
			else
				var/datum/feed_message/newMsg = new /datum/feed_message
				newMsg.author = src.scanned_user
				newMsg.body = src.msg
				if(photo)
					newMsg.img = photo.img
				feedback_inc("newscaster_stories",1)
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == src.channel_name)
						FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
						break
				src.screen=4
				for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
					NEWSCASTER.newsAlert(src.channel_name)

			src.updateUsrDialog()

		else if(href_list["create_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a channel"))
				usr << "\red You can't do that."
				return
			src.screen=2
			src.updateUsrDialog()

		else if(href_list["create_feed_story"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"created a feed story"))
				usr << "\red You can't do that."
				return
			src.screen=3
			src.updateUsrDialog()

		else if(href_list["menu_paper"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				usr << "\red You can't do that."
				return
			src.screen=8
			src.updateUsrDialog()
		else if(href_list["print_paper"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"printed a paper"))
				usr << "\red You can't do that."
				return
			if(!src.paper_remaining)
				src.screen=21
			else
				src.print_paper()
				src.screen = 20
			src.updateUsrDialog()

		else if(href_list["menu_censor_story"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"censored a story"))
				usr << "\red You can't do that."
				return
			src.screen=10
			src.updateUsrDialog()

		else if(href_list["menu_censor_channel"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"censored a channel"))
				usr << "\red You can't do that."
				return
			src.screen=11
			src.updateUsrDialog()

		else if(href_list["menu_wanted"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				usr << "\red You can't do that."
				return
			var/already_wanted = 0
			if(news_network.wanted_issue)
				already_wanted = 1

			if(already_wanted)
				src.channel_name = news_network.wanted_issue.author
				src.msg = news_network.wanted_issue.body
			src.screen = 14
			src.updateUsrDialog()

		else if(href_list["set_wanted_name"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the name of a wanted person"))
				usr << "\red You can't do that."
				return
			src.channel_name = strip_html(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
			while (findtext(src.channel_name," ") == 1)
				src.channel_name = copytext(src.channel_name,2,length(src.channel_name)+1)
			src.updateUsrDialog()

		else if(href_list["set_wanted_desc"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set the description of a wanted person"))
				usr << "\red You can't do that."
				return
			src.msg = strip_html(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
			while (findtext(src.msg," ") == 1)
				src.msg = copytext(src.msg,2,length(src.msg)+1)
			src.updateUsrDialog()

		else if(href_list["submit_wanted"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"submitted a wanted poster"))
				usr << "\red You can't do that."
				return
			var/input_param = text2num(href_list["submit_wanted"])
			if(src.msg == "" || src.channel_name == "" || src.scanned_user == "Unknown")
				src.screen = 16
			else
				var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
				if(choice=="Confirm")
					if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
						var/datum/feed_message/WANTED = new /datum/feed_message
						WANTED.author = src.channel_name
						WANTED.body = src.msg
						WANTED.backup_author = src.scanned_user //I know, a bit wacky
						if(photo)
							WANTED.img = photo.img
						news_network.wanted_issue = WANTED
						for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
							NEWSCASTER.newsAlert()
							NEWSCASTER.update_icon()
						src.screen = 15
					else
						if(news_network.wanted_issue.is_admin_message)
							alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.","Ok")
							return
						news_network.wanted_issue.author = src.channel_name
						news_network.wanted_issue.body = src.msg
						news_network.wanted_issue.backup_author = src.scanned_user
						if(photo)
							news_network.wanted_issue.img = photo.img
						src.screen = 19

			src.updateUsrDialog()

		else if(href_list["cancel_wanted"])
			if(news_network.wanted_issue.is_admin_message)
				alert("The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.","Ok")
				return
			var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				news_network.wanted_issue = null
				for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
					NEWSCASTER.update_icon()
				src.screen=17
			src.updateUsrDialog()

		else if(href_list["view_wanted"])
			src.screen=18
			src.updateUsrDialog()
		else if(href_list["censor_channel_author"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor an author"))
				usr << "\red You can't do that."
				return
			var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(FC.author != "<B>\[REDACTED\]</B>")
				FC.backup_author = FC.author
				FC.author = "<B>\[REDACTED\]</B>"
			else
				FC.author = FC.backup_author
			src.updateUsrDialog()

		else if(href_list["censor_channel_story_author"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor a story's author"))
				usr << "\red You can't do that."
				return
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_author"])
			if(MSG.is_admin_message)
				alert("This message was created by a Nanotrasen Officer. You cannot censor its author.","Ok")
				return
			if(MSG.author != "<B>\[REDACTED\]</B>")
				MSG.backup_author = MSG.author
				MSG.author = "<B>\[REDACTED\]</B>"
			else
				MSG.author = MSG.backup_author
			src.updateUsrDialog()

		else if(href_list["censor_channel_story_body"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to censor a story"))
				usr << "\red You can't do that."
				return
			var/datum/feed_message/MSG = locate(href_list["censor_channel_story_body"])
			if(MSG.is_admin_message)
				alert("This channel was created by a Nanotrasen Officer. You cannot censor it.","Ok")
				return
			if(MSG.img != null)
				MSG.backup_img = MSG.img
				MSG.img = null
			else
				MSG.img = MSG.backup_img
			if(MSG.body != "<B>\[REDACTED\]</B>")
				MSG.backup_body = MSG.body
				MSG.body = "<B>\[REDACTED\]</B>"
			else
				MSG.body = MSG.backup_body
			src.updateUsrDialog()

		else if(href_list["pick_d_notice"])
			if(isobserver(usr) && !canGhostWrite(usr,src,""))
				usr << "\red You can't do that."
				return
			var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
			src.viewing_channel = FC
			src.screen=13
			src.updateUsrDialog()

		else if(href_list["toggle_d_notice"])
			if(isobserver(usr) && !canGhostWrite(usr,src,"tried to set a D-notice"))
				usr << "\red You can't do that."
				return
			var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
			if(FC.is_admin_channel)
				alert("This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.","Ok")
				return
			FC.censored = !FC.censored
			src.updateUsrDialog()

		else if(href_list["view"])
			src.screen=1
			src.updateUsrDialog()

		else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
			src.screen = text2num(href_list["setScreen"])
			if (src.screen == 0)
				src.scanned_user = "Unknown";
				msg = "";
				src.c_locked=0;
				channel_name="";
				src.viewing_channel = null
			src.updateUsrDialog()

		else if(href_list["show_channel"])
			var/datum/feed_channel/FC = locate(href_list["show_channel"])
			src.viewing_channel = FC
			src.screen = 9
			src.updateUsrDialog()

		else if(href_list["pick_censor_channel"])
			var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
			src.viewing_channel = FC
			src.screen = 12
			src.updateUsrDialog()

		else if(href_list["refresh"])
			src.updateUsrDialog()


/obj/machinery/newscaster/attackby(obj/item/I as obj, mob/user as mob)

/*	if (istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda) ) //Name verification for channels or messages
		if(src.screen == 4 || src.screen == 5)
			if( istype(I, /obj/item/device/pda) )
				var/obj/item/device/pda/P = I
				if(P.id)
					src.scanned_user = "[P.id.registered_name] ([P.id.assignment])"
					src.screen=2
			else
				var/obj/item/weapon/card/id/T = I
				src.scanned_user = text("[T.registered_name] ([T.assignment])")
				src.screen=2*/  //Obsolete after autorecognition

	if ((src.isbroken) && (istype(I, /obj/item/stack/sheet/glass)))
		var/obj/item/stack/sheet/glass/stack = I
		if ((stack.amount - 2) < 0)
			user << "\red You need more glass to do that."
		else
			stack.use(2)
			src.hitstaken = 0
			src.isbroken = 0
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 80, 1)

	else if (src.isbroken)
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 100, 1)
		for (var/mob/O in hearers(5, src.loc))
			O.show_message("<EM>[user.name]</EM> further abuses the shattered [src.name].")

	else
		if(istype(I, /obj/item/weapon) )
			var/obj/item/weapon/W = I
			if(W.force <15)
				for (var/mob/O in hearers(5, src.loc))
					O.show_message("[user.name] hits the [src.name] with the [W.name] with no visible effect." )
					playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 100, 1)
			else
				src.hitstaken++
				if(src.hitstaken==3)
					for (var/mob/O in hearers(5, src.loc))
						O.show_message("[user.name] smashes the [src.name]!" )
					src.isbroken=1
					playsound(get_turf(src), 'sound/effects/Glassbr3.ogg', 100, 1)
				else
					for (var/mob/O in hearers(5, src.loc))
						O.show_message("[user.name] forcefully slams the [src.name] with the [I.name]!" )
					playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 100, 1)
		else
			user << "<FONT COLOR='blue'>This does nothing.</FONT>"
	src.update_icon()

/obj/machinery/newscaster/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user) //or maybe it'll have some special functions? No idea.


/obj/machinery/newscaster/attack_paw(mob/user as mob)
	user << "<font color='blue'>The newscaster controls are far too complicated for your tiny brain!</font>"
	return

/obj/machinery/newscaster/proc/AttachPhoto(mob/user as mob)
	if(photo)
		photo.loc = src.loc
		user.put_in_inactive_hand(photo)
		photo = null
	if(istype(user.get_active_hand(), /obj/item/weapon/photo))
		photo = user.get_active_hand()
		user.drop_item()
		photo.loc = src





//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

/obj/item/weapon/newspaper
	name = "newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = 2	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble=""
	var/scribble_page = null

/*obj/item/weapon/newspaper/attack_hand(mob/user as mob)
	..()
	world << "derp"*/

obj/item/weapon/newspaper/attack_self(mob/user as mob)
	if(ishuman(user))
		//var/mob/living/carbon/human/human_user = user
		var/dat
		src.pages = 0
		switch(screen)
			if(0) //Cover

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:806: dat+="<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>"
				dat += {"<DIV ALIGN='center'><B><FONT SIZE=6>The Griffon</FONT></B></div>
					<DIV ALIGN='center'><FONT SIZE=2>Nanotrasen-standard newspaper, for use on Nanotrasen© Space Facilities</FONT></div><HR>"}
				// END AUTOFIX
				if(isemptylist(src.news_content))
					if(src.important_message)
						dat+="Contents:<BR><ul><B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [src.pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>Other than the title, the rest of the newspaper is unprinted...</I>"
				else
					dat+="Contents:<BR><ul>"
					for(var/datum/feed_channel/NP in src.news_content)
						src.pages++
					if(src.important_message)
						dat+="<B><FONT COLOR='red'>**</FONT>Important Security Announcement<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[page [src.pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in src.news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[page [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV> <div style='float:left;'><A href='?src=\ref[usr];mach_close=newspaper_main'>Done reading</A></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++ //Let's get it right again.
				var/datum/feed_channel/C = src.news_content[src.curr_page]
				dat+="<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[created by: <FONT COLOR='maroon'>[C.author]</FONT>\]</FONT><BR><BR>"
				if(C.censored)
					dat+="This channel was deemed dangerous to the general welfare of the station and therefore marked with a <B><FONT COLOR='red'>D-Notice</B></FONT>. Its contents were not transferred to the newspaper at the time of printing."
				else
					if(isemptylist(C.messages))
						dat+="No Feed stories stem from this channel..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV>"
			if(2) //Last page
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++
				if(src.important_message!=null)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\newscaster.dm:855: dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>"
					dat += {"<DIV STYLE='float:center;'><FONT SIZE=4><B>Wanted Issue:</B></FONT SIZE></DIV><BR><BR>
						<B>Criminal name</B>: <FONT COLOR='maroon'>[important_message.author]</FONT><BR>
						<B>Description</B>: [important_message.body]<BR>
						<B>Photo:</B>: "}
					// END AUTOFIX
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="None"
				else
					dat+="<I>Apart from some uninteresting Classified ads, there's nothing on this page...</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>There is a small scribble near the end of this page... It reads: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			else
				dat+="I'm sorry to break your immersion. This shit's bugged. Report this bug to Agouri, polyxenitopalidou@gmail.com"

		dat+="<BR><HR><div align='center'>[src.curr_page+1]</div>"
		usr << browse(dat, "window=newspaper_main;size=300x400")
		onclose(usr, "newspaper_main")
	else
		user << "The paper is full of intelligible symbols!"


obj/item/weapon/newspaper/Topic(href, href_list)
	var/mob/U = usr
	//..() // Allow ghosts to do pretty much everything except add shit
	if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==src.pages+1)
				return //Don't need that at all, but anyway.
			if(src.curr_page == src.pages) //We're at the middle, get to the end
				src.screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					src.screen=1
			src.curr_page++
			playsound(get_turf(src), "pageturn", 50, 1)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				src.screen = 0

			else
				if(curr_page == src.pages+1) //we're at the end, let's go back to the middle.
					src.screen = 1
			src.curr_page--
			playsound(get_turf(src), "pageturn", 50, 1)

		if (istype(src.loc, /mob))
			src.attack_self(src.loc)


obj/item/weapon/newspaper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pen))
		if(src.scribble_page == src.curr_page)
			user << "<FONT COLOR='blue'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</FONT>"
		else
			var/s = strip_html( input(user, "Write something", "Newspaper", "") )
			s = copytext(sanitize(s), 1, MAX_MESSAGE_LEN)
			if (!s)
				return
			if (!in_range(src, usr) && src.loc != usr)
				return
			src.scribble_page = src.curr_page
			src.scribble = s
			src.attack_self(user)
		return


////////////////////////////////////helper procs


/obj/machinery/newscaster/proc/scan_user(mob/user)
	if(masterController)
		if(masterController != user)
			if(get_dist(masterController,src)<=1)
				if(!isobserver(masterController))
					user << "\red Wait for [masterController] to finish and move away."
					return
	if(istype(user,/mob/living/carbon/human))                       //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/device/pda) )	//autorecognition, woo!
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					src.scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					src.scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				src.scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				src.scanned_user ="Unknown"
		else
			src.scanned_user ="Unknown"
	else if (isAI(user))
		var/mob/living/silicon/ai_user = user
		src.scanned_user = "[ai_user.name] ([ai_user.job])"
	else if (isAdminGhost(user))
		src.scanned_user = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	else if (isobserver(user))
		src.scanned_user = "Space-Time Anomaly #[rand(0,9)][rand(0,9)][rand(0,9)]"
//	if(masterController && masterController.client && get_dist(masterController,src)<=1)
//		masterController << "\red You were booted from \the [src] by [scanned_user]."
	masterController = user
//	masterController << "\icon[src] \blue Welcome back, [scanned_user]!"

/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/weapon/newspaper/NEWSPAPER = new /obj/item/weapon/newspaper
	for(var/datum/feed_channel/FC in news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(news_network.wanted_issue)
		NEWSPAPER.important_message = news_network.wanted_issue
	NEWSPAPER.loc = get_turf(src)
	src.paper_remaining--
	return

//Removed for now so these aren't even checked every tick. Left this here in-case Agouri needs it later.
///obj/machinery/newscaster/process()       //Was thinking of doing the icon update through process, but multiple iterations per second does not
//	return                                  //bode well with a newscaster network of 10+ machines. Let's just return it, as it's added in the machines list.

/obj/machinery/newscaster/proc/newsAlert(channel)   //This isn't Agouri's work, for it is ugly and vile.
	var/turf/T = get_turf(src)                      //Who the fuck uses spawn(600) anyway, jesus christ
	if(channel)
		for(var/mob/O in hearers(world.view-1, T))
			O.show_message("<span class='newscaster'><EM>[src.name]</EM> beeps, \"Breaking news from [channel]!\"</span>",2)
		src.alert = 1
		src.update_icon()
		spawn(300)
			src.alert = 0
			src.update_icon()
		playsound(get_turf(src), 'sound/machines/twobeep.ogg', 75, 1)
	else
		for(var/mob/O in hearers(world.view-1, T))
			O.show_message("<span class='newscaster'><EM>[src.name]</EM> beeps, \"Attention! Wanted issue distributed!\"</span>",2)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 75, 1)
	return
