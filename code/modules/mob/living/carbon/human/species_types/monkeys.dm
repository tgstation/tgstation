/datum/species/monkey
	name = "Monkey"
	id = SPECIES_MONKEY
	say_mod = "chimpers"
	bodytype = BODYTYPE_ORGANIC | BODYTYPE_MONKEY
	attack_verb = "bite"
	attack_effect = ATTACK_EFFECT_BITE
	attack_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	external_organs = list(
		/obj/item/organ/external/tail/monkey = "Monkey"
	)
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	species_traits = list(
		HAS_FLESH,
		HAS_BONE,
		NO_UNDERWEAR,
		LIPS,
		NOEYESPRITES,
		NOBLOODOVERLAY,
		NOTRANSSTING,
		NOAUGMENTS,
	)
	inherent_traits = list(
		TRAIT_CAN_STRIP,
		TRAIT_GUN_NATURAL,
		//TRAIT_LITERATE,
		TRAIT_PRIMITIVE,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_WEAK_SOUL,
	)
	no_equip = list(
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_FEET,
		ITEM_SLOT_SUITSTORE,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	liked_food = MEAT | FRUIT | BUGS
	disliked_food = CLOTH
	damage_overlay_type = "monkey"
	sexes = FALSE
	punchdamagelow = 1
	punchdamagehigh = 3
	punchstunthreshold = 4 // no stun punches
	species_language_holder = /datum/language_holder/monkey

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/monkey,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/monkey,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/monkey,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/monkey,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey,
	)
	fire_overlay = "monkey"
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	payday_modifier = 1.5



/datum/species/monkey/random_name(gender,unique,lastname)
	var/randname = "monkey ([rand(1,999)])"

	return randname

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.pass_flags |= PASSTABLE
	H.butcher_results = knife_butcher_results
	H.dna.add_mutation(/datum/mutation/human/race, MUT_NORMAL)
	H.dna.activate_mutation(/datum/mutation/human/race)


/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.pass_flags = initial(C.pass_flags)
	C.butcher_results = null
	C.dna.remove_mutation(/datum/mutation/human/race)

/datum/species/monkey/spec_unarmedattack(mob/living/carbon/human/user, atom/target, modifiers)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(!iscarbon(target))
			return TRUE
		var/mob/living/carbon/victim = target
		if(user.is_muzzled())
			return TRUE
		var/obj/item/bodypart/affecting = null
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			affecting = human_victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armor = victim.run_armor_check(affecting, MELEE)
		if(prob(25))
			victim.visible_message(span_danger("[user]'s bite misses [victim]!"),
				span_danger("You avoid [user]'s bite!"), span_hear("You hear jaws snapping shut!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("Your bite misses [victim]!"))
			return TRUE
		victim.apply_damage(rand(punchdamagelow, punchdamagehigh), BRUTE, affecting, armor)
		victim.visible_message(span_danger("[name] bites [victim]!"),
			span_userdanger("[name] bites you!"), span_hear("You hear a chomp!"), COMBAT_MESSAGE_RANGE, name)
		to_chat(user, span_danger("You bite [victim]!"))
		if(armor >= 2)
			return TRUE
		for(var/d in user.diseases)
			var/datum/disease/bite_infection = d
			if(bite_infection.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
				continue
			victim.ForceContractDisease(bite_infection)
		return TRUE
	target.attack_paw(user, modifiers)
	return TRUE

/datum/species/monkey/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[MONKEYDAY])
		return TRUE
	return ..()

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/monkey)
	return pick(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',
	)

/datum/species/monkey/get_species_description()
	return "Monkeys are a type of primate that exist between humans and animals on the evolutionary chain. \
		Every year, on Monkey Day, Nanotrasen shows their respect for the little guys by allowing them to roam the station freely."

/datum/species/monkey/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station Thirteen. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up it? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Monkeys are reverted into normal humans upon being exposed to Mutadone.",
		),
	)

	return to_add

/datum/species/monkey/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add
