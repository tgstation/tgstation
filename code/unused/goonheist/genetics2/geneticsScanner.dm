var/list/genescanner_addresses = list()

/obj/machinery/genetics_scanner
	name = "GeneTek scanner"
	icon = 'Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	mats = 15
	var/mob/occupant = null
	var/locked = 0
	anchored = 1.0

	var/net_id = null
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

	New()
		..()
		spawn(8)
			if(radio_controller)
				radio_connection = radio_controller.add_object(src, "[frequency]")
			if(!src.net_id)
				src.net_id = generate_net_id(src)
				genescanner_addresses += src.net_id

	disposing()
		if (radio_controller)
			radio_controller.remove_object(src, "[frequency]")
		radio_connection = null
		if (src.net_id)
			genescanner_addresses -= src.net_id
		occupant = null
		..()

	receive_signal(datum/signal/signal)
		if(stat & NOPOWER)
			return

		if(!signal || signal.encryption || !signal.data["sender"])
			return

		var/target = signal.data["sender"]
		if((signal.data["address_1"] == "ping") && target)
			spawn(5) //Send a reply for those curious jerks

				var/datum/signal/newsignal = get_free_signal()
				newsignal.source = src
				newsignal.transmission_method = TRANSMISSION_RADIO
				newsignal.data["command"] = "ping_reply"
				newsignal.data["device"] = "NET_DNASCANNER"
				newsignal.data["netid"] = src.net_id

				newsignal.data["address_1"] = target
				newsignal.data["sender"] = src.net_id

				radio_connection.post_signal(src, newsignal)

			return

		if(signal.data["address_1"] != src.net_id || !target || signal.data["command"] != "add" || !istype(signal.data_file, /datum/computer/file/genetics_scan))
			return

		var/datum/computer/file/genetics_scan/scanFile = signal.data_file
		for(var/datum/computer/file/genetics_scan/O in genResearch.dna_samples)
			if(scanFile.subject_uID == O.subject_uID)
				spawn(5)

					var/datum/signal/newsignal = get_free_signal()
					newsignal.source = src
					newsignal.transmission_method = TRANSMISSION_RADIO
					newsignal.data["command"] = "text_message"
					newsignal.data["sender_name"] = "DNASCAN-MAILBOT"
					newsignal.data["message"] = "Notice: DNA Sample already exists in database."

					newsignal.data["address_1"] = target
					newsignal.data["sender"] = src.net_id

					radio_connection.post_signal(src, newsignal)
				return

		src.dna_scanner_new_file(scanFile)
		spawn(5)

			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "DNASCAN-MAILBOT"
			newsignal.data["message"] = "Notice: DNA Sample entered into database."

			newsignal.data["address_1"] = target
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

	allow_drop()
		return 0

	examine()
		set src in oview(7)

		..()
		if (src.occupant)
			usr << "[src.occupant.name] is inside the scanner."
		else
			usr << "There is nobody currently inside the scanner."
		if (src.locked)
			usr << "The scanner is currently locked."
		else
			usr << "The scanner is not currently locked."

	verb/move_inside()
		set name = "Enter"
		set src in oview(1)

		if(!iscarbon(usr))
			usr << "\red <B>The scanner supports only carbon based lifeforms.</B>"
			return

		if (usr.stat != 0)
			return

		if (src.occupant)
			usr << "\blue <B>The scanner is already occupied!</B>"
			return

		if (src.locked)
			usr << "\red <B>You need to unlock the scanner first.</B>"
			return

		usr.pulling = null
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.set_loc(src)
		src.occupant = usr
		src.icon_state = "scanner_1"

		for(var/obj/O in src)
			qdel(O)

		src.add_fingerprint(usr)
		return

	attackby(var/obj/item/grab/G as obj, user as mob)
		if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
			return

		if (src.occupant)
			user << "\red <B>The scanner is already occupied!</B>"
			return

		if (src.locked)
			usr << "\red <B>You need to unlock the scanner first.</B>"
			return

		if(!iscarbon(G.affecting))
			user << "\blue <B>The scanner supports only carbon based lifeforms.</B>"
			return

		var/mob/M = G.affecting
		if (M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.set_loc(src)
		src.occupant = M
		src.icon_state = "scanner_1"

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(user)
		qdel(G)
		return

	verb/eject()
		set name = "Eject Occupant"
		set src in oview(1)

		if (usr.stat != 0)
			return
		if (src.locked)
			usr << "\red <b>The scanner door is locked!</b>"
			return

		src.go_out()
		add_fingerprint(usr)
		return

	verb/lock()
		set name = "Scanner Lock"
		set src in oview(1)

		if (usr.stat != 0)
			return
		if (usr == src.occupant)
			usr << "\red <b>You can't reach the scanner lock from the inside.</b>"
			return

		playsound(src.loc, 'click.ogg', 50, 1)
		if (src.locked)
			src.locked = 0
			usr.visible_message("<b>[usr]</b> unlocks the scanner.")
			if (src.occupant)
				src.occupant << "\red You hear the scanner's lock slide out of place."
		else
			src.locked = 1
			usr.visible_message("<b>[usr]</b> locks the scanner.")
			if (src.occupant)
				src.occupant << "\red You hear the scanner's lock click into place."

	proc/go_out()
		if (!src.occupant)
			return

		if (src.locked)
			return

		for(var/obj/O in src)
			O.set_loc(src.loc)

		if (src.occupant.client)
			src.occupant.client.eye = src.occupant.client.mob
			src.occupant.client.perspective = MOB_PERSPECTIVE

		src.occupant.set_loc(src.loc)
		src.occupant = null
		src.icon_state = "scanner_0"
		return

	proc/dna_scanner_new_file(var/datum/computer/file/genetics_scan/source_file)
		if (!source_file)
			return
		var/datum/computer/file/genetics_scan/new_file = new /datum/computer/file/genetics_scan(genResearch.dna_samples)

		new_file.subject_name = source_file.subject_name
		new_file.subject_uID = source_file.subject_uID
		for(var/datum/bioEffect/BE in source_file.dna_pool)
			var/datum/bioEffect/MUT = new BE.type(new_file)
			MUT.dnaBlocks = BE.dnaBlocks
			new_file.dna_pool += MUT
		genResearch.dna_samples += new_file
		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/genetics_appearancemenu
	var/client/usercl = null

	var/mob/living/carbon/human/target_mob = null

	var/h_style = "Short Hair"
	var/f_style = "Shaved"
	var/d_style = "None"

	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0

	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0

	var/r_detail = 0.0
	var/g_detail = 0.0
	var/b_detail = 0.0

	var/s_tone = 0.0
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0

	var/icon/preview_icon = null

	New(var/client/newuser, var/mob/target)
		..()
		if(!newuser || !ishuman(target))
			qdel(src)
			return

		src.target_mob = target
		src.usercl = newuser
		src.load_mob_data(src.target_mob)
		src.update_menu()
		src.process()
		return

	disposing()
		if(usercl && usercl.mob)
			usercl.mob << browse(null, "window=geneticsappearance")
			usercl = null
		target_mob = null
		..()

	Topic(href, href_list)
		if(href_list["close"])
			qdel(src)
			return

		else if (href_list["h_style"])
			var/new_style = input(usr, "Please select hair style", "Appearance Menu")  as null|anything in hair_styles + (genResearch.isResearched(/datum/geneticsResearchEntry/hairf) ? hair_styles_gimmick : list())

			if (new_style)
				src.h_style = new_style

		else if (href_list["f_style"])
			var/new_style = input(usr, "Please select facial style", "Appearance Menu")  as null|anything in fhair_styles + (genResearch.isResearched(/datum/geneticsResearchEntry/hairf) ? fhair_styles_gimmick : list())

			if (new_style)
				src.f_style = new_style

		else if (href_list["d_style"])
			var/new_style = input(usr, "Please select detail style", "Appearance Menu")  as null|anything in detail_styles + (genResearch.isResearched(/datum/geneticsResearchEntry/hairf) ? detail_styles_gimmick : list())

			if (new_style)
				src.d_style = new_style

		else if (href_list["hair"])
			var/new_hair = input(usr, "Please select hair color.", "Appearance Menu") as color
			if(new_hair)
				src.r_hair = hex2num(copytext(new_hair, 2, 4))
				src.g_hair = hex2num(copytext(new_hair, 4, 6))
				src.b_hair = hex2num(copytext(new_hair, 6, 8))

		else if (href_list["facial"])
			var/new_facial = input(usr, "Please select facial hair color.", "Appearance Menu") as color
			if(new_facial)
				src.r_facial = hex2num(copytext(new_facial, 2, 4))
				src.g_facial = hex2num(copytext(new_facial, 4, 6))
				src.b_facial = hex2num(copytext(new_facial, 6, 8))

		else if (href_list["detail"])
			var/new_detail = input(usr, "Please select detail color.", "Appearance Menu") as color
			if(new_detail)
				src.r_detail = hex2num(copytext(new_detail, 2, 4))
				src.g_detail = hex2num(copytext(new_detail, 4, 6))
				src.b_detail = hex2num(copytext(new_detail, 6, 8))

		else if (href_list["eyes"])
			var/new_eyes = input(usr, "Please select eye color.", "Appearance Menu") as color
			if(new_eyes)
				src.r_eyes = hex2num(copytext(new_eyes, 2, 4))
				src.g_eyes = hex2num(copytext(new_eyes, 4, 6))
				src.b_eyes = hex2num(copytext(new_eyes, 6, 8))

		else if (href_list["s_tone"])
			var/new_tone = input(usr, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Appearance Menu")  as text

			if (new_tone)
				src.s_tone = max(min(round(text2num(new_tone)), 220), 1)
				src.s_tone =  -src.s_tone + 35

		else if(href_list["apply"])
			src.copy_to_target()
			qdel(src)

		src.update_menu()
		return

	proc
		load_mob_data(var/mob/living/carbon/human/H)
			if(!ishuman(H))
				qdel(src)
				return

			src.s_tone = H.bioHolder.mobAppearance.s_tone

			src.h_style = H.bioHolder.mobAppearance.h_style
			src.r_hair = H.bioHolder.mobAppearance.r_hair
			src.g_hair = H.bioHolder.mobAppearance.g_hair
			src.b_hair = H.bioHolder.mobAppearance.b_hair

			src.f_style = H.bioHolder.mobAppearance.f_style
			src.r_facial = H.bioHolder.mobAppearance.r_facial
			src.g_facial = H.bioHolder.mobAppearance.g_facial
			src.b_facial = H.bioHolder.mobAppearance.b_facial

			src.d_style = H.bioHolder.mobAppearance.d_style
			src.r_detail = H.bioHolder.mobAppearance.r_detail
			src.g_detail = H.bioHolder.mobAppearance.g_detail
			src.b_detail = H.bioHolder.mobAppearance.b_detail

			if(!(hair_styles[src.h_style] || hair_styles_gimmick[src.h_style]))
				src.h_style = "Bald"

			if(!(fhair_styles[src.f_style] || fhair_styles_gimmick[src.f_style]))
				src.f_style = "Shaved"

			if(!(detail_styles[src.d_style] || detail_styles_gimmick[src.d_style]))
				src.d_style = "None"

			src.r_eyes = H.bioHolder.mobAppearance.r_eyes
			src.g_eyes = H.bioHolder.mobAppearance.g_eyes
			src.b_eyes = H.bioHolder.mobAppearance.b_eyes

			return

		update_menu()
			set background = 1
			if(!usercl)
				qdel(src)
				return
			var/mob/user = usercl.mob
			src.update_preview_icon()
			user << browse_rsc(preview_icon, "polymorphicon.png")

			var/dat = "<html><body><title>GeneTek Appearance Modifier</title>"

			dat += "<table><tr><td>"
			dat += "<b>Appearance:</b><br>"
			dat += "<a href='byond://?src=\ref[src];s_tone=input'><b>Skin Tone:</b></a> [-src.s_tone + 35]/220<br>"
			dat += "<a href='byond://?src=\ref[src];eyes=input'><b>Eye Color:</b> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_eyes, 2)][num2hex(src.g_eyes, 2)][num2hex(src.b_eyes, 2)]\"><b>#</b></font></a><br>"

			dat += "<a href='byond://?src=\ref[src];h_style=input'><b>Hair:</b></a> [src.h_style] "
			dat += "<a href='byond://?src=\ref[src];hair=input'><font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_hair, 2)][num2hex(src.g_hair, 2)][num2hex(src.b_hair, 2)]\"><b>#</b></font></a><br>"

			dat += "<a href='byond://?src=\ref[src];f_style=input'><b>Facial Hair:</b></a> [src.f_style] "
			dat += "<a href='byond://?src=\ref[src];facial=input'><font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_facial, 2)][num2hex(src.g_facial, 2)][num2hex(src.b_facial, 2)]\"><b>#</b></font></a><br>"

			dat += "<a href='byond://?src=\ref[src];d_style=input'><b>Detail:</b></a> [src.d_style] "
			dat += "<a href='byond://?src=\ref[src];detail=input'><font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_detail, 2)][num2hex(src.g_detail, 2)][num2hex(src.b_detail, 2)]\"><b>#</b></font></a><br>"

			dat += "</td><td>"
			dat += "<center><b>Preview</b>:<br>"
			dat += "<img src=polymorphicon.png height=64 width=64></center>"
			dat += "</td></tr></table>"
			dat += "<hr>"

			dat += "<a href='byond://?src=\ref[src];apply=1'>Apply</a><br>"
			dat += "</body></html>"

			user << browse(dat, "window=geneticsappearance;size=300x250;can_resize=0;can_minimize=0")
			onclose(user, "geneticsappearance", src)
			return

		copy_to_target()
			if(!target_mob)
				return

			target_mob.bioHolder.mobAppearance.r_eyes = r_eyes
			target_mob.bioHolder.mobAppearance.g_eyes = g_eyes
			target_mob.bioHolder.mobAppearance.b_eyes = b_eyes

			target_mob.bioHolder.mobAppearance.r_hair = r_hair
			target_mob.bioHolder.mobAppearance.g_hair = g_hair
			target_mob.bioHolder.mobAppearance.b_hair = b_hair

			target_mob.bioHolder.mobAppearance.r_facial = r_facial
			target_mob.bioHolder.mobAppearance.g_facial = g_facial
			target_mob.bioHolder.mobAppearance.b_facial = b_facial

			target_mob.bioHolder.mobAppearance.r_detail = r_detail
			target_mob.bioHolder.mobAppearance.g_detail = g_detail
			target_mob.bioHolder.mobAppearance.b_detail = b_detail

			target_mob.bioHolder.mobAppearance.s_tone = s_tone

			target_mob.bioHolder.mobAppearance.h_style = h_style
			target_mob.bioHolder.mobAppearance.f_style = f_style
			target_mob.bioHolder.mobAppearance.d_style = d_style

			target_mob.hair_icon_state = hair_styles[h_style]
			if(!target_mob.hair_icon_state)
				target_mob.hair_icon_state = hair_styles_gimmick[h_style]
				if(!target_mob.hair_icon_state)
					target_mob.hair_icon_state = "Bald"

			target_mob.face_icon_state = fhair_styles[f_style]
			if(!target_mob.face_icon_state)
				target_mob.face_icon_state = fhair_styles_gimmick[f_style]
				if(!target_mob.face_icon_state)
					target_mob.face_icon_state = "Shaved"

			target_mob.detail_icon_state = detail_styles[d_style]
			if(!target_mob.detail_icon_state)
				target_mob.detail_icon_state = detail_styles_gimmick[d_style]
				if(!target_mob.detail_icon_state)
					target_mob.detail_icon_state = "None"

			target_mob.set_face_icon_dirty()
			target_mob.set_body_icon_dirty()
			target_mob.set_clothing_icon_dirty()
			return

		process()
			set background = 1
			if(!usercl || !target_mob)
				qdel(src)
				return
			spawn(20)
				src.process()
			return

		update_preview_icon()
			set background = 1
			qdel(src.preview_icon)

			var/h_style_r = null
			var/f_style_r = null
			var/d_style_r = null

			var/gender = ""
			if(target_mob.gender == "male") gender = "m"
			else gender = "f"

			src.preview_icon = new /icon('human.dmi', "body_[gender]_s")

			if (src.s_tone >= 0)
				src.preview_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), ICON_ADD)
			else
				src.preview_icon.Blend(rgb(-src.s_tone,  -src.s_tone,  -src.s_tone), ICON_SUBTRACT)

			var/icon/eyes_s = new/icon("icon" = 'human_detail.dmi', "icon_state" = "eyes_s")

			h_style_r = hair_styles[h_style]
			if(!h_style_r)
				h_style_r = hair_styles_gimmick[h_style]
				if(!h_style_r)
					h_style_r = "Bald"

			f_style_r = fhair_styles[f_style]
			if(!f_style_r)
				f_style_r = fhair_styles_gimmick[f_style]
				if(!f_style_r)
					f_style_r = "Shaved"

			d_style_r = detail_styles[d_style]
			if(!d_style_r)
				d_style_r = detail_styles_gimmick[d_style]
				if(!d_style_r)
					d_style_r = "None"

			var/icon/hair_s = new/icon("icon" = 'human_hair.dmi', "icon_state" = "[h_style_r]_s")
			hair_s.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)
			qdel(hair_s)

			var/icon/facial_s = new/icon("icon" = 'human_beard.dmi', "icon_state" = "[f_style_r]_s")
			facial_s.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)
			qdel(facial_s)

			var/icon/detail_s = new/icon("icon" = 'human_detail.dmi', "icon_state" = "[d_style_r]_s")
			detail_s.Blend(rgb(src.r_detail, src.g_detail, src.b_detail), ICON_ADD)
			eyes_s.Blend(detail_s, ICON_OVERLAY)
			qdel(detail_s)

			src.preview_icon.Blend(eyes_s, ICON_OVERLAY)
			qdel(eyes_s)
			return