/obj/item/announcer
	name = "bootleg announcer"
	desc = "Fake an announcement from Centcom! Note that it's unlikely they will back up your story if asked."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	var/uses = 1 // -1 is infinite uses.

/obj/item/announcer/attack_self(mob/user)
	if(uses == 0)
		user << "<span class='warning'>[src] has run out of [command_name()] encryption keys, and can send no more messages.</span>"
		return

	var/result = create_command_report(user)
	if(result && uses != -1)
		uses--

/obj/item/announcer/unlimited
	name = "official announcer"
	desc = "Send an official announcement from Centcom. Since you're holding this, you MUST be a Centcom employee, so it has unlimited uses."
	icon_state = "gangtool-white"
	uses = -1

/obj/item/announcer/fake_extended
	name = "intel disruption device"
	desc = "If used early enough in the shift, this device can prevent the station being informed of potential threats."
	icon_state = "gangtool-blue"

/obj/item/announcer/fake_extended/attack_self(mob/user)
	if(ticker.mode.intercept_sent)
		user << "<span class='warning'>[src] reports that the intel broadcast has already been recieved by the station!</span>"
		return

	user << "<span class='notice'>You use [src] to disrupt the station's communication network and to fake an \"all clear\" notice.</span>"

	ticker.mode.send_no_threats_intercept = TRUE
	// Deleting the object means we don't to worry about used ones being
	// refunded.
	visible_message("<span class='warning'>[src] dissolves into sparks!</span>")

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)
	sparks.start()

	qdel(src)

/proc/create_command_report(mob/user)
	var/input = input(user, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	if(!input)
		return

	var/confirm = alert(user, "Do you want to announce the contents of the report to the crew?", "Announce", "Yes", "No")
	if(confirm == "Yes")
		priority_announce(input, null, 'sound/AI/commandreport.ogg')
	else
		priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

	print_command_report(input,"[confirm=="Yes" ? "" : "Classified "][command_name()] Update")
	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report")
	return TRUE
