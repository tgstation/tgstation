#define SAIYAN_TAIL_MOOD "saiyan_humiliated"

/datum/species/saiyan
	name = "\improper Saiyan"
	id = SPECIES_SAIYAN
	mutanteyes = /obj/item/organ/internal/eyes/saiyan
	mutantbrain = /obj/item/organ/internal/brain/saiyan
	mutantheart = /obj/item/organ/internal/heart/saiyan
	mutantstomach = /obj/item/organ/internal/stomach/saiyan
	payday_modifier = 2.0
	inherent_traits = list(
		TRAIT_CATLIKE_GRACE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_USES_SKINTONES,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/clown

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/saiyan,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/saiyan,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/saiyan,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/saiyan,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/saiyan,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/saiyan,
	)
	external_organs = list(
		/obj/item/organ/external/tail/monkey/saiyan = "Monkey",
	)

/datum/species/saiyan/prepare_human_for_preview(mob/living/carbon/human/human)
	human.set_haircolor("#292929", update = FALSE)
	human.set_hairstyle("Spiky 2", update = TRUE)

/datum/species/saiyan/check_roundstart_eligible()
	return TRUE
	// if(check_holidays(APRIL_FOOLS))
	//	return TRUE
	// return ..()

/datum/species/saiyan/get_scream_sound(mob/living/carbon/human/human)
	if(human.physique == MALE)
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

/datum/species/saiyan/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_SAIYAN_SURVIVOR, PROC_REF(on_survived_boost))
	RegisterSignal(human_who_gained_species, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_tail_gained))
	RegisterSignal(human_who_gained_species, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_tail_removed))
	RegisterSignal(human_who_gained_species, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(check_tail_sever))

/datum/species/saiyan/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, list(
		COMSIG_ATOM_AFTER_ATTACKEDBY,
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_SAIYAN_SURVIVOR,
	))

/// If you take sharp damage someone might sever your tail
/datum/species/saiyan/proc/check_tail_sever(mob/living/carbon/target, obj/item/weapon, mob/attacker, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if (!proximity_flag || weapon.force < 5 || weapon.get_sharpness() != SHARP_EDGED)
		return
	if (attacker.zone_selected != BODY_ZONE_PRECISE_GROIN && attacker.zone_selected != BODY_ZONE_CHEST)
		return
	var/obj/item/organ/external/tail/saiyan_tail = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	if (isnull(saiyan_tail) || !prob(3))
		return
	target.visible_message(span_warning("[target]'s tail falls to the ground, severed completely!"))
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	saiyan_tail.Remove(target)
	saiyan_tail.forceMove(target.loc)

/// Called when we survive near-death
/datum/species/saiyan/proc/on_survived_boost(mob/living/saiyan)
	SIGNAL_HANDLER
	to_chat(saiyan, span_notice("Your near-death experience grants you more strength!"))
	saiyan.saiyan_boost()

/// When your tail is cut you get weaker
/datum/species/saiyan/proc/on_tail_gained(mob/living/vegeta, obj/item/organ/tail)
	SIGNAL_HANDLER
	if (!istype(tail, /obj/item/organ/external/tail/monkey/saiyan))
		return
	if (!vegeta.mob_mood.has_mood_of_category(SAIYAN_TAIL_MOOD))
		return
	to_chat(vegeta, span_notice("As your tail returns, your strength returns too."))
	vegeta.saiyan_boost(multiplier = 5)
	vegeta.clear_mood_event(SAIYAN_TAIL_MOOD)

/// If your tail is restored you return to original strength
/datum/species/saiyan/proc/on_tail_removed(mob/living/vegeta, obj/item/organ/tail)
	SIGNAL_HANDLER
	if (!istype(tail, /obj/item/organ/external/tail/monkey/saiyan))
		return
	to_chat(vegeta, span_boldwarning("No! Your tail!!"))
	vegeta.saiyan_boost(multiplier = -5)
	vegeta.add_mood_event(SAIYAN_TAIL_MOOD, /datum/mood_event/saiyan_humiliated)
	vegeta.Paralyze(10 SECONDS)
	vegeta.adjust_confusion(1 MINUTES)

/datum/species/saiyan/get_physical_attributes()
	return "While they appear superficially similar to humans, Saiyans are universally specimens of toned and perfect health with \
		the honed physique of warriors. They can be distinguished from inferior Human stock by their simian tails, and expressive haircuts."

/datum/species/saiyan/get_species_description()
	return "Martially-inclined space warriors who live for battle and carnage. Have a tendency to lose it when exposed to moonlight."

/datum/species/saiyan/get_species_lore()
	return list(
		"Saiyans were once native to the planet Vegeta, which they shared with another species that they annihilated utterly. \
		Saiyans are natural warriors with an instinctive understanding of martial arts and love of violence, \
		their predominant reputation in the galaxy is as conquerors who clear planets of life before selling them to the highest bidder.",
	)

/datum/species/saiyan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Strong",
			SPECIES_PERK_DESC = "Saiyans build muscle quickly and easily, and have a natural understanding of fighting unarmed.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Ki Mastery",
			SPECIES_PERK_DESC = "Mastery of martial arts grants Saiyans many useful abilities such as the ability to fire Ki Blasts, and flight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "first-aid",
			SPECIES_PERK_NAME = "Fighting Spirit",
			SPECIES_PERK_DESC = "A Saiyan who recovers from grievous injury (but not death) often becomes more powerful.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Going Ape",
			SPECIES_PERK_DESC = "Saiyans uncontrollably revert into the form of powerful giant apes when exposed to moonlight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "warning",
			SPECIES_PERK_NAME = "Achilles' Tail",
			SPECIES_PERK_DESC = "Saiyans are significantly weakened if their tail is harmed or removed.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bowl-rice",
			SPECIES_PERK_NAME = "Warrior's Appetite",
			SPECIES_PERK_DESC = "Maintaining fighting fitness sure makes you awfully hungry.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Melee Fixation",
			SPECIES_PERK_DESC = "Saiyans mostly disavow the use of projectile weaponry on the grounds of honour, although some say it's simply that their big hands mean that they're not very good at using it.",
		),
	)

	return to_add

/datum/movespeed_modifier/saiyan_speed
	variable = TRUE

/datum/mood_event/saiyan_humiliated
	description = "Someone removed your Saiyan birthright... such an insult must not be tolerated."
	mood_change = -4

#undef SAIYAN_TAIL_MOOD
