#define DISMEMBER_CHANCE_HIGH 50
#define DISMEMBER_CHANCE_LOW 25

#define MOVEDELAY_ANGRY 4.5
#define MOVEDELAY_SAFTY 2.5

/obj/vehicle/sealed/mecha/justice
	desc = "Black and red syndicate mech designed for execution orders. \
		For safety reasons, the syndicate advises against standing too close."
	name = "\improper Justice"
	icon_state = "justice"
	base_icon_state = "justice"
	movedelay = MOVEDELAY_SAFTY // fast
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
	mecha_flags = ID_LOCK_ON | QUIET_STEPS | QUIET_TURNS | CAN_STRAFE | HAS_LIGHTS | MMI_COMPATIBLE | IS_ENCLOSED
	destroy_wall_sound = 'sound/mecha/mech_blade_break_wall.ogg'
	brute_attack_sound = 'sound/mecha/mech_blade_attack.ogg'
	attack_verbs = list("cut", "cuts", "cutting")
	weapons_safety = TRUE
	max_equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	step_energy_drain = 2
	///Looking for parent of invisibility action in occupant abilities to check its status
	var/datum/action/vehicle/sealed/mecha/invisibility/stealth_action
	///Looking for parent of charge attack action in occupant abilities to check its status
	var/datum/action/vehicle/sealed/mecha/charge_attack/charge_action

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
	if(LAZYLEN(occupants))
		icon_state = weapons_safety ? "[base_icon_state]" : "[base_icon_state]-angry"
	if(!has_gravity())
		icon_state = "[icon_state]-fly"

/obj/vehicle/sealed/mecha/justice/process(seconds_per_tick)
	. = ..()
	for(var/mob/living/occupant in occupants)
		stealth_action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/invisibility)
		charge_action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/charge_attack)
		if(alpha == 255)
			stealth_action.on = FALSE
		else if(alpha == 0)
			stealth_action.on = TRUE
	update_appearance(UPDATE_ICON_STATE)

/obj/vehicle/sealed/mecha/justice/set_safety(mob/user)
	weapons_safety = !weapons_safety

	if(weapons_safety)
		movedelay = MOVEDELAY_SAFTY
	else
		movedelay = MOVEDELAY_ANGRY
	playsound(src, 'sound/mecha/mech_blade_safty.ogg', 75, FALSE) //everyone need to hear this sound
	balloon_alert(user, "justice [weapons_safety ? "calm and focused" : "is ready for battle"]")
	SEND_SIGNAL(src, COMSIG_MECH_SAFETIES_TOGGLE, user, weapons_safety)
	set_mouse_pointer()

	update_appearance(UPDATE_ICON_STATE)

/obj/vehicle/sealed/mecha/justice/Move(newloc, dir)
	if(stealth_action.start_attack)
		return
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

///Says 1 of 3 epic phrases before attacking and make a finishing blow to targets in stun or crit after 1 SECOND.
/obj/vehicle/sealed/mecha/justice/proc/justice_fatality(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	var/mob/living/live_or_dead = target
	if(live_or_dead.stat < UNCONSCIOUS && live_or_dead.getStaminaLoss() < 100)
		return FALSE
	if(charge_action?.on)
		return FALSE
	if(stealth_action?.on)
		return FALSE
	say(pick("Take my Justice-Slash!", "A falling leaf...", "Justice is quite a lonely path"), forced = "Justice Mech")
	playsound(src, 'sound/mecha/mech_stealth_pre_attack.ogg', 75, FALSE)
	addtimer(CALLBACK(src, PROC_REF(finish_him), pilot, live_or_dead), 1 SECONDS)
	return TRUE

/**
 * ## finish_him
 *
 * Target's head is cut off (if it has one),
 * Otherwise it deals 100 damage.
 * Attack from invisability and charged attack have higher priority.
 * Arguments:
 * * finisher - Mech pilot who makes an attack.
 * * him - Target at which the mech makes an attack.
 */
/obj/vehicle/sealed/mecha/justice/proc/finish_him(mob/finisher, mob/living/him)
	/// turf where we end attack
	var/turf/finish_turf = get_step(him, get_dir(finisher, him))
	/// turf where we start attack
	var/turf/for_line_turf = get_turf(finisher)
	var/obj/item/bodypart/in_your_head = him.get_bodypart(BODY_ZONE_HEAD)
	if(in_your_head)
		in_your_head.dismember(BRUTE)
	else
		him.apply_damage(100, BRUTE)
	playsound(src, brute_attack_sound, 75, FALSE)
	for_line_turf.Beam(src, icon_state = "mech_charge", time = 8)
	forceMove(finish_turf)

/obj/vehicle/sealed/mecha/justice/melee_attack_effect(mob/living/victim, heavy)
	if(!heavy)
		victim.Knockdown(4 SECONDS)
		return
	if(!prob(DISMEMBER_CUALITY_HIGTH))
		return
	var/obj/item/bodypart/cut_bodypart = victim.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
	cut_bodypart?.dismember(BRUTE)


/obj/vehicle/sealed/mecha/justice/mob_exit(mob/M, silent, randomstep, forced)
	. = ..()
	if(!stealth_action?.on)
		return
	animate(src, alpha = 255, time = 0.5 SECONDS)
	playsound(src, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/Bump(atom/obstacle)
	. = ..()
	if(!isliving(obstacle))
		return
	if(!stealth_action?.on)
		return
	animate(src, alpha = 255, time = 0.5 SECONDS)
	playsound(src, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return
	if(!stealth_action?.on)
		return
	animate(src, alpha = 255, time = 0.5 SECONDS)
	playsound(src, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(stealth_action?.on)
		animate(src, alpha = 255, time = 0.5 SECONDS)
		playsound(src, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	if(LAZYLEN(occupants))
		if(prob(60))
			new /obj/effect/temp_visual/mech_sparks(get_turf(src))
			playsound(src, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)
			return
	return ..()

/datum/action/vehicle/sealed/mecha/invisibility
	name = "Invisibility"
	button_icon_state = "mech_stealth_off"
	/// Is invisibility activated.
	var/on = FALSE
	/// Recharge check.
	var/charge = TRUE
	/// Block movement if we start aoe attack from invisibility.
	var/start_attack = FALSE
	/// Aoe pre attack sound.
	var/stealth_pre_attack_sound = 'sound/mecha/mech_stealth_pre_attack.ogg'
	/// Aoe attack sound.
	var/stealth_attack_sound = 'sound/mecha/mech_stealth_attack.ogg'

/datum/action/vehicle/sealed/mecha/invisibility/Trigger(trigger_flags)
	. = ..()
	if(chassis.weapons_safety)
		owner.balloon_alert(owner, "safety is on!")
		return
	if(!charge)
		owner.balloon_alert(owner, "recharging!")
		return
	new /obj/effect/temp_visual/mech_sparks(get_turf(chassis))
	on = !on
	playsound(chassis, 'sound/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	if(on)
		for(var/mob/living/occupant in chassis.occupants)
			var/datum/action/vehicle/sealed/mecha/charge_attack/charge_action = LAZYACCESSASSOC(chassis.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/charge_attack)
			if(charge_action?.on)
				charge_action.on = FALSE
		animate(chassis, alpha = 0, time = 0.5 SECONDS)
		button_icon_state = "mech_stealth_on"
		addtimer(CALLBACK(src, PROC_REF(end_stealth)), 20 SECONDS)
		RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(stealth_attack_aoe))
	else
		addtimer(CALLBACK(src, PROC_REF(charge)), 5 SECONDS)
		animate(chassis, alpha = 255, time = 0.5 SECONDS)
		button_icon_state = "mech_stealth_off"
		UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
	build_all_button_icons()

/**
 * ## end_stealth
 *
 * Called when mech runs out of invisibility time.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/end_stealth()
	if(!on)
		return
	owner.balloon_alert(owner, "invisability is over")
	Trigger()

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
	start_attack = TRUE
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
	Trigger()
	new /obj/effect/temp_visual/mech_attack_aoe_attack(get_turf(chassis))
	for(var/mob/living/something_living in range(1, get_turf(chassis)))
		if(somthing_living.stat >= UNCONSCIOUS)
			continue
		if(somthing_living.getStaminaLoss() >= 100)
			continue
		if(somthing_living == pilot)
			continue
		if(prob(DISMEMBER_CUALITY_LOW))
			var/obj/item/bodypart/cut_bodypart = somthing_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
			cut_bodypart?.dismember(BRUTE)
		somthing_living.apply_damage(35, BRUTE)
	playsound(chassis, stealth_attack_sound, 75, FALSE)
	start_attack = FALSE
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
	/// Is invisibility activated.
	var/on = FALSE
	/// Recharge check.
	var/charge = TRUE
	/// Maximum range of charge attack.
	var/max_charge_range = 7
	/// Sound when mech do charge attack.
	var/charge_attack_sound = 'sound/mecha/mech_charge_attack.ogg'

/datum/action/vehicle/sealed/mecha/charge_attack/Trigger(trigger_flags)
	if(chassis.weapons_safety)
		owner.balloon_alert(owner, "safety is on!")
		return
	if(!charge)
		owner.balloon_alert(owner, "recharging!")
		return
	on = !on
	if(on)
		for(var/who_inside in chassis.occupants)
			var/mob/living/occupant = who_inside
			var/datum/action/vehicle/sealed/mecha/charge_attack/stealth_action = LAZYACCESSASSOC(chassis.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/invisibility)
			if(stealth_action)
				if(stealth_action.on)
					stealth_action.Trigger()
		button_icon_state = "mech_charge_on"
		RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(click_try_charge))
	else
		button_icon_state = "mech_charge_off"
		UnregisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK)
	build_all_button_icons()

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
 * Brings mech out of invisibility.
 * Deal everyone in range 3x3 35 damage and 25 chanse to cut off limb.
 * Arguments:
 * * charger - occupant inside mech.
 * * target - occupant inside mech.
 */
/datum/action/vehicle/sealed/mecha/charge_attack/proc/charge_attack(mob/living/charger, turf/target)
	var/turf/start_charge_here = get_turf(charger)
	var/charge_range = min(get_dist_euclidian(start_charge_here, target), max_charge_range)
	var/turf/but_we_gonna_here = get_ranged_target_turf(start_charge_here, get_dir(start_charge_here, target), floor(charge_range))
	var/turf/here_we_go = start_charge_here
	for(var/turf/line_turf in get_line(get_step(start_charge_here, get_dir(start_charge_here, target)), but_we_gonna_here))
		if(get_turf(charger) == get_turf(line_turf))
			continue
		if(isclosedturf(line_turf))
			if(isindestructiblewall(line_turf))
				break
			if(istype(line_turf, /turf/closed/wall))
				line_turf.atom_destruction(MELEE)
		for(var/obj/break_in as anything in line_turf.contents)
			if(istype(break_in, /obj/machinery/power/supermatter_crystal))
				var/obj/machinery/power/supermatter_crystal/funny_crystal = break_in
				funny_crystal.Bumped(chassis)
				break
			if(istype(break_in, /obj/machinery/gravity_generator))
				continue
			if(istype(break_in, /obj/machinery/atmospherics/pipe))
				continue
			if(istype(break_in, /obj/structure/disposalpipe))
				continue
			if(istype(break_in, /obj/structure/cable))
				continue
			if(istype(break_in, /obj/machinery) || istype(break_in, /obj/structure))
				break_in.atom_destruction(MELEE)
				continue
		for(var/mob/living/somthing_living as anything in line_turf.contents)
			if(!isliving(somthing_living))
				continue
			if(somthing_living.stat >= UNCONSCIOUS)
				continue
			if(somthing_living.getStaminaLoss() >= 100)
				continue
			if(somthing_living == charger)
				continue
			if(prob(DISMEMBER_CUALITY_LOW))
				var/obj/item/bodypart/cut_bodypart = somthing_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_HEAD))
				cut_bodypart.dismember(BRUTE)
			somthing_living.apply_damage(35, BRUTE)
		here_we_go = line_turf

	// If the mech didn't move, it didn't charge
	if(here_we_go == start_charge_here)
		charger.balloon_alert(charger, "invalid direction!")
		return FALSE
	chassis.forceMove(here_we_go)
	start_charge_here.Beam(chassis, icon_state = "mech_charge", time = 8)
	playsound(chassis, charge_attack_sound, 75, FALSE)
	on = !on
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
	cell = new /obj/item/stock_parts/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()

#undef DISMEMBER_CUALITY_HIGTH
#undef DISMEMBER_CUALITY_LOW

#undef MOVEDELAY_ANGRY
#undef MOVEDELAY_SAFTY
