
//cael - some changes here. the analysis pad is entirely new

/obj/machinery/artifact_analyser
	name = "Artifact Analyser"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/working = 0
	var/accuO = 0
	var/accuT = 0
	var/accuE1 = 0
	var/accuE2 = 0
	var/aorigin = "None"
	var/atrigger = "None"
	var/aeffect1 = "None"
	var/aeffect2 = "None"
	var/list/origin_bonuses
	var/list/trigger_bonuses
	var/list/function_bonuses
	var/list/range_bonuses
	var/cur_id = ""
	var/scan_num = 0
	var/obj/machinery/artifact/cur_artifact = null
	var/obj/machinery/analyser_pad/owned_pad = null
	var/list/allorigins = list("Ancient Robots","Martian","Wizard Federation","Extradimensional","Precursor")
	var/list/alltriggers = list("Contact with Living Organism","Heavy Impact","Contact with Energy Source","Contact with Hydrogen","Contact with Corrosive Substance","Contact with Volatile Substance","Contact with Toxins","Exposure to Heat")
	var/list/alleffects = list("Healing Device","Anti-biological Weapon","Non-lethal Stunning Trap","Mechanoid Repair Module","Mechanoid Deconstruction Device","Power Generator","Power Drain","Stellar Mineral Attractor","Agriculture Regulator","Shield Generator","Space-Time Displacer")
	var/list/allranges = list("Constant Short-Range Energy Field","Medium Range Energy Pulses","Long Range Energy Pulses","Extreme Range Energy Pulses","Requires contact with subject")

/obj/machinery/artifact_analyser/New()
	..()
	origin_bonuses = new/list()
	origin_bonuses["ancient"] = 0
	origin_bonuses["martian"] = 0
	origin_bonuses["wizard"] = 0
	origin_bonuses["eldritch"] = 0
	origin_bonuses["precursor"] = 0
	trigger_bonuses = new/list()
	trigger_bonuses["ancient"] = 0
	trigger_bonuses["martian"] = 0
	trigger_bonuses["wizard"] = 0
	trigger_bonuses["eldritch"] = 0
	trigger_bonuses["precursor"] = 0
	function_bonuses = new/list()
	function_bonuses["ancient"] = 0
	function_bonuses["martian"] = 0
	function_bonuses["wizard"] = 0
	function_bonuses["eldritch"] = 0
	function_bonuses["precursor"] = 0
	range_bonuses = new/list()
	range_bonuses["ancient"] = 0
	range_bonuses["martian"] = 0
	range_bonuses["wizard"] = 0
	range_bonuses["eldritch"] = 0
	range_bonuses["precursor"] = 0
	//
	spawn(10)
		owned_pad = locate() in orange(1, src)

/obj/machinery/artifact_analyser/attack_hand(var/mob/user as mob)
	user.machine = src
	var/dat = "<B>Artifact Analyser</B><BR>"
	dat += "<HR><BR>"
	if(!owned_pad)
		dat += "<B><font color=red>Unable to locate analysis pad.</font><BR></b>"
		dat += "<HR><BR>"
	else if (!src.working)
		dat += "<B>Artifact ID:</B> [cur_id]<BR>"
		dat += "<B>Artifact Origin:</B> [aorigin] ([accuO]%)<BR>"
		dat += "<B>Activation Trigger:</B> [atrigger] ([accuT]%)<BR>"
		dat += "<B>Artifact Function:</B> [aeffect1] ([accuE1]%)<BR>"
		dat += "<B>Artifact Range:</B> [aeffect2] ([accuE2]%)<BR><BR>"
		dat += "<HR><BR>"
		dat += "Artifact ID is determined from unique energy emission signatures.<br>"
		dat += "<A href='?src=\ref[src];analyse=1'>Analyse Artifact (Scan number #[scan_num+1])</a><BR>"
		dat += "<A href='?src=\ref[src];upload=1'>Upload/update artifact scan</a><BR>"
		dat += "<A href='?src=\ref[src];print=1'>Print Page</a><BR>"
	else
		dat += "<B>Please wait. Analysis in progress.</B><BR>"
		dat += "<HR><BR>"
	//
	dat += "<A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artanalyser;size=450x500")
	onclose(user, "artanalyser")

/obj/machinery/artifact_analyser/process()
	if(!owned_pad)
		for(var/obj/machinery/analyser_pad/pad in range(1))
			owned_pad = pad
			break

/obj/machinery/artifact_analyser/proc/AA_FailedAnalysis(var/failtype)
	switch(failtype)
		if(1)
			src.aorigin = "Failed to Identify"
			if (prob(20)) src.aorigin = pick(src.allorigins)
		if(2)
			src.atrigger = "Failed to Identify"
			if (prob(20)) src.atrigger = pick(src.alltriggers)
		if(3)
			src.aeffect1 = "Failed to Identify"
			if (prob(20)) src.aeffect1 = pick(src.alleffects)
		if(4)
			src.aeffect2 = "Failed to Identify"
			if (prob(20)) src.aeffect2 = pick(src.allranges)

/obj/machinery/artifact_analyser/proc/AA_Analyse()
	if(!cur_artifact)
		return
	src.accuO = 5 + rand(0,10) + origin_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	src.accuT = 5 + rand(0,10) + trigger_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	src.accuE1 = 5 + rand(0,10) + function_bonuses[cur_artifact.origin] + cur_artifact.activated * 50
	src.accuE2 = 5 + rand(0,10) + range_bonuses[cur_artifact.origin] + cur_artifact.activated * 50

	//keep any correctly determined properties the same
	var/origin_correct = 0
	var/trigger_correct = 0
	var/function_correct = 0
	var/range_correct = 0
	if(cur_id == cur_artifact.display_id)
		if(src.aorigin == cur_artifact.origin)
			origin_correct = 1

		if(src.atrigger == cur_artifact.my_effect.trigger)
			trigger_correct = 1
		else if(src.atrigger == cur_artifact.my_effect.triggerX)
			trigger_correct = 1

		if(src.aeffect1 == cur_artifact.my_effect.effecttype)
			function_correct = 1

		if(src.aeffect2 == cur_artifact.my_effect.effectmode)
			range_correct = 1

	if (src.accuO > 100) src.accuO = 100
	if (src.accuT > 100) src.accuT = 100
	if (src.accuE1 > 100) src.accuE1 = 100
	if (src.accuE2 > 100) src.accuE2 = 100
	// Roll to generate report
	if (prob(accuO) || origin_correct)
		switch(cur_artifact.origin)
			if("ancient") src.aorigin = "Ancient Robots"
			if("martian") src.aorigin = "Martian"
			if("wizard") src.aorigin = "Wizard Federation"
			if("eldritch") src.aorigin = "Extradimensional"
			if("precursor") src.aorigin = "Precursor"
			else src.aorigin = "Unknown Origin"
		origin_bonuses[cur_artifact.origin] += 10
	else
		AA_FailedAnalysis(1)
		origin_bonuses[cur_artifact.origin] += 5
	if (prob(accuT) || trigger_correct)
		switch(cur_artifact.my_effect.trigger)
			if("touch") src.atrigger = "Contact with Living Organism"
			if("force") src.atrigger = "Heavy Impact"
			if("energy") src.atrigger = "Contact with Energy Source"
			if("chemical")
				switch(cur_artifact.my_effect.triggerX)
					if("hydrogen") src.atrigger = "Contact with Hydrogen"
					if("corrosive") src.atrigger = "Contact with Corrosive Substance"
					if("volatile") src.atrigger = "Contact with Volatile Substance"
					if("toxin") src.atrigger = "Contact with Toxins"
			if("heat") src.atrigger = "Exposure to Heat"
			else src.atrigger = "Unknown Trigger"
		trigger_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(2)
		trigger_bonuses[cur_artifact.origin] += 1
	if (prob(accuE1) || function_correct)
		switch(cur_artifact.my_effect.effecttype)
			if("healing")  src.aeffect1 = "Healing Device"
			if("injure") src.aeffect1 = "Anti-biological Weapon"
			if("stun") src.aeffect1 = "Non-lethal Stunning Trap"
			if("roboheal") src.aeffect1 = "Mechanoid Repair Module"
			if("robohurt") src.aeffect1 = "Mechanoid Deconstruction Device"
			if("cellcharge") src.aeffect1 = "Power Generator"
			if("celldrain") src.aeffect1 = "Power Drain"
			if("planthelper") src.aeffect1 = "Agriculture Regulator"
			if("forcefield") src.aeffect1 = "Shield Generator"
			if("teleport") src.aeffect1 = "Space-Time Displacer"
			else src.aeffect1 = "Unknown Effect"
		function_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(3)
		function_bonuses[cur_artifact.origin] += 1
	if (prob(accuE2) || range_correct)
		switch(cur_artifact.my_effect.effectmode)
			if("aura") src.aeffect2 = "Constant Short-Range Energy Field"
			if("pulse")
				if(cur_artifact.my_effect.aurarange > 7) src.aeffect2 = "Long Range Energy Pulses"
				else src.aeffect2 = "Medium Range Energy Pulses"
			if("worldpulse") src.aeffect2 = "Extreme Range Energy Pulses"
			if("contact") src.aeffect2 = "Requires contact with subject"
			else src.aeffect2 = "Unknown Range"
		range_bonuses[cur_artifact.origin] += 5
	else
		AA_FailedAnalysis(4)
		range_bonuses[cur_artifact.origin] += 1

	cur_artifact.name = "alien artifact ([cur_artifact.display_id])"
	cur_artifact.desc = "A large alien device. It has a small tag near the bottom that reads \"[cur_artifact.display_id]\"."
	cur_id = cur_artifact.display_id

/obj/machinery/artifact_analyser/Topic(href, href_list)

	if(href_list["analyse"])
		if(owned_pad)
			var/turf/pad_turf = get_turf(owned_pad)
			var/findarti = 0
			for(var/obj/machinery/artifact/A in pad_turf.contents)
				findarti++
				cur_artifact = A
			if (findarti == 1)
				cur_artifact.anchored = 1
				src.working = 1
				src.icon_state = "analyser_processing"
				var/time = rand(30,50) + max(0, 300 - scan_num * 10)
				/*for(var/i = artifact_research.starting_tier, i <= artifact_research.max_tiers, i++)
					for(var/datum/artiresearch/R in artifact_research.researched_items[i])
						if (R.bonustype == "analyser") time -= R.bonusTime*/
				time *= 10
				var/message = "<b>[src]</b> states, \"Commencing analysis.\""
				src.visible_message(message, message)
				spawn(time)
					src.working = 0
					icon_state = "analyser"
					cur_artifact.anchored = 0
					if(cur_artifact.loc == pad_turf)
						AA_Analyse()
						scan_num++
						message = "<b>[src]</b> states, \"Analysis complete.\""
						src.visible_message(message, message)
			else if (findarti > 1)
				var/message = "<b>[src]</b> states, \"Cannot analyse. Too many artifacts on pad.\""
				src.visible_message(message, message)
			else
				var/message = "<b>[src]</b> states, \"Cannot analyse. No artifact found.\""
				src.visible_message(message, message)

	if(href_list["upload"] && cur_id != "")
		//add new datum to every DB in the world
		for(var/obj/machinery/computer/artifact_database/DB in world)
			var/update = 0
			for(var/datum/catalogued_artifact/CA in DB.catalogued_artifacts)
				if(CA.display_id == cur_id)
					//already there, so update it
					update = 1
					CA.origin = aorigin + " ([accuO]%)"
					CA.trigger = atrigger + " ([accuT]%)"
					CA.effecttype = aeffect1 + " ([accuE1]%)"
					CA.effectmode = aeffect2 + " ([accuE2]%)"
			if(!update)
				//not there, so add it
				var/datum/catalogued_artifact/CA = new()
				CA.display_id = cur_id
				CA.origin = aorigin + " ([accuO]%)"
				CA.trigger = atrigger + " ([accuT]%)"
				CA.effecttype = aeffect1 + " ([accuE1]%)"
				CA.effectmode = aeffect2 + " ([accuE2]%)"
				DB.catalogued_artifacts.Add(CA)

	if(href_list["print"])
		var/r = "Artifact Analysis Report (Scan #[scan_num])<hr>"
		r += "<B>Artifact ID:</B> [cur_id] (determined from unique energy emission signatures)<BR>"
		r += "<B>Artifact Origin:</B> [aorigin] ([accuO]%)<BR>"
		r += "<B>Activation Trigger:</B> [atrigger] ([accuT]%)<BR>"
		r += "<B>Artifact Function:</B> [aeffect1] ([accuE1]%)<BR>"
		r += "<B>Artifact Range:</B> [aeffect2] ([accuE2]%)<BR><BR>"
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
		P.name = "Artifact Analysis Report #[scan_num]"
		P.info = r
		for(var/mob/O in hearers(src, null))
			O.show_message("\icon[src] \blue The [src.name] prints a sheet of paper", 3)

	if(href_list["close"])
		usr << browse(null, "window=artanalyser")
		usr.machine = null

	src.updateDialog()

//stick artifacts onto this then switch the analyser on
/obj/machinery/analyser_pad
	name = "artifact analysis pad"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'stationobjs.dmi'
	icon_state = "tele0"
	anchored = 1
	density = 0

/obj/machinery/analyser_pad/New()
	..()
	/*spawn(10)
		for(var/obj/machinery/artifact_analyser/analyser in orange(1))
			world << "pad found analyser"
			if(!analyser.owned_pad)
				analyser.owned_pad = src
				world << "pad set analyser to self"
				break*/
