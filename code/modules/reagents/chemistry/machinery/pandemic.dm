/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/weapon/circuitboard/computer/pandemic
	use_power = 1
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/temp_html = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/beaker = null

/obj/machinery/computer/pandemic/New()
	..()
	update_icon()

/obj/machinery/computer/pandemic/proc/GetVirusByIndex(index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses[index]
	return null

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances[index]
	return null

/obj/machinery/computer/pandemic/proc/GetVirusTypeByIndex(index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()
	return null

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(src.loc, 'sound/machines/ping.ogg', 30, 1)

/obj/machinery/computer/pandemic/update_icon()
	if(stat & BROKEN)
		icon_state = (beaker ? "mixer1_b" : "mixer0_b")
		return

	icon_state = "mixer[(beaker)?"1":"0"][(powered()) ? "" : "_nopower"]"

	if(wait)
		cut_overlays()
	else
		add_overlay("waitlight")

/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(!beaker) return

	if (href_list["create_vaccine"])
		if(!src.wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			if(B)
				B.pixel_x = rand(-3, 3)
				B.pixel_y = rand(-3, 3)
				var/path = GetResistancesByIndex(text2num(href_list["create_vaccine"]))
				var/vaccine_type = path
				var/vaccine_name = "Unknown"

				if(!ispath(vaccine_type))
					if(archive_diseases[path])
						var/datum/disease/D = archive_diseases[path]
						if(D)
							vaccine_name = D.name
							vaccine_type = path
				else if(vaccine_type)
					var/datum/disease/D = new vaccine_type(0, null)
					if(D)
						vaccine_name = D.name

				if(vaccine_type)

					B.name = "[vaccine_name] vaccine bottle"
					B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
					replicator_cooldown(200)
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if (href_list["create_virus_culture"])
		if(!wait)
			var/type = GetVirusTypeByIndex(text2num(href_list["create_virus_culture"]))//the path is received as string - converting
			var/datum/disease/D = null
			if(!ispath(type))
				D = GetVirusByIndex(text2num(href_list["create_virus_culture"]))
				var/datum/disease/advance/A = archive_diseases[D.GetDiseaseID()]
				if(A)
					D = new A.type(0, A)
			else if(type)
				if(type in diseases) // Make sure this is a disease
					D = new type(0, null)
			if(!D)
				return
			var/name = stripped_input(usr,"Name:","Name the culture",D.name,MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			B.pixel_x = rand(-3, 3)
			B.pixel_y = rand(-3, 3)
			replicator_cooldown(50)
			var/list/data = list("viruses"=list(D))
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			updateUsrDialog()
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if (href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		updateUsrDialog()
		return
	else if (href_list["eject"])
		beaker.forceMove(get_turf(loc))
		beaker = null
		icon_state = "mixer0"
		updateUsrDialog()
		return
	else if (href_list["emptyeject_beaker"])
		beaker.reagents.clear_reagents()
		beaker.forceMove(get_turf(loc))
		beaker = null
		icon_state = "mixer0"
		updateUsrDialog()
		return
	else if(href_list["clear"])
		temp_html = ""
		updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(!new_name)
			return
		if(..())
			return
		var/id = GetVirusTypeByIndex(text2num(href_list["name_disease"]))
		if(archive_diseases[id])
			var/datum/disease/advance/A = archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in SSdisease.processing)
				AD.Refresh()
		updateUsrDialog()


	else
		usr << browse(null, "window=pandemic")
		updateUsrDialog()
		return

	add_fingerprint(usr)
	return

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = ""
	if(temp_html)
		dat = "[src.temp_html]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else if(!beaker)
		dat += "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		var/datum/reagent/blood/Blood = null
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
		if(!R.total_volume||!R.reagent_list.len)
			dat += "The beaker is empty<BR>"
		else if(!Blood)
			dat += "No blood sample found in beaker."
		else if(!Blood.data)
			dat += "No blood data found in beaker."
		else
			dat += "<h3>Blood sample data:</h3>"
			dat += "<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>"
			dat += "<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"


			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					var/i = 0
					for(var/datum/disease/D in Blood.data["viruses"])
						i++
						if(!(D.visibility_flags & HIDDEN_PANDEMIC))

							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = archive_diseases[A.GetDiseaseID()]
								if(D && D.name == "Unknown")
									dat += "<b><a href='?src=\ref[src];name_disease=[i]'>Name Disease</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")

							dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[i]'>Create virus culture bottle</A>":"none"]<BR>"
							dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
							dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
							dat += "<b>Spread:</b> [(D.spread_text||"none")]<BR>"
							dat += "<b>Possible cure:</b> [(D.cure_text||"none")]<BR><BR>"
							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Stealth:</b> [(A.totalStealth())]<BR>"
								dat += "<b>Resistance:</b> [(A.totalResistance())]<BR>"
								dat += "<b>Stage Speed:</b> [(A.totalStageSpeed())]<BR>"
								dat += "<b>Transmission:</b> [(A.totalTransmittable())]<BR><BR>"
								dat += "<b>Symptoms:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)

						else
							dat += "No detectable virus in the sample."
			else
				dat += "No detectable virus in the sample."

			dat += "<BR><b>Contains antibodies to:</b> "
			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<ul>"
					var/i = 0
					for(var/type in Blood.data["resistances"])
						i++
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type(0, null)
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=\ref[src];create_vaccine=[i]'>Create vaccine bottle</A></li>"
					dat += "</ul><BR>"
				else
					dat += "nothing<BR>"
			else
				dat += "nothing<BR>"
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]"
		dat += "[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];emptyeject_beaker=1'>Empty and Eject beaker</A>":"")]<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"

	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers) && (I.container_type & OPENCONTAINER))
		. = 1 //no afterattack
		if(stat & (NOPOWER|BROKEN))
			return
		if(beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return
		if(!user.drop_item())
			return

		beaker =  I
		beaker.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
		updateUsrDialog()
		icon_state = "mixer1"
	else
		return ..()

/obj/machinery/computer/pandemic/on_deconstruction()
	if(beaker)
		beaker.loc = get_turf(src)
	..()