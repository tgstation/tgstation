var/list/announcement_systems = list()

/obj/machinery/announcement_system
	density = 1
	anchored = 1
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/announcement_system.dmi'
	icon_state = "AAS_on_closed"
	var/obj/item/device/radio/headset/radio

	idle_power_usage = 20

	var/arrival = "%PERSON has signed up as %RANK"
	var/newhead = "%PERSON, %RANK, is the department head."

/obj/machinery/announcement_system/New()
	..()
	announcement_systems += src
	radio = new /obj/item/device/radio/headset/ai(src)

/obj/machinery/announcement_system/update_icon()
	if(is_operational())
		icon_state = (panel_open ? "AAS_on_open" : "AAS_on_closed")
	else
		icon_state = (panel_open ? "AAS_off_open" : "AAS_off_closed")

/obj/machinery/announcement_system/power_change()
	..()
	update_icon()

/obj/machinery/announcement_system/attackby(obj/item/P, mob/user, params)
	if(istype(P, obj/item/weapon/screwdriver))
		if(state_open)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You open the control panel of [src]."
			panel_open = 1
		else
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You close the control panel of [src]."
			panel_open = 0
		update_icon()
		return

	default_deconstruction_crowbar(P)

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/machinery/announcement_system/proc/announce(message_type, user, rank, list/channels)
	if(!is_operational())
		return

	var/message

	if(message_type == "ARRIVAL")
		message = CompileText(arrival, user, rank)
	else if(message_type == "NEWHEAD")
		message = CompileText(newhead, user, rank)

	if(channels.len == 0)
		radio.talk_into(src, message, null, list(SPAN_ROBOT))
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel, list(SPAN_ROBOT))

//config stuff

/obj/machinery/announcement_system/proc/Interact(mob/user)
	if(!is_operational())
		return

	var/contents = "Arrival Announcement:<br>\n<A href='?src=\ref[src];ArrivalTopic=1'>[arrival]</a><br>\n"
	contents += "Departmental Head Announcement:<br>\n<A href='?src=\ref[src];NewheadTopic=1'>[newhead]</a><br>\n"

	var/datum/browser/popup = new(user, "announcement_config", "Automated Announcement Configuration", 350, 240)
	popup.set_content(contents)
	popup.open()

/obj/machinery/announcement_system/Topic(href, href_list)
	if(!is_operational() || usr.lying || usr.stat || usr.stunned || (!Adjacent(usr)) && !isAI(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/item_in_hand = living_user.get_active_hand()
	if(!istype(item_in_hand, /obj/item/device/multitool) && !isAI(usr))
		living_user << "<span class='warning'>You need a multitool!</span>"
		return

	if(href_list["ArrivalTopic"])
		var/NewMessage = stripped_input(usr, "Enter in the arrivals announcement configuration.", "Arrivals Announcement Config", arrival)
		if(!in_range(src, usr) && src.loc != usr && !isAI(usr))
			return
		if(NewMessage)
			arrival = NewMessage
	else if(href_list["NewheadTopic"])
		var/NewMessage = stripped_input(usr, "Enter in the departmental head announcement configuration.", "Head Departmental Announcement Config", newhead)
		if(!in_range(src, usr) && src.loc != usr && !isAI(usr))
			return
		if(NewMessage)
			newhead = NewMessage

	add_fingerprint(usr)
	Interact(usr)
	return

/obj/machinery/announcement_system/attackby(obj/item/W, mob/user, params)
	..()
	if (istype(W, /obj/item/device/multitool))
		Interact(user)

/obj/machinery/announcement_system/attack_ai(var/mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	Interact(user)