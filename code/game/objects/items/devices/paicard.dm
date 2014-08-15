/obj/item/device/paicard
	name = "personal AI device"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	origin_tech = "programming=2"
	var/obj/item/device/radio/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai

/obj/item/device/paicard/New()
	..()
	overlays += "pai-off"

/obj/item/device/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	if(!isnull(pai))
		pai.death(0)
	..()

/obj/item/device/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Personal AI Device</B><BR>"
	if(pai && (!pai.master_dna || !pai.master))
		dat += "<a href='byond://?src=\ref[src];setdna=1'>Imprint Master DNA</a><br>"
	if(pai)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\paicard.dm:32: dat += "Installed Personality: [pai.name]<br>"
		dat += {"Installed Personality: [pai.name]<br>
			Prime directive: <br>[pai.pai_law0]<br>
			Additional directives: <br>[pai.pai_laws]<br>
			<a href='byond://?src=\ref[src];setlaws=1'>Configure Directives</a><br>
			<br>
			<h3>Device Settings</h3><br>"}
		// END AUTOFIX
		if(radio)
			dat += "<b>Radio Uplink</b><br>"
			dat += "Transmit: <A href='byond://?src=\ref[src];wires=[WIRE_TRANSMIT]'>[(radio.wires.IsIndexCut(WIRE_TRANSMIT)) ? "Disabled" : "Enabled"]</A><br>"
			dat += "Receive: <A href='byond://?src=\ref[src];wires=[WIRE_RECEIVE]'>[(radio.wires.IsIndexCut(WIRE_RECEIVE)) ? "Disabled" : "Enabled"]</A><br>"
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\paicard.dm:44: dat += "<b>Radio Uplink</b><br>"
			dat += {"<b>Radio Uplink</b><br>
				<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"}
		// END AUTOFIX
		dat += "<A href='byond://?src=\ref[src];wipe=1'>\[Wipe current pAI personality\]</a><br>"
	else
		if(looking_for_personality)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\paicard.dm:49: dat += "Searching for a personality..."
			dat += {"Searching for a personality...
				<A href='byond://?src=\ref[src];request=1'>\[View available personalities\]</a><br>"}
			// END AUTOFIX
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\objects\items\devices\paicard.dm:52: dat += "No personality is installed.<br>"
			dat += {"No personality is installed.<br>
				<A href='byond://?src=\ref[src];request=1'>\[Request personal AI personality\]</a><br>
				Each time this button is pressed, a request will be sent out to any available personalities. Check back often and alot time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness."}
			// END AUTOFIX
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/device/paicard/Topic(href, href_list)

	if(!usr || usr.stat)
		return

	if(href_list["setdna"])
		if(pai.master_dna)
			return
		var/mob/M = usr
		if(!istype(M, /mob/living/carbon))
			usr << "<font color=blue>You don't have any DNA, or your DNA is incompatible with this device.</font>"
		else
			var/datum/dna/dna = usr.dna
			pai.master = M.real_name
			pai.master_dna = dna.unique_enzymes
			pai << "<font color = red><h3>You have been bound to a new master.</h3></font>"
	if(href_list["request"])
		src.looking_for_personality = 1
		paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
		if(confirm == "Yes")
			for(var/mob/M in src)
				M << "<font color = #ff0000><h2>You feel yourself slipping away from reality.</h2></font>"
				M << "<font color = #ff4d4d><h3>Byte by byte you lose your sense of self.</h3></font>"
				M << "<font color = #ff8787><h4>Your mental faculties leave you.</h4></font>"
				M << "<font color = #ffc4c4><h5>oblivion... </h5></font>"
				M.death(0)
			removePersonality()
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if(radio)
			radio.wires.CutWireIndex(t1)
	if(href_list["setlaws"])
		var/newlaws = copytext(sanitize(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.pai_laws) as message),1,MAX_MESSAGE_LEN)
		if(newlaws)
			pai.pai_laws = newlaws
			pai << "Your supplemental directives have been updated. Your new directives are:"
			pai << "Prime Directive : <br>[pai.pai_law0]"
			pai << "Supplemental Directives: <br>[pai.pai_laws]"
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/device/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.overlays += "pai-happy"

/obj/item/device/paicard/proc/removePersonality()
	src.pai = null
	src.overlays.Cut()
	src.overlays += "pai-off"

/obj/item/device/paicard/proc/setEmotion(var/emotion)
	if(pai)
		src.overlays.Cut()
		switch(emotion)
			if(1) src.overlays += "pai-happy"
			if(2) src.overlays += "pai-cat"
			if(3) src.overlays += "pai-extremely-happy"
			if(4) src.overlays += "pai-face"
			if(5) src.overlays += "pai-laugh"
			if(6) src.overlays += "pai-off"
			if(7) src.overlays += "pai-sad"
			if(8) src.overlays += "pai-angry"
			if(9) src.overlays += "pai-what"
			if(10) src.overlays += "pai-longface"
			if(11) src.overlays += "pai-sick"
			if(12) src.overlays += "pai-high"
			if(13) src.overlays += "pai-love"
			if(14) src.overlays += "pai-electric"
			if(15) src.overlays += "pai-pissed"
			if(16) src.overlays += "pai-nose"
			if(17) src.overlays += "pai-kawaii"
			if(18) src.overlays += "pai-cry"

/obj/item/device/paicard/proc/alertUpdate()
	var/turf/T = get_turf_or_move(src.loc)
	for (var/mob/M in viewers(T))
		M.show_message("\blue [src] flashes a message across its screen, \"Additional personalities available for download.\"", 3, "\blue [src] bleeps electronically.", 2)
		playsound(loc, 'sound/machines/paistartup.ogg', 50, 1)

/obj/item/device/paicard/emp_act(severity)
	for(var/mob/M in src)
		M.emp_act(severity)
	..()

