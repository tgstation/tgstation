var/list/genetics_computers = list()

/obj/machinery/computer/genetics
	name = "genetics console"
	icon = 'computer.dmi'
	icon_state = "scanner"
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/genetics_scanner/scanner = null //Linked scanner. For scanning.
	var/list/equipment = list(0,0,0,0)
	// Injector, Analyser, Emitter, Reclaimer
	var/datum/bioEffect/currently_browsing = null
	var/datum/geneticsResearchEntry/tracked_research = null

	var/botbutton_html = ""
	var/info_html = ""
	var/topbotbutton_html = ""

	var/list/buffered = new/list()
	var/list/filesToBuffer = list(
	'DNAorbit.gif',
	'DNAorbitstatic.png',
	'dnabutt.png',
	'dnabuttUnk.png',
	'dnabuttAct.png',
	'dnabuttRes.png',
	'bpA.png',
	'bpT.png',
	'bpC.png',
	'bpG.png',
	'bpX.png',
	'bpUnk0.png',
	'bpUnk1.png',
	'bpUnk2.png',
	'bpUnk3.png',
	'bpUnk4.png',
	'bpUnk5.png',
	'eqResearch.png',
	'eqAnalyser.png',
	'eqEmitter.png',
	'eqReclaimer.png',
	'eqInjector.png',
	'bpSep.png',
	'bpSep-green.png',
	'bpSep-red.png',
	'bpSep-blue.png',
	'bpSep-locked.png',
	'bpSpacer.png',
	'gprint.png'
	)

	var/print = 0
	var/printlabel = null

/obj/machinery/computer/genetics/New()
	..()
	genetics_computers += src
	spawn(5)
		src.scanner = locate(/obj/machinery/genetics_scanner, orange(1,src))
		return
	return

/obj/machinery/computer/genetics/disposing()
	genetics_computers -= src
	..()

/obj/machinery/computer/genetics/attackby(obj/item/W as obj, mob/user as mob)
	if((istype(W, /obj/item/screwdriver)) && ((src.stat & BROKEN) || !src.scanner))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			user << "\blue The broken glass falls out."
			var/obj/computerframe/A = new /obj/computerframe( src.loc )
			new /obj/item/shard( src.loc )
			var/obj/item/circuitboard/genetics/M = new /obj/item/circuitboard/genetics( A )
			for (var/obj/C in src)
				C.set_loc(src.loc)
			A.circuit = M
			A.state = 3
			A.icon_state = "3"
			A.anchored = 1
			qdel(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/genetics/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/genetics/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	if(!buffered.Find(usr.client))
		for(var/a in filesToBuffer)
			user << browse_rsc(a)
		buffered.Add(usr.client)

	var/basicinfo = {"<b>Materials:</b> [genResearch.researchMaterial] * "}

	botbutton_html = "<p><small>"
	if (scanner && scanner.occupant)
		basicinfo += {"<b>Scanner Occupant:</b> [scanner.occupant.name]"}
		botbutton_html += {"<a href='?src=\ref[src];menu=potential'>Potential</a>  "}
		botbutton_html += {"<a href='?src=\ref[src];menu=mutations'>Mutations</a>  "}
		if (istype(scanner.occupant,/mob/living/carbon/human/))
			botbutton_html += {"<a href='?src=\ref[src];menu=appearance'>Change Appearance</a>  "}
	else
		basicinfo += {"<b>Scanner Occupant:</b> None"}
	botbutton_html += "<br>"
	botbutton_html += {"<a href='?src=\ref[src];menu=research'>Research Menu</a>  "}

	if (genResearch.isResearched(/datum/geneticsResearchEntry/checker))
		botbutton_html += {"<img alt="Analyser Cooldown" src="eqAnalyser.png" style="border-style: none">: [max(0,round((src.equipment[2] - world.time) / 10))] "}
	if (genResearch.isResearched(/datum/geneticsResearchEntry/rademitter))
		botbutton_html += {"<img alt="Emitter Cooldown" src="eqEmitter.png" style="border-style: none">: [max(0,round((src.equipment[3] - world.time) / 10))] "}
	if (genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer))
		botbutton_html += {"<img alt="Reclaimer Cooldown" src="eqReclaimer.png" style="border-style: none">: [max(0,round((src.equipment[4] - world.time) / 10))] "}
	if (genResearch.isResearched(/datum/geneticsResearchEntry/injector))
		botbutton_html += {"<img alt="Injector Cooldown" src="eqInjector.png" style="border-style: none">: [max(0,round((src.equipment[1] - world.time) / 10))] "}
	if (src.tracked_research)
		botbutton_html += {"<img alt="[src.tracked_research.name]" src="eqResearch.png" style="border-style: none">: [max(0,round((src.tracked_research.finishTime - world.time) / 10))] "}

	botbutton_html += "<br>[basicinfo]"

	//botbutton_html += {"<a href='?src=\ref[src];menu=saveload'>Save / Load</a>  "}
	botbutton_html += "</small></p>"

	var/html = {"<html><head><title>GeneTek</title>
				<STYLE type=text/css>
				A:link {COLOR: #EAFDE6}
				A:visited {COLOR: #88C425}
				A:hover{COLOR: #BEF202}
				A {font-family:"Arial", sans-serif; font-size:14px; COLOR: #EAFDE6;}
				P {font-family:"Arial", sans-serif; font-size:14px; COLOR: #EAFDE6;}
				</STYLE>
				</head>
				<body style="overflow: hidden; background-color: rgb(27, 103, 107); font-family:"Arial", sans-serif; font-size:14px; COLOR: #800080;">
				<span></span>
				<big style="font-family: Helvetica,Arial,sans-serif; color: rgb(234, 253, 230); font-style: italic;">GeneTek Console v1</big>
				<table style="text-align: left; background-color: rgb(27, 103, 107); width: 700px; height: 335px;" border="0" cellpadding="0" cellspacing="0">
				<tbody><tr><td style="width: 183px;">
				<img style="width: 182px; height: 300px;" alt="" src="DNAorbit.gif"></td>
				<td><table style="text-align: left; width: 100%; height: 100%;" border="0" cellpadding="0" cellspacing="0"><tbody>
				<tr><td style="vertical-align: middle; height: 20%;">[topbotbutton_html]</td></tr>
				<tr><td valign="middle"><div style="overflow:auto;width:517px; height:240px; padding:0px 0px 0px 0px; margin:0px 0 0px 0;margin:0 auto;">[info_html]</div></td></tr>
				</tbody></table></td></tr>
				<tr><td valign="middle" align="middle"><a href='?src=\ref[src];print=1'><img alt="" src="gprint.png" style="border-style: none"></a><br>
				<a href='?src=\ref[src];printlabel=1'><small>Label: [src.printlabel ? "[src.printlabel]" : "No Label"]</small></a></td>
				<td style="vertical-align: middle; height: 40px;">[botbutton_html]</td></tr>
				</tbody></table>
				<span></span></body></html>
				"}

	user.machine = src
	add_fingerprint(user)

	if(print) //Hilariously hacky temporary print thing.
		print = 0

		var/temp_html = {"
		<script language='javascript' type='text/javascript'>
		window.onload = function() {
    	var anchors = document.getElementsByTagName("a");
    	for (var i = 0; i < anchors.length; i++)
    	{
        	anchors\[i\].onclick = function() {return(false);};
        }
        };
        </script>
        "} + html

		temp_html = replacetext(temp_html, "DNAorbit.gif", "DNAorbitstatic.png")

		playsound(src.loc, 'printer_dotmatrix.ogg', 50, 1)
		var/obj/item/paper/p = new (src.loc)
		p.sizex = 730
		p.sizey = 415
		if (src.printlabel)
			p.name = src.printlabel
		else
			p.name = "Genetics Console Paper"
		p.info = temp_html

	user << browse(html, "window=genetics;size=730x415;can_resize=0;can_minimize=0")
	onclose(user, "genetics")
	return

/obj/machinery/computer/genetics/proc/checkOccupant()
	if(!scanner)
		info_html = "<p>No linked scanner detected. Cannot complete operation.</p>"
		src.updateUsrDialog()
		return 1
	if (!scanner.occupant)
		info_html = "<p>The linked scanner is currently empty.</p>"
		src.updateUsrDialog()
		return 1
	if(!istype(scanner.occupant.bioHolder,/datum/bioHolder/))
		info_html = "<p>Scanner occupant's DNA structure is corrupt.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/proc/bioEffect_sanity_check(var/datum/bioEffect/E)
	if(!istype(E,/datum/bioEffect/))
		info_html = "<p>Unable to scan gene. The gene may be corrupt.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/proc/sample_sanity_check(var/datum/computer/file/genetics_scan/S)
	if (!istype(S,/datum/computer/file/genetics_scan/))
		info_html = "<p>Unable to scan DNA Sample. The sample may be corrupt.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/proc/research_sanity_check(var/datum/geneticsResearchEntry/R)
	if (!istype(R,/datum/geneticsResearchEntry/))
		info_html = "<p>Invalid research article.</p>"
		src.updateUsrDialog()
		return 1
	return 0

/obj/machinery/computer/genetics/Topic(href, href_list)

	if(href_list["viewpool"])

		if(checkOccupant()) return
		var/datum/bioEffect/E = locate(href_list["viewpool"])
		if (bioEffect_sanity_check(E)) return

		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("pool")

		info_html = {"<p><b>[genResearch.researchedMutations[E.id] >= 1 ? E.name : "Unknown Mutation"]</b>"}
		if(src.equipment_available("precision_emitter",E))
			info_html += " <a href='?src=\ref[src];Prademitter=\ref[E]'><small>(Scramble)</small></a>"
		if(src.equipment_available("reclaimer",E))
			info_html += " <a href='?src=\ref[src];reclaimer=\ref[E]'><small>(Reclaim)</small></a>"
		info_html += "</p><br>"

		info_html += src.ui_build_mutation_research(E)

		info_html += "<p> Sequence: <br>"
		var/list/build = src.ui_build_sequence(E,"pool")
		info_html += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

		if(E.dnaBlocks.sequenceCorrect())
			info_html += "<p>Sequence Stable. <a href='?src=\ref[src];activatepool=\ref[E]'>Activate?</a></p>"
		else if (src.equipment_available("analyser"))
			info_html += "<p><a href='?src=\ref[src];checkstability=\ref[E]'>Check Sequence Stability</a></p>"

	else if(href_list["sample_viewpool"])

		var/datum/bioEffect/E = locate(href_list["sample_viewpool"])
		if (bioEffect_sanity_check(E)) return
		var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_viewpool"])
		if (sample_sanity_check(sample)) return

		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("sample_pool",sample)

		info_html = {"<p><b>[genResearch.researchedMutations[E.id] >= 1 ? E.name : "Unknown Mutation"]</b></p><br>"}

		info_html += src.ui_build_mutation_research(E,sample)

		info_html += "<p> Sequence : <br>"
		var/list/build = src.ui_build_sequence(E,"sample_pool")
		info_html += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"

	else if(href_list["vieweffect"])

		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["vieweffect"])
		if (bioEffect_sanity_check(E)) return

		var/datum/bioEffect/globalInstance = bioEffectList[E.type]
		src.currently_browsing = E
		topbotbutton_html = ui_build_clickable_genes("active")

		if(globalInstance != null)
			info_html = {"<p><b>[genResearch.researchedMutations[globalInstance.id] >= 1 ? globalInstance.name : "Unknown Mutation"]</b><br>
			[genResearch.researchedMutations[globalInstance.id] >= 1  ? globalInstance.desc : "Research on a non-active instance of this gene is required."]</p>"}
			if (src.equipment_available("injector",E))
				info_html += " <a href='?src=\ref[src];make_injector=\ref[E]'><small>(Create Injector)</small></a>"

			info_html += "<p> Sequence : <br>"
			var/list/build = src.ui_build_sequence(E,"active")
			info_html += "[build[1]]<br>[build[2]]<br>[build[3]]</p><br>"
		else
			info_html = "<p>Error attempting to read gene.</p>"

	else if(href_list["make_injector"])
		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["make_injector"])
		if (bioEffect_sanity_check(E)) return

		var/price = genResearch.injector_cost
		if (genResearch.researchMaterial < price)
			usr << "\red <b>SCANNER ALERT:</b> Not enough research materials to manufacture an injector."
			return
		if (!E.can_make_injector)
			usr << "\red <b>SCANNER ALERT:</b> Cannot make an injector using this gene."
			return

		src.equipment_cooldown("injector")

		genResearch.researchMaterial -= price
		var/obj/item/genetics_injector/dna_injector/I = new /obj/item/genetics_injector/dna_injector(src.loc)
		I.name = "dna injector - [E.name]"
		I.genes += "[E.id]"

		spawn(0)
			usr << link("byond://?src=\ref[src];vieweffect=\ref[E]")

	else if(href_list["checkstability"])
		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["checkstability"])
		if (bioEffect_sanity_check(E)) return

		var/block_count = 0
		var/right_count = 0
		for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
			block_count++
			var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
			var/datum/basePair/bpc = E.dnaBlocks.blockList[i+1]
			if (bp.marker == "locked")
				continue
			if (bp.bpp1 == bpc.bpp1 && bp.bpp2 == bpc.bpp2)
				bp.marker = "blue"
				right_count++
			else
				bp.marker = "red"
		usr << "<b>SCANNER REPORT:</b> [right_count]/[block_count] base pairs stable."

		src.equipment_cooldown("analyser")

		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")

	else if(href_list["rademitter"])
		topbotbutton_html = ""

		if(checkOccupant()) return

		if(scanner.occupant.stat)
			usr << "<b>SCANNER ALERT:</b> Emitter cannot be used on dead or dying patients."
			return

		var/rads = 75
		if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_dampers))
			rads = 30
		scanner.occupant.bioHolder.RemoveAllEffects()
		scanner.occupant.bioHolder.BuildEffectPool()
		scanner.occupant.radiation += rads

		src.equipment_cooldown("emitter")

		usr << "<B>SCANNER:</B> Genes successfully scrambled."

		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["Prademitter"])
		if(checkOccupant()) return
		var/datum/bioEffect/E = locate(href_list["Prademitter"])
		if (bioEffect_sanity_check(E)) return

		if(scanner.occupant.stat)
			usr << "<b>SCANNER ALERT:</b> Emitter cannot be used on dead or dying patients."
			return

		topbotbutton_html = ""

		var/rads = 75
		if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_dampers))
			rads = 30
		scanner.occupant.radiation += rads

		scanner.occupant.bioHolder.RemovePoolEffect(E)
		scanner.occupant.bioHolder.AddRandomNewPoolEffect()

		src.equipment_cooldown("precision_emitter")

		usr << "<b>SCANNER ALERT:</b> Gene successfully scrambled."
		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["reclaimer"])
		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["reclaimer"])
		if (bioEffect_sanity_check(E)) return

		var/reclamation_cap = genResearch.max_material * 1.5
		if (prob(E.reclaim_fail))
			usr << "<b>SCANNER:</b> Reclamation failed."
		else
			var/waste = (E.reclaim_mats + genResearch.researchMaterial) - reclamation_cap
			if (waste == E.reclaim_mats)
				usr << "<b>SCANNER ALERT:</b> Nothing would be gained from reclamation due to material capacity limit. Reclamation aborted."
				return
			else
				genResearch.researchMaterial = min(genResearch.researchMaterial + E.reclaim_mats, reclamation_cap)
				if (waste > 0)
					usr << "<b>SCANNER:</b> Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial]. [waste] units of material wasted due to material capacity limit."
				else
					usr << "<b>SCANNER:</b> Reclamation successful. [E.reclaim_mats] materials gained. Material count now at [genResearch.researchMaterial]."
				scanner.occupant.bioHolder.RemovePoolEffect(E)

		src.equipment_cooldown("reclaimer")
		src.currently_browsing = null
		usr << link("byond://?src=\ref[src];menu=potential")

	else if(href_list["print"])
		print = 1

	else if(href_list["printlabel"])
		var/label = input("Automatically label printouts as what?","[src.name]",src.printlabel) as null|text
		if (!label)
			src.printlabel = null
		else
			src.printlabel = label

	else if(href_list["setseq"])

		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["setseq"])
		if (bioEffect_sanity_check(E)) return

		if(scanner.occupant.bioHolder.effectPool.Find(E))
			if(href_list["setseq1"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq1"])]
				if (bp.marker == "locked")
					usr << "\red <b>SCANNER ERROR:</b> Cannot alter encrypted base pairs. Click lock to attempt decryption."
					return
			else if(href_list["setseq2"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq2"])]
				if (bp.marker == "locked")
					usr << "\red <b>SCANNER ERROR:</b> Cannot alter encrypted base pairs. Click lock to attempt decryption."
					return

		var/input = input(usr, "Select:", "GeneTek") as null|anything in list("G", "T", "C", "A", "Swap Pair")
		if(!input)
			return
		if(checkOccupant())
			return

		var/temp_holder = null

		if(scanner.occupant.bioHolder.effectPool.Find(E)) //Change this to occupant and check if empty aswell.
			if(href_list["setseq1"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq1"])]
				if (input == "Swap Pair")
					temp_holder = bp.bpp1
					bp.bpp1 = bp.bpp2
					bp.bpp2 = temp_holder
				else
					bp.bpp1 = input
			else if(href_list["setseq2"])
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["setseq2"])]
				if (input == "Swap Pair")
					temp_holder = bp.bpp1
					bp.bpp1 = bp.bpp2
					bp.bpp2 = temp_holder
				else
					bp.bpp2 = input
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]") //OH MAN LOOK AT THIS CRAP. FUCK BYOND. (This refreshes the page)
		return

	else if(href_list["marker"])
		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["marker"])
		if (bioEffect_sanity_check(E)) return
		var/datum/basePair/bp = E.dnaBlocks.blockListCurr[text2num(href_list["themark"])]

		if(bp.marker == "locked")
			usr << "\blue <b>SCANNER ALERT:</b> Encryption is a [E.lockedDiff]-character code."
			var/characters = ""
			for(var/X in E.lockedChars)
				characters += "[X] "
			usr << "\blue Possible characters in this code: [characters]"
			var/code = input("Enter decryption code.","Genetic Decryption") as null|text
			if(!code)
				return
			if(lentext(code) != lentext(bp.lockcode))
				usr << "\red <b>SCANNER ALERT:</b> Invalid code length."
				return
			if (code == bp.lockcode)
				var/datum/basePair/bpc = E.dnaBlocks.blockList[text2num(href_list["themark"])]
				bp.bpp1 = bpc.bpp1
				bp.bpp2 = bpc.bpp2
				bp.marker = "green"
				usr << "\blue <b>SCANNER ALERT:</b> Decryption successful. Base pair unlocked."
			else
				if (bp.locktries <= 1)
					bp.lockcode = ""
					for (var/c = E.lockedDiff, c > 0, c--)
						bp.lockcode += pick(E.lockedChars)
					bp.locktries = E.lockedTries
					usr << "\red <b>SCANNER ALERT:</b> Decryption failed. Base pair encryption code has been changed."
				else
					bp.locktries--
					var/length = lentext(bp.lockcode)

					var/list/lockcode_list = list()
					for(var/i=0,i < length,i++)
						//lockcode_list += "[copytext(bp.lockcode,i+1,i+2)]"
						lockcode_list["[copytext(bp.lockcode,i+1,i+2)]"]++

					var/correct_full = 0
					var/correct_char = 0
					var/current
					var/seek = 0
					for(var/i=0,i < length,i++)
						current = copytext(code,i+1,i+2)
						if (current == copytext(bp.lockcode,i+1,i+2))
							correct_full++
							//correct_char++
							//continue
						seek = lockcode_list.Find(current)
						if (seek)
							correct_char++
							lockcode_list[current]--
							if (lockcode_list[current] <= 0)
								lockcode_list -= current

					usr << "\red <b>SCANNER ALERT:</b> Decryption failed."
					usr << "\red [correct_char]/[length] correct characters in entered code."
					usr << "\red [correct_full]/[length] characters in correct position."
					usr << "\red Attempts remaining: [bp.locktries]."
		else
			switch(bp.marker)
				if("green")
					bp.marker = "red"
				if("red")
					bp.marker = "blue"
				if("blue")
					bp.marker = "green"
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]") // i hear ya buddy =(
		return

	else if(href_list["activatepool"])

		if(checkOccupant()) return

		var/datum/bioEffect/E = locate(href_list["activatepool"])
		if (bioEffect_sanity_check(E)) return
		scanner.occupant.bioHolder.ActivatePoolEffect(E)
		usr << link("byond://?src=\ref[src];menu=mutations") //send them to the mutations page.
		return

	else if(href_list["viewopenres"])
		var/datum/geneticsResearchEntry/E = locate(href_list["viewopenres"])
		if (research_sanity_check(E)) return

		topbotbutton_html = ""
		info_html = {"
		<p>[E.name]<br><br>
		[E.desc]</p><br><br>
		<a href='?src=\ref[src];research=\ref[E]'>Research now</a>"}

	else if(href_list["researchmut"])
		var/datum/bioEffect/E = locate(href_list["researchmut"])
		if (bioEffect_sanity_check(E)) return

		topbotbutton_html = ""
		if (!genResearch.addResearch(E))
			usr << "<b>SCANNER ERROR: Unable to begin research.</b>"
		else
			usr << "<b>SCANNER:</b> Research initiated successfully."
		usr << link("byond://?src=\ref[src];viewpool=\ref[E]")
		return

	else if(href_list["researchmut_sample"])
		var/datum/bioEffect/E = locate(href_list["researchmut_sample"])
		if (bioEffect_sanity_check(E)) return
		var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_research"])
		if (sample_sanity_check(sample)) return

		if (!genResearch.addResearch(E))
			usr << "\red <b>SCANNER ERROR:</b> Unable to begin research."
		else
			usr << "<b>SCANNER:</b> Research initiated successfully."

		usr << link("byond://?src=\ref[src];sample_viewpool=\ref[E];sample_to_viewpool=\ref[sample]")
		return

	else if(href_list["research"])
		var/datum/geneticsResearchEntry/E = locate(href_list["research"])
		if (research_sanity_check(E)) return

		topbotbutton_html = ""
		if(genResearch.addResearch(E))
			usr << "<b>SCANNER:</b> Research initiated successfully."
			usr << link("byond://?src=\ref[src];menu=resopen")
		else
			usr << "\red <b>SCANNER ERROR:</b> Unable to begin research."
		return

	else if(href_list["copyself"])

		if(checkOccupant()) return

		usr:bioHolder.CopyOther(scanner.occupant.bioHolder, 0, 0)

		topbotbutton_html = ""
		info_html = "<p>Done ...</p>"

	else if(href_list["delete_sample"])
		var/datum/computer/file/genetics_scan/sample = locate(href_list["delete_sample"])
		if (sample_sanity_check(sample)) return

		info_html = "<p><a href='?src=\ref[src];menu=dna_samples'>[sample.subject_name] DNA sample deleted.</a></p>"

		genResearch.dna_samples -= sample
		qdel(sample)
		src.updateUsrDialog()
		return

	else if(href_list["track_research"])
		var/datum/geneticsResearchEntry/R = locate(href_list["track_research"])
		if (!istype(R,/datum/geneticsResearchEntry/))
			return
		src.tracked_research = R
		usr << link("byond://?src=\ref[src];menu=resrunning")
		return

	else if(href_list["menu"])
		switch(href_list["menu"])
			if("potential")
				topbotbutton_html = ""

				if(checkOccupant()) return

				topbotbutton_html = ui_build_clickable_genes("pool")

				info_html = "<p><b>Occupant</b>: [src.scanner.occupant ? "[src.scanner.occupant.name]" : "None"]</p><br>"
				info_html += "<p>Showing potential mutations</p><br>"
				if(src.equipment_available("emitter"))
					info_html += "<a href='?src=\ref[src];rademitter=1'>Scramble DNA</a>"

			if("sample_potential")
				topbotbutton_html = ""

				var/datum/computer/file/genetics_scan/sample = locate(href_list["sample_to_view_potential"])
				if (sample_sanity_check(sample)) return

				topbotbutton_html = ui_build_clickable_genes("sample_pool",sample)

				info_html = "<p><b>Sample</b>: [sample.subject_name] <small>([sample.subject_uID])</small></p><br>"
				info_html += "<p>Showing potential mutations <small><a href='?src=\ref[src];menu=dna_samples'>(Back)</a></small></p><br>"

			if("mutations")
				topbotbutton_html = ""

				if(checkOccupant()) return

				topbotbutton_html = ui_build_clickable_genes("active")

				info_html = "<p><b>Occupant</b>: [src.scanner.occupant ? "[src.scanner.occupant.name]" : "None"]</p><br>"
				info_html += "<p>Showing active mutations</p>"

			if("research")
				topbotbutton_html = {"<p><b>Research Menu</b><br>
				<b>Research Material:</b> [genResearch.researchMaterial]<br>
				<b>Research Budget:</b> [wagesystem.research_budget] Credits<br>
				<b>Mutations Researched:</b> [genResearch.researchedMutations.len]
				</p>"}
				info_html = {"<br>

				<a href='?src=\ref[src];menu=buymats'>Purchase Additional Materials</a><br>
				<a href='?src=\ref[src];menu=resopen'>Available Research</a><br>
				<a href='?src=\ref[src];menu=resrunning'>Research in Progress</a><br>
				<a href='?src=\ref[src];menu=resfin'>Finished Research</a><br>
				<a href='?src=\ref[src];menu=dna_samples'>View DNA Samples</a><br>
				"}

			if("resopen")
				topbotbutton_html = "<p><b>Available Research</b> - ([genResearch.researchMaterial] Research Materials)</p>"
				var/lastTier = -1
				info_html = ""
				for(var/R in genResearch.researchTreeTiered)
					if(text2num(R) == 0) continue
					var/list/tierList = genResearch.researchTreeTiered[R]
					if(text2num(R) != lastTier)
						info_html += "[info_html ? "<br>" : ""]<p><b>Tier [text2num(R)]:</b></p>"

					for(var/datum/geneticsResearchEntry/C in tierList)
						if(!C.meetsRequirements())
							continue

						var/research_cost = C.researchCost
						if (genResearch.cost_discount)
							research_cost -= round(research_cost * genResearch.cost_discount)
						var/research_time = C.researchTime
						if (genResearch.time_discount)
							research_time -= round(research_time * genResearch.time_discount)
						if (research_time)
							research_time = round(research_time / 10)

						info_html += "<a href='?src=\ref[src];viewopenres=\ref[C]'>• [C.name] (Cost: [research_cost] * Time: [research_time] sec)</a><br>"

			if("resrunning")
				topbotbutton_html = "<p><b>Research in Progress</b></p>"
				info_html = "<p>"
				for(var/datum/geneticsResearchEntry/R in genResearch.currentResearch)
					info_html += "• [R.name] - [round((R.finishTime - world.time) / 10)] seconds left."
					if (R != src.tracked_research)
						info_html += " <small><a href='?src=\ref[src];track_research=\ref[R]'>(Track)</a></small>"
					info_html += "<br>"
				info_html += "</p>"

			if("buymats")
				var/amount = input("50 credits per 1 point.","Buying Materials") as null|num
				if (amount + genResearch.researchMaterial > genResearch.max_material)
					amount = genResearch.max_material - genResearch.researchMaterial
					usr << "You cannot exceed [genResearch.max_material] research materials with this option."
				if (!amount || amount <= 0)
					return

				var/cost = amount * 50
				if (cost > wagesystem.research_budget)
					info_html = "<p>Insufficient research budget to make that transaction.</p>"
				else
					info_html = "<p>Transaction successful.</p>"
					wagesystem.research_budget -= cost
					genResearch.researchMaterial += amount

			if("resfin")
				topbotbutton_html = "<p><b>Finished Research</b></p>"
				var/lastTier = -1
				info_html = "<p>"
				for(var/R in genResearch.researchTreeTiered)
					if(text2num(R) == 0) continue
					var/list/tierList = genResearch.researchTreeTiered[R]
					if(text2num(R) != lastTier)
						info_html += "[info_html ? "<br>" : ""]<b>Tier [text2num(R)]:</b><br>"

					for(var/datum/geneticsResearchEntry/C in tierList)
						if(C.isResearched == 0 || C.isResearched == -1) continue
						info_html += "• [C.name]<br>"
				info_html += "</p>"

			if("dna_samples")
				if(!scanner)
					info_html = "<p>Scanner not found.</p>"
					src.updateUsrDialog()
					return

				topbotbutton_html = "<p><b>DNA Samples</b></p>"

				info_html = "<p>"
				for(var/datum/computer/file/genetics_scan/sample in genResearch.dna_samples)
					info_html += "* <a href='?src=\ref[src];menu=sample_potential;sample_to_view_potential=\ref[sample]'>[sample.subject_name]</a> <small>([sample.subject_uID]) <a href='?src=\ref[src];delete_sample=\ref[sample]'>(Delete)</a></small><br>"
				info_html += "</p>"

			if("appearance")
				topbotbutton_html = ""
				if(checkOccupant()) return
				if(istype(scanner.occupant, /mob/living/carbon/human))
					if(hasvar(scanner.occupant, "mutantrace"))
						if(scanner.occupant:mutantrace)
							topbotbutton_html = ""
							info_html = "<p>Can not change appearance of mutants.</p>"
						else
							new/datum/genetics_appearancemenu(usr.client, scanner.occupant)
							usr << browse(null, "window=genetics")
							usr.machine = null
				else
					topbotbutton_html = ""
					info_html = "<p>Can not change appearance of non-humans.</p>"

			if("saveload")
				topbotbutton_html = ""
				//info_html = "<p>Temporary : </p><a href='?src=\ref[src];copyself=1'>Copy Occupant to Self</a>" Disabled due to shitlords

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/genetics/proc/equipment_available(var/equipment = "analyser",var/datum/bioEffect/E)
	switch(equipment)
		if("analyser")
			if(genResearch.isResearched(/datum/geneticsResearchEntry/checker) && world.time >= src.equipment[2])
				return 1
		if("emitter")
			if(!istype(src.scanner.occupant,/mob/living/carbon/))
				return 0
			if(genResearch.isResearched(/datum/geneticsResearchEntry/rademitter) && world.time >= src.equipment[3])
				return 1
		if("precision_emitter")
			if(!istype(src.scanner.occupant,/mob/living/carbon/))
				return 0
			if(E && genResearch.researchedMutations[E.id] >= 1 && E.can_scramble)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_precision) && world.time >= src.equipment[3])
					return 1
		if("reclaimer")
			if(E && genResearch.researchedMutations[E.id] >= 1 && E.can_reclaim)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/reclaimer) && world.time >= src.equipment[4])
					return 1
		if("injector")
			if(genResearch.researchMaterial < genResearch.injector_cost)
				return 0
			if(E && genResearch.researchedMutations[E.id] >= 1 && E.can_make_injector)
				if(genResearch.isResearched(/datum/geneticsResearchEntry/injector) && world.time >= src.equipment[1])
					return 1
	return 0

/obj/machinery/computer/genetics/proc/equipment_cooldown(var/equipment = "analyser")
	var/base_cooldown = 1
	var/equipment_num = 1
	switch(equipment)
		if("analyser")
			base_cooldown = 200
			equipment_num = 2
		if("emitter")
			base_cooldown = 1200
			equipment_num = 3
			if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_coolant))
				base_cooldown = 900
		if("precision_emitter")
			base_cooldown = 1800
			equipment_num = 3
			if(genResearch.isResearched(/datum/geneticsResearchEntry/rad_coolant))
				base_cooldown = 1200
		if("reclaimer")
			base_cooldown = 600
			equipment_num = 4
		if("injector")
			base_cooldown = 800
			equipment_num = 1
	if(genResearch.isResearched(/datum/geneticsResearchEntry/improvedcooldowns))
		base_cooldown /= 2
	if (equipment_num < 1 || equipment_num > src.equipment.len)
		return
	src.equipment[equipment_num] = world.time + base_cooldown

/obj/machinery/computer/genetics/proc/ui_build_mutation_research(var/datum/bioEffect/E,var/datum/computer/file/genetics_scan/sample = null)
	if(!E)
		return null

	var/research_cost = genResearch.mut_research_cost
	if (genResearch.cost_discount)
		research_cost -= round(research_cost * genResearch.cost_discount)

	var/build = ""
	switch(genResearch.researchedMutations[E.id])
		if (0,null)
			if (E.can_research)
				if (E.req_mut_research && !E.req_mut_research in genResearch.researchedMutations)
					info_html += "<p>Genetic structure unknown. Research currently impossible.</p>"
				else
					if (sample)
						info_html += "<p><a href='?src=\ref[src];researchmut_sample=\ref[E];sample_to_research=\ref[sample]'>Research required.</a> Material: [research_cost]/[genResearch.researchMaterial]</p>"
					else
						info_html += "<p><a href='?src=\ref[src];researchmut=\ref[E]'>Research required.</a> Material: [research_cost]/[genResearch.researchMaterial]</p>"
			else
				info_html += "<p>Manual Research required.</p>"
		if(-1)
			info_html += "<p>Currently under research. "
			for(var/datum/geneticsResearchEntry/mutation/R in genResearch.currentResearch)
				if (R.mutationId == E.id)
					info_html += "Time Left: [round((R.finishTime - world.time) / 10)]"
					break
			info_html += "</p>"
		else
			info_html += "<p>[E.desc]</p>"

	return build

/obj/machinery/computer/genetics/proc/ui_build_sequence(var/datum/bioEffect/E, var/screen = "pool")
	if (!E)
		return list("ERROR","ERROR","ERROR")

	var/list/build = list()

	var/top = ""
	var/mid = ""
	var/bot = ""

	switch(screen)
		if("pool")
			for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
				top += {"<a href='?src=\ref[src];setseq=\ref[E];setseq1=[i+1]'><img alt="" src="bp[bp.bpp1].png" style="border-style: none"></a>  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}
				mid += {"<a href='?src=\ref[src];marker=\ref[E];themark=[i+1]'><img alt="" src="bpSep-[bp.marker].png" border=0></a>  [blockEnd ? {"<img alt="" src="bpSpacer.png" style="border-style: none">"} : ""]"}
				bot += {"<a href='?src=\ref[src];setseq=\ref[E];setseq2=[i+1]'><img alt="" src="bp[bp.bpp2].png" style="border-style: none"></a>  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}
		if("sample_pool")
			for(var/i=0, i < E.dnaBlocks.blockListCurr.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = E.dnaBlocks.blockListCurr[i+1]
				top += {"<img alt="" src="bp[bp.bpp1].png" style="border-style: none">  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}
				mid += {"<img alt="" src="bpSep-[bp.marker].png">  [blockEnd ? {"<img alt="" src="bpSpacer.png" style="border-style: none">"} : ""]"}
				bot += {"<img alt="" src="bp[bp.bpp2].png" style="border-style: none">  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}
		if("active")
			var/datum/bioEffect/globalInstance = bioEffectList[E.type]
			for(var/i=0, i < globalInstance.dnaBlocks.blockList.len, i++)
				var/blockEnd = (((i+1) % 4) == 0 ? 1 : 0)
				var/datum/basePair/bp = globalInstance.dnaBlocks.blockList[i+1]
				top += {"<img alt="" src="bp[bp.bpp1].png" style="border-style: none">  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}
				mid += {"<img alt="" src="bpSep-[bp.marker].png">  [blockEnd ? {"<img alt="" src="bpSpacer.png" style="border-style: none">"} : ""]"}
				bot += {"<img alt="" src="bp[bp.bpp2].png" style="border-style: none">  [blockEnd ? {"<img alt="" src="bpSpacer.png">"} : ""]"}

	build += top
	build += mid
	build += bot

	return build

/obj/machinery/computer/genetics/proc/ui_build_clickable_genes(var/screen = "pool",var/datum/computer/file/genetics_scan/sample)
	if(screen == "sample_pool")
		if(!sample)
			return
	else
		if (checkOccupant())
			return

	var/build = ""
	var/gene_icon_status = "dnabutt.png"
	switch(screen)
		if("sample_pool")
			for(var/datum/bioEffect/E in sample.dna_pool)
				gene_icon_status = "dnabutt.png"
				switch(genResearch.researchedMutations[E.id])
					if (0,null)
						gene_icon_status = "dnabuttUnk.png"
					if (-1)
						gene_icon_status = "dnabuttRes.png"
				build += {"<a href='?src=\ref[src];sample_viewpool=\ref[E];sample_to_viewpool=\ref[sample]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src=[gene_icon_status] alt="[genResearch.researchedMutations[E.id] >= 1  ? E.name : "???"]" width="43" height="39"></a>"}
		if("pool")
			for(var/datum/bioEffect/E in scanner.occupant.bioHolder.effectPool)
				gene_icon_status = "dnabutt.png"
				switch(genResearch.researchedMutations[E.id])
					if (0,null)
						gene_icon_status = "dnabuttUnk.png"
					if (-1)
						gene_icon_status = "dnabuttRes.png"
				build += {"<a href='?src=\ref[src];viewpool=\ref[E]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src=[gene_icon_status] alt="[genResearch.researchedMutations[E.id] >= 1  ? E.name : "???"]" width="43" height="39"></a>"}

		if("active")
			for(var/datum/bioEffect/E in scanner.occupant.bioHolder.effects)
				if (E.isHidden > 0)
					continue
				gene_icon_status = "dnabuttAct.png"
				build += {"<a href='?src=\ref[src];vieweffect=\ref[E]'>"}
				build += {"<img style="border: [E == src.currently_browsing ? "solid 1px #00FFFF" : "dotted 1px #88C425"]" src=[gene_icon_status] alt="[E.name]" width="43" height="39"></a>"}

	return build

/obj/machinery/computer/genetics/power_change()
	if(stat & BROKEN)
		icon_state = "commb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER