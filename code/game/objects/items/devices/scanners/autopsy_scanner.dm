/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Used in surgery to extract information from a cadaver."
	icon = 'icons/obj/device.dmi'
	icon_state = "autopsy_scanner"
	inhand_icon_state = "autopsy_scanner"
	worn_icon_state = "autopsy_scanner"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = 200)
	custom_price = PAYCHECK_COMMAND

/obj/item/autopsy_scanner/proc/scan_cadaver(mob/living/carbon/human/user, mob/living/carbon/scanned)
	if(scanned.stat != DEAD)
		return

	var/list/autopsy_information = list()
	autopsy_information += "[scanned.name] - Species: [scanned.dna.species.name]"
	autopsy_information += "Time of Death - [scanned.tod]"
	autopsy_information += "Time of Autopsy - [station_time_timestamp()]"
	autopsy_information += "Autopsy Coroner - [user.name]"

	autopsy_information += "Toxin damage: [CEILING(scanned.getToxLoss(), 1)]"
	autopsy_information += "Oxygen damage: [CEILING(scanned.getOxyLoss(), 1)]"
	autopsy_information += "Cloning damage: [CEILING(scanned.getCloneLoss(), 1)]"

	autopsy_information += "<center>Bodypart Data</center><br>"
	for(var/obj/item/bodypart/bodyparts as anything in scanned.bodyparts)
		autopsy_information += "<b>[bodyparts.name]</b><br>"
		autopsy_information += "BRUTE: [bodyparts.brute_dam] | BURN: [bodyparts.burn_dam]<br>"
		if(!bodyparts.wounds)
			continue
		autopsy_information += "Wounds found:<br>"
		for(var/datum/wound/wounds as anything in bodyparts.wounds)
			if(wounds.wound_source)
				autopsy_information += "<b>[wounds.name]</b> - Caused by <i>[wounds.wound_source]</i><br>"

	autopsy_information += "<center>Organ Data</center>"
	for(var/obj/item/organ/organs as anything in scanned.organs)
		autopsy_information += "[organs.name]: <b>[CEILING(organs.damage, 1)] damage</b><br>"

	autopsy_information += "<center>Chemical Data</center>"
	for(var/datum/reagent/scanned_reagents as anything in scanned.reagents.reagent_list)
		if(scanned_reagents.chemical_flags & REAGENT_INVISIBLE)
			continue
		autopsy_information += "<b>[round(scanned_reagents.volume, 0.1)] unit\s of [scanned_reagents.name]</b><br>"
		autopsy_information += "Chemical Information: <i>[scanned_reagents.description]</i><br>"

	autopsy_information += "<center>Blood Data</center>"
	if(HAS_TRAIT(scanned, TRAIT_HUSK))
		autopsy_information += "Blood can't be found, victim is husked by: "
		if(HAS_TRAIT_FROM(scanned, TRAIT_HUSK, BURN))
			autopsy_information += "Severe burns.</br>"
		else if (HAS_TRAIT_FROM(scanned, TRAIT_HUSK, CHANGELING_DRAIN))
			autopsy_information += "Desiccation, commonly caused by Changelings.</br>"
		else
			autopsy_information += "Unknown causes.</br>"
	else
		var/blood_id = scanned.get_blood_id()
		if(blood_id)
			var/blood_percent = round((scanned.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
			var/blood_type = scanned.dna.blood_type
			if(blood_id != /datum/reagent/blood)
				var/datum/reagent/reagents = GLOB.chemical_reagents_list[blood_id]
				blood_type = reagents ? reagents.name : blood_id
				autopsy_information += "Blood Type: [blood_type]<br>"
				autopsy_information += "Blood Volume: [scanned.blood_volume] cl ([blood_percent]) %<br>"

	for(var/datum/disease/diseases as anything in scanned.diseases)
		autopsy_information += "Name: [diseases.name] | Type: [diseases.spread_text]<br>"
		if(!istype(diseases, /datum/disease/advance))
			continue
		autopsy_information += "<b>Symptoms:</b><br>"
		var/datum/disease/advance/advanced_disease = diseases
		for(var/datum/symptom/symptom as anything in advanced_disease.symptoms)
			autopsy_information += "[symptom.name] - [symptom.desc]<br>"

	var/obj/item/paper/autopsy_report = new(user.loc)
	autopsy_report.name = "Autopsy Report ([scanned.name])"
	autopsy_report.add_raw_text(autopsy_information.Join("\n"))
	autopsy_report.update_appearance(UPDATE_ICON)
	user.put_in_hands(autopsy_report)
	user.balloon_alert(user, "report printed")
	return TRUE
