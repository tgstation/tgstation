/datum/species/alien
	name = "Xenomorph"
	id = SPECIES_XENOMORPH
	say_mod = "hisses"
	attack_verb = "slash"
	attack_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	allowed_animal_origin = ALIEN_BODY
	mutant_organs = list(/obj/item/organ/alien/hivenode)
	skinned_type = /obj/item/stack/sheet/animalhide/xeno
	meat = /obj/item/food/meat/slab/xeno
	ass_image = 'icons/ass/assalien.png'
	knife_butcher_results = list(
		/obj/item/food/meat/slab/xeno = 5,
		/obj/item/stack/sheet/animalhide/xeno = 1,
	)
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
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	liked_food = NONE
	disliked_food = NONE
	limbs_id = "alien"
	damage_overlay_type = "" //Todo: add sprites
	fire_overlay = "Generic_mob_burning"
	dust_anim = "dust-a"
	gib_anim = "gibbed-a"
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

	mutantbrain = /obj/item/organ/brain/alien
	mutanttongue = /obj/item/organ/tongue/alien
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	mutantears = /obj/item/organ/ears
	mutantliver = /obj/item/organ/liver/alien


/datum/species/alien/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.apply_status_effect(/datum/status_effect/agent_pinpointer/xeno_queen)

/datum/species/alien/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.remove_status_effect(/datum/status_effect/agent_pinpointer/xeno_queen)
	return ..()

/datum/species/alien/get_scream_sound(mob/living/carbon/human/alien)
	return 'sound/voice/hiss5.ogg'

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
		return TRUE
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
	. = ..()

/**
 * ALIEN SUBTYPES
 *
 * - Drone
 * - Hunter
 * - Sentinel
 * - Praetorian
 * - Queen
 */

/datum/species/alien/drone
	mutant_organs = list(
		/obj/item/organ/alien/hivenode,
		/obj/item/organ/alien/plasmavessel/large,
		/obj/item/organ/alien/resinspinner,
		/obj/item/organ/alien/acid,
	)

/datum/species/alien/drone/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.AddAbility(new/obj/effect/proc_holder/alien/evolve(null))

/datum/species/alien/drone/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.RemoveAbility(new/obj/effect/proc_holder/alien/evolve(null))
	return ..()



/datum/species/alien/hunter
/datum/species/alien/sentinel
/datum/species/alien
/datum/species/alien
