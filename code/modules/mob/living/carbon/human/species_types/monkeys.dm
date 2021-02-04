/datum/species/monkey
	name = "Monkey"
	id = "monkey"
	say_mod = "chimpers"
	attack_verb = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	mutant_organs = list(/obj/item/organ/tail/monkey)
	mutant_bodyparts = list("tail_monkey" = "Monkey")
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	meat = /obj/item/food/meat/slab/monkey
	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	species_traits = list(HAS_FLESH,HAS_BONE,NO_UNDERWEAR,LIPS,NOEYESPRITES,NOBLOODOVERLAY,NOTRANSSTING, NOAUGMENTS)
	inherent_traits = list(TRAIT_MONKEYLIKE)
	no_equip = list(ITEM_SLOT_EARS, ITEM_SLOT_EYES, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN | SLIME_EXTRACT
	liked_food = MEAT | FRUIT
	limbs_id = "monkey"
	damage_overlay_type = "monkey"
	sexes = FALSE
	punchdamagelow = 1
	punchdamagehigh = 3
	punchstunthreshold = 4 // no stun punches
	species_language_holder = /datum/language_holder/monkey
	bodypart_overides = list(
	BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/monkey,\
	BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/monkey,\
	BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey,\
	BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/monkey,\
	BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/monkey,\
	BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey)
	dust_anim = "dust-m"
	gib_anim = "gibbed-m"

	payday_modifier = 1.5


/datum/species/monkey/random_name(gender,unique,lastname)
	var/randname = "monkey ([rand(1,999)])"

	return randname

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.ventcrawler = VENTCRAWLER_NUDE
	H.pass_flags |= PASSTABLE
	H.butcher_results = knife_butcher_results
	if(!H.dna.features["tail_monkey"] || H.dna.features["tail_monkey"] == "None")
		H.dna.features["tail_monkey"] = "Monkey"
		handle_mutant_bodyparts(H)

	H.dna.add_mutation(RACEMUT, MUT_NORMAL)
	H.dna.activate_mutation(RACEMUT)


/datum/species/monkey/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)
	C.pass_flags = initial(C.pass_flags)
	C.butcher_results = null
	C.dna.remove_mutation(RACEMUT)

/datum/species/monkey/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(!iscarbon(target))
			return TRUE
		var/mob/living/carbon/victim = target
		if(user.a_intent != INTENT_HARM || user.is_muzzled())
			return TRUE
		var/obj/item/bodypart/affecting = null
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			affecting = human_victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armor = victim.run_armor_check(affecting, MELEE)
		if(prob(25))
			victim.visible_message("<span class='danger'>[user]'s bite misses [victim]!</span>",
				"<span class='danger'>You avoid [user]'s bite!</span>", "<span class='hear'>You hear jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>Your bite misses [victim]!</span>")
			return TRUE
		victim.apply_damage(rand(punchdamagelow, punchdamagehigh), BRUTE, affecting, armor)
		victim.visible_message("<span class='danger'>[name] bites [victim]!</span>",
			"<span class='userdanger'>[name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>", COMBAT_MESSAGE_RANGE, name)
		to_chat(user, "<span class='danger'>You bite [victim]!</span>")
		if(armor >= 2)
			return TRUE
		for(var/d in user.diseases)
			var/datum/disease/bite_infection = d
			victim.ForceContractDisease(bite_infection)
		return TRUE
	target.attack_paw(user)
	return TRUE

/datum/species/monkey/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = ..()
	if(H.radiation > RAD_MOB_MUTATE * 2 && prob(50))	
		H.gorillize()	
		return

/datum/species/monkey/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[MONKEYDAY])
		return TRUE
	return ..()
