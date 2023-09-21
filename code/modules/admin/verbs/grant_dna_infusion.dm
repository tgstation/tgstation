/*
 * Attempts to grant the target all organs from a given DNA infuser entry.area
 * Returns the entry if all organs were successfully replaced.
 * If no infusion was picked, the infusion had no organs, or if one or more organs could not be granted, returns FALSE
*/
/client/proc/grant_dna_infusion(mob/living/carbon/human/target in world)
	set name = "Apply DNA Infusion"
	set category = "Debug"

	var/list/infusions = list()
	for(var/path in subtypesof(/datum/infuser_entry))
		infusions += path

	var/datum/infuser_entry/picked_infusion = tgui_input_list(usr, "Select infusion", "Apply DNA Infusion", infusions)
	// This is necessary because list propererties are not defined until initialization
	picked_infusion = new picked_infusion()

	if(isnull(picked_infusion))
		return FALSE
	if(!length(picked_infusion.output_organs))
		return FALSE

	. = picked_infusion
	for(var/obj/item/organ/infusion_organ as anything in picked_infusion.output_organs)
		var/obj/item/organ/new_organ = new infusion_organ()
		if(!new_organ.replace_into(target))
			to_chat(usr, span_notice("[target] is unable to carry [new_organ]!"))
			qdel(new_organ)
			. = FALSE
			continue
		log_admin("[key_name(usr)] has added organ [new_organ.type] to [key_name(target)]")
		message_admins("[key_name_admin(usr)] has added organ [new_organ.type] to [ADMIN_LOOKUPFLW(target)]")
