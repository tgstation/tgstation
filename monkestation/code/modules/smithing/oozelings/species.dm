#define DAMAGE_WATER_STACKS 5
#define REGEN_WATER_STACKS 1

/datum/species/oozeling
	name = "\improper Oozeling"
	plural_form = "Oozelings"
	id = SPECIES_OOZELING
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	species_traits = list(
		MUTCOLORS,
		)

	hair_color = "mutcolor"
	hair_alpha = 160

	mutantliver = /obj/item/organ/internal/liver/slime
	mutantstomach = /obj/item/organ/internal/stomach/slime
	mutantbrain = /obj/item/organ/internal/brain/slime
	mutantears = /obj/item/organ/internal/ears/jelly
	mutantlungs = /obj/item/organ/internal/lungs/slime
	mutanttongue = /obj/item/organ/internal/tongue/jelly

	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TOXINLOVER,
		TRAIT_NOBLOOD,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOFIRE,
	)

	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimeooze
	burnmod = 0.6 // = 3/5x generic burn damage
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	inherent_factions = list(FACTION_SLIME) //an oozeling wont be eaten by their brethren
	species_language_holder = /datum/language_holder/oozeling
	ass_image = 'icons/ass/assslime.png'
	//swimming_component = /datum/component/swimming/dissolve
	wing_types = list(/obj/item/organ/external/wings/functional/slime)

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling,
	)

	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	var/datum/action/cooldown/spell/slime_washing/slime_washing
	var/datum/action/cooldown/spell/slime_hydrophobia/slime_hydrophobia
	var/datum/action/innate/core_signal/core_signal

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
	if(slime_washing)
		slime_washing.Remove(C)
	if(slime_hydrophobia)
		slime_hydrophobia.Remove(C)
	if(core_signal)
		core_signal.Remove(C)
	..()

/datum/species/oozeling/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)
		slime_washing = new
		slime_washing.Grant(C)
		slime_hydrophobia = new
		slime_hydrophobia.Grant(C)
		core_signal = new
		core_signal.Grant(C)

//////
/// HEALING SECTION
/// Handles passive healing and water damage.

/datum/species/oozeling/spec_life(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	. = ..()
	if(slime.stat != CONSCIOUS)
		return

	var/healing = TRUE

	var/datum/status_effect/fire_handler/wet_stacks/wetness = locate() in slime.status_effects
	if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
		return
	if(istype(wetness) && wetness.stacks > (DAMAGE_WATER_STACKS))
		slime.blood_volume -= 2 * seconds_per_tick
		if (SPT_PROB(25, seconds_per_tick))
			slime.visible_message(span_danger("[slime]'s form begins to lose cohesion, seemingly diluting with the water!"), span_warning("The water starts to dilute your body, dry it off!"))

	if(istype(wetness) && wetness.stacks > (REGEN_WATER_STACKS))
		healing = FALSE
		if (SPT_PROB(25, seconds_per_tick))
			to_chat(slime, span_warning("You can't pull your body together and regenerate with water inside it!"))
			slime.blood_volume -= 1 * seconds_per_tick

	if(slime.blood_volume > BLOOD_VOLUME_NORMAL && healing)
		if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
			return
		if(slime.stat != CONSCIOUS)
			return
		slime.heal_overall_damage(brute = 2 * seconds_per_tick, burn = 2 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
		slime.adjustOxyLoss(-1 * seconds_per_tick)

	if(!slime.blood_volume)
		slime.blood_volume += 5
		slime.adjustBruteLoss(5)
		to_chat(slime, span_danger("You feel empty!"))

	if(slime.nutrition >= NUTRITION_LEVEL_WELL_FED && slime.blood_volume <= 672)
		if(slime.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
			slime.adjust_nutrition(-5)
			slime.blood_volume += 10
		else
			slime.blood_volume += 8

	if(slime.nutrition <= NUTRITION_LEVEL_HUNGRY)
		if(slime.nutrition <= NUTRITION_LEVEL_STARVING)
			slime.blood_volume -= 8
			if(prob(5))
				to_chat(slime, span_info("You're starving! Get some food!"))
		else
			if(prob(35))
				slime.blood_volume -= 2
				if(prob(5))
					to_chat(slime, span_danger("You're feeling pretty hungry..."))

	if(slime.blood_volume < BLOOD_VOLUME_OKAY && prob(5))
		to_chat(slime, span_danger("You feel drained!"))
	if(slime.blood_volume < BLOOD_VOLUME_OKAY)
		Cannibalize_Body(slime)

	if(slime.blood_volume < 0)
		slime.blood_volume = 0

/datum/species/oozeling/proc/Cannibalize_Body(mob/living/carbon/human/slime)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - slime.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb

	if(!limbs_to_consume.len)
		slime.losebreath++
		return
	if(slime.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)

	consumed_limb = slime.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()

	to_chat(slime, span_userdanger("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	slime.blood_volume += 80
	slime.nutrition += 20

///////
/// CHEMICAL HANDLING
/// Here's where slimes heal off plasma and where they hate drinking water.

/datum/species/oozeling/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	// slimes use plasma to fix wounds, and if they have enough blood, organs
	var/static/list/organs_we_mend = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
	)
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		for(var/datum/wound/iter_wound as anything in slime.all_wounds)
			iter_wound.on_xadone(4 * REM * seconds_per_tick)
			slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if(slime.blood_volume > BLOOD_VOLUME_SLIME_SPLIT)
			slime.adjustOrganLoss(
			pick(organs_we_mend),
			- 2 * seconds_per_tick,
		)
		if (SPT_PROB(5, seconds_per_tick))
			to_chat(slime, span_purple("Your body's thirst for plasma is quenched, your inner and outer membrane using it to regenerate."))

	if(chem.type == /datum/reagent/water)
		if(HAS_TRAIT(slime, TRAIT_SLIME_HYDROPHOBIA))
			return TRUE

		slime.blood_volume -= 3 * seconds_per_tick
		slime.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
		if (SPT_PROB(25, seconds_per_tick))
			to_chat(slime, span_warning("The water starts to weaken and adulterate your insides!"))

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
		to_chat(M, span_danger("Your insides are burning!</span>"))
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
