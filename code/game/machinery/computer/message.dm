
// Allows you to monitor messages that passes the server.




/obj/machinery/computer/message_monitor
	name = "Message Monitor Console"
	desc = "Used to Monitor the crew's messages, that are sent via PDA. Can also be used to view Request Console messages."
	icon_state = "comm_logs"
	var/hack_icon = "comm_logsc"
	var/normal_icon = "comm_logs"
	circuit = "/obj/item/weapon/circuitboard/message_monitor"
	//Server linked to.
	var/obj/machinery/message_server/linkedServer = null
	//Sparks effect - For emag
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	//Messages - Saves me time if I want to change something.
	var/noserver = "<span class='alert'>ALERT: No server detected.</span>"
	var/incorrectkey = "<span class='warning'>ALERT: Incorrect decryption key!</span>"
	var/defaultmsg = "<span class='notice'>Welcome. Please select an option.</span>"
	var/rebootmsg = "<span class='warning'>%$&(£: Critical %$$@ Error // !RestArting! <lOadiNg backUp iNput ouTput> - ?pLeaSe wAit!</span>"
	//Computer properties
	var/screen = 0 		// 0 = Main menu, 1 = Message Logs, 2 = Hacked screen, 3 = Custom Message
	var/hacking = 0		// Is it being hacked into by the AI/Cyborg
	var/emag = 0		// When it is emagged.
	var/message = "<span class='notice'>System bootup complete. Please select an option.</span>"	// The message that shows on the main menu.
	var/auth = 0 // Are they authenticated?
	var/optioncount = 7
	// Custom Message Properties
	var/customsender = "System Administrator"
	var/obj/item/device/pda/customrecepient = null
	var/customjob		= "Admin"
	var/custommessage 	= "This is a test, please ignore."


/obj/machinery/computer/message_monitor/attackby(obj/item/weapon/O as obj, mob/living/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!istype(user))
		return
	if(istype(O,/obj/item/weapon/card/emag/))
		// Will create sparks and print out the console's password. You will then have to wait a while for the console to be back online.
		// It'll take more time if there's more characters in the password..
		if(!emag)
			if(!isnull(src.linkedServer))
				icon_state = hack_icon // An error screen I made in the computers.dmi
				emag = 1
				screen = 2
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				var/obj/item/weapon/paper/monitorkey/MK = new/obj/item/weapon/paper/monitorkey
				MK.loc = src.loc
				// Will help make emagging the console not so easy to get away with.
				MK.info += "<br><br><font color='red'>£%@%(*$%&(£&?*(%&£/{}</font>"
				spawn(100*length(src.linkedServer.decryptkey)) UnmagConsole()
				message = rebootmsg
			else
				user << "<span class='notice'>A no server error appears on the screen.</span>"
	if(isscrewdriver(O) && emag)
		//Stops people from just unscrewing the monitor and putting it back to get the console working again.
		user << "<span class='warning'>It is too hot to mess with!</span>"
		return

	..()
	return

/obj/machinery/computer/message_monitor/power_change()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(emag || hacking)
		icon_state = hack_icon
	else
		icon_state = normal_icon

/obj/machinery/computer/message_monitor/process()
	//Is the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer)
		if(message_servers && message_servers.len > 0)
			linkedServer = message_servers[1]
	return

/obj/machinery/computer/message_monitor/attack_hand(var/mob/living/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!istype(user))
		return
	//If the computer is being hacked or is emagged, display the reboot message.
	if(hacking || emag)
		message = rebootmsg
	var/dat = "<head><title>Message Monitor Console</title></head><body>"
	dat += "<center><h2>Message Monitor Console</h2></center><hr>"
	dat += "<center><h4><font color='blue'[message]</h5></center>"

	if(auth)
		dat += "<h4><dd><A href='?src=\ref[src];auth=1'>&#09;<font color='green'>\[Authenticated\]</font></a>&#09;/"
		dat += " Server Power: <A href='?src=\ref[src];active=1'>[src.linkedServer && src.linkedServer.active ? "<font color='green'>\[On\]</font>":"<font color='red'>\[Off\]</font>"]</a></h4>"
	else
		dat += "<h4><dd><A href='?src=\ref[src];auth=1'>&#09;<font color='red'>\[Unauthenticated\]</font></a>&#09;/"
		dat += " Server Power: <u>[src.linkedServer && src.linkedServer.active ? "<font color='green'>\[On\]</font>":"<font color='red'>\[Off\]</font>"]</u></h4>"

	if(hacking || emag)
		screen = 2
	else if(!auth || !linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
		if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN))) message = noserver
		screen = 0

	switch(screen)
		//Main menu
		if(0)
			//&#09; = TAB
			var/i = 0
			dat += "<dd><A href='?src=\ref[src];find=1'>&#09;[++i]. Link To A Server</a></dd>"
			if(auth)
				if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
					dat += "<dd><A>&#09;ERROR: Server not found!</A><br></dd>"
				else
					dat += "<dd><A href='?src=\ref[src];view=1'>&#09;[++i]. View Message Logs </a><br></dd>"
					dat += "<dd><A href='?src=\ref[src];viewr=1'>&#09;[++i]. View Request Console Logs </a></br></dd>"
					dat += "<dd><A href='?src=\ref[src];clear=1'>&#09;[++i]. Clear Message Logs</a><br></dd>"
					dat += "<dd><A href='?src=\ref[src];clearr=1'>&#09;[++i]. Clear Request Console Logs</a><br></dd>"
					dat += "<dd><A href='?src=\ref[src];pass=1'>&#09;[++i]. Set Custom Key</a><br></dd>"
					dat += "<dd><A href='?src=\ref[src];msg=1'>&#09;[++i]. Send Admin Message</a><br></dd>"
			else
				for(var/n = ++i; n <= optioncount; n++)
					dat += "<dd><font color='blue'>&#09;[n]. ---------------</font><br></dd>"
			if((istype(user, /mob/living/silicon/ai) || istype(user, /mob/living/silicon/robot)) && (user.mind.special_role && user.mind.original == user))
				//Malf/Traitor AIs can bruteforce into the system to gain the Key.
				dat += "<dd><A href='?src=\ref[src];hack=1'><i><font color='Red'>*&@#. Bruteforce Key</font></i></font></a><br></dd>"
			else
				dat += "<br>"

			//Bottom message
			if(!auth)
				dat += "<br><hr><dd><span class='notice'>Please authenticate with the server in order to show additional options.</span>"
			else
				dat += "<br><hr><dd><span class='warning'>Reg, #514 forbids sending messages to a Head of Staff containing Erotic Rendering Properties.</span>"

		//Message Logs
		if(1)
			var/index = 0
			//var/recipient = "Unspecified" //name of the person
			//var/sender = "Unspecified" //name of the sender
			//var/message = "Blank" //transferred message
			dat += "<center><A href='?src=\ref[src];back=1'>Back</a> - <A href='?src=\ref[src];refresh=1'>Refresh</center><hr>"
			dat += "<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sender</th><th width='15%'>Recipient</th><th width='300px' word-wrap: break-word>Message</th></tr>"
			for(var/datum/data_pda_msg/pda in src.linkedServer.pda_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += "<tr><td width = '5%'><center><A href='?src=\ref[src];delete=\ref[pda]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[pda.sender]</td><td width='15%'>[pda.recipient]</td><td width='300px'>[pda.message]</td></tr>"
			dat += "</table>"
		//Hacking screen.
		if(2)
			if(istype(user, /mob/living/silicon/ai) || istype(user, /mob/living/silicon/robot))
				dat += "Brute-forcing for server key.<br> It will take 20 seconds for every character that the password has."
				dat += "In the meantime, this console can reveal your true intentions if you let someone access it. Make sure no humans enter the room during that time."
			else
				//It's the same message as the one above but in binary. Because robots understand binary and humans don't... well I thought it was clever.
				dat += {"01000010011100100111010101110100011001010010110<br>
				10110011001101111011100100110001101101001011011100110011<br>
				10010000001100110011011110111001000100000011100110110010<br>
				10111001001110110011001010111001000100000011010110110010<br>
				10111100100101110001000000100100101110100001000000111011<br>
				10110100101101100011011000010000001110100011000010110101<br>
				10110010100100000001100100011000000100000011100110110010<br>
				10110001101101111011011100110010001110011001000000110011<br>
				00110111101110010001000000110010101110110011001010111001<br>
				00111100100100000011000110110100001100001011100100110000<br>
				10110001101110100011001010111001000100000011101000110100<br>
				00110000101110100001000000111010001101000011001010010000<br>
				00111000001100001011100110111001101110111011011110111001<br>
				00110010000100000011010000110000101110011001011100010000<br>
				00100100101101110001000000111010001101000011001010010000<br>
				00110110101100101011000010110111001110100011010010110110<br>
				10110010100101100001000000111010001101000011010010111001<br>
				10010000001100011011011110110111001110011011011110110110<br>
				00110010100100000011000110110000101101110001000000111001<br>
				00110010101110110011001010110000101101100001000000111100<br>
				10110111101110101011100100010000001110100011100100111010<br>
				10110010100100000011010010110111001110100011001010110111<br>
				00111010001101001011011110110111001110011001000000110100<br>
				10110011000100000011110010110111101110101001000000110110<br>
				00110010101110100001000000111001101101111011011010110010<br>
				10110111101101110011001010010000001100001011000110110001<br>
				10110010101110011011100110010000001101001011101000010111<br>
				00010000001001101011000010110101101100101001000000111001<br>
				10111010101110010011001010010000001101110011011110010000<br>
				00110100001110101011011010110000101101110011100110010000<br>
				00110010101101110011101000110010101110010001000000111010<br>
				00110100001100101001000000111001001101111011011110110110<br>
				10010000001100100011101010111001001101001011011100110011<br>
				10010000001110100011010000110000101110100001000000111010<br>
				001101001011011010110010100101110"}

		//Fake messages
		if(3)
			dat += "<center><A href='?src=\ref[src];back=1'>Back</a> - <A href='?src=\ref[src];Reset=1'>Reset</a></center><hr>"

			dat += {"<table border='1' width='100%'>
					<tr><td width='20%'><A href='?src=\ref[src];select=Sender'>Sender</a></td>
					<td width='20%'><A href='?src=\ref[src];select=RecJob'>Sender's Job</a></td>
					<td width='20%'><A href='?src=\ref[src];select=Recepient'>Recipient</a></td>
					<td width='300px' word-wrap: break-word><A href='?src=\ref[src];select=Message'>Message</a></td></tr>"}
				//Sender  - Sender's Job  - Recepient - Message
				//Al Green- Your Dad	  - Your Mom  - WHAT UP!?

			dat += {"<tr><td width='20%'>[customsender]</td>
			<td width='20%'>[customjob]</td>
			<td width='20%'>[customrecepient ? customrecepient.owner : "NONE"]</td>
			<td width='300px'>[custommessage]</td></tr>"}
			dat += "</table><br><center><A href='?src=\ref[src];select=Send'>Send</a>"

		//Request Console Logs
		if(4)

			var/index = 0
			/* 	data_rc_msg
				X												 - 5%
				var/rec_dpt = "Unspecified" //name of the person - 15%
				var/send_dpt = "Unspecified" //name of the sender- 15%
				var/message = "Blank" //transferred message		 - 300px
				var/stamp = "Unstamped"							 - 15%
				var/id_auth = "Unauthenticated"					 - 15%
				var/priority = "Normal"							 - 10%
			*/
			dat += "<center><A href='?src=\ref[src];back=1'>Back</a> - <A href='?src=\ref[src];refresh=1'>Refresh</center><hr>"
			dat += {"<table border='1' width='100%'><tr><th width = '5%'>X</th><th width='15%'>Sending Dep.</th><th width='15%'>Receiving Dep.</th>
			<th width='300px' word-wrap: break-word>Message</th><th width='15%'>Stamp</th><th width='15%'>ID Auth.</th><th width='15%'>Priority.</th></tr>"}
			for(var/datum/data_rc_msg/rc in src.linkedServer.rc_msgs)
				index++
				if(index > 3000)
					break
				// Del - Sender   - Recepient - Message
				// X   - Al Green - Your Mom  - WHAT UP!?
				dat += {"<tr><td width = '5%'><center><A href='?src=\ref[src];deleter=\ref[rc]' style='color: rgb(255,0,0)'>X</a></center></td><td width='15%'>[rc.send_dpt]</td>
				<td width='15%'>[rc.rec_dpt]</td><td width='300px'>[rc.message]</td><td width='15%'>[rc.stamp]</td><td width='15%'>[rc.id_auth]</td><td width='15%'>[rc.priority]</td></tr>"}
			dat += "</table>"


	dat += "</body>"
	message = defaultmsg
	user << browse(dat, "window=message;size=700x700")
	onclose(user, "message")
	return

/obj/machinery/computer/message_monitor/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user as mob)
	if(isnull(linkedServer))
		user << "<span class='warning'>Could not complete brute-force: Linked Server Disconnected!</span>"
	else
		var/currentKey = src.linkedServer.decryptkey
		user << "<span class='warning'>Brute-force completed! The key is '[currentKey]'.</span>"
	src.hacking = 0
	src.icon_state = normal_icon
	src.screen = 0 // Return the screen back to normal

/obj/machinery/computer/message_monitor/proc/UnmagConsole()
	src.icon_state = normal_icon
	src.emag = 0

/obj/machinery/computer/message_monitor/proc/ResetMessage()
	customsender 	= "System Administrator"
	customrecepient = null
	custommessage 	= "This is a test, please ignore."
	customjob 		= "Admin"

/obj/machinery/computer/message_monitor/Topic(href, href_list)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!istype(usr, /mob/living))
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		//Authenticate
		if (href_list["auth"])
			if(auth)
				auth = 0
				screen = 0
			else
				var/dkey = trim(input(usr, "Please enter the decryption key.") as text|null)
				if(dkey && dkey != "")
					if(src.linkedServer.decryptkey == dkey)
						auth = 1
					else
						message = incorrectkey

		//Turn the server on/off.
		if (href_list["active"])
			if(auth) linkedServer.active = !linkedServer.active
		//Find a server
		if (href_list["find"])
			if(message_servers && message_servers.len > 1)
				src.linkedServer = input(usr,"Please select a server.", "Select a server.", null) as null|anything in message_servers
				message = "<span class='alert'>NOTICE: Server selected.</span>"
			else if(message_servers && message_servers.len > 0)
				linkedServer = message_servers[1]
				message =  "<span class='notice'>NOTICE: Only Single Server Detected - Server selected.</span>"
			else
				message = noserver

		//View the logs - KEY REQUIRED
		if (href_list["view"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 1

		//Clears the logs - KEY REQUIRED
		if (href_list["clear"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.linkedServer.pda_msgs = list()
					message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Clears the request console logs - KEY REQUIRED
		if (href_list["clearr"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.linkedServer.rc_msgs = list()
					message = "<span class='notice'>NOTICE: Logs cleared.</span>"
		//Change the password - KEY REQUIRED
		if (href_list["pass"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					var/dkey = trim(input(usr, "Please enter the decryption key.") as text|null)
					if(dkey && dkey != "")
						if(src.linkedServer.decryptkey == dkey)
							var/newkey = trim(input(usr,"Please enter the new key (3 - 16 characters max):"))
							if(length(newkey) <= 3)
								message = "<span class='notice'>NOTICE: Decryption key too short!</span>"
							else if(length(newkey) > 16)
								message = "<span class='notice'>NOTICE: Decryption key too long!</span>"
							else if(newkey && newkey != "")
								src.linkedServer.decryptkey = newkey
							message = "<span class='notice'>NOTICE: Decryption key set.</span>"
						else
							message = incorrectkey

		//Hack the Console to get the password
		if (href_list["hack"])
			if((istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot)) && (usr.mind.special_role && usr.mind.original == usr))
				src.hacking = 1
				src.screen = 2
				src.icon_state = hack_icon
				//Time it takes to bruteforce is dependant on the password length.
				spawn(100*length(src.linkedServer.decryptkey))
					if(src && src.linkedServer && usr)
						BruteForce(usr)
		//Delete the log.
		if (href_list["delete"])
			//Are they on the view logs screen?
			if(screen == 1)
				if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
					message = noserver
				else //if(istype(href_list["delete"], /datum/data_pda_msg))
					src.linkedServer.pda_msgs -= locate(href_list["delete"])
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Delete the request console log.
		if (href_list["deleter"])
			//Are they on the view logs screen?
			if(screen == 4)
				if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
					message = noserver
				else //if(istype(href_list["delete"], /datum/data_pda_msg))
					src.linkedServer.rc_msgs -= locate(href_list["deleter"])
					message = "<span class='notice'>NOTICE: Log Deleted!</span>"
		//Create a custom message
		if (href_list["msg"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 3
		//Fake messaging selection - KEY REQUIRED
		if (href_list["select"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
				screen = 0
			else
				switch(href_list["select"])

					//Reset
					if("Reset")
						ResetMessage()

					//Select Your Name
					if("Sender")
						customsender 	= input(usr, "Please enter the sender's name.") as text|null

					//Select Receiver
					if("Recepient")
						//Get out list of viable PDAs
						var/list/obj/item/device/pda/sendPDAs = list()
						for(var/obj/item/device/pda/P in PDAs)
							if(!P.owner || P.toff) continue
							sendPDAs += P
						if(PDAs && PDAs.len > 0)
							customrecepient = input(usr, "Select a PDA from the list.") as null|anything in sortAtom(sendPDAs)
						else
							customrecepient = null

					//Enter custom job
					if("RecJob")
						customjob	 	= input(usr, "Please enter the sender's job.") as text|null

					//Enter message
					if("Message")
						custommessage	= input(usr, "Please enter your message.") as text|null
						custommessage	= copytext(sanitize(custommessage), 1, MAX_MESSAGE_LEN)

					//Send message
					if("Send")

						if(isnull(customsender) || customsender == "")
							customsender = "UNKNOWN"

						if(isnull(customrecepient))
							message = "<span class='notice'>NOTICE: No recepient selected!</span>"
							return src.attack_hand(usr)

						if(isnull(custommessage) || custommessage == "")
							message = "<span class='notice'>NOTICE: No message entered!</span>"
							return src.attack_hand(usr)

						var/obj/item/device/pda/PDARec = null
						for (var/obj/item/device/pda/P in PDAs)
							if (!P.owner||P.toff)	continue
							if(P.owner == customsender)
								PDARec = P
						//Sender isn't faking as someone who exists
						if(isnull(PDARec))
							src.linkedServer.send_pda_message("[customrecepient.owner]", "[customsender]","[custommessage]")
							customrecepient.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[customrecepient];choice=Message;target=\ref[src]'>[customsender]</a> ([customjob]):</b></i><br>[custommessage]<br>"
							if (!customrecepient.silent)
								playsound(customrecepient.loc, 'sound/machines/twobeep.ogg', 50, 1)
								for (var/mob/O in hearers(3, customrecepient.loc))
									O.show_message(text("\icon[customrecepient] *[customrecepient.ttone]*"))
								if( customrecepient.loc && ishuman(customrecepient.loc) )
									var/mob/living/carbon/human/H = customrecepient.loc
									H << "\icon[customrecepient] <b>Message from [customsender] ([customjob]), </b>\"[custommessage]\" (<a href='byond://?src=\ref[src];choice=Message;skiprefresh=1;target=\ref[src]'>Reply</a>)"
								log_pda("[usr] (PDA: [customsender]) sent \"[custommessage]\" to [customrecepient.owner]")
								customrecepient.overlays = null
								customrecepient.overlays += image('icons/obj/pda.dmi', "pda-r")
						//Sender is faking as someone who exists
						else
							src.linkedServer.send_pda_message("[customrecepient.owner]", "[PDARec.owner]","[custommessage]")
							customrecepient.tnote += "<i><b>&larr; From <a href='byond://?src=\ref[customrecepient];choice=Message;target=\ref[PDARec]'>[PDARec.owner]</a> ([customjob]):</b></i><br>[custommessage]<br>"
							if (!customrecepient.silent)
								playsound(customrecepient.loc, 'sound/machines/twobeep.ogg', 50, 1)
								for (var/mob/O in hearers(3, customrecepient.loc))
									O.show_message(text("\icon[customrecepient] *[customrecepient.ttone]*"))
								if( customrecepient.loc && ishuman(customrecepient.loc) )
									var/mob/living/carbon/human/H = customrecepient.loc
									H << "\icon[customrecepient] <b>Message from [PDARec.owner] ([customjob]), </b>\"[custommessage]\" (<a href='byond://?src=\ref[customrecepient];choice=Message;skiprefresh=1;target=\ref[PDARec]'>Reply</a>)"
								log_pda("[usr] (PDA: [PDARec.owner]) sent \"[custommessage]\" to [customrecepient.owner]")
								customrecepient.overlays = null
								customrecepient.overlays += image('icons/obj/pda.dmi', "pda-r")
						//Finally..
						ResetMessage()

		//Request Console Logs - KEY REQUIRED
		if(href_list["viewr"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				message = noserver
			else
				if(auth)
					src.screen = 4

			//usr << href_list["select"]

		if (href_list["back"])
			src.screen = 0

	return src.attack_hand(usr)


/obj/item/weapon/paper/monitorkey
	//..()
	name = "Monitor Decryption Key"
	var/obj/machinery/message_server/server = null

/obj/item/weapon/paper/monitorkey/New()
	..()
	spawn(10)
		if(message_servers)
			for(var/obj/machinery/message_server/server in message_servers)
				if(!isnull(server))
					if(!isnull(server.decryptkey))
						info = "<center><h2>Daily Key Reset</h2></center><br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret.<br>If necessary, change the password to a more secure one."
						info_links = info
						overlays += "paper_words"
						break
