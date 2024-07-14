/// Returns the species's laugh sound.
/datum/species/proc/get_laugh_sound(mob/living/carbon/human/human)
	return

/datum/species/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	var/list/skillchips = organ_holder.clone_skillchip_list()
	organ_holder.destroy_all_skillchips(silent = TRUE)
	. = ..()
	for(var/chip in skillchips)
		var/chip_type = chip["type"]
		if(!ispath(chip_type, /obj/item/skillchip))
			continue
		var/obj/item/skillchip/skillchip = new chip_type(organ_holder)
		if(organ_holder.implant_skillchip(skillchip, force = TRUE))
			qdel(skillchip)
			continue
		skillchip.set_metadata(chip)
