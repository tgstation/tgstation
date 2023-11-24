

/datum/symptom/cough
	max_chance = 10
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/cough/activate(mob/living/carbon/mob)
	mob.emote("cough")
	
	var/datum/gas_mixture/breath
	if (ishuman(mob))
		var/mob/living/carbon/human/H = mob
		breath = H.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		var/head_block = 0
		if (ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if (H.head && (H.head.flags_cover & HEADCOVERSMOUTH))
				head_block = 1
		if(!head_block)
			if(!mob.wear_mask || !(mob.wear_mask.flags_cover & MASKCOVERSMOUTH))
				if(isturf(mob.loc))
					if(mob.check_airborne_sterility())
						return
					var/strength = 0
					for (var/datum/disease/advanced/V in mob.diseases)
						strength += V.infectionchance
					strength = round(strength / mob.diseases.len)
					var/i = 1
					while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
						new /obj/effect/pathogen_cloud/core(get_turf(src), mob, virus_copylist(mob.diseases))
						strength -= 30
						i++
