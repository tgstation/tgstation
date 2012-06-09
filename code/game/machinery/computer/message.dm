
// Allows you to monitor messages that passes the server.

/obj/machinery/computer/message_monitor
	name = "Message Monitor Console"
	desc = "Used to Monitor the crew's messages, that are sent via PDA."
	icon_state = "comm_monitor"
	circuit = "/obj/item/weapon/circuitboard/message_monitor"
	var/obj/machinery/message_server/linkedServer = null
	var/screen = 0 		// 0 = Main menu, 1 = Message Logs
	var/hacking = 0		// Is it being hacked into by the AI/Cyborg


/obj/machinery/computer/message_monitor/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/card/emag/))
		//Just brings up the Message Log without having to know the passcode.
		if(!hacking)
			usr << "<span class='warning'>BZZT.. The console beeps and brings up the Message Logs.</span>"
			screen = 1
		else
			usr << "<span class='notice'>It looks like the console is already being hacked into.</span>"
	..()
	return

/obj/machinery/computer/message_monitor/process()
	//Is the server isn't linked to a server, and there's a server available, default it to the first one in the list.
	if(!linkedServer)
		if(message_servers && message_servers.len > 0)
			linkedServer = message_servers[1]
	return

/obj/machinery/computer/message_monitor/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!istype(user, /mob/living))
		return
	var/dat = "<head><title>Message Monitor Console</title></head><body>"
	dat += "<center><h2>Message Monitor Console</h2></center><hr>"
	switch(screen)
		//Main menu
		if(0)
			if(hacking)
				screen = 2
				return src.attack_hand(user)
			if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
				dat += "1. ERROR: Server not found<br>"
			else
				dat += "<A href='?src=\ref[src];active=1'>1. Toggle Power: [src.linkedServer.active ? "<font color='green'>\[On\]</font>":"<font color='red'>\[Off\]</font>"]</a><br>"
			dat += "<A href='?src=\ref[src];find=1'>2. Link To A Server</a><br>"
			dat += "<A href='?src=\ref[src];clear=1'>3. Clear Message Logs</a><hr>"
			dat += "<font color='red'> KEY REQUIRED</font><br>"
			dat += "<A href='?src=\ref[src];view=1'>4. View Message Logs </a><br>"
			dat += "<A href='?src=\ref[src];pass=1'>5. Set Custom Key</a><hr><br>"
			//Malf/Traitor AIs can bruteforce into the system to gain the Key.
			if((istype(user, /mob/living/silicon/ai) || istype(user, /mob/living/silicon/robot)) && (user.mind.special_role && user.mind.original == user))
				dat += "<A href='?src=\ref[src];hack=1'><i><font color='Red'>*&@. Bruteforce Key</font></i></font></a><br>"
		//Message Logs
		if(1)
			if(hacking)
				screen = 2
				return src.attack_hand(user)
			if(!linkedServer || (linkedServer.stat & (NOPOWER|BROKEN)))
				usr << "<span class='notice'>No server detected.</span>"
				screen = 0
				return src.attack_hand(user)

			var/index = 0
			//var/recipient = "Unspecified" //name of the person
			//var/sender = "Unspecified" //name of the sender
			//var/message = "Blank" //transferred message
			dat += "<center><A href='?src=\ref[src];back=1'>Return</a> - <A href='?src=\ref[src];refresh=1'>Refresh</center><hr>"
			dat += "<table border='1' width='100%'><tr><th width='20%'>Sender</th><th width='20%'>Recipient</th><th width='300px' word-wrap: break-word>Message</th></tr>"
			for(var/list/datum/data_pda_msg/pda in src.linkedServer.pda_msgs)
				index++
				if(index > 3000)
					break
				dat += "<tr><td width='20%'>[pda.sender]</td><td width='20%'>[pda.recipient]</td><td width='80%'>[pda.message]</td></tr>"
			dat += "</table>"
		//Hacking screen.
		if(2)
			if(!hacking)
				screen = 0
				return src.attack_hand(user)
			if(istype(user, /mob/living/silicon/ai) || istype(user, /mob/living/silicon/robot))
				dat += "Brute-forcing for server key.<br> This will take anywhere from two to five minutes."
				dat += "In the meantime, this console can reveal your true intentions if you let someone access it. Make sure no humans enter the room during that time."
			else
				//It's the same message as the one above but in binary. Because robots understand binary and humans don't... well I thought it was clever.
				dat += {"010101000110100001101001011100110010000001110111011010010110110
				0011011000010000001110100011000010110101101100101001000000110000101101110
				01111001011101110110100001100101011100100110010100100000011001100111001001
				10111101101101001000000111010001110111011011110010000001110100011011110010
				00000110011001101001011101100110010100100000011011010110100101101110011101
				01011101000110010101110011001011100010000001001001011011100010000001110100
				01101000011001010010000001101101011001010110000101101110001011010111010001
				10100101101101011001010010110000100000011101000110100001101001011100110010
				00000110001101101111011011100111001101101111011011000110010100100000011000
				11011000010110111000100000011100100110010101110110011001010110000101101100
				00100000011110010110111101110101011100100010000001110100011100100111010101
				10010100100000011010010110111001110100011001010110111001110100011010010110
				11110110111001110011001000000110100101100110001000000111100101101111011101
				01001000000110110001100101011101000010000001110011011011110110110101100101
				01101111011011100110010100100000011000010110001101100011011001010111001101
				11001100100000011010010111010000101110001000000100110101100001011010110110
				01010010000001110011011101010111001001100101001000000110111001101111001000
				00011010000111010101101101011000010110111001110011001000000110010101101110
				01110100011001010111001000100000011101000110100001100101001000000111001001
				10111101101111011011010010000001100100011101010111001001101001011011100110
				01110010000001110100011010000110000101110100001000000111010001101001011011
				010110010100101110"}


	dat += "</body>"
	user << browse(dat, "window=message;size=500x700")
	onclose(user, "message")
	return

/obj/machinery/computer/message_monitor/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/message_monitor/proc/BruteForce(mob/user as mob)
	var/currentKey = src.linkedServer.decryptkey
	user << "<span class='warning'>Brute-force completed! The key is '[currentKey]'.</span>"
	src.hacking = 0
	src.screen = 0 // Return the screen back to normal

/obj/machinery/computer/message_monitor/Topic(href, href_list)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!istype(usr, /mob/living))
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))

		if (href_list["active"])
			linkedServer.active = !linkedServer.active

		if (href_list["find"])
			if(message_servers && message_servers.len > 1)
				src.linkedServer = input(usr,"Please select a server.", "Select a server.", null) as null|anything in message_servers
				usr << "Server selected.</span>"
			else if(message_servers && message_servers.len > 0)
				linkedServer = message_servers[1]
				usr << "<span class='notice'>Single Server Detected - Server selected.</span>"
			else
				usr << "<span class='notice'>No server detected.</span>"

		if (href_list["view"])
			if(src.linkedServer == null || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				usr << "<span class='notice'>No server detected.</span>"
			else
				var/dkey = trim(input(usr, "Please enter the decryption key.") as text|null)
				if(dkey && dkey != "")
					if(src.linkedServer.decryptkey == dkey)
						src.screen = 1
					else
						usr << "<span class='warning'>ALERT: Incorrect password!</span>"


		if (href_list["clear"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				usr << "<span class='notice'>No server detected.</span>"
			else
				src.linkedServer.pda_msgs = list()
				usr << "<span class='notice'>Logs cleared.</span>"

		if (href_list["pass"])
			if(!linkedServer || (src.linkedServer.stat & (NOPOWER|BROKEN)))
				usr << "<span class='notice'>No server detected.</span>"
			else
				var/dkey = trim(input(usr,"Please enter the decryption key.") as text|null)
				if(dkey && dkey != "")
					if(dkey == src.linkedServer.decryptkey)
						var/newkey = trim(input(usr,"Please enter the new key."))
						if(newkey && newkey != "")
							src.linkedServer.decryptkey = newkey
							usr << "<span class='notice'>Password set.</span>"
					else
						usr << "<span class='warning'>ALERT: Incorrect password!</span>"

		if (href_list["hack"])
			if((istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot)) && (usr.mind.special_role && usr.mind.original == usr))
				src.hacking = 1
				src.screen = 2
				//usr << "[src.linkedServer.decryptkey]"
				spawn((100*6)*rand(2, 4))
					if(src && src.linkedServer && usr)
						BruteForce(usr)


		if (href_list["back"])
			src.screen = 0

	return src.attack_hand(usr)


/obj/item/weapon/paper/monitorkey
	//..()
	name = "Monitor Decryption Key"
	var/obj/machinery/message_server/server = null

/obj/item/weapon/paper/monitorkey/New()
	..()
	if(message_servers && message_servers.len > 0)
		server = message_servers[1]
		info = "<center><h2>Daily Key Reset</h2></center><br>The new message monitor key is '[server.decryptkey]'.<br>Please keep this a secret and away from the clown.<br>If necessary, change the password to a more secure one."
		info_links = info
		overlays += "paper_words"