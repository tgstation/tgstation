/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "singularity_hammer0"
	base_icon_state = "singularity_hammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	worn_icon_state = "singularity_hammer"
	flags_1 = CONDUCT_1
	item_flags = NEEDS_PERMIT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	armor_type = /datum/armor/item_magichammer
	attack_style = /datum/attack_style/melee_weapon/swing/requires_wield/singularity_hammer
	weapon_sprite_angle = 45
	/// AOE radius if the suck. Don't VV this too high, you have been warned
	var/suck_radius = 5
	/// Duration of cooldown between sucks
	var/suck_cooldown_duration = 10 SECONDS
	/// Actual suck cooldown tracker
	COOLDOWN_DECLARE(suck_cooldown)

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)
	AddComponent(/datum/component/two_handed, \
		force_multiplier = 4, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/singularityhammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/datum/attack_style/melee_weapon/swing/requires_wield/singularity_hammer

/datum/attack_style/melee_weapon/swing/requires_wield/singularity_hammer/execute_attack(mob/living/attacker, obj/item/singularityhammer/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	. = ..()
	if(!istype(weapon) || !(. & ATTACK_STYLE_HIT))
		return
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		return
	if(!COOLDOWN_FINISHED(weapon, suck_cooldown))
		return

	// Grab the middle turf of the swing
	var/turf/middle_turf = affecting[ROUND_UP(length(affecting) / 2)]
	var/mob/living/bonus_damage_target = (isliving(priority_target) && (priority_target in middle_turf)) ? priority_target : locate() in middle_turf
	// Apply some bonus damage to anyone (prioritizing the clicked atom) in the middle turf
	bonus_damage_target?.apply_damage(20, BRUTE, BODY_ZONE_CHEST, wound_bonus = 5)
	// And suck in all non-anchored movables nearby
	for(var/atom/movable/suck_in in orange(weapon.suck_radius, attacker))
		if(suck_in == attacker)
			continue
		if(suck_in.move_resist >= MOVE_FORCE_OVERPOWERING || suck_in.anchored)
			continue
		if(isliving(suck_in))
			var/mob/living/vortexed_mob = suck_in
			if(vortexed_mob.mob_negates_gravity())
				continue

			vortexed_mob.Paralyze(2 SECONDS)

		step_towards(suck_in, middle_turf)
		step_towards(suck_in, middle_turf)
		step_towards(suck_in, middle_turf)

	playsound(weapon, 'sound/weapons/marauder.ogg', 50, TRUE)
	COOLDOWN_START(weapon, suck_cooldown, weapon.suck_cooldown_duration)

/obj/item/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	worn_icon_state = "mjolnir"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = NEEDS_PERMIT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE
	armor_type = /datum/armor/item_magichammer
	attack_style = /datum/attack_style/melee_weapon/swing/requires_wield
	weapon_sprite_angle = 45

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_UNCATCHABLE, INNATE_TRAIT) // No one can save you now
	AddComponent(/datum/component/two_handed, \
		force_multiplier = 5, \
		icon_wielded = "[base_icon_state]1", \
		attacksound = SFX_SPARKS, \
	)

/obj/item/mjollnir/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/mjollnir/proc/shock(mob/living/target)
	if(!istype(target))
		CRASH("Non-living target passed to shock()!")

	var/datum/effect_system/lightning_spread/thunder_and_lightning = new()
	thunder_and_lightning.set_up(5, 1, target.loc)
	thunder_and_lightning.start()

	target.Stun(1.5 SECONDS)
	target.Knockdown(10 SECONDS)
	target.visible_message(
		span_danger("[target] is shocked by [src]!"),
		span_userdanger("You feel a powerful shock course through your body sending you flying!"),
		span_hear("You hear a heavy electrical crack!"),
	)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)

/obj/item/mjollnir/attack(mob/living/target_mob, mob/user)
	. = ..()
	if(.)
		return
	if(!QDELETED(target_mob) && HAS_TRAIT(src, TRAIT_WIELDED))
		shock(target_mob)

/obj/item/mjollnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	if(!QDELETED(hit_atom) && isliving(hit_atom))
		shock(hit_atom)

/datum/armor/item_magichammer
	melee = 50
	bullet = 50
	laser = 50
	bomb = 50
	fire = 100
	acid = 100
