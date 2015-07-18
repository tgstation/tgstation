var/list/announcement_systems = list()

/obj/machinery/announcement_system
	density = 1
	anchored = 1
	name = "\improper Automated Announcement System"
	desc = "An automated announcement system that handles minor announcements over the radio."
	icon = 'icons/obj/machines/announcement_system.dmi'
	icon_state = "AAS_on_closed"
	var/obj/item/device/radio/headset/radio

	var/broken = 0

	idle_power_usage = 20
	active_power_usage = 50

	var/arrival = "%PERSON has signed up as %RANK"
	var/arrivalToggle = 1
	var/newhead = "%PERSON, %RANK, is the department head."
	var/newheadToggle = 1

	var/greenlight = "green_light"
	var/pinklight = "pink_light"
	var/errorlight = "error_light"

/obj/machinery/announcement_system/New()
	..()
	announcement_systems += src
	radio = new /obj/item/device/radio/headset/ai(src)

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/announcement_system(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

	update_icon()

/obj/machinery/announcement_system/update_icon()
	if(is_operational())
		icon_state = (panel_open ? "AAS_on_open" : "AAS_on_closed")
	else
		icon_state = (panel_open ? "AAS_off_open" : "AAS_off_closed")


	overlays.Cut()
	if(arrivalToggle)
		overlays |= greenlight
	else
		overlays -= greenlight

	if(newheadToggle)
		overlays |= pinklight
	else
		overlays -= pinklight

	if(broken)
		overlays |= errorlight
	else
		overlays -= errorlight

/obj/machinery/announcement_system/Destroy()
	announcement_systems -= src //"OH GOD WHY ARE THERE 100,000 LISTED ANNOUNCEMENT SYSTEMS?!!"

/obj/machinery/announcement_system/power_change()
	..()
	update_icon()

/obj/machinery/announcement_system/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/weapon/screwdriver))
		if(!panel_open)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You open the control panel of [src]."
			panel_open = 1
		else
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "You close the control panel of [src]."
			panel_open = 0
		update_icon()
		return

	if(panel_open)
		default_deconstruction_crowbar(P)
		if(istype(P, /obj/item/device/multitool) && broken)
			user << "You reset [src]'s firmware."
			broken = 0
			update_icon()

/obj/machinery/announcement_system/attack_hand(mob/user)
	if((panel_open || isAI(user)) && can_be_used_by(user))
		Interact(user)

/obj/machinery/announcement_system/proc/CompileText(str, user, rank) //replaces user-given variables with actual thingies.
	str = replacetext(str, "%PERSON", "[user]")
	str = replacetext(str, "%RANK", "[rank]")
	return str

/obj/machinery/announcement_system/proc/announce(message_type, user, rank, list/channels)
	if(!is_operational())
		return

	var/message

	if(message_type == "ARRIVAL" && arrivalToggle)
		message = CompileText(arrival, user, rank)

	else if(message_type == "NEWHEAD" && newheadToggle)
		message = CompileText(newhead, user, rank)

	if(channels.len == 0)
		radio.talk_into(src, message, null, list(SPAN_ROBOT))
	else
		for(var/channel in channels)
			radio.talk_into(src, message, channel, list(SPAN_ROBOT))

//config stuff

/obj/machinery/announcement_system/proc/Interact(mob/user)
	if(!(panel_open || isAI(user)) || !can_be_used_by(user))
		return

	if(broken)
		visible_message("[src] buzzes", "You hear a faint buzz.")
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
		return


	var/contents = "Arrival Announcement:  <A href='?src=\ref[src];ArrivalT-Topic=1'>([(arrivalToggle ? "On" : "Off")])</a><br>\n<A href='?src=\ref[src];ArrivalTopic=1'>[arrival]</a><br><br>\n"
	contents += "Departmental Head Announcement:  <A href='?src=\ref[src];NewheadT-Topic=1'>([(newheadToggle ? "On" : "Off")])</a><br>\n<A href='?src=\ref[src];NewheadTopic=1'>[newhead]</a><br><br>\n"

	var/datum/browser/popup = new(user, "announcement_config", "Automated Announcement Configuration", 370, 220)
	popup.set_content(contents)
	popup.open()

/obj/machinery/announcement_system/Topic(href, href_list)
	if(!(panel_open || isAI(usr)) || !can_be_used_by(usr) || usr.lying || usr.stat || usr.stunned)
		return
	if(broken)
		visible_message("[src] buzzes", "You hear a faint buzz.")
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
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

	else if(href_list["NewheadT-Topic"])
		newheadToggle = !newheadToggle
		update_icon()
	else if(href_list["ArrivalT-Topic"])
		arrivalToggle = !arrivalToggle
		update_icon()

	add_fingerprint(usr)
	Interact(usr)
	return

/obj/machinery/announcement_system/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	if(broken)
		user << "[src]'s firmware appears to be malfunctioning!"
		return
	Interact(user)

/obj/machinery/announcement_system/proc/act_up() //does funny breakage stuff
	broken = 1
	update_icon()

	arrival = "#!@%ERR-34%2 CANNOT LOCAT@# JO# F*LE!"
	newhead = "OV#RL()D: \[UNKNOWN??\] DET*#CT)D!"

/obj/machinery/announcement_system/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	act_up()
	..(severity)

/obj/machinery/announcement_system/emag_act()
	..()
	emagged = 1
	act_up()