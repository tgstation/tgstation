/datum/species/oozeling
	name = "\improper Oozeling"
	plural_form = "Oozelings"
	id = SPECIES_OOZELING
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		HAIR,FACEHAIR,
		)
	inherent_traits = list(
		TRAIT_TOXINLOVER,
		TRAIT_NOFIRE,
		//TRAIT_ALWAYS_CLEAN,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOBLOOD,
		)

	hair_color = "mutcolor"
	hair_alpha = 150
	mutantlungs = /obj/item/organ/internal/lungs/oozeling
	mutanttongue = /obj/item/organ/internal/tongue/oozeling
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimeooze
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	burnmod = 0.6 // = 3/5x generic burn damage
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list(FACTION_SLIME) //an oozeling wont be eaten by their brethren
	species_language_holder = /datum/language_holder/oozeling
	ass_image = 'icons/ass/assslime.png'
	//swimming_component = /datum/component/swimming/dissolve
	toxic_food = NONE
	disliked_food = NONE

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling,
	)

/datum/species/oozeling/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick(
			'sound/voice/human/malescream_1.ogg',
			'sound/voice/human/malescream_2.ogg',
			'sound/voice/human/malescream_3.ogg',
			'sound/voice/human/malescream_4.ogg',
			'sound/voice/human/malescream_5.ogg',
			'sound/voice/human/malescream_6.ogg',
		)

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/femalescream_5.ogg',
	)
/datum/species/oozeling/get_laugh_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		return pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')
	else
		return 'sound/voice/human/womanlaugh.ogg'

/datum/species/oozeling/get_species_description()
	return "A species of sentient semi-solids. \
		They require nutriment in order to maintain their body mass."

/datum/species/oozeling/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.oozeling_first_names)]"
	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.oozeling_last_names)]"

	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, lastname, ++attempts)

/datum/species/oozeling/on_species_loss(mob/living/carbon/C)
	if(regenerate_limbs)
		regenerate_limbs.Remove(C)
	..()

/datum/species/oozeling/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)

/datum/species/oozeling/spec_life(mob/living/carbon/human/H)
	..()
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return
	if(!H.blood_volume)
		H.blood_volume += 5
		H.adjustBruteLoss(5)
		to_chat(H, span_danger("You feel empty!"))
	if(H.nutrition >= NUTRITION_LEVEL_WELL_FED && H.blood_volume <= 672)
		if(H.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
			H.adjust_nutrition(-5)
			H.blood_volume += 10
		else
			H.blood_volume += 8
	if(H.nutrition <= NUTRITION_LEVEL_HUNGRY)
		if(H.nutrition <= NUTRITION_LEVEL_STARVING)
			H.blood_volume -= 8
			if(prob(5))
				to_chat(H, span_info("You're starving! Get some food!"))
		else
			if(prob(35))
				H.blood_volume -= 2
				if(prob(5))
					to_chat(H, span_danger("You're feeling pretty hungry..."))
	var/atmos_sealed = FALSE
	if(H.wear_suit && H.head && isclothing(H.wear_suit) && isclothing(H.head))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if(CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			atmos_sealed = TRUE
	if(H.w_uniform && H.head)
		var/obj/item/clothing/head_clothing = H.head
		if(istype(head_clothing) && (head_clothing.clothing_flags & STOPSPRESSUREDAMAGE))
			atmos_sealed = TRUE
	if(!atmos_sealed)
		var/datum/gas_mixture/environment = H.loc.return_air()
		if(environment?.total_moles())
			environment.assert_gas(/datum/gas/water_vapor)
			if(environment.gases[/datum/gas/water_vapor][MOLES] >= 1)
				H.blood_volume -= 15
				if(prob(50))
					to_chat(H, "<span class='danger'>Your ooze melts away rapidly in the water vapor!</span>")
			environment.assert_gas(/datum/gas/plasma)
			if(H.blood_volume <= 672 && environment.gases[/datum/gas/plasma][MOLES] >= 1)
				H.blood_volume += 15
	if(H.blood_volume < BLOOD_VOLUME_OKAY && prob(5))
		to_chat(H, "<span class='danger'>You feel drained!</span>")
	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		Cannibalize_Body(H)

/datum/species/oozeling/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!limbs_to_consume.len)
		H.losebreath++
		return
	if(H.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, "<span class='userdanger'>Your [consumed_limb] is drawn back into your body, unable to maintain its shape!</span>")
	qdel(consumed_limb)
	H.blood_volume += 80
	H.nutrition += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*length(limbs_to_heal)
		to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

/datum/species/oozeling/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/water)
		if(chem.volume > 10)
			H.reagents.remove_reagent(chem.type, chem.volume - 10)
			to_chat(H, "<span class='warning'>The water you consumed is melting away your insides!</span>")
		H.blood_volume -= 25
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/reagent/toxin/slimeooze
	name = "Slime Ooze"
	description = "A gooey semi-liquid produced from Oozelings"
	color = "#611e80"
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 1.5

/datum/reagent/toxin/slimeooze/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		to_chat(M, "<span class='danger'>Your insides are burning!</span>")
		M.adjustToxLoss(rand(1,10)*REM, 0)
		. = 1
	else if(prob(40))
		M.heal_bodypart_damage(5*REM)
		. = 1
	..()

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Respiration",
			SPECIES_PERK_DESC = "[plural_form] can breathe plasma, and restore blood by doing so.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "incombustible",
			SPECIES_PERK_DESC = "[plural_form] cannot be set aflame.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = initial(exotic_blood.name),
			SPECIES_PERK_DESC = "[name] blood is [initial(exotic_blood.name)], which can make recieving medical treatment harder.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Anaerobic Lineage",
			SPECIES_PERK_DESC = "[plural_form] don't require much oxygen to live."
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Self-Consumption",
			SPECIES_PERK_DESC = "Once hungry enough, [plural_form] will begin to consume their own blood and limbs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Liquid Being",
			SPECIES_PERK_DESC = "[plural_form] will melt away when in contact with water.",
		),
		list(
            SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
            SPECIES_PERK_ICON = "briefcase-medical",
            SPECIES_PERK_NAME = "Oozeling Biology",
            SPECIES_PERK_DESC = "[plural_form] take specialized medical knowledge to be \
                treated. Do not expect speedy revival, if you are lucky enough to get \
                one at all.",
        ),
	)

	return to_add
