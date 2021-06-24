/datum/component/kneecapping

/datum/component/kneecapping/Initialize()
	if(!isitem(parent))
		stack_trace("Kneecapping component added to non-item object: \[[parent]\]")
		return COMPONENT_INCOMPATIBLE

	var/obj/item/parent_item = parent

	if(parent_item.force < WOUND_MINIMUM_DAMAGE)
		stack_trace("Kneecapping component added to item with too little force to wound: \[[parent]\]")
		return COMPONENT_INCOMPATIBLE

/datum/component/kneecapping/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SECONDARY , .proc/try_kneecap_target)

/datum/component/kneecapping/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY)

/datum/component/kneecapping/proc/try_kneecap_target(obj/item/source, mob/living/carbon/target, mob/attacker, params)
	SIGNAL_HANDLER

	if((attacker.zone_selected != BODY_ZONE_L_LEG) && (attacker.zone_selected != BODY_ZONE_R_LEG))
		return

	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		return

	if(!iscarbon(target))
		return

	if(!target.buckled && !HAS_TRAIT(target, TRAIT_FLOORED) && !HAS_TRAIT(target, TRAIT_IMMOBILIZED))
		return

	var/obj/item/bodypart/leg = target.get_bodypart(attacker.zone_selected)

	if(!leg)
		return

	. = COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, .proc/do_kneecap_target, source, leg, target, attacker)

/datum/component/kneecapping/proc/do_kneecap_target(obj/item/weapon, obj/item/bodypart/leg, mob/living/carbon/target, mob/attacker)
	if(LAZYACCESS(attacker.do_afters, src))
		return

	attacker.visible_message(span_warning("[attacker] carefully aims [attacker.p_their()] [weapon] for a swing at [target]'s kneecaps!"), span_danger("You carefully aim \the [weapon] for a swing at [target]'s kneecaps!"))
	log_combat(attacker, target, "started aiming a swing to break the kneecaps of", weapon)

	if(do_mob(attacker, target, 2 SECONDS, interaction_key = src))
		attacker.visible_message(span_warning("[attacker] swings [attacker.p_their()] [weapon] at [target]'s kneecaps!"), span_danger("You swing \the [weapon] at [target]'s kneecaps!"))
		var/datum/wound/blunt/severe/severe_wound_type = /datum/wound/blunt/severe
		var/datum/wound/blunt/critical/critical_wound_type = /datum/wound/blunt/critical
		leg.receive_damage(brute = weapon.force, wound_bonus = rand(initial(severe_wound_type.threshold_minimum), initial(critical_wound_type.threshold_minimum) + 10))
		log_combat(attacker, target, "broke ther kneecaps of", weapon)
		target.update_damage_overlays()
		attacker.do_attack_animation(target, used_item = weapon)
		playsound(source = get_turf(weapon), soundin = weapon.hitsound, vol = weapon.get_clamped_volume(), vary = TRUE)
