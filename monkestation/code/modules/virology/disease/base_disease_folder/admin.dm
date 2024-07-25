/proc/make_custom_virus(client/C, mob/living/infectedMob)
	if(!istype(C) || !C.holder)
		return 0

	var/datum/disease/advanced/D = new /datum/disease/advanced()
	D.origin = "Badmin"

	var/list/known_forms = list()
	for (var/disease_type in subtypesof(/datum/disease/advanced))
		var/datum/disease/advanced/d_type = disease_type
		known_forms[initial(d_type.form)] = d_type

	known_forms += "custom"

	/*
	if (islist(GLOB.inspectable_diseases) && GLOB.inspectable_diseases.len > 0)
		known_forms += "infect with an already existing pathogen"
	*/

	var/chosen_form = input(C, "Choose a form for your pathogen", "Choose a form") as null | anything in known_forms
	if (!chosen_form)
		qdel(D)
		return

	if (chosen_form == "infect with an already existing pathogen")
		var/list/existing_pathogen = list()
		for(var/datum/disease/advanced/dis as anything in GLOB.inspectable_diseases)
			existing_pathogen += dis
		var/chosen_pathogen = input(C, "Choose a pathogen", "Choose a pathogen") as null | anything in existing_pathogen
		if (!chosen_pathogen)
			qdel(D)
			return
		var/datum/disease/advanced/dis = chosen_pathogen
		D = dis.Copy()
		D.origin = "[D.origin] (Badmin)"
	else
		if (chosen_form == "custom")
			var/form_name = copytext(sanitize(input(C, "Give your custom form a name", "Name your form", "Pathogen")  as null | text),1,MAX_NAME_LEN)
			if (!form_name)
				qdel(D)
				return
			D.form = form_name
			D.max_stages = input(C, "How many stages will your pathogen have?", "Custom Pathogen", D.max_stages) as num
			D.max_stages = clamp(D.max_stages,1,99)
			D.infectionchance = input(C, "What will be your pathogen's infection chance?", "Custom Pathogen", D.infectionchance) as num
			D.infectionchance = clamp(D.infectionchance,0,100)
			D.infectionchance_base = D.infectionchance
			D.stageprob = input(C, "What will be your pathogen's progression speed?", "Custom Pathogen", D.stageprob) as num
			D.stageprob = clamp(D.stageprob,0,100)
			D.stage_variance = input(C, "What will be your pathogen's stage variance?", "Custom Pathogen", D.stage_variance) as num
			D.stageprob = clamp(D.stageprob,-1*D.max_stages,0)
			//D.can_kill = something something a while loop but probably not worth the effort. If you need it for your bus code it yourself.
		else
			var/d_type = known_forms[chosen_form]
			var/datum/disease/advanced/d_inst = new d_type
			D.form = chosen_form
			D.max_stages = d_inst.max_stages
			D.infectionchance = d_inst.infectionchance
			D.stageprob = d_inst.stageprob
			D.stage_variance = d_inst.stage_variance
			D.can_kill = d_inst.can_kill.Copy()
			qdel(d_inst)

		D.strength = input(C, "What will be your pathogen's strength? (1-50 is trivial to cure. 50-100 requires a bit more effort)", "Pathogen Strength", D.infectionchance) as num
		D.strength = clamp(D.strength,0,100)

		D.robustness = input(C, "What will be your pathogen's robustness? (1-100) Lower values mean that infected can carry the pathogen without getting affected by its symptoms.", "Pathogen Robustness", D.infectionchance) as num
		D.robustness = clamp(D.strength,0,100)

		D.uniqueID = clamp(input(C, "You can specify the 4 number ID for your Pathogen, or just use this randomly generated one.", "Pick a unique ID", rand(0,9999)) as num, 0, 9999)

		D.subID = rand(0,9999)
		D.childID = 0

		for(var/i = 1; i <= D.max_stages; i++)  // run through this loop until everything is set
			var/datum/symptom/symptom = input(C, "Choose a symptom for your disease's stage [i] (out of [D.max_stages])", "Choose a Symptom") as null | anything in (subtypesof(/datum/symptom))
			if (!symptom)
				return 0

			var/datum/symptom/e = new symptom(D)
			e.stage = i
			e.chance = input(C, "Choose the default chance for this effect to activate", "Effect", e.chance) as null | num
			e.chance = clamp(e.chance,0,100)
			e.max_chance = input(C, "Choose the maximum chance for this effect to activate", "Effect", e.max_chance) as null | num
			e.max_chance = clamp(e.max_chance,0,100)
			e.multiplier = input(C, "Choose the default strength for this effect", "Effect", e.multiplier) as null | num
			e.multiplier = clamp(e.multiplier,0,100)
			e.max_multiplier = input(C, "Choose the maximum strength for this effect", "Effect", e.max_multiplier) as null | num
			e.max_multiplier = clamp(e.max_multiplier,0,100)

			D.log += "Added [e.name] at [e.chance]% chance and [e.multiplier] strength<br>"
			D.symptoms += e

		if (alert("Do you want to specify which antigen are selected?","Choose your Antigen","Yes","No") == "Yes")
			D.antigen = list(input(C, "Choose your first antigen", "Choose your Antigen") as null | anything in GLOB.all_antigens)
			if (!D.antigen)
				D.antigen = list(input(C, "Choose your second antigen", "Choose your Antigen") as null | anything in GLOB.all_antigens)
			else
				D.antigen |= input(C, "Choose your second antigen", "Choose your Antigen") as null | anything in GLOB.all_antigens
			if (!D.antigen)
				if (alert("Beware, your disease having no antigen means that it's incurable. We can still roll some random antigen for you. Are you sure you want your pathogen to have no antigen anyway?","Choose your Antigen","Yes","No") == "No")
					D.roll_antigen()
				else
					D.antigen = list()
		else
			D.roll_antigen()

		var/list/randomhexes = list("8","9","a","b","c","d","e")
		D.color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		D.pattern = rand(1,6)
		D.pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		if (alert("Do you want to specify the appearance of your pathogen in a petri dish?","Choose your appearance","Yes","No") == "Yes")
			D.color = tgui_color_picker(C, "Choose the color of the dish", "Cosmetic")
			D.pattern = input(C, "Choose the shape of the pattern inside the dish (1 to 6)", "Cosmetic",rand(1,6)) as num
			D.pattern = clamp(D.pattern,1,6)
			D.pattern_color = tgui_color_picker(C, "Choose the color of the pattern", "Cosmetic")

		D.spread_flags = 0
		if (alert("Can this virus spread_flags into blood? (warning! if choosing No, this virus will be impossible to sample and analyse!)","Spreading Vectors","Yes","No") == "Yes")
			D.spread_flags |= DISEASE_SPREAD_BLOOD
		if(D.allowed_transmission & DISEASE_SPREAD_CONTACT_SKIN)
			if (alert("Can this virus spread_flags by contact, and on items?","Spreading Vectors","Yes","No") == "Yes")
				D.spread_flags |= DISEASE_SPREAD_CONTACT_SKIN
		if(D.allowed_transmission & DISEASE_SPREAD_AIRBORNE)
			if (alert("Can this virus spread_flags through the air?","Spreading Vectors","Yes","No") == "Yes")
				D.spread_flags |= DISEASE_SPREAD_AIRBORNE
		/*
		if(D.allowed_transmission & SPREAD_COLONY)
			if (alert("Does this fungus prefer suits? Exclusive with contact/air.","Spreading Vectors","Yes","No") == "Yes")
				D.spread_flags |= SPREAD_COLONY
				D.spread_flags &= ~(SPREAD_BLOOD|SPREAD_AIRBORNE)
		if(D.allowed_transmission & SPREAD_MEMETIC)
			if (alert("Can this virus spread_flags through words?","Spreading Vectors","Yes","No") == "Yes")
				D.spread_flags |= SPREAD_MEMETIC
		*/
		GLOB.inspectable_diseases -= "[D.uniqueID]-[D.subID]"//little odds of this happening thanks to subID but who knows
		D.update_global_log()

		if (alert("Lastly, do you want this pathogen to be added to the station's Database? (allows medical HUDs to locate infected mobs, among other things)","Pathogen Database","Yes","No") == "Yes")
			D.addToDB()

	if (istype(infectedMob))
		D.log += "<br />[ROUND_TIME()] Infected [key_name(infectedMob)]"
		if(!length(infectedMob.diseases))
			infectedMob.diseases = list()
		infectedMob.diseases += D
		var/nickname = ""
		if ("[D.uniqueID]-[D.subID]" in GLOB.virusDB)
			var/datum/data/record/v = GLOB.virusDB["[D.uniqueID]-[D.subID]"]
			nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
		log_admin("[infectedMob] was infected with [D.form] #[D.uniqueID]-[D.subID][nickname] by [C.ckey]")
		message_admins("[infectedMob] was infected with  [D.form] #["[D.uniqueID]"]-["[D.subID]"][nickname] by [C.ckey]")
		D.AddToGoggleView(infectedMob)
	else
		var/obj/item/weapon/virusdish/dish = new(C.mob.loc)
		dish.contained_virus = D
		dish.growth = rand(5, 50)
		dish.name = "growth dish (Unknown [D.form])"
		if ("[D.uniqueID]-[D.subID]" in GLOB.virusDB)
			dish.name = "growth dish ([D.name(TRUE)])"
		dish.update_icon()

	return 1

/mob/var/disease_view = FALSE
/client/proc/disease_view()
	set category = "Admin.Debug"
	set name = "Disease View"
	set desc = "See viro Overlay"

	if(!holder)
		return
	if(!mob)
		return
	if(mob.disease_view)
		mob.stopvirusView()
	else
		mob.virusView()
	mob.disease_view = !mob.disease_view

/client/proc/diseases_panel()
	set category = "Admin.Logging"
	set name = "Disease Panel"
	set desc = "See diseases and disease information"

	if(!holder)
		return
	holder.diseases_panel()

/datum/admins/var/viewingID

/datum/admins/proc/diseases_panel()
	if (!GLOB.inspectable_diseases || !length(GLOB.inspectable_diseases))
		alert("There are no pathogen in the round currently!")
		return
	var/list/logs = list()
	var/dat = {"<html>
		<head>
		<style>
		table,h2 {
		font-family: Arial, Helvetica, sans-serif;
		border-collapse: collapse;
		}
		td, th {
		border: 1px solid #dddddd;
		padding: 8px;
		}
		tr:nth-child(even) {
		background-color: #dddddd;
		}
		</style>
		</head>
		<body>
		<h2 style="text-align:center">Disease Panel</h2>
		<table>
		<tr>
		<th style="width:2%">Disease ID</th>
		<th style="width:1%">Origin</th>
		<th style="width:1%">in Database?</th>
		<th style="width:1%">Infected People</th>
		<th style="width:1%">Infected Items</th>
		<th style="width:1%">in Growth Dishes</th>
		</tr>
		"}

	for (var/ID in GLOB.inspectable_diseases)
		var/infctd_mobs = 0
		var/infctd_mobs_dead = 0
		var/infctd_items = 0
		var/dishes = 0
		for (var/mob/living/L in GLOB.mob_list)
			for(var/datum/disease/advanced/D as anything in L.diseases)
				if (ID == "[D.uniqueID]-[D.subID]")
					infctd_mobs++
					if (L.stat == DEAD)
						infctd_mobs_dead++
					if(!length(logs["[ID]"]))
						logs["[ID]"]= list()
					logs["[ID]"] += "[L]"
					logs["[ID]"]["[L]"] = D.log

		for (var/obj/item/I in GLOB.infected_items)
			for(var/datum/disease/advanced/D as anything in I.viruses)
				if (ID == "[D.uniqueID]-[D.subID]")
					infctd_items++
					if(!length(logs["[ID]"]))
						logs["[ID]"] = list()
					logs["[ID]"] += "[I]"
					logs["[ID]"]["[I]"] = D.log
		for (var/obj/item/weapon/virusdish/dish in GLOB.virusdishes)
			if (dish.contained_virus)
				if (ID == "[dish.contained_virus.uniqueID]-[dish.contained_virus.subID]")
					dishes++
					if(!length(logs["[ID]"]))
						logs["[ID]"] = list()
					logs["[ID]"] += "[dish]"
					logs["[ID]"]["[dish]"] = dish.contained_virus.log

		var/datum/disease/advanced/D = GLOB.inspectable_diseases[ID]
		dat += {"<tr>
			<td><a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];diseasepanel_examine=["[D.uniqueID]"]-["[D.subID]"]'>[D.form] #["[D.uniqueID]"]-["[D.subID]"]</a></td>
			<td>[D.origin]</td>
			<td><a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];diseasepanel_toggledb=\ref[D]'>[(ID in GLOB.virusDB) ? "Yes" : "No"]</a></td>
			<td><a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];diseasepanel_infectedmobs=\ref[D]'>[infctd_mobs][infctd_mobs_dead ? " (including [infctd_mobs_dead] dead)" : "" ]</a></td>
			<td><a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];diseasepanel_infecteditems=\ref[D]'>[infctd_items]</a></td>
			<td><a href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];diseasepanel_dishes=\ref[D]'>[dishes]</a></td>
			</tr>
			"}

	dat += {"</table>
		"}
	dat += {"<table>
		<tr>
		<th style="width:2%">Disease Logs</th>
		</tr>"}
	for(var/item in logs[viewingID])
		dat += {"<tr>
		<td><b>[item] - [viewingID]</b><br>[logs[viewingID][item]]
		</tr>
		"}
	dat += {"</table>
		</body>
		</html>
	"}
	usr << browse(dat, "window=diseasespanel;size=705x450")

/datum/admins/Topic(href, href_list)
	. = ..()
	if(href_list["diseasepanel_examine"])
		viewingID = href_list["diseasepanel_examine"]
		diseases_panel()
