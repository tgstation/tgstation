/// Component for Strongleg prosthesis combat abilities
/datum/component/strongleg_combat
	var/kick_knockback_distance

/datum/component/strongleg_combat/Initialize(kick_knockback_distance = 3)
	. = ..()
	src.kick_knockback_distance = kick_knockback_distance

/datum/component/strongleg_combat/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_PUNCHED, PROC_REF(on_kick))

/datum/component/strongleg_combat/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_HUMAN_PUNCHED)

/datum/component/strongleg_combat/proc/on_kick(mob/living/carbon/human/source, mob/living/carbon/human/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	if(!kicking)
		return NONE

	if(target.body_position == LYING_DOWN)
		return NONE

	var/throw_dir = get_dir(source, target)
	var/turf/throw_target = get_edge_target_turf(target, throw_dir)
	target.safe_throw_at(throw_target, kick_knockback_distance, 1, source, gentle = FALSE)

	target.visible_message(
		span_danger("[capitalize(target.declent_ru(NOMINATIVE))] отлетает от мощного пинка!"),
		span_userdanger("Мощный пинок отбрасывает вас!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Ваш пинок отбрасывает [target.declent_ru(ACCUSATIVE)]!"))

/// Counts installed strongleg limbs
/proc/count_strongleg_limbs(mob/living/carbon/owner)
	var/count = 0
	if(istype(owner.get_bodypart(BODY_ZONE_L_LEG), /obj/item/bodypart/leg/left/strongleg))
		count++
	if(istype(owner.get_bodypart(BODY_ZONE_R_LEG), /obj/item/bodypart/leg/right/strongleg))
		count++
	return count

/// Creates component if 2 limbs, removes if less
/proc/setup_strongleg(mob/living/carbon/owner)
	var/limbs_count = count_strongleg_limbs(owner)

	if(limbs_count >= HUMAN_LIMBS_COUNT)
		if(!owner.GetComponent(/datum/component/strongleg_combat))
			owner.AddComponent(/datum/component/strongleg_combat, 2)
	else
		var/datum/component/strongleg_combat/combat_component = owner.GetComponent(/datum/component/strongleg_combat)
		qdel(combat_component)

/// Removes component when limbs drop below required
/proc/cleanup_strongleg(mob/living/carbon/owner)
	var/limbs_count = count_strongleg_limbs(owner)

	if(limbs_count < HUMAN_LIMBS_COUNT)
		var/datum/component/strongleg_combat/combat_component = owner.GetComponent(/datum/component/strongleg_combat)
		qdel(combat_component)

/obj/item/bodypart/leg/left/strongleg
	name = "augmented left leg"
	desc = "Combat prosthesis with enhanced hydraulics for powerful kicks and rapid movement. \
		Kicks knockback enemies, stomps keep them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	speed_modifier = -0.2

	unarmed_damage_low = 15
	unarmed_damage_high = 30
	unarmed_effectiveness = 25

	bodypart_traits = list(
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
	)

/obj/item/bodypart/leg/left/strongleg/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		setup_strongleg(new_owner)

/obj/item/bodypart/leg/left/strongleg/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		cleanup_strongleg(old_owner)
	return ..()

/obj/item/bodypart/leg/right/strongleg
	name = "augmented right leg"
	desc = "Combat prosthesis with enhanced hydraulics for powerful kicks and rapid movement. \
		Kicks knockback enemies, stomps keep them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	speed_modifier = -0.2

	unarmed_damage_low = 15
	unarmed_damage_high = 30
	unarmed_effectiveness = 25

	bodypart_traits = list(
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
	)

/obj/item/bodypart/leg/right/strongleg/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		setup_strongleg(new_owner)

/obj/item/bodypart/leg/right/strongleg/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		cleanup_strongleg(old_owner)
	return ..()
