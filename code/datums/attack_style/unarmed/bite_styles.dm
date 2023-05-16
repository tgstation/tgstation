/*
 * This iteration of bite is based on the head bodypart
 */
/datum/attack_style/unarmed/generic_damage/limb_based/bite
	successful_hit_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	attack_effect = ATTACK_EFFECT_BITE
	default_attack_verb = "bite"
	deaf_miss_phrase = "jaws snapping shut"
	miss_chance_modifier = 25

	/// Having less armor than this on the hit bodypart will result in diseases being spread by the attacker.
	var/disease_armor_thresold = 2

/datum/attack_style/unarmed/generic_damage/limb_based/bite/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(attacker.is_muzzled() || attacker.is_mouth_covered(ITEM_SLOT_MASK))
		attacker.balloon_alert(attacker, "mouth covered, can't bite!")
		return FALSE

	return ..()

/datum/attack_style/unarmed/generic_damage/limb_based/bite/actually_apply_damage(
	mob/living/attacker,
	mob/living/smacked,
	obj/item/bodypart/hitting_with,
	damage,
	obj/item/bodypart/affecting,
	armor_block,
	direction,
)
	. = ..()
	if(armor_block >= disease_armor_thresold)
		return
	if(!smacked.try_inject(attacker, affecting))
		return

	for(var/datum/disease/bite_infection as anything in attacker.diseases)
		if(bite_infection.spread_flags & (DISEASE_SPREAD_SPECIAL|DISEASE_SPREAD_NON_CONTAGIOUS))
			continue // ignore diseases that have special spread logic, or are not contagious
		smacked.ForceContractDisease(bite_infection)

/*
 * This iteration of bite is based on the mob itself
 */
/datum/attack_style/unarmed/generic_damage/mob_attack/bite
	successful_hit_sound = 'sound/weapons/bite.ogg'
	miss_sound = 'sound/weapons/bite.ogg'
	attack_effect = ATTACK_EFFECT_BITE
	default_attack_verb = "bite"
	deaf_miss_phrase = "jaws snapping shut"
	miss_chance_modifier = 0

/datum/attack_style/unarmed/generic_damage/mob_attack/bite/larva
	miss_chance_modifier = 10

/datum/attack_style/unarmed/generic_damage/mob_attack/bite/larva/actually_apply_damage(
	mob/living/carbon/alien/larva/attacker,
	mob/living/smacked,
	obj/item/bodypart/hitting_with,
	damage,
	obj/item/bodypart/affecting,
	armor_block,
	direction,
)
	. = ..()
	// Larva will grow when they bite organic people
	if(smacked.mob_biotypes & MOB_ORGANIC)
		attacker.amount_grown = min(attacker.amount_grown + damage, attacker.max_grown)
