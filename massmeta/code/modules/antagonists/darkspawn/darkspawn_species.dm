/datum/species/darkspawn
	name = "Darkspawn"
	id = "darkspawn"
	examine_limb_id = SPECIES_SHADOW
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE
	siemens_coeff = 0
	brutemod = 0.6
	burnmod = 0.9
	heatmod = 1.5
	no_equip_flags = ITEM_SLOT_HEAD | ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	species_traits = list(NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
		TRAIT_NOGUNS,
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/darkspawn,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/darkspawn,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/darkspawn,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/darkspawn,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/darkspawn,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/darkspawn,
	)
	mutanteyes = /obj/item/organ/internal/eyes/shadow
	var/list/upgrades = list()

/datum/species/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.real_name = "[pick(GLOB.nightmare_names)]"
	C.name = C.real_name
	if(C.mind)
		C.mind.name = C.real_name
	C.dna.real_name = C.real_name

/datum/species/darkspawn/on_species_loss(mob/living/carbon/C)
	. = ..()

/datum/species/darkspawn/spec_life(mob/living/carbon/human/H)
	handle_upgrades(H)
	var/turf/T = H.loc
	if(istype(T) && H.stat != DEAD)
		var/light_amount = T.get_lumcount()
		if(light_amount < DARKSPAWN_DIM_LIGHT) //rapid healing and stun reduction in the darkness
			var/healing_amount = DARKSPAWN_DARK_HEAL
			if(upgrades["dark_healing"])
				healing_amount *= 1.25
			H.adjustBruteLoss(-healing_amount)
			H.adjustFireLoss(-healing_amount * 0.5)
			H.adjustToxLoss(-healing_amount)
			H.adjustStaminaLoss(-healing_amount * 20)
			H.AdjustStun(-healing_amount * 4)
			H.AdjustKnockdown(-healing_amount * 4)
			H.AdjustUnconscious(-healing_amount * 4)
			H.SetSleeping(0)
			H.setOrganLoss(ORGAN_SLOT_BRAIN,0)
			H.setCloneLoss(0)
		else if(light_amount < DARKSPAWN_BRIGHT_LIGHT && !upgrades["light_resistance"]) //not bright, but still dim
			H.adjustFireLoss(1)
		else if(light_amount > DARKSPAWN_BRIGHT_LIGHT && !H.has_status_effect(STATUS_EFFECT_CREEP)) //but quick death in the light
			if(upgrades["spacewalking"] && isspaceturf(T))
				return
			else if(!upgrades["light_resistance"])
				to_chat(H, "<span class='userdanger'>The light burns you!</span>")
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
				H.adjustFireLoss(DARKSPAWN_LIGHT_BURN)
			else
				to_chat(H, "<span class='userdanger'>The light singes you!</span>")
				H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 50 * light_amount), TRUE)
				H.adjustFireLoss(DARKSPAWN_LIGHT_BURN * 0.5)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'massmeta/sounds/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/darkspawn/proc/handle_upgrades(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/darkspawn
	if(H.mind)
		darkspawn = H.mind.has_antag_datum(/datum/antagonist/darkspawn)
		if(darkspawn)
			upgrades = darkspawn.upgrades

/mob/living/carbon/human/species/darkspawn
	race = /datum/species/darkspawn //God knows why would you need it but ok
