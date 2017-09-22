/obj/machinery/computer/prisoner
	name = "prisoner management console"
	desc = "Used to manage tracking implants placed inside criminals."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	var/id = 0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	var/obj/item/card/id/prisoner/inserted_id
	circuit = /obj/item/circuitboard/computer/prisoner

	light_color = LIGHT_COLOR_RED

/obj/machinery/computer/prisoner/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = ""
	if(screen == 0)
		dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		dat += "<H3>Prisoner ID Management</H3>"
		if(inserted_id)
			dat += text("<A href='?src=\ref[src];id=eject'>[inserted_id]</A><br>")
			dat += text("Collected Points: [inserted_id.points]. <A href='?src=\ref[src];id=reset'>Reset.</A><br>")
			dat += text("Card goal: [inserted_id.goal].  <A href='?src=\ref[src];id=setgoal'>Set </A><br>")
			dat += text("Space Law recommends quotas of 100 points per minute they would normally serve in the brig.<BR>")
		else
			dat += text("<A href='?src=\ref[src];id=insert'>Insert Prisoner ID.</A><br>")
		dat += "<H3>Prisoner Implant Management</H3>"
		dat += "<HR>Chemical Implants<BR>"
		var/turf/Tr = null
		for(var/obj/item/implant/chem/C in GLOB.tracked_chem_implants)
			Tr = get_turf(C)
			if((Tr) && (Tr.z != src.z))
				continue//Out of range
			if(!C.imp_in)
				continue
			dat += "ID: [C.imp_in.name] | Remaining Units: [C.reagents.total_volume] <BR>"
			dat += "| Inject: "
			dat += "<A href='?src=\ref[src];inject1=\ref[C]'>(<font class='bad'>(1)</font>)</A>"
			dat += "<A href='?src=\ref[src];inject5=\ref[C]'>(<font class='bad'>(5)</font>)</A>"
			dat += "<A href='?src=\ref[src];inject10=\ref[C]'>(<font class='bad'>(10)</font>)</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/implant/tracking/T in GLOB.tracked_implants)
			if(!isliving(T.imp_in))
				continue
			Tr = get_turf(T)
			if((Tr) && (Tr.z != src.z))
				continue//Out of range

			var/loc_display = "Unknown"
			var/mob/living/M = T.imp_in
			if((Tr.z in GLOB.station_z_levels) && !isspaceturf(M.loc))
				var/turf/mob_loc = get_turf(M)
				loc_display = mob_loc.loc

			dat += "ID: [T.imp_in.name] | Location: [loc_display]<BR>"
			dat += "<A href='?src=\ref[src];warn=\ref[T]'>(<font class='bad'><i>Message Holder</i></font>)</A> |<BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"
	var/datum/browser/popup = new(user, "computer", "Prisoner Management Console", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		return attack_hand(user)
	else
		return ..()

/obj/machinery/computer/prisoner/process()
	if(!..())
		src.updateDialog()
	return


/obj/machinery/computer/prisoner/Topic(href, href_list)
	if(..())
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		usr.set_machine(src)

		if(href_list["id"])
			if(href_list["id"] =="insert" && !inserted_id)
				var/obj/item/card/id/prisoner/I = usr.get_active_held_item()
				if(istype(I))
					if(!usr.drop_item())
						return
					I.loc = src
					inserted_id = I
				else to_chat(usr, "<span class='danger'>No valid ID.</span>")
			else if(inserted_id)
				switch(href_list["id"])
					if("eject")
						inserted_id.loc = get_turf(src)
						inserted_id.verb_pickup()
						inserted_id = null
					if("reset")
						inserted_id.points = 0
					if("setgoal")
						var/num = round(input(usr, "Choose prisoner's goal:", "Input an Integer", null) as num|null)
						if(num >= 0)
							num = min(num,1000) //Cap the quota to the equivilent of 10 minutes.
							inserted_id.goal = num
		else if(href_list["inject1"])
			var/obj/item/implant/I = locate(href_list["inject1"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(1)
		else if(href_list["inject5"])
			var/obj/item/implant/I = locate(href_list["inject5"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(5)

		else if(href_list["inject10"])
			var/obj/item/implant/I = locate(href_list["inject10"]) in GLOB.tracked_chem_implants
			if(I && istype(I))
				I.activate(10)

		else if(href_list["lock"])
			if(src.allowed(usr))
				screen = !screen
			else
				to_chat(usr, "Unauthorized Access.")

		else if(href_list["warn"])
			var/warning = copytext(sanitize(input(usr,"Message:","Enter your message here!","")),1,MAX_MESSAGE_LEN)
			if(!warning)
				return
			var/obj/item/implant/I = locate(href_list["warn"]) in GLOB.tracked_implants
			if(I && istype(I) && I.imp_in)
				var/mob/living/R = I.imp_in
				to_chat(R, "<span class='italics'>You hear a voice in your head saying: '[warning]'</span>")
				log_talk(usr,"[key_name(usr)] sent an implant message to [R]/[R.ckey]: '[warning]'",LOGSAY)

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return
