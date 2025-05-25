#define DISMEMBER_CHANCE_HIGH 50
#define DISMEMBER_CHANCE_LOW 25

#define MOVEDELAY_ANGRY 4.5
#define MOVEDELAY_SAFETY 2.5

/obj/vehicle/sealed/mecha/justice
	name = "\improper Justice"
	desc = "Black and red syndicate mech designed for execution orders. \
		For safety reasons, the syndicate advises against standing too close."
	icon_state = "justice"
	base_icon_state = "justice"
	movedelay = MOVEDELAY_SAFETY // fast
	max_integrity = 200 // but weak
	accesses = list(ACCESS_SYNDICATE)
	armor_type = /datum/armor/mecha_justice
	max_temperature = 40000
	force = 60 // dangerous in melee
	damtype = BRUTE
	destruction_sleep_duration = 10
	exit_delay = 10
	wreckage = /obj/structure/mecha_wreckage/justice
	mech_type = EXOSUIT_MODULE_JUSTICE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	mecha_flags = ID_LOCK_ON | QUIET_STEPS | QUIET_TURNS | CAN_STRAFE | HAS_LIGHTS | MMI_COMPATIBLE | IS_ENCLOSED | AI_COMPATIBLE
	destroy_wall_sound = 'sound/vehicles/mecha/mech_blade_break_wall.ogg'
	brute_attack_sound = 'sound/vehicles/mecha/mech_blade_attack.ogg'
	attack_verbs = list("cut", "cuts", "cutting")
	weapons_safety = TRUE
	safety_sound_custom = TRUE
	max_equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	step_energy_drain = 2

/datum/armor/mecha_justice
	melee = 30
	bullet = 20
	laser = 20
	energy = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/justice/Initialize(mapload, built_manually)
	. = ..()
	RegisterSignal(src, COMSIG_MECHA_MELEE_CLICK, PROC_REF(justice_fatality)) //We do not hit those who are in crit or stun. We are finishing them.
	transform = transform.Scale(1.04, 1.04)

/obj/vehicle/sealed/mecha/justice/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/invisibility)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/charge_attack)

/obj/vehicle/sealed/mecha/justice/update_icon_state()
	. = ..()
	if(!LAZYLEN(occupants))
		return
	icon_state = weapons_safety ? "[base_icon_state]" : "[base_icon_state]-angry"
	if(!has_gravity())
		icon_state = "[icon_state]-fly"

/obj/vehicle/sealed/mecha/justice/set_safety(mob/user)
	. = ..()
	if(weapons_safety)
		movedelay = MOVEDELAY_SAFETY
	else
		movedelay = MOVEDELAY_ANGRY

	playsound(src, 'sound/vehicles/mecha/mech_blade_safty.ogg', 75, FALSE) //everyone need to hear this sound

	update_appearance(UPDATE_ICON_STATE)

/obj/vehicle/sealed/mecha/justice/Move(newloc, dir)
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/// Says 1 of 3 epic phrases before attacking and make a finishing blow to targets in stun or crit after 1 SECOND.
/obj/vehicle/sealed/mecha/justice/proc/justice_fatality(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/live_or_dead = target
	if(live_or_dead.stat < UNCONSCIOUS && live_or_dead.getStaminaLoss() < 100)
		return FALSE
	var/obj/item/bodypart/check_head = live_or_dead.get_bodypart(BODY_ZONE_HEAD)
	if(!check_head)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(finish_him), src, pilot, live_or_dead)
	return TRUE

/**
 * ## finish_him
 *
 * Target's head is cut off (if it has one)
 * Attack from invisibility and charged attack have higher priority.
 * Arguments:
 * * finisher - Mech pilot who makes an attack.
 * * him - Target at which the mech makes an attack.
 */
/obj/vehicle/sealed/mecha/justice/proc/finish_him(obj/vehicle/sealed/mecha/my_mech, mob/finisher, mob/living/him)
	say(pick("Take my Justice-Slash!", "A falling leaf...", "Justice is quite a lonely path"), forced = "Justice Mech")
	playsound(src, 'sound/vehicles/mecha/mech_stealth_pre_attack.ogg', 75, FALSE)
	if(!do_after(finisher, 1 SECONDS, him))
		return
	if(QDELETED(finisher))
		return
	if(QDELETED(him))
		return
	if(QDELETED(my_mech))
		return
	if(!LAZYLEN(my_mech.occupants))
		return
	var/turf/finish_turf = get_step(him, get_dir(my_mech, him))
	var/turf/for_line_turf = get_turf(my_mech)
	var/obj/item/bodypart/in_your_head = him.get_bodypart(BODY_ZONE_HEAD)
	in_your_head?.dismember(BRUTE)
	playsound(src, brute_attack_sound, 75, FALSE)
	for_line_turf.Beam(src, icon_state = "mech_charge", time = 8)
	forceMove(finish_turf)

/obj/vehicle/sealed/mecha/justice/melee_attack_effect(mob/living/victim, heavy)
	if(!heavy)
		victim.Knockdown(4 SECONDS)
		return
	if(!prob(DISMEMBER_CHANCE_HIGH))
		return
	var/obj/item/bodypart/cut_bodypart = victim.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
	cut_bodypart?.dismember(BRUTE)


/obj/vehicle/sealed/mecha/justice/mob_exit(mob/M, silent, randomstep, forced)
	. = ..()
	if(alpha == 255)
		return
	animate(src, alpha = 255, time = 0.5 SECONDS)
	playsound(src, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(LAZYLEN(occupants))
		if(prob(60))
			new /obj/effect/temp_visual/mech_sparks(get_turf(src))
			playsound(src, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)
			return
	return ..()

/datum/action/vehicle/sealed/mecha/invisibility
	name = "Invisibility"
	button_icon_state = "mech_stealth_off"
	/// Is invisibility activated.
	var/on = FALSE
	/// Recharge check.
	var/charge = TRUE
	/// Varset for invisibility timer
	var/invisibility_timer
	/// Energy cost to become invisibile
	var/energy_cost = 200
	/// Aoe pre attack sound.
	var/stealth_pre_attack_sound = 'sound/vehicles/mecha/mech_stealth_pre_attack.ogg'
	/// Aoe attack sound.
	var/stealth_attack_sound = 'sound/vehicles/mecha/mech_stealth_attack.ogg'

/datum/action/vehicle/sealed/mecha/invisibility/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECH_SAFETIES_TOGGLE, PROC_REF(on_toggle_safety))

/// update button icon when toggle safety and turns invisibility off.
/datum/action/vehicle/sealed/mecha/invisibility/proc/on_toggle_safety()
	SIGNAL_HANDLER
	invisibility_off()
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/vehicle/sealed/mecha/invisibility/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	on = !on
	if(on)
		invisibility_on()
	else
		invisibility_off()

/datum/action/vehicle/sealed/mecha/invisibility/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!chassis.has_charge(energy_cost))
		if(feedback)
			owner.balloon_alert(owner, "not enough energy!")
		return FALSE
	if(chassis.weapons_safety)
		if(feedback)
			owner.balloon_alert(owner, "safety is on!")
		return FALSE
	if(!charge)
		if(feedback)
			owner.balloon_alert(owner, "recharging!")
		return FALSE

	return TRUE

///Called when invisibility activated.
/datum/action/vehicle/sealed/mecha/invisibility/proc/invisibility_on()
	new /obj/effect/temp_visual/mech_sparks(get_turf(chassis))
	playsound(chassis, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	check_charge_attack()
	animate(chassis, alpha = 0, time = 0.5 SECONDS)
	button_icon_state = "mech_stealth_on"
	invisibility_timer = addtimer(CALLBACK(src, PROC_REF(end_stealth)), 20 SECONDS)
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(stealth_attack_aoe))
	RegisterSignal(chassis, COMSIG_MOVABLE_BUMP, PROC_REF(bumb_on))
	RegisterSignal(chassis, COMSIG_ATOM_BUMPED, PROC_REF(bumbed_on))
	RegisterSignal(chassis, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(take_damage))
	chassis.use_energy(energy_cost)
	build_all_button_icons()

///Called when invisibility deactivated.
/datum/action/vehicle/sealed/mecha/invisibility/proc/invisibility_off()
	new /obj/effect/temp_visual/mech_sparks(get_turf(chassis))
	playsound(chassis, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	invisibility_timer = null
	charge = FALSE
	addtimer(CALLBACK(src, PROC_REF(charge)), 5 SECONDS)
	button_icon_state = "mech_stealth_cooldown"
	animate(chassis, alpha = 255, time = 0.5 SECONDS)
	UnregisterSignal(chassis, list(
		COMSIG_MECHA_MELEE_CLICK,
		COMSIG_MOVABLE_BUMP,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_TAKE_DAMAGE
		))
	build_all_button_icons()

///Check if mech use charge attack and deactivate it when we activate invisibility.
/datum/action/vehicle/sealed/mecha/invisibility/proc/check_charge_attack()
	for(var/mob/living/occupant in chassis.occupants)
		var/datum/action/vehicle/sealed/mecha/charge_attack/charge_action = LAZYACCESSASSOC(chassis.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/charge_attack)
		if(charge_action?.on)
			charge_action.on = !on
			charge_action.charge_attack_off()
/**
 * ## end_stealth
 *
 * Called when mech runs out of invisibility time.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/end_stealth()
	make_visible()

/**
 * ## bumb_on
 *
 * Called when mech bumb on somthing. If is living somthing shutdown mech invisibility.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/bumb_on(obj/vehicle/sealed/mecha/our_mech, atom/obstacle)
	SIGNAL_HANDLER

	if(!isliving(obstacle))
		return
	make_visible()

/**
 * ## bumbed_on
 *
 * Called when somthing bumbed on mech. If is living somthing shutdown mech invisibility.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/bumbed_on(obj/vehicle/sealed/mecha/our_mech, atom/movable/bumped_atom)
	SIGNAL_HANDLER

	if(!isliving(bumped_atom))
		return
	make_visible()

/**
 * ## take_damage
 *
 * Called when mech take damage. Shutdown mech invisibility.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/take_damage(obj/vehicle/sealed/mecha/our_mech)
	SIGNAL_HANDLER

	make_visible()

/**
 * ## make_visible
 *
 * Called when somthing force invisibility shutdown.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/make_visible()
	if(!on)
		return
	on = !on
	invisibility_off()

/**
 * Proc makes an AOE attack after 1 SECOND.
 * Called by the mech pilot when he is in stealth mode and wants to attack.
 * During this, mech cannot move.
*/
/datum/action/vehicle/sealed/mecha/invisibility/proc/stealth_attack_aoe(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	if(!charge)
		return FALSE
	if(chassis.alpha != 0)
		UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
		return FALSE
	UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
	new /obj/effect/temp_visual/mech_attack_aoe_charge(get_turf(chassis))
	ADD_TRAIT(chassis, TRAIT_IMMOBILIZED, REF(src))
	playsound(chassis, stealth_pre_attack_sound, 75, FALSE)
	addtimer(CALLBACK(src, PROC_REF(attack_in_aoe), pilot), 1 SECONDS)
	return TRUE

/**
 * ## attack_in_aoe
 *
 * Brings mech out of invisibility.
 * Deal everyone in range 3x3 35 damage and 25 chanse to cut off limb.
 * Arguments:
 * * pilot - occupant inside mech.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/attack_in_aoe(mob/living/pilot)
	invisibility_off()
	new /obj/effect/temp_visual/mech_attack_aoe_attack(get_turf(chassis))
	for(var/mob/living/something_living in range(1, get_turf(chassis)))
		if(something_living.stat >= UNCONSCIOUS)
			continue
		if(something_living.getStaminaLoss() >= 100)
			continue
		if(something_living == pilot)
			continue
		if(prob(DISMEMBER_CHANCE_LOW))
			var/obj/item/bodypart/cut_bodypart = something_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
			cut_bodypart?.dismember(BRUTE)
		something_living.apply_damage(35, BRUTE)
	playsound(chassis, stealth_attack_sound, 75, FALSE)
	REMOVE_TRAIT(chassis, TRAIT_IMMOBILIZED, REF(src))
	on = !on
	charge = FALSE
	button_icon_state = "mech_stealth_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, PROC_REF(charge)), 5 SECONDS)

/**
 * ## charge
 *
 * Recharge invisibility action after 5 SECONDS.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/charge()
	button_icon_state = "mech_stealth_off"
	charge = TRUE
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/charge_attack
	name = "Charge Attack"
	button_icon_state = "mech_charge_off"
	/// Is charge attack activated.
	var/on = FALSE
	/// Recharge check.
	var/charge = TRUE
	/// Energy cost to perform charge attack
	var/energy_cost = 400
	/// Maximum range of charge attack.
	var/max_charge_range = 7
	/// Sound when mech do charge attack.
	var/charge_attack_sound = 'sound/vehicles/mecha/mech_charge_attack.ogg'

/datum/action/vehicle/sealed/mecha/charge_attack/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECH_SAFETIES_TOGGLE, PROC_REF(on_toggle_safety))

/// update button icon when toggle safety.
/datum/action/vehicle/sealed/mecha/charge_attack/proc/on_toggle_safety()
	SIGNAL_HANDLER

	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/vehicle/sealed/mecha/charge_attack/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	on = !on
	if(on)
		charge_attack_on()
	else
		charge_attack_off()

/datum/action/vehicle/sealed/mecha/charge_attack/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!chassis.has_charge(energy_cost))
		if(feedback)
			owner.balloon_alert(owner, "not enough energy!")
		return FALSE
	if(chassis.weapons_safety)
		if(feedback)
			owner.balloon_alert(owner, "safety is on!")
		return FALSE
	if(!charge)
		if(feedback)
			owner.balloon_alert(owner, "recharging!")
		return FALSE

	return TRUE

///Called when charge attack activated
/datum/action/vehicle/sealed/mecha/charge_attack/proc/charge_attack_on()
	check_visability()
	button_icon_state = "mech_charge_on"
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(click_try_charge))
	build_all_button_icons()

///Called when charge attack deactivated
/datum/action/vehicle/sealed/mecha/charge_attack/proc/charge_attack_off()
	button_icon_state = "mech_charge_off"
	UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
	build_all_button_icons()

///Check if mech use invisibility and deactivate it when we activate charge attack.
/datum/action/vehicle/sealed/mecha/charge_attack/proc/check_visability()
	for(var/who_inside in chassis.occupants)
		var/mob/living/occupant = who_inside
		var/datum/action/vehicle/sealed/mecha/invisibility/stealth_action = LAZYACCESSASSOC(chassis.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/invisibility)
		if(stealth_action?.on)
			stealth_action.make_visible()

///Called when mech attacks with charge attack enabled.
/datum/action/vehicle/sealed/mecha/charge_attack/proc/click_try_charge(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	var/turf = get_turf(target)
	if(!on)
		UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
		return FALSE
	if(isnull(turf))
		pilot.balloon_alert(pilot, "invalid direction!")
		return FALSE
	if(!charge)
		pilot.balloon_alert(pilot, "recharging!")
		return FALSE
	else
		if(charge_attack(pilot, turf))
			return TRUE
	return FALSE

/**
 * ## charge_attack
 *
 * Deal everyone in line for mech location to mouse location 35 damage and 25 chanse to cut off limb.
 * Teleport mech to the end of line.
 * Arguments:
 * * charger - occupant inside mech.
 * * target - occupant inside mech.
 */
/datum/action/vehicle/sealed/mecha/charge_attack/proc/charge_attack(mob/living/charger, atom/target)
	var/turf/start_charge_here = get_turf(charger)
	var/turf/target_pos = get_turf(target)
	var/turf/here_we_go = start_charge_here
	for(var/turf/line_turf in get_line(start_charge_here, target_pos))
		if(floor(get_dist_euclidean(start_charge_here, line_turf)) > max_charge_range)
			break
		if(get_turf(charger) == get_turf(line_turf))
			continue
		if(isclosedturf(line_turf))
			break
		var/obj/machinery/power/supermatter_crystal/funny_crystal = locate() in line_turf
		if(funny_crystal)
			funny_crystal.Bumped(chassis)
			break
		var/obj/machinery/door/airlock/like_a_wall = locate() in line_turf
		if(like_a_wall?.density)
			break
		if(locate(/obj/structure/window) in line_turf)
			break
		for(var/mob/living/something_living in line_turf.contents)
			if(something_living.stat >= UNCONSCIOUS || something_living.getStaminaLoss() >= 100 || something_living == charger)
				continue
			if(prob(DISMEMBER_CHANCE_LOW))
				var/obj/item/bodypart/cut_bodypart = something_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_HEAD))
				cut_bodypart?.dismember(BRUTE)
			something_living.apply_damage(35, BRUTE)
		here_we_go = line_turf

	// If the mech didn't move, it didn't charge
	if(here_we_go == start_charge_here)
		charger.balloon_alert(charger, "invalid direction!")
		return FALSE
	chassis.forceMove(here_we_go)
	start_charge_here.Beam(chassis, icon_state = "mech_charge", time = 8)
	playsound(chassis, charge_attack_sound, 75, FALSE)
	on = !on
	chassis.use_energy(energy_cost)
	UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
	charge = FALSE
	button_icon_state = "mech_charge_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, PROC_REF(charge)), 5 SECONDS)
	return TRUE

/**
 * ## charge
 *
 * Recharge charge attack action after 5 SECONDS.
 */
/datum/action/vehicle/sealed/mecha/charge_attack/proc/charge()
	charge = TRUE
	button_icon_state = "mech_charge_off"
	build_all_button_icons()

/obj/vehicle/sealed/mecha/justice/loaded
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/justice/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()

#undef DISMEMBER_CHANCE_HIGH
#undef DISMEMBER_CHANCE_LOW

#undef MOVEDELAY_ANGRY
#undef MOVEDELAY_SAFETY
