/**
 * Kneecapping component replaces the item's secondary attack with an aimed attack at the kneecaps under certain circumstances.
 *
 * Component incompatible with non-items. Requires the parent item to have a force equal to or greater than WOUND_MINIMUM_DAMAGE.
 * Also requires that the parent can actually get past pre_secondary_attack without the attack chain cancelling.
 *
 * Kneecapping attacks have a wounding bonus between severe and critical+10 wound thresholds. Without some serious wound protecting
 * armour this all but guarantees a wound of some sort. The attack is directed specifically at a limb and the limb takes the damage.
 *
 * Requires the attacker to be aiming for either leg zone, which will be targetted specifically. They will than have a 2-second
 * do_mob before executing the attack.
 *
 * Kneecapping requires the target to either be on the floor, immobilised or buckled to something.
 *
 * Passing all the checks will cancel the entire attack chain.
 */
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
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SECONDARY)

/**
 * Signal handler for COMSIG_ITEM_ATTACK_SECONDARY. Does checks for pacifism, zones and target state before either returning nothing
 * if the special attack could not be attempted, performing the ordinary attack procs instead - Or cancelling the attack chain if
 * the attack can be started.
 */
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

/**
 * After a short do_mob, attacker applies damage to the given leg with a significant wounding bonus, applying the weapon's force as damage.
 */
/datum/component/kneecapping/proc/do_kneecap_target(obj/item/weapon, obj/item/bodypart/leg, mob/living/carbon/target, mob/attacker)
	if(LAZYACCESS(attacker.do_afters, src))
		return

	attacker.visible_message(span_warning("[attacker] carefully aims [attacker.p_their()] [weapon] for a swing at [target]'s kneecaps!"), span_danger("You carefully aim \the [weapon] for a swing at [target]'s kneecaps!"))
	log_combat(attacker, target, "started aiming a swing to break the kneecaps of", weapon)

	if(do_mob(attacker, target, 3 SECONDS, interaction_key = src))
		attacker.visible_message(span_warning("[attacker] swings [attacker.p_their()] [weapon] at [target]'s kneecaps!"), span_danger("You swing \the [weapon] at [target]'s kneecaps!"))
		var/datum/wound/blunt/severe/severe_wound_type = /datum/wound/blunt/severe
		var/datum/wound/blunt/critical/critical_wound_type = /datum/wound/blunt/critical
		leg.receive_damage(brute = weapon.force, wound_bonus = rand(initial(severe_wound_type.threshold_minimum), initial(critical_wound_type.threshold_minimum) + 10))
		log_combat(attacker, target, "broke ther kneecaps of", weapon)
		target.update_damage_overlays()
		attacker.do_attack_animation(target, used_item = weapon)
		playsound(source = get_turf(weapon), soundin = weapon.hitsound, vol = weapon.get_clamped_volume(), vary = TRUE)
