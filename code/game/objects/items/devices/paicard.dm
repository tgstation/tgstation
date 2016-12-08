/obj/item/device/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=2"
	var/obj/item/device/radio/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai

/obj/item/device/paicard/New()
	..()
	add_overlay("pai-off")

/obj/item/device/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	if(!isnull(pai))
		pai.death(0)
	return ..()

/obj/item/device/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Personal AI Device</B><BR>"
	if(pai && (!pai.master_dna || !pai.master))
		dat += "<a href='byond://?src=\ref[src];setdna=1'>Imprint Master DNA</a><br>"
	if(pai)
		dat += "Installed Personality: [pai.name]<br>"
		dat += "Prime directive: <br>[pai.laws.zeroth]<br>"
		for(var/slaws in pai.laws.supplied)
			dat += "Additional directives: <br>[slaws]<br>"
		dat += "<a href='byond://?src=\ref[src];setlaws=1'>Configure Directives</a><br>"
		dat += "<br>"
		dat += "<h3>Device Settings</h3><br>"
		if(radio)
			dat += "<b>Radio Uplink</b><br>"
			dat += "Transmit: <A href='byond://?src=\ref[src];wires=[WIRE_TX]'>[(radio.wires.is_cut(WIRE_TX)) ? "Disabled" : "Enabled"]</A><br>"
			dat += "Receive: <A href='byond://?src=\ref[src];wires=[WIRE_RX]'>[(radio.wires.is_cut(WIRE_RX)) ? "Disabled" : "Enabled"]</A><br>"
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"
		dat += "<A href='byond://?src=\ref[src];wipe=1'>\[Wipe current pAI personality\]</a><br>"
	else
		if(looking_for_personality)
			dat += "Searching for a personality..."
			dat += "<A href='byond://?src=\ref[src];request=1'>\[View available personalities\]</a><br>"
		else
			dat += "No personality is installed.<br>"
			dat += "<A href='byond://?src=\ref[src];request=1'>\[Request personal AI personality\]</a><br>"
			dat += "Each time this button is pressed, a request will be sent out to any available personalities. Check back often and give a lot of time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness."
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/device/paicard/Topic(href, href_list)

	if(!usr || usr.stat)
		return

	if(href_list["request"])
		src.looking_for_personality = 1
		SSpai.findPAI(src, usr)

	if(pai)
		if(href_list["setdna"])
			if(pai.master_dna)
				return
			if(!istype(usr, /mob/living/carbon))
				usr << "<span class='warning'>You don't have any DNA, or your DNA is incompatible with this device!</span>"
			else
				var/mob/living/carbon/M = usr
				pai.master = M.real_name
				pai.master_dna = M.dna.unique_enzymes
				pai << "<span class='notice'>You have been bound to a new master.</span>"
		if(href_list["wipe"])
			var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
			if(confirm == "Yes")
				if(pai)
					pai << "<span class='warning'>You feel yourself slipping away from reality.</span>"
					pai << "<span class='danger'>Byte by byte you lose your sense of self.</span>"
					pai << "<span class='userdanger'>Your mental faculties leave you.</span>"
					pai << "<span class='rose'>oblivion... </span>"
					pai.death(0)
		if(href_list["wires"])
			var/wire = text2num(href_list["wires"])
			if(radio)
				radio.wires.cut(wire)
		if(href_list["setlaws"])
			var/newlaws = copytext(sanitize(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1]) as message),1,MAX_MESSAGE_LEN)
			if(newlaws && pai)
				pai.add_supplied_law(0,newlaws)
				pai << "Your supplemental directives have been updated. Your new directives are:"
				pai << "Prime Directive : <br>[pai.laws.zeroth]"
				for(var/slaws in pai.laws.supplied)
					pai << "Supplemental Directives: <br>[slaws]"
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/device/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.add_overlay("pai-null")

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, 1, -1)
	audible_message("\The [src] plays a cheerful startup noise!")

/obj/item/device/paicard/proc/removePersonality()
	src.pai = null
	src.cut_overlays()
	src.add_overlay("pai-off")

/obj/item/device/paicard/proc/setEmotion(emotion)
	if(pai)
		src.cut_overlays()
		switch(emotion)
			if(1) src.add_overlay("pai-happy")
			if(2) src.add_overlay("pai-cat")
			if(3) src.add_overlay("pai-extremely-happy")
			if(4) src.add_overlay("pai-face")
			if(5) src.add_overlay("pai-laugh")
			if(6) src.add_overlay("pai-off")
			if(7) src.add_overlay("pai-sad")
			if(8) src.add_overlay("pai-angry")
			if(9) src.add_overlay("pai-what")
			if(10) src.add_overlay("pai-null")

/obj/item/device/paicard/proc/alertUpdate()
	visible_message("<span class ='info'>[src] flashes a message across its screen, \"Additional personalities available for download.\"", "<span class='notice'>[src] bleeps electronically.</span>")

/obj/item/device/paicard/emp_act(severity)
	if(pai)
		pai.emp_act(severity)
	..()

