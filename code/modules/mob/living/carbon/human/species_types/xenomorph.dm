/datum/species/alien
	name = "Xenomorph"
	id = SPECIES_XENOMORPH
	say_mod = "hisses"
	attack_verb = "slashes"
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	mutant_organs = list(/obj/item/organ/alien/hivenode)
	skinned_type = /obj/item/stack/sheet/animalhide/xeno
	meat = /obj/item/food/meat/slab/xeno
	allowed_animal_origin = ALIEN_BODY
//	knife_butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	species_traits = list(
		HAS_FLESH,
		HAS_BONE,
		NO_UNDERWEAR,
		LIPS,
		NOEYESPRITES,
		NOBLOODOVERLAY,
		NOTRANSSTING,
		NOAUGMENTS,
		TRAIT_VIRUSIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_STUNRESISTANCE,
	)
	inherent_traits = list(
		TRAIT_CAN_STRIP,
		TRAIT_VENTCRAWLER_ALWAYS,
		TRAIT_PRIMITIVE,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NOHUNGER,
		TRAIT_NEVER_WOUNDED,
	)
	no_equip = list(
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_EYES,
		ITEM_SLOT_EARS,
		ITEM_SLOT_MASK,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_FEET,
		ITEM_SLOT_ID,
		ITEM_SLOT_BELT,
		ITEM_SLOT_BACK,
		ITEM_SLOT_NECK,
		ITEM_SLOT_BACKPACK,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_LPOCKET,
		ITEM_SLOT_RPOCKET,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	liked_food = NONE
	disliked_food = NONE
	limbs_id = "alien"
//	damage_overlay_type = "monkey"
	sexes = FALSE
	heatmod = 0.5 // minor heat insulation
	punchdamagelow = 20
	punchdamagehigh = 20
	species_language_holder = /datum/language_holder/alien
	bodypart_overides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/alien,\
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/alien,\
		BODY_ZONE_HEAD = /obj/item/bodypart/head/alien,\
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/alien,\
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/alien,\
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/alien,\
	)
//	fire_overlay = "Monkey_burning"
	dust_anim = "dust-a"
	gib_anim = "gibbed-a"

	mutantbrain = /obj/item/organ/brain/alien
	mutanttongue = /obj/item/organ/tongue/alien
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	mutantears = /obj/item/organ/ears
	mutantliver = /obj/item/organ/liver/alien

/datum/species/alien/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_shields(user, 0, "the [user.name]"))
		user.visible_message(span_danger("[user] attempts to touch [target]!"), \
						span_danger("[user] attempts to touch you!"), span_hear("You hear a swoosh!"), null, user)
		to_chat(user, span_warning("You attempt to touch [target]!"))
		return FALSE

	var/obj/item/held_item = target.get_active_held_item()
	if(held_item && target.dropItemToGround(held_item))
		playsound(target.loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
		user.visible_message(span_danger("[user] disarms [target]!"), \
						span_userdanger("[user] disarms you!"), span_hear("You hear aggressive shuffling!"), null, user)
		to_chat(user, span_danger("You disarm [target]!"))
	else
		playsound(target.loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
		target.Paralyze(100)
		log_combat(user, target, "tackled")
		user.visible_message(span_danger("[user] tackles [target] down!"), \
						span_userdanger("[user] tackles you down!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), null, user)
		to_chat(user, span_danger("You tackle [target] down!"))
	return TRUE


/datum/species/alien/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(target.check_shields(user, 0, "the [user.name]"))
		user.visible_message(span_danger("[user] attempts to touch [target]!"), \
						span_danger("[user] attempts to touch you!"), span_hear("You hear a swoosh!"), null, user)
		to_chat(user, span_warning("You attempt to touch [target]!"))
		return FALSE

	if(human_target.w_uniform)
		human_target.w_uniform.add_fingerprint(user)
	var/damage = prob(90) ? rand(user.melee_damage_lower, user.melee_damage_upper) : 0
	if(!damage)
		playsound(target.loc, 'sound/weapons/slashmiss.ogg', 50, TRUE, -1)
		user.visible_message(span_danger("[user] lunges at [target]!"), \
						span_userdanger("[user] lunges at you!"), span_hear("You hear a swoosh!"), null, user)
		to_chat(user, span_danger("You lunge at [target]!"))
		return FALSE
	var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
	if(!affecting)
		affecting = target.get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = target.run_armor_check(affecting, MELEE,"","",10)

	playsound(target.loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
	user.visible_message(span_danger("[user] slashes at [target]!"), \
					span_userdanger("[user] slashes at you!"), span_hear("You hear a sickening sound of a slice!"), null, user)
	to_chat(user, span_danger("You slash at [target]!"))
	log_combat(user, target, "attacked")
	if(!human_target.dismembering_strike(user, user.zone_selected)) //Dismemberment successful
		return TRUE
	target.apply_damage(damage, BRUTE, affecting, armor_block)

/datum/species/alien/spec_life(mob/living/carbon/human/species/alien/alien_current, delta_time, times_fired)
	alien_current.findQueen()
	return ..()

/datum/species/monkey/get_scream_sound(mob/living/carbon/human/alien)
	return 'sound/voice/hiss5.ogg'
