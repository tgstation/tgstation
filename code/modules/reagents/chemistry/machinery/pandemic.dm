#define TAB_ANALYSIS 1
#define TAB_EXPERIMENT 2
#define TAB_DATABASE 3

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
	var/virusfood_ammount = 0
	var/mutagen_ammount = 0
	var/plasma_ammount = 0
	var/synaptizine_ammount = 0
	var/new_diseases = list()
	var/new_symptoms = list()
	var/new_cures = list()
	var/tab_open = TAB_ANALYSIS //the magic of defines!
	var/temp_html = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

/obj/machinery/computer/pandemic/New()
	..()
	update_icon()

/obj/machinery/computer/pandemic/proc/GetVirusByIndex(var/index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses[index]
	return null

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(var/index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances[index]
	return null

/obj/machinery/computer/pandemic/proc/GetVirusTypeByIndex(var/index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()
	return null

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		src.wait = null
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

	if (href_list["symptom"])
		if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					for(var/datum/disease/advance/D in viruses)
						D.AddSymptom(new_symptoms[text2num(href_list["symptom"])])
		updateUsrDialog()
		return

	if (href_list["cure"])
		if(!src.wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle
			if(B)
				B.pixel_x = rand(-3, 3)
				B.pixel_y = rand(-3, 3)
				var/vaccine_type = new_cures[text2num(href_list["cure"])]
				if(vaccine_type)
					if(!ispath(vaccine_type))
						if(archive_diseases[vaccine_type])
							var/datum/disease/D = archive_diseases[vaccine_type]
							B.name = "[D.name] vaccine bottle"
							B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
							replicator_cooldown(200)
					else
						var/datum/disease/D = vaccine_type
						B.name = "[D.name] vaccine bottle"
						B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
						replicator_cooldown(200)
		else
			src.temp_html = "The replicator is not ready yet."
		src.updateUsrDialog()
		return

	else if (href_list["virus"])
		if(!wait)
			var/datum/disease/D = new_diseases[text2num(href_list["virus"])]
			if(!D)
				return
			var/name = stripped_input(usr,"Name:","Name the culture",D.name,MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle
			B.icon_state = "bottle3"
			B.pixel_x = rand(-3, 3)
			B.pixel_y = rand(-3, 3)
			replicator_cooldown(50)
			var/list/data = list("viruses"=list(D))
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			src.updateUsrDialog()
		else
			temp_html = "The replicator is not ready yet."
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

	else if (href_list["eject"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			B.loc = loc
			beaker = null
			icon_state = "mixer0"
			updateUsrDialog()
			return

	else if (href_list["tab_open"])
		tab_open = text2num(href_list["tab_open"]) //fucking text
		updateUsrDialog()
		return

	else if(href_list["chem_choice"])
		switch(href_list["chem_choice"])
			if("virusfood")
				if(virusfood_ammount>0)
					beaker.reagents.add_reagent("virusfood",max(beaker.reagents.maximum_volume-beaker.reagents.total_volume,1))
					virusfood_ammount -= 1
					usr << "Virus Food administered."
				else
					usr << "Not enough Virus Food stored!"
			if("mutagen")
				if(mutagen_ammount>0)
					beaker.reagents.add_reagent("mutagen",max(beaker.reagents.maximum_volume-beaker.reagents.total_volume,1))
					mutagen_ammount -= 1
					usr << "Unstable Mutagen administered."
				else
					usr << "Not enough Unstable Mutagen stored!"
			if("plasma")
				if(plasma_ammount>0)
					beaker.reagents.add_reagent("plasma",max(beaker.reagents.maximum_volume-beaker.reagents.total_volume,1))
					plasma_ammount -= 1 //no idea why plasma_ammount-- doesn't work here.
					usr << "Plasma administered."
				else
					usr << "Not enough Plasma stored!"
			if("synaptizine")
				if(synaptizine_ammount>0)
					beaker.reagents.add_reagent("synaptizine",max(beaker.reagents.maximum_volume-beaker.reagents.total_volume,1))
					synaptizine_ammount -= 1
					usr << "Synaptizine administered."
				else
					usr << "Not enough Synaptizine!"
			if("reset")
				beaker.reagents.clear_reagents()
				var/datum/disease/advance/AD = new /datum/disease/advance/inert
				var/list/data = list("viruses"=list(AD))
				beaker.reagents.add_reagent("blood",20,data)
				usr << "Viral strain reset!."
		updateUsrDialog()
		return

var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
	else if(href_list["update_virus"])
		if(is_valid_beaker(beaker))
			if(BL.data && BL.data["viruses"])
				var/list/viruses = BL.data["viruses"]
				for(var/datum/disease/D in viruses)
					var/d_test = 1
					for(var/datum/disease/DT in new_diseases) //we scan for the desease itself to add to the list
						if(D.IsSame(DT))
							d_test = 0
					if(d_test)
						new_diseases += D
						usr << "New disease added to the database!"
	else if(href_list["update_symptom"])
		if(BL.data && BL.data["viruses"])
			var/list/viruses = BL.data["viruses"]
			for(var/datum/disease/D in viruses)
				if(istype(D,/datum/disease/advance)) //advanced deseases, we scan for symptoms
					var/datum/disease/advance/AD = D //inheritance failed me today
					for(var/datum/symptom/S in AD.symptoms)
						var/s_test = 1
						for(var/datum/symptom/ST in new_symptoms ) //this is awfull, I know.
							if(S.name == ST.name) //I really hoped there was another way of doing this.
								s_test = 0
						if(s_test)
							new_symptoms += S
							usr << "New symptom added to the database!"
	else if(href_list["update_cure"])
		if(beaker && beaker.reagents)
			if(BL.data && BL.data["resistances"])
				var/v_test = 1
				for(var/resistance in BL.data["resistances"])
					for(var/res in new_cures)
						if(resistance == res)
							v_test = 0
					if(v_test)
						new_cures += list(resistance)
						if(!istype(resistance, /datum/disease))
							new_cures[resistance] = resistance
						usr << "New vaccine added to the database!"
			usr << "No virus found!"
		else
			usr << "No blood found!"
	else
		usr << "Beaker is empty!"
	else
		usr << browse(null, "window=pandemic")
		updateUsrDialog()
		return

	add_fingerprint(usr)
	return

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	if(..())
		return
	var/dat = ""
	dat += "<A href='?src=\ref[src];tab_open=1'>Analysis</a>"
	dat += "<A href='?src=\ref[src];tab_open=2'>Experiment</a>"
	dat += "<A href='?src=\ref[src];tab_open=3'>Database</a><br><hr><BR>"

	switch(tab_open)
		if(TAB_ANALYSIS)
			if(!beaker)
				dat += "<b>No beaker inserted.</b><BR>"

			else
				var/datum/reagents/R = beaker.reagents
				var/datum/reagent/blood/Blood = null
				for(var/datum/reagent/blood/B in R.reagent_list)
					if(B)
						Blood = B
						break
				if(!R.total_volume||!R.reagent_list.len)
					dat += "<b>The beaker is empty</b><BR>"
				else if(!Blood)
					dat += "<b>No blood sample found in beaker.</b>"
				else if(!Blood.data)
					dat += "<b>No blood data found in beaker.</b>"
				else
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

									dat += "<b>Disease Agent:</b> [D?"[D.agent]":"none"]<BR>"
									dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
									dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
									dat += "<b>Spread:</b> [(D.spread_text||"none")]<BR><hr><br>"
									dat += "<b>Possible cure:</b> [(D.cure_text||"none")]<BR>"

									if(istype(D, /datum/disease/advance))
										var/datum/disease/advance/A = D
										dat += "<b>Symptoms:</b> "
										var/english_symptoms = list()
										for(var/datum/symptom/S in A.symptoms)
											english_symptoms += S.name
										dat += english_list(english_symptoms)

								else
									dat += "<b>No detectable virus in the sample.</b>"
					else
						dat += "<b>No detectable virus in the sample.</b>"
					dat += "<BR><hr><BR><b>Contains antibodies to:</b> "
					if(Blood.data["resistances"])
						var/list/res = Blood.data["resistances"]
						if(res.len)
							dat += "<ul>"
							for(var/type in Blood.data["resistances"])
								var/disease_name = "Unknown"
								if(!ispath(type))
									var/datum/disease/advance/A = archive_diseases[type]
									if(A)
										disease_name = A.name
								else
									var/datum/disease/D = new type(0, null)
									disease_name = D.name
								dat += "<li>[disease_name]</li>"
							dat += "</ul><BR>"
						else
							dat += "nothing<BR>"
					else
						dat += "nothing<BR>"
		if(TAB_EXPERIMENT)
			dat += "<b>Available Chems:</b><br>"
			dat += "Virus Food: [virusfood_ammount].<br>"
			dat += "Unstable Mutage: [mutagen_ammount].<br>"
			dat += "Plasma: [plasma_ammount].<br>"
			dat += "Synaptizine: [synaptizine_ammount].<br><hr><br>"

			if(!beaker)
				dat += "<b>No beaker inserted.</b><BR>"
			else
				var/datum/reagents/R = beaker.reagents
				var/datum/reagent/blood/Blood = null
				for(var/datum/reagent/blood/B in R.reagent_list)
					if(B)
						Blood = B
						break
				if(!R.total_volume||!R.reagent_list.len)
					dat += "<b>The beaker is empty</b><BR>"
				else if(!Blood)
					dat += "<b>No blood sample found in beaker.</b>"
				else if(!Blood.data)
					dat += "<b>No blood data found in beaker.</b>"
				else
					if(Blood.data["viruses"])
						var/list/vir = Blood.data["viruses"]
						if(vir.len)
							for(var/datum/disease/D in Blood.data["viruses"])
								if(!(D.visibility_flags & HIDDEN_PANDEMIC))
									if(!D)
										CRASH("We weren't able to get the advance disease from the archive.")
									if(istype(D, /datum/disease/advance))
										var/datum/disease/advance/A = D
										dat += "<b>Symptoms:</b> "
										var/english_symptoms = list()
										dat += "<ul>"
										for(var/datum/symptom/S in A.symptoms)
											english_symptoms += S.name
										dat += english_list(english_symptoms)+"<br>"
										dat += "</ul>"

								else
									dat += "<b>No detectable virus in the sample.</b>"
				dat += "<br><hr><br>"
				dat += "<b>Inject Sample with:</b><br>"
				dat += "<A href='?src=\ref[src];chem_choice=virusfood'>Virus Food</a><BR>"
				dat += "<A href='?src=\ref[src];chem_choice=mutagen'>Unstable Mutagen</a><BR>"
				dat += "<A href='?src=\ref[src];chem_choice=plasma'>Plasma</a><BR>"
				dat += "<A href='?src=\ref[src];chem_choice=synaptizine'>Synaptizine</a><BR>"
				dat += "<A href='?src=\ref[src];chem_choice=reset'>Reset Virus</a><BR>"

		if(TAB_DATABASE)
			dat += "<b>Database:</b><BR><hr>"
			//describe database here
			var/loop = 0
			dat += "<br><b>Diseases:</b>"
			dat += "<A href='?src=\ref[src];update_virus=1'>Update</a><BR><hr>"
			for(var/datum/disease/type in new_diseases)
				loop++
				dat += "[type.name] "
				dat += "<li><A href='?src=\ref[src];virus=[loop]'>- <i>Make</i></A><br></li>"
			loop = 0
			dat += "<br><b>Symptoms:</b>"
			dat += "<A href='?src=\ref[src];update_symptom=1'>Update</a><BR><hr>"
			for(var/datum/symptom/type in new_symptoms)
				loop++
				dat += "[type.name] "
				dat += "<li><A href='?src=\ref[src];symptom=[loop]'>- <i>Mutate</i></A><br></li>"
			loop = 0
			dat += "<br><b>Vaccines:</b>"
			dat += "<A href='?src=\ref[src];update_cure=1'>Update</a><BR><hr>"
			for(var/type in new_cures)
				loop++
				if(!ispath(type))
					var/datum/disease/DD = archive_diseases[type]
					dat += "[DD.name] "
				else
					var/datum/disease/gn = new type(0, null)
					dat += "[gn.name] "
				dat += "<li><A href='?src=\ref[src];cure=[loop]'> - <i>Make</i></A><br></li>"

	dat += "<hr><BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>"

	var/datum/browser/popup = new(user, "pandemic", "PanD.E.M.I.C 2200")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open(1)
	return

/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(stat & (NOPOWER|BROKEN)) return

		for(var/datum/reagent/R in I.reagents.reagent_list)
			switch(R.id)
				if(R.id == "virusfood")
					virusfood_ammount += R.volume
					I.reagents.remove_reagent("virusfood",R.volume)
					user << "You add the Virus Food into the machine!"
					updateUsrDialog()
				if(R.id == "mutagen")
					mutagen_ammount += R.volume
					I.reagents.remove_reagent("mutagen",R.volume)
					user << "You add the Unstable Mutagen into the machine!"
					updateUsrDialog()
				if(R.id == "plasma")
					plasma_ammount += R.volume
					I.reagents.remove_reagent("plasma",R.volume)
					user << "You add the Plasma into the machine!"
					updateUsrDialog()
				if(R.id == "synaptizine")
					synaptizine_ammount += R.volume
					I.reagents.remove_reagent("synaptizine",R.volume)
					user << "You add the Synaptizine into the machine!"
					updateUsrDialog()

		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return
		src.beaker =  I
		user.drop_item()
		I.loc = forceMove(src)
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(src.beaker)
			beaker.loc = forceMove(src)
		..()
		return
	else
		..()
	return

/obj/machinery/computer/pandemic/proc/is_valid_beaker(var/index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
	else
		usr << "No beaker found!"
		updateUsrDialog()
		return

#undef TAB_ANALYSIS
#undef TAB_EXPERIMENT
#undef TAB_DATABASE
