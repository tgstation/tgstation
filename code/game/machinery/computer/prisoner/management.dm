/obj/machinery/computer/prisoner/management
	name = "prisoner management console"
	desc = "Used to modify prisoner IDs, as well as manage security implants placed inside convicts and parolees."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	light_color = COLOR_SOFT_RED
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed
	circuit = /obj/item/circuitboard/computer/prisoner


/obj/machinery/computer/prisoner/management/ui_interact(mob/user)
	. = ..()
	if(isliving(user))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	var/dat = ""
	if(screen == 0)
		dat += "<HR><A href='?src=[REF(src)];lock=1'>{Log In}</A>"
	else if(screen == 1)
		dat += "<H3>Prisoner ID Management</H3>"
		if(contained_id)
			dat += "<A href='?src=[REF(src)];id=eject'>[contained_id]</A><br>"
			dat += "Collected Points: [contained_id.points]. <A href='?src=[REF(src)];id=reset'>Reset.</A><br>"
			dat += "Card goal: [contained_id.goal].  <A href='?src=[REF(src)];id=setgoal'>Set </A><br>"
			dat += "Space Law recommends quotas of 100 points per minute they would normally serve in the brig.<BR>"
		else
			dat += "<A href='?src=[REF(src)];id=insert'>Insert Prisoner ID.</A><br>"

		dat += "<H3>Prisoner Implant Management</H3>"

		var/turf/current_turf = get_turf(src)
		if(length(GLOB.tracked_chem_implants))
			dat += "<HR>Chemical Implants<BR>"
			for(var/obj/item/implant/chem/chem_implant in GLOB.tracked_chem_implants)
				var/turf/implant_turf = get_turf(chem_implant)
				if(!is_valid_z_level(current_turf, implant_turf))
					continue//Out of range
				if(!chem_implant.imp_in)
					continue
				dat += "ID: [chem_implant.imp_in.name] | Remaining Units: [chem_implant.reagents.total_volume] <BR>"
				dat += "| Inject: "
				dat += "<A href='?src=[REF(src)];inject1=[REF(chem_implant)]'>(<font class='bad'>(1)</font>)</A>"
				dat += "<A href='?src=[REF(src)];inject5=[REF(chem_implant)]'>(<font class='bad'>(5)</font>)</A>"
				dat += "<A href='?src=[REF(src)];inject10=[REF(chem_implant)]'>(<font class='bad'>(10)</font>)</A><BR>"
				dat += add_destroy_topic(chem_implant)
				dat += "********************************<BR>"

		if(length(GLOB.tracked_tracking_implants))
			dat += "<HR>Tracking Implants<BR>"
			for(var/obj/item/implant/tracking/track_implant in GLOB.tracked_tracking_implants)
				if(track_implant.imp_in.stat == DEAD && track_implant.imp_in.timeofdeath + track_implant.lifespan_postmortem < world.time)
					continue
				var/turf/implant_turf = get_turf(track_implant)
				if(!is_valid_z_level(current_turf, implant_turf))
					continue //Out of range

				var/loc_display = "Unknown"
				var/mob/living/implanted_mob = track_implant.imp_in
				if(is_station_level(implant_turf.z) && !isspaceturf(implanted_mob.loc))
					var/turf/mob_loc = get_turf(implanted_mob)
					loc_display = mob_loc.loc

				dat += "ID: [track_implant.imp_in.name] | Location: [loc_display]<BR>"
				dat += "<A href='?src=[REF(src)];warn=[REF(track_implant)]'>(<font class='bad'><i>Message Holder</i></font>)</A> | [add_destroy_topic(track_implant)]<BR>"
				dat += "********************************<BR>"

		if(length(GLOB.tracked_beacon_implants))
			dat += "<HR>Beacon Implants<BR>"
			for(var/obj/item/implant/beacon/beacon_implant in GLOB.tracked_beacon_implants)
				dat += "ID: [beacon_implant.imp_in.name]<BR>"
				var/area/destination_area = get_area(beacon_implant.imp_in)
				if(!destination_area || destination_area.area_flags & NOTELEPORT)
					dat += "<font class='bad'><i>Implant carrier teleport signal cannot be reached!</i></font><BR>"
				else
					var/turf/turf_to_check = get_turf(beacon_implant.imp_in)
					if(is_safe_turf(turf_to_check, dense_atoms = TRUE))
						dat += "Implant carrier is in a safe environment.<BR>"
					else
						dat += "(<font class='bad'><i>Implant carrier is in a hazardous environment!</i></font>)<BR>"
				dat += add_destroy_topic(beacon_implant)
				dat += "********************************<BR>"

		dat += "<HR><A href='?src=[REF(src)];lock=1'>{Log Out}</A>"

	var/datum/browser/popup = new(user, "computer", "Prisoner Management Console", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/prisoner/management/attackby(obj/item/our_id, mob/user, params)
	if(isidcard(our_id))
		if(screen)
			id_insert(user)
		else
			to_chat(user, span_danger("Unauthorized access."))
	else
		return ..()

/obj/machinery/computer/prisoner/management/process()
	if(!..())
		src.updateDialog()
	return

/obj/machinery/computer/prisoner/management/Topic(href, href_list)
	if(..())
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		usr.set_machine(src)

		if(href_list["id"])
			if(href_list["id"] == "insert" && !contained_id)
				id_insert(usr)
			else if(contained_id)
				switch(href_list["id"])
					if("eject")
						id_eject(usr)
					if("reset")
						contained_id.points = 0
					if("setgoal")
						var/num = tgui_input_text(usr, "Enter the prisoner's goal", "Prisoner Management", 1, 1000, 1)
						if(isnull(num))
							return
						contained_id.goal = round(num)
		else if(href_list["inject1"])
			var/obj/item/implant/chem_implant = locate(href_list["inject1"]) in GLOB.tracked_chem_implants
			if(chem_implant && istype(chem_implant))
				chem_implant.activate(chem_implant)
		else if(href_list["inject5"])
			var/obj/item/implant/chem_implant = locate(href_list["inject5"]) in GLOB.tracked_chem_implants
			if(chem_implant && istype(chem_implant))
				chem_implant.activate(chem_implant)
		else if(href_list["inject10"])
			var/obj/item/implant/chem_implant = locate(href_list["inject10"]) in GLOB.tracked_chem_implants
			if(chem_implant && istype(chem_implant))
				chem_implant.activate(10)

		else if(href_list["lock"])
			if(allowed(usr))
				screen = !screen
				playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
			else
				to_chat(usr, span_danger("Unauthorized access."))

		else if(href_list["warn"])
			var/warning = tgui_input_text(usr, "Enter your message here", "Messaging")
			if(!warning)
				return
			var/obj/item/implant/warn_implant = locate(href_list["warn"]) in GLOB.tracked_tracking_implants
			if(warn_implant && istype(warn_implant) && warn_implant.imp_in)
				var/mob/living/victim = warn_implant.imp_in
				to_chat(victim, span_hear("You hear a voice in your head saying: '[warning]'"))
				log_directed_talk(usr, victim, warning, LOG_SAY, "implant message")
		else if(href_list["self_destruct"])
			var/warning = tgui_alert(usr, "Activation will harmlessly self-destruct this implant. Proceed?", "You sure?", list("Yes","No"))
			if(!warning)
				return
			var/obj/item/implant/our_implant = locate(href_list["self_destruct"]) in GLOB.tracked_generic_implants
			if(our_implant && istype(our_implant) && our_implant.imp_in)
				var/mob/living/victim = our_implant.imp_in
				to_chat(victim, span_hear("You feel a tiny jolt from inside of you as one of your implants fizzles out."))
				do_sparks(number = 2, cardinal_only = FALSE, source = our_implant)
				qdel(our_implant)

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

///Adds a topic for remotely destroying a security implant. Appended to all implants in the menu.
/obj/machinery/computer/prisoner/management/proc/add_destroy_topic(obj/item/implant/our_implant)
	return "<A href='?src=[REF(src)];self_destruct=[REF(our_implant)]'>(<font class='bad'>Destroy</font>)</A><BR>"
