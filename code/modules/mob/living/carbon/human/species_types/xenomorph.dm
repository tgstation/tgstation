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
		TRAIT_NOBREATH,
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
	mutantears = /obj/item/organ/ears/alien
	mutantliver = /obj/item/organ/liver/alien

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


/datum/species/alien/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.apply_status_effect(/datum/status_effect/agent_pinpointer/xeno_queen)

/datum/species/alien/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.remove_status_effect(/datum/status_effect/agent_pinpointer/xeno_queen)
	return ..()

/datum/species/alien/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	return FALSE

/datum/species/alien/handle_environment(mob/living/carbon/human/alien, datum/gas_mixture/environment, delta_time, times_fired)
	// Run base mob body temperature proc before taking damage
	// this balances body temp to the environment and natural stabilization
	. = ..()

	if(alien.bodytemperature <= BODYTEMP_HEAT_DAMAGE_LIMIT)
		alien.clear_alert("alien_fire")
		return
	//Body temperature is too hot.
	alien.throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
	switch(alien.bodytemperature)
		if(360 to 400)
			apply_damage(HEAT_DAMAGE_LEVEL_1 * delta_time, BURN)
		if(400 to 460)
			apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)
		if(460 to INFINITY)
			if(alien.on_fire)
				apply_damage(HEAT_DAMAGE_LEVEL_3 * delta_time, BURN)
			else
				apply_damage(HEAT_DAMAGE_LEVEL_2 * delta_time, BURN)

/datum/species/alien/spec_death(gibbed, mob/living/carbon/human/H)
	if(stat == DEAD)
		return
	. = ..()

	update_icons()
	status_flags |= CANPUSH

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
	if(isalien(target))
		set_resting(FALSE)
		AdjustStun(-60)
		AdjustKnockdown(-60)
		AdjustImmobilized(-60)
		AdjustParalyzed(-60)
		AdjustUnconscious(-60)
		AdjustSleeping(-100)
		visible_message(span_notice("[user.name] nuzzles [src] trying to wake [p_them()] up!"))
		return TRUE
	. = ..()

/datum/species/alien/get_scream_sound(mob/living/carbon/human/alien)
	return 'sound/voice/hiss5.ogg'

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
	C.AddAbility(new /obj/effect/proc_holder/alien/evolve)

/datum/species/alien/drone/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.RemoveAbility(new /obj/effect/proc_holder/alien/evolve)
	return ..()


#define XENO_TACKLING_RANGE 7
#define XENO_TACKLING_SPEED 2
#define XENO_TACKLING_SKILL 5

/datum/species/alien/hunter
	mutant_organs = list(
		/obj/item/organ/alien/hivenode,
		/obj/item/organ/alien/plasmavessel/small,
	)
	///The stored tackling datum, to delete.
	var/datum/component/tackler

/datum/species/alien/hunter/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	tackler = C.AddComponent(/datum/component/tackler, range = XENO_TACKLING_RANGE, speed = XENO_TACKLING_SPEED, skill_mod = XENO_TACKLING_SKILL)

/datum/species/alien/hunter/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	QDEL_NULL(tackler)
	return ..()

#undef XENO_TACKLING_RANGE
#undef XENO_TACKLING_SPEED
#undef XENO_TACKLING_SKILL

/datum/species/alien/sentinel
	mutant_organs = list(
		/obj/item/organ/alien/hivenode,
		/obj/item/organ/alien/plasmavessel,
		/obj/item/organ/alien/acid,
		/obj/item/organ/alien/neurotoxin,
	)

/datum/species/alien/sentinel/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.AddAbility(new /obj/effect/proc_holder/alien/sneak)

/datum/species/alien/sentinel/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.RemoveAbility(new /obj/effect/proc_holder/alien/sneak)
	return ..()


/datum/species/alien
/datum/species/alien
