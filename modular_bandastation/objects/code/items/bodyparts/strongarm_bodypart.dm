/// Element for enhanced mob throwing
/datum/element/strongarm_throw

/datum/element/strongarm_throw/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_THROWINGARM, "strongarm_prosthesis")

/datum/element/strongarm_throw/Detach(datum/target)
	REMOVE_TRAIT(target, TRAIT_THROWINGARM, "strongarm_prosthesis")
	return ..()

/// Component for Strongarm prosthesis combat abilities
/datum/component/strongarm_combat
	var/knockback_distance
	var/shove_throw_distance
	var/shove_throw_speed
	var/shove_knockdown_time

/datum/component/strongarm_combat/Initialize(
	knockback_distance = 3,
	shove_throw_distance = 5,
	shove_throw_speed = 3,
	shove_knockdown_time = 3 SECONDS,
)
	. = ..()
	src.knockback_distance = knockback_distance
	src.shove_throw_distance = shove_throw_distance
	src.shove_throw_speed = shove_throw_speed
	src.shove_knockdown_time = shove_knockdown_time

/datum/component/strongarm_combat/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HUMAN_PUNCHED, PROC_REF(on_punch))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))

/datum/component/strongarm_combat/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HUMAN_PUNCHED, COMSIG_LIVING_UNARMED_ATTACK))

/datum/component/strongarm_combat/proc/on_punch(mob/living/carbon/human/source, mob/living/carbon/human/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	if(kicking || target.body_position == LYING_DOWN)
		return NONE

	var/throw_dir = get_dir(source, target)
	var/turf/throw_target = get_edge_target_turf(target, throw_dir)
	target.safe_throw_at(throw_target, knockback_distance, 1, source, gentle = FALSE)

	target.visible_message(
		span_danger("[capitalize(target.declent_ru(NOMINATIVE))] отлетает от мощного удара!"),
		span_userdanger("Мощный удар отбрасывает вас!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Ваш удар отбрасывает [target.declent_ru(ACCUSATIVE)]!"))

/datum/component/strongarm_combat/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE

	if(!isliving(target))
		return NONE

	var/mob/living/living_target = target
	if(source == living_target)
		return NONE

	var/mob/living/carbon/human/human_source = source
	if(!istype(human_source))
		return NONE


	if(living_target.check_block(human_source, 0, "[human_source.declent_ru(ACCUSATIVE)]", UNARMED_ATTACK))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	var/throw_dir = get_dir(source, living_target)
	var/turf/throw_target = get_edge_target_turf(living_target, throw_dir)

	playsound(living_target, 'sound/items/weapons/shove.ogg', 50, TRUE, -1)
	human_source.do_attack_animation(living_target, ATTACK_EFFECT_DISARM)

	living_target.Knockdown(shove_knockdown_time, daze_amount = 3 SECONDS)
	living_target.safe_throw_at(throw_target, shove_throw_distance, shove_throw_speed, source, gentle = FALSE)

	var/obj/item/target_held_item = living_target.get_active_held_item()
	if(target_held_item && (living_target.has_status_effect(/datum/status_effect/staggered) || living_target.body_position == LYING_DOWN))
		living_target.dropItemToGround(target_held_item)
		living_target.visible_message(
			span_danger("[capitalize(living_target.declent_ru(NOMINATIVE))] роняет [target_held_item.declent_ru(ACCUSATIVE)]!"),
			span_warning("Вы роняете [target_held_item.declent_ru(ACCUSATIVE)]!"),
			null,
			COMBAT_MESSAGE_RANGE
		)

	living_target.visible_message(
		span_danger("[capitalize(source.declent_ru(NOMINATIVE))] с силой толкает [living_target.declent_ru(ACCUSATIVE)], сбивая с ног!"),
		span_userdanger("[capitalize(source.declent_ru(NOMINATIVE))] с огромной силой толкает вас, сбивая с ног!"),
		span_hear("Вы слышите глухой удар!"),
		COMBAT_MESSAGE_RANGE,
		source
	)
	to_chat(source, span_danger("Вы с силой толкаете [living_target.declent_ru(ACCUSATIVE)], сбивая с ног!"))

	log_combat(source, living_target, "strongarm shoved")

	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Counts installed strongarm limbs
/proc/count_strongarm_limbs(mob/living/carbon/owner)
	var/count = 0
	if(istype(owner.get_bodypart(BODY_ZONE_L_ARM), /obj/item/bodypart/arm/left/strongarm))
		count++
	if(istype(owner.get_bodypart(BODY_ZONE_R_ARM), /obj/item/bodypart/arm/right/strongarm))
		count++
	return count

/// Creates component and element if 2 limbs, removes if less
/proc/setup_strongarm(mob/living/carbon/owner)
	var/limbs_count = count_strongarm_limbs(owner)

	if(limbs_count >= HUMAN_LIMBS_COUNT)
		owner.AddElement(/datum/element/strongarm_throw)
		if(!owner.GetComponent(/datum/component/strongarm_combat))
			owner.AddComponent(/datum/component/strongarm_combat, 3, 5, 3, 3 SECONDS)
	else
		owner.RemoveElement(/datum/element/strongarm_throw)
		var/datum/component/strongarm_combat/combat_component = owner.GetComponent(/datum/component/strongarm_combat)
		qdel(combat_component)

/// Removes component and element when limbs drop below required
/proc/cleanup_strongarm(mob/living/carbon/owner)
	var/limbs_count = count_strongarm_limbs(owner)

	if(limbs_count < HUMAN_LIMBS_COUNT)
		owner.RemoveElement(/datum/element/strongarm_throw)
		var/datum/component/strongarm_combat/combat_component = owner.GetComponent(/datum/component/strongarm_combat)
		qdel(combat_component)

/obj/item/bodypart/arm/left/strongarm
	name = "augmented left arm"
	desc = "Combat prosthesis with enhanced hydraulics for crushing blows, grabs and throws. \
		Punches knockback enemies, shoves knock them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	interaction_modifier = -0.5
	click_cd_modifier = 0.7

	unarmed_damage_low = 20
	unarmed_damage_high = 45
	unarmed_effectiveness = 35
	unarmed_grab_damage_bonus = 35
	unarmed_grab_state_bonus = 10
	unarmed_grab_escape_chance_bonus = -100
	unarmed_pummeling_bonus = 2.0

	bodypart_traits = list(
		TRAIT_THROWINGARM,
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_GRABRESISTANCE,
	)

/obj/item/bodypart/arm/left/strongarm/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		setup_strongarm(new_owner)

/obj/item/bodypart/arm/left/strongarm/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		cleanup_strongarm(old_owner)
	return ..()

/obj/item/bodypart/arm/right/strongarm
	name = "augmented right arm"
	desc = "Combat prosthesis with enhanced hydraulics for crushing blows, grabs and throws. \
		Punches knockback enemies, shoves knock them down. \
		Based on technology similar to the Strongarm implant, but implemented as a full prosthesis."

	brute_modifier = 0.5
	burn_modifier = 0.5
	wound_resistance = 20
	max_damage = 80
	can_be_disabled = FALSE

	interaction_modifier = -0.5
	click_cd_modifier = 0.7

	unarmed_damage_low = 20
	unarmed_damage_high = 45
	unarmed_effectiveness = 35
	unarmed_grab_damage_bonus = 35
	unarmed_grab_state_bonus = 10
	unarmed_grab_escape_chance_bonus = -100
	unarmed_pummeling_bonus = 2.0

	bodypart_traits = list(
		TRAIT_THROWINGARM,
		TRAIT_SHOCKIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_GRABRESISTANCE,
	)

/obj/item/bodypart/arm/right/strongarm/try_attach_limb(mob/living/carbon/new_owner, special)
	. = ..()
	if(. && istype(new_owner))
		setup_strongarm(new_owner)

/obj/item/bodypart/arm/right/strongarm/on_removal(mob/living/carbon/old_owner)
	if(old_owner)
		cleanup_strongarm(old_owner)
	return ..()
