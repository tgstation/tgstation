var/list/announcement_systems = list()

/obj/structure/announcement_system
	density = 0
	anchored = 1
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	var/obj/item/device/radio/headset/radio

	var/arrival = "%PERSON has signed up as %RANK"
	var/newhead = "%PERSON, %RANK, is the department head."

/obj/structure/announcement_system/New()
	announcement_systems += src
	radio = new /obj/item/device/radio/headset/ai(src)

/obj/structure/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/structure/announcement_system/proc/announce(message_type, user, rank, list/channels)
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

/obj/structure/announcement_system/proc/Interact(mob/user)
	var/contents = "Arrival Announcement:<br>\n<A href='?src=\ref[src];ArrivalTopic=1'>[arrival]</a><br>\n"
	contents += "Departmental Head Announcement:<br>\n<A href='?src=\ref[src];NewheadTopic=1'>[newhead]</a><br>\n"

	var/datum/browser/popup = new(user, "announcement_config", "Automated Announcement Configuration", 340, 220)
	popup.set_content(contents)
	popup.open()

/obj/structure/announcement_system/Topic(href, href_list)
	if(usr.lying || usr.stat || usr.stunned || (!Adjacent(usr)) && !isAI(usr))
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
		var/NewMessage = stripped_input(usr, "Enter in the departmental head announcement configuration.", "Arrivals Announcement Config", newhead)
		if(!in_range(src, usr) && src.loc != usr && !isAI(usr))
			return
		if(NewMessage)
			newhead = NewMessage

	add_fingerprint(usr)
	Interact(usr)
	return

/obj/structure/announcement_system/attackby(obj/item/W, mob/user, params)
	..()
	if (istype(W, /obj/item/device/multitool))
		Interact(user)

/obj/structure/announcement_system/attack_ai(var/mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	Interact(user)