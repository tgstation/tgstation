/datum/computer_file/program/robocontrol
	filename = "robocontrol"
	filedesc = "Bot Remote Controller"
	program_icon_state = "robot"
	extended_desc = "A remote controller used for giving basic commands to non-sentient robots."
	requires_ntnet = TRUE
	network_destination = "robotics control network"
	size = 12
	tgui_id = "ntos_robocontrol"
	ui_x = 450
	ui_y = 350

	var/botcount = 0




/datum/computer_file/program/robocontrol/ui_data(mob/user)
	var/list/data = get_header_data()

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	if(..())
		return TRUE







	for(var/B in GLOB.bots_list) //Git da botz
		var/mob/living/simple_animal/bot/Bot = B




	if(active_bot)
		menu += "<B>[active_bot]</B><BR> Status: (<A href='byond://?src=[REF(src)];op=control;bot=[REF(active_bot)]'>[PDAIMG(refresh)]<i>refresh</i></A>)<BR>"
		menu += "Model: [active_bot.model]<BR>"
		menu += "Location: [get_area(active_bot)]<BR>"
		menu += "Mode: [active_bot.get_mode()]"
		if(active_bot.allow_pai)
			menu += "<BR>pAI: "
			if(active_bot.paicard && active_bot.paicard.pai)
				menu += "[active_bot.paicard.pai.name]"
				if(active_bot.bot_core.allowed(usr))
					menu += " (<A href='byond://?src=[REF(src)];op=ejectpai'><i>eject</i></A>)"
			else
				menu += "<i>none</i>"

		//MULEs!
		if(active_bot.bot_type == MULE_BOT)
			var/mob/living/simple_animal/bot/mulebot/MULE = active_bot
			var/atom/Load = MULE.load
			menu += "<BR>Current Load: [ !Load ? "<i>none</i>" : "[Load.name] (<A href='byond://?src=[REF(src)];mule=unload'><i>unload</i></A>)" ]<BR>"
			menu += "Destination: [MULE.destination ? MULE.destination : "<i>None</i>"] (<A href='byond://?src=[REF(src)];mule=destination'><i>set</i></A>)<BR>"
			menu += "Set ID: [MULE.suffix] <A href='byond://?src=[REF(src)];mule=setid'><i> Modify</i></A><BR>"
			menu += "Power: [MULE.cell ? MULE.cell.percent() : 0]%<BR>"
			menu += "Home: [!MULE.home_destination ? "<i>none</i>" : MULE.home_destination ]<BR>"
			menu += "Delivery Reporting: <A href='byond://?src=[REF(src)];mule=report'>[MULE.report_delivery ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR>"
			menu += "Auto Return Home: <A href='byond://?src=[REF(src)];mule=autoret'>[MULE.auto_return ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR>"
			menu += "Auto Pickup Crate: <A href='byond://?src=[REF(src)];mule=autopick'>[MULE.auto_pickup ? "(<B>On</B>)": "(<B>Off</B>)"]</A><BR><BR>" //Hue.

			menu += "\[<A href='byond://?src=[REF(src)];mule=stop'>Stop</A>\] "
			menu += "\[<A href='byond://?src=[REF(src)];mule=go'>Proceed</A>\] "
			menu += "\[<A href='byond://?src=[REF(src)];mule=home'>Return Home</A>\]<BR>"

		else
			menu += "<BR>\[<A href='byond://?src=[REF(src)];op=patroloff'>Stop Patrol</A>\] "	//patrolon
			menu += "\[<A href='byond://?src=[REF(src)];op=patrolon'>Start Patrol</A>\] "	//patroloff
			menu += "\[<A href='byond://?src=[REF(src)];op=summon'>Summon Bot</A>\]<BR>"		//summon
			menu += "Keep an ID inserted to upload access codes upon summoning."

		menu += "<HR><A href='byond://?src=[REF(src)];op=botlist'>[PDAIMG(back)]Return to bot list</A>"
	else
		menu += "<BR><A href='byond://?src=[REF(src)];op=botlist'>[PDAIMG(refresh)]Scan for active bots</A><BR><BR>"
		var/turf/current_turf = get_turf(src)
		var/zlevel = current_turf.z
		var/botcount = 0
		for(var/B in GLOB.bots_list) //Git da botz
			var/mob/living/simple_animal/bot/Bot = B
			if(!Bot.on || Bot.z != zlevel || Bot.remote_disabled || !(bot_access_flags & Bot.bot_type)) //Only non-emagged bots on the same Z-level are detected!
				continue //Also, the PDA must have access to the bot type.
			menu += "<A href='byond://?src=[REF(src)];op=control;bot=[REF(Bot)]'><b>[Bot.name]</b> ([Bot.get_mode()])<BR>"
			botcount++
		if(!botcount) //No bots at all? Lame.
			menu += "No bots found.<BR>"
			return

	return menu
