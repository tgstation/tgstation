/datum/attack_style/unarmed/generic_damage/limb_based/punch
	default_attack_verb = "punch" // The classic punch, wonderfully classic and completely random
	/// Amount of bonus stamina damage to apply in addition to the main attack type
	var/bonus_stamina_damage_modifier = 1.5

/datum/attack_style/unarmed/generic_damage/limb_based/punch/actually_apply_damage(
	mob/living/attacker,
	mob/living/smacked,
	obj/item/bodypart/hitting_with,
	obj/item/bodypart/affecting,
	datum/apply_damage_packet/packet,
)
	. = ..()
	var/datum/apply_damage_packet/new_packet = packet.copy_packet()
	new_packet.damage *= bonus_stamina_damage_modifier
	new_packet.damagetype = STAMINA
	new_packet.execute(attacker)

/datum/attack_style/unarmed/generic_damage/limb_based/punch/ethereal
	successful_hit_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	default_attack_verb = "burn"

/datum/attack_style/unarmed/generic_damage/limb_based/punch/claw
	attack_effect = ATTACK_EFFECT_CLAW
	successful_hit_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	default_attack_verb = "slash"

/datum/attack_style/unarmed/generic_damage/limb_based/punch/snail
	attack_effect = ATTACK_EFFECT_DISARM
	default_attack_verb = "slap"
