/datum/action/item_action/ninjastatus
	check_flags = NONE
	name = "Status Readout"
	desc = "Gives a detailed readout about your current status."
	button_icon_state = "health"
	icon_icon = 'icons/obj/device.dmi'

/**
 * Proc called to put a status readout to the ninja in chat.
 *
 * Called put some information about the ninja's current status into chat.
 * This information used to be displayed constantly on the status tab screen
 * when the suit was on, but was turned into this as to remove the code from
 * human.dm
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninjastatus()
	var/mob/living/carbon/human/ninja = affecting
	var/list/info_list = list()
	info_list += "<span class='info'>SpiderOS Status: [s_initialized ? "Initialized" : "Disabled"]</span>\n"
	info_list += "<span class='info'>Current Time: [station_time_timestamp()]</span>\n"
	//Ninja status
	info_list += "<span class='info'>Fingerprints: [md5(ninja.dna.uni_identity)]</span>\n"
	info_list += "<span class='info'>Unique Identity: [ninja.dna.unique_enzymes]</span>\n"
	info_list += "<span class='info'>Overall Status: [ninja.stat > 1 ? "dead" : "[ninja.health]% healthy"]</span>\n"
	info_list += "<span class='info'>Nutrition Status: [ninja.nutrition]</span>\n"
	info_list += "<span class='info'>Oxygen Loss: [ninja.getOxyLoss()]</span>\n"
	info_list += "<span class='info'>Toxin Levels: [ninja.getToxLoss()]</span>\n"
	info_list += "<span class='info'>Burn Severity: [ninja.getFireLoss()]</span>\n"
	info_list += "<span class='info'>Brute Trauma: [ninja.getBruteLoss()]</span>\n"
	info_list += "<span class='info'>Radiation Levels: [ninja.radiation] rad</span>\n"
	info_list += "<span class='info'>Body Temperature: [ninja.bodytemperature-T0C] degrees C ([ninja.bodytemperature*1.8-459.67] degrees F)</span>\n"

	//Diseases
	if(length(ninja.diseases))
		info_list += "Viruses:"
		for(var/datum/disease/ninja_disease in ninja.diseases)
			info_list += "<span class='info'>* [ninja_disease.name], Type: [ninja_disease.spread_text], Stage: [ninja_disease.stage]/[ninja_disease.max_stages], Possible Cure: [ninja_disease.cure_text]</span>\n"

	to_chat(ninja, "[info_list.Join()]")
