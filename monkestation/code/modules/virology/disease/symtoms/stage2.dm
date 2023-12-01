

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

/datum/symptom/beard
	name = "Facial Hypertrichosis"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	max_multiplier = 5
	badness = EFFECT_DANGER_FLAVOR


/datum/symptom/beard/activate(mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(ishuman(mob))
			var/beard_name = ""
			spawn(5 SECONDS)
				if(multiplier >= 1 && multiplier < 2)
					beard_name = "Beard (Jensen)"
				if(multiplier >= 2 && multiplier < 3)
					beard_name = "Beard (Full)"
				if(multiplier >= 3 && multiplier < 4)
					beard_name = "Beard (Very Long)"
				if(multiplier >= 4)
					beard_name = "Beard (Dwarf)"
				if(beard_name != "" && H.facial_hairstyle != beard_name)
					H.facial_hairstyle = beard_name
					to_chat(H, span_warning("Your chin itches."))
					H.update_body_parts()

/datum/symptom/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	multiplier = 5
	max_multiplier = 10

/datum/symptom/drowsness/activate(mob/living/mob)
	mob.adjust_drowsiness_up_to(multiplier, 40 SECONDS)

/datum/symptom/cough//creates pathogenic clouds that may contain even non-airborne viruses.
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, releasing pathogenic clouds."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	max_chance = 10

/datum/symptom/cough/activate(var/mob/living/mob)
	mob.emote("cough")
	if(!ishuman(mob))
		var/mob/living/carbon/human/H = mob
	var/datum/gas_mixture/breath
	breath = H.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		if(!mob.wear_mask)
			if(isturf(mob.loc))
				var/list/blockers = list()
				blockers = list(H.wear_mask,H.glasses,H.head)
				for (var/item in blockers)
					var/obj/item/I = item
					if (!istype(I))
						continue
					if (I.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
						return
				if(mob.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anythingin mob.diseases)
					strength += V.infectionchance
				strength = round(strength/mob.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), mob, virus_copylist(mob.diseases))
					strength -= 30
					i++
