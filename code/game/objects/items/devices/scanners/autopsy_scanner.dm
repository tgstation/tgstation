/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Used in surgery to extract information from a cadaver. Can also scan the health of cadavers like an advanced health analyzer!"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "autopsy_scanner"
	inhand_icon_state = "autopsy_scanner"
	worn_icon_state = "autopsy_scanner"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = CRUEL_IMPLEMENT
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*2)
	custom_price = PAYCHECK_COMMAND

/obj/item/autopsy_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!user.can_read(src) || user.is_blind())
		return ITEM_INTERACT_BLOCKING

	var/mob/living/scanned = interacting_with

	if(scanned.stat != DEAD && !HAS_TRAIT(scanned, TRAIT_FAKEDEATH)) // good job, you found a loophole
		to_chat(user, span_deadsay("[icon2html(src, user)] ERROR! CANNOT SCAN LIVE CADAVERS. PROCURE HEALTH ANALYZER OR TERMINATE PATIENT."))
		return ITEM_INTERACT_BLOCKING

	. = ITEM_INTERACT_SUCCESS

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(span_warning("[user] analyzes the floor's vitals!"), \
							span_notice("You stupidly try to analyze the floor's vitals!"))
		to_chat(user, "[span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>")]\
				\n[span_info("Key: <font color='#00cccc'>Suffocation</font>/<font color='#00cc66'>Toxin</font>/<font color='#ffcc33'>Burn</font>/<font color='#ff3333'>Brute</font>")]\
				\n[span_info("\tDamage specifics: <font color='#66cccc'>0</font>-<font color='#00cc66'>0</font>-<font color='#ff9933'>0</font>-<font color='#ff3333'>0</font>")]\
				\n[span_info("Body temperature: ???")]")
		return

	user.visible_message(span_notice("[user] scans [scanned]'s cadaver."))
	to_chat(user, span_deadsay("[icon2html(src, user)] ANALYZING CADAVER."))

	healthscan(user, scanned, advanced = TRUE)

	add_fingerprint(user)

/obj/item/autopsy_scanner/proc/scan_cadaver(mob/living/carbon/human/user, mob/living/carbon/scanned)
	if(scanned.stat != DEAD)
		return

	var/obj/item/paper/autopsy_report = new(get_turf(src))
	autopsy_report.color = "#99ccff"
	autopsy_report.name = "autopsy report of [scanned] - [station_time_timestamp()])"
	var/final_report_text = "<center><b>Autopsy report. Time of Autopsy: [station_time_timestamp()]</b></center>"

	//A lot of this is extremely similar to /proc/healthscan() - but with different formatting, no color, and some added/removed info
	//Does not list quirks/exhaustion/how to repair wounds
	//DOES list wound sources/
	var/list/autopsy_information = list()
	autopsy_information += "Autopsy Coroner - [user.name]<hr>"

	autopsy_information += "Analyzing results for <b>[scanned.name]</b>:</br></br>"
	autopsy_information += "Time of Death - <b>[scanned.station_timestamp_timeofdeath]</b></br>"
	autopsy_information += "Subject has been dead for <b>[DisplayTimeText(round(world.time - scanned.timeofdeath))]</b>.<hr>"

	var/oxy_loss = scanned.getOxyLoss()
	var/tox_loss = scanned.getToxLoss()
	var/fire_loss = scanned.getFireLoss()
	var/brute_loss = scanned.getBruteLoss()
	/// "Body Data" portion of the autopsy - damage, wounds, and limbs
	var/dmgreport = "<u><b>Body Data:</b></u>\
					<table class='ml-2'>\
					<tr>\
					<td style='width:7em;'><b>Damage:</b></td>\
					<td style='width:5em;'><b>Brute</b></td>\
					<td style='width:4em;'><b>Burn</b></td>\
					<td style='width:4em;'><b>Toxin</b></td>\
					<td style='width:8em;'><b>Suffocation</b></td>\
					</tr>"
	for(var/zone in scanned.get_all_limbs()) //Same order every time for consistency across all humans
		var/obj/item/bodypart/limb = scanned.get_bodypart(zone)
		if(isnull(limb))
			dmgreport += "<tr>"
			dmgreport += "<td><b>[capitalize(parse_zone(zone))]:</b></td>"
			dmgreport += "<td>-</td>"
			dmgreport += "<td>-</td>"
			dmgreport += "</tr>"
			dmgreport += "<tr><td colspan=6>&rdsh; Physical trauma: <u>Dismembered</u></td></tr>"
			continue
		var/has_any_embeds = length(limb.embedded_objects) >= 1
		var/has_any_wounds = length(limb.wounds) >= 1
		dmgreport += "<tr>"
		dmgreport += "<td><b>[capitalize(limb.name)]:</b></td>"
		dmgreport += "<td>[limb.brute_dam > 0 ? ceil(limb.brute_dam) : "0"]</td>"
		dmgreport += "<td>[limb.burn_dam > 0 ? ceil(limb.burn_dam) : "0"]</td>"
		if(zone == BODY_ZONE_CHEST) // tox/oxy is stored in the chest
			dmgreport += "<td>[tox_loss > 0 ? ceil(tox_loss) : "0"]</td>"
			dmgreport += "<td>[oxy_loss > 0 ? ceil(oxy_loss) : "0"]</td>"
		dmgreport += "</tr>"
		if(has_any_embeds)
			var/list/embedded_names = list()
			for(var/obj/item/embed as anything in limb.embedded_objects)
				embedded_names[capitalize(embed.name)] += 1
			for(var/embedded_name in embedded_names)
				var/displayed = embedded_name
				var/embedded_amt = embedded_names[embedded_name]
				if(embedded_amt > 1)
					displayed = "[embedded_amt]x [embedded_name]"
				dmgreport += "<tr><td colspan=6><i>&rdsh; Foreign object(s): [displayed].</i></td></tr>"
		if(has_any_wounds)
			for(var/datum/wound/wound as anything in limb.wounds)
				dmgreport += "<tr><td colspan=6><i>&rdsh; Physical trauma: [wound.name] ([wound.severity_text()]) - Caused by <u>[wound.wound_source].</u></i></td></tr>"

	dmgreport += "<tr>\
		<td><b>Overall:</b></td>\
		<td><b>[ceil(brute_loss)] Brute</b></td>\
		<td><b>[ceil(fire_loss)] Burn</b></td>\
		<td><b>[ceil(tox_loss)] Toxin</b></td>\
		<td><b>[ceil(oxy_loss)] Suffocation</b></td>\
		</tr>"
	dmgreport += "</table><hr>"
	autopsy_information += dmgreport

	// Only humanoids list organs, implants, gene stability, species and core-temp
	if(ishuman(scanned))
		var/mob/living/carbon/human/humantarget = scanned
		/// "Organ Data" portion of the autopsy - damage, functional status (or if it's missing), and implants
		var/organreport = "<u><b>Organ Data:</b></u>\
				<table class='ml-2'>\
				<tr>\
				<td style='width:10em;'><b>Organ:</b></td>\
				<td style='width:6em;'><b>Dmg</b></td>\
				<td style='width:30em;'><b>Status</b></td>\
				</tr>"

		var/list/missing_organs = humantarget.get_missing_organs()
		for(var/sorted_slot in GLOB.organ_process_order) //Same order every time for consistency across all humans
			var/obj/item/organ/organ = humantarget.get_organ_slot(sorted_slot)
			if(isnull(organ))
				if(missing_organs[sorted_slot])
					organreport += "<tr><td><b>[missing_organs[sorted_slot]]:</b></td>\
						<td>-</td>\
						<td><u>Missing</u></td></tr>"
				continue
			var/status = organ.get_status_text(advanced = TRUE, add_tooltips = FALSE, colored = FALSE)
			var/appendix = organ.get_status_appendix(advanced = TRUE, add_tooltips = FALSE)
			if(!status)
				status ||= "OK" // otherwise flawless organs have no status reported by default
			organreport += "<tr>\
				<td><b>[capitalize(organ.name)]:</b></td>\
				<td>[organ.damage > 0 ? ceil(organ.damage) : "0"]</td>\
				<td>[status]</td>\
				</tr>"
			if(appendix)
				organreport += "<tr><td colspan=4><i>&rdsh; [appendix]</i></td></tr>"
		organreport += "</table>" //<hr> comes after Cybernetics below
		autopsy_information += organreport

		var/mutant = HAS_TRAIT(humantarget, TRAIT_HULK) //Also applied by genetics infusions
		// Cybernetics
		var/list/cyberimps
		for(var/obj/item/organ/target_organ as anything in humantarget.organs)
			if(IS_ROBOTIC_ORGAN(target_organ) && !(target_organ.organ_flags & ORGAN_HIDDEN))
				LAZYADD(cyberimps, target_organ.examine_title(user))
			if(target_organ.organ_flags & ORGAN_MUTANT)
				mutant = TRUE
		if(LAZYLEN(cyberimps))
			autopsy_information += "<b>Detected cybernetic modifications:</b></br>"
			autopsy_information += "[english_list(cyberimps, and_text = ", and ")]</br>"

		autopsy_information += "<hr>"

		// Genetic Stability, Species, and Body Temperature
		if(humantarget.has_dna() && humantarget.dna.stability != initial(humantarget.dna.stability))
			autopsy_information += "<b>Genetic Stability:</b> [humantarget.dna.stability]%.</br>"
		var/datum/species/targetspecies = humantarget.dna.species
		var/disguised = !ishumanbasic(humantarget) && istype(humantarget.head, /obj/item/clothing/head/hooded/human_head) && istype(humantarget.wear_suit, /obj/item/clothing/suit/hooded/bloated_human)
		var/species_name = "[disguised ? "\"[/datum/species/human::name]\"" : targetspecies.name][mutant ? "-derived mutant" : ""]"
		autopsy_information += "<b>Species:</b> [species_name]</br>"
		autopsy_information += "<b>Core temperature:</b> [round(humantarget.coretemperature-T0C, 0.1)] &deg;C ([round(humantarget.coretemperature*1.8-459.67,0.1)] &deg;F)</br>"
	// (End of humanoid-only information)
	autopsy_information += "<b>Body temperature:</b> [round(scanned.bodytemperature-T0C, 0.1)] &deg;C ([round(scanned.bodytemperature*1.8-459.67,0.1)] &deg;F)</br>"

	// Blood Info
	if(HAS_TRAIT(scanned, TRAIT_HUSK))
		autopsy_information += "Blood can't be found, subject is husked by: "
		if(HAS_TRAIT_FROM(scanned, TRAIT_HUSK, BURN))
			autopsy_information += "Severe burns.</br>"
		else if (HAS_TRAIT_FROM(scanned, TRAIT_HUSK, CHANGELING_DRAIN))
			autopsy_information += "Desiccation, commonly caused by Changelings.</br>"
		else
			autopsy_information += "Unknown causes.</br>"
	else
		var/datum/blood_type/blood_type = scanned.get_bloodtype()
		if(blood_type)
			var/blood_percent = round((scanned.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
			var/blood_type_format
			var/level_format
			if(scanned.blood_volume <= BLOOD_VOLUME_SAFE && scanned.blood_volume > BLOOD_VOLUME_OKAY)
				level_format = "LOW [blood_percent]%, [scanned.blood_volume] cl"
			else if(scanned.blood_volume <= BLOOD_VOLUME_OKAY)
				level_format = "<u>CRITICAL [blood_percent]%</u>, [scanned.blood_volume] cl"
			else
				level_format = "[blood_percent]%, [scanned.blood_volume] cl"
			if(blood_type.get_type())
				blood_type_format = "type: [blood_type.get_type()]"
			autopsy_information += "<b>[blood_type.get_blood_name()] level:</b> [level_format], [blood_type_format]</br>"
		var/blood_alcohol_content = scanned.get_blood_alcohol_content()
		if(blood_alcohol_content > 0)
			autopsy_information += "&rdsh; [blood_type?.get_blood_name() || "Blood"] alcohol content: [blood_alcohol_content]%</br>"
	autopsy_information += "<hr>"

	autopsy_information += "<u>Chemical Data:</u></br>"
	for(var/datum/reagent/scanned_reagents as anything in scanned.reagents.reagent_list)
		if(scanned_reagents.chemical_flags & REAGENT_INVISIBLE)
			continue
		autopsy_information += "<b>[scanned_reagents.name]:</b> [round(scanned_reagents.volume, 0.1)] unit\s in bloodstream.</br>"
		autopsy_information += "<i>&rdsh; [scanned_reagents.description]</i></br>"
	autopsy_information += "<hr>"

	autopsy_information += "<u>Disease Data:</u></br>"
	for(var/datum/disease/diseases as anything in scanned.diseases)
		autopsy_information += "<b>Disease Name:</b> \"[diseases.name]\"</br>"
		autopsy_information += "<b>Transmission Type:</b> [diseases.spread_text]</br>"
		if(!istype(diseases, /datum/disease/advance))
			continue
		autopsy_information += "<b>Symptoms:</b></br>"
		var/datum/disease/advance/advanced_disease = diseases
		for(var/datum/symptom/symptom as anything in advanced_disease.symptoms)
			autopsy_information += "&rdsh; [symptom.name] - <i>[symptom.desc]</i></br>"
	autopsy_information += "<hr>"

	autopsy_information += "<b>Coroner's Notes:</b>" //Bottom of the page, anything past here is player-written

	final_report_text += jointext(autopsy_information, "")
	autopsy_report.add_raw_text(final_report_text)
	autopsy_report.update_appearance()
	user.put_in_hands(autopsy_report)
	user.balloon_alert(user, "report printed")
	return TRUE
