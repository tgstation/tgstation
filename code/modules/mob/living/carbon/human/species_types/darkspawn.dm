/datum/species/darkspawn
	name = "Darkspawn"
	id = "darkspawn"
	limbs_id = "darkspawn"
	sexes = FALSE
	nojumpsuit = TRUE
	blacklisted = TRUE
	dangerous_existence = TRUE
	siemens_coeff = 0
	brutemod = 0.9
	heatmod = 1.5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store, slot_head)
	species_traits = list(NOBREATH, RESISTCOLD, RESISTPRESSURE, NOGUNS, NOBLOOD, RADIMMUNE, VIRUSIMMUNE, PIERCEIMMUNE, NODISMEMBER, NO_UNDERWEAR, NOHUNGER, NO_DNA_COPY, NOTRANSSTING, NOEYES)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien

/datum/species/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "[pick(GLOB.nightmare_names)]"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name

/datum/species/darkspawn/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.bubble_icon = initial(C.bubble_icon)

/datum/species/darkspawn/spec_life(mob/living/carbon/human/H)
	H.bubble_icon = "darkspawn"
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < DARKSPAWN_DIM_LIGHT) //rapid healing and stun reduction in the darkness
			H.adjustBruteLoss(-DARKSPAWN_DARK_HEAL)
			H.adjustFireLoss(-DARKSPAWN_DARK_HEAL * 0.5)
			H.adjustToxLoss(-DARKSPAWN_DARK_HEAL)
			H.AdjustStun(-DARKSPAWN_DARK_HEAL * 4)
			H.AdjustKnockdown(-DARKSPAWN_DARK_HEAL * 4)
			H.AdjustUnconscious(-DARKSPAWN_DARK_HEAL * 4)
			H.SetSleeping(0)
			H.setBrainLoss(0)
			H.setCloneLoss(0)
		else if(light_amount < DARKSPAWN_BRIGHT_LIGHT) //not bright, but still dim
			H.adjustFireLoss(1)
		else if(light_amount > DARKSPAWN_BRIGHT_LIGHT && !H.has_status_effect(STATUS_EFFECT_CREEP)) //but quick death in the light
			to_chat(H, "<span class='userdanger'>The light burns you!</span>")
			H.playsound_local(H, 'sound/weapons/sear.ogg', 50, TRUE)
			H.adjustFireLoss(DARKSPAWN_LIGHT_BURN)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'sound/creatures/darkspawn_death.ogg', 50, FALSE)
