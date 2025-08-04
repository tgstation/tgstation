#define MOVEDELAY_IDLE 3
#define MOVEDELAY_PRE_CHARGE 4

/obj/vehicle/sealed/mecha/justice
	name = "\improper Justice"
	desc = "Black and red syndicate mech designed for execution orders. \
		For safety reasons, the syndicate advises against standing too close."
	icon_state = "justice"
	base_icon_state = "justice"
	movedelay = MOVEDELAY_IDLE
	max_integrity = 300
	accesses = list(ACCESS_SYNDICATE)
	armor_type = /datum/armor/mecha_justice
	max_temperature = 40000
	force = 40 // dangerous in melee
	melee_lower_damage_range = 0.8
	melee_armor_penetration = 50
	melee_sharpness = SHARP_EDGED
	damtype = BRUTE
	destruction_sleep_duration = 10
	exit_delay = 10
	wreckage = /obj/structure/mecha_wreckage/justice
	mech_type = EXOSUIT_MODULE_JUSTICE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	mecha_flags = ID_LOCK_ON | QUIET_TURNS | CAN_STRAFE | HAS_LIGHTS | MMI_COMPATIBLE | IS_ENCLOSED | AI_COMPATIBLE
	destroy_wall_sound = 'sound/vehicles/mecha/mech_blade_break_wall.ogg'
	brute_attack_sound = 'sound/vehicles/mecha/mech_blade_attack.ogg'
	attack_verbs = list("cut", "cuts", "cutting")
	weapons_safety = TRUE
	safety_sound_custom = TRUE
	max_equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/bola/justice,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	step_energy_drain = 2
	allow_diagonal_movement = TRUE
	movedelay = 2.5
	/// What actions does justice execute?
	var/justice_state = JUSTICE_IDLE
	/// Refs to our engines
	var/list/obj/justice_engines = list()
	/// UI arrow which directs justice mech during charge
	var/atom/movable/screen/justice_charge_arrow/charge_arrow
	/// Track turf to where justice wanna charge while drag right mouse button
	var/turf/turf_to_charge
	/// Maximum range of charge attack.
	var/max_charge_range = 7
	/// Is charge used or can be used.
	var/charge_on_cooldown = FALSE
	/// Remember strafe mode when we press right click to make charge attack. We need it to return strafe mode that was before we pressed right click button.
	var/remember_strafe = FALSE
	/// Sound when mech do charge attack.
	var/charge_attack_sound = 'sound/vehicles/mecha/mech_charge_attack.ogg'
	/// Aoe pre attack sound.
	var/stealth_pre_attack_sound = 'sound/vehicles/mecha/mech_stealth_pre_attack.ogg'
	/// Aoe attack sound.
	var/stealth_attack_sound = 'sound/vehicles/mecha/mech_stealth_attack.ogg'
	/// Sound plays when one of justice engine being succesful attacked.
	var/engine_attacked_sound = 'sound/vehicles/mecha/justice_shield_broken.ogg'
	/// Sound plays when justice lose all engines.
	var/shields_disabled_sound = 'sound/vehicles/mecha/justice_warning.ogg'
	/// Sound plays when justice pilot press right mouse button to prepare charge attack.
	var/pre_charge_sound = 'sound/vehicles/mecha/justice_pre_charge.ogg'
	/// Last mob we slashed
	var/last_hit = null
	/// Alternates between true and false to play footsteps
	VAR_PRIVATE/footstep_step = TRUE

/datum/armor/mecha_justice
	melee = 50
	bullet = 50
	laser = 50
	energy = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/justice/Initialize(mapload, built_manually)
	. = ..()
	RegisterSignal(src, COMSIG_MECHA_MELEE_CLICK, PROC_REF(justice_attack)) //We do not hit those who are in crit or stun. We are finishing them.
	transform = transform.Scale(1.04, 1.04)
	for(var/i in 1 to 3)
		addtimer(CALLBACK(src, PROC_REF(create_engine)), i * 1 SECONDS)
	ADD_TRAIT(src, TRAIT_PERFECT_ATTACKER, INNATE_TRAIT)

/obj/vehicle/sealed/mecha/justice/update_icon_state()
	. = ..()
	if(!LAZYLEN(occupants))
		return
	icon_state = weapons_safety ? "[base_icon_state]" : "[base_icon_state]-angry"
	if(!has_gravity())
		icon_state = "[icon_state]-fly"

/obj/vehicle/sealed/mecha/justice/set_safety(mob/user)
	. = ..()

	playsound(src, 'sound/vehicles/mecha/mech_blade_safty.ogg', 75, FALSE) //everyone need to hear this sound

	update_appearance(UPDATE_ICON_STATE)

/obj/vehicle/sealed/mecha/justice/Move(newloc, dir)
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/vehicle/sealed/mecha/justice/mob_enter(mob/he_drive, silent)
	. = ..()
	if(!.)
		return
	if(!isliving(he_drive))
		return
	if(!is_driver(he_drive))
		return
	RegisterSignal(he_drive.canon_client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(driver_mousedown))
	activate_engines()
	var/datum/hud/user_hud = he_drive.hud_used
	if(!user_hud)
		return
	charge_arrow = new /atom/movable/screen/justice_charge_arrow(null, user_hud)
	charge_arrow.screen_loc = around_player
	charge_arrow.icon_state = charge_arrow.inactive_icon
	user_hud.infodisplay += charge_arrow
	user_hud.show_hud(user_hud.hud_version)

/obj/vehicle/sealed/mecha/justice/mob_exit(mob/exiter, silent, randomstep, forced)
	. = ..()
	null_arrow(exiter.hud_used)
	deactivate_engines()
	UnregisterSignal(exiter.canon_client, COMSIG_CLIENT_MOUSEDOWN)

/obj/vehicle/sealed/mecha/justice/Destroy()
	QDEL_LIST(justice_engines)
	return ..()

/obj/vehicle/sealed/mecha/justice/play_stepsound()
	if(footstep_step)
		playsound(src, pick(
			'sound/effects/footstep/stomp1.ogg',
			'sound/effects/footstep/stomp2.ogg',
			'sound/effects/footstep/stomp3.ogg',
			'sound/effects/footstep/stomp4.ogg',
			'sound/effects/footstep/stomp5.ogg',
		), 20, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = 0.75)
	footstep_step = !footstep_step

/obj/vehicle/sealed/mecha/justice/proc/null_arrow(datum/hud/user_hud)
	if(isnull(user_hud))
		return
	user_hud.infodisplay -= charge_arrow
	user_hud.show_hud(user_hud.hud_version)

/obj/vehicle/sealed/mecha/justice/proc/driver_mousedown(client/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(!weapons_safety)
		return
	if(charge_on_cooldown)
		for(var/mob/mob_occupant as anything in occupants)
			balloon_alert(mob_occupant, "on cooldown!")
		return

	turf_to_charge = get_turf(target)
	if(!isnull(turf_to_charge))
		var/rotate_dir = get_dir(src, turf_to_charge)
		animate(charge_arrow, transform = matrix(dir2angle(rotate_dir), MATRIX_ROTATE), 0.2 SECONDS)
		dir = rotate_dir
	else
		set_charge_mouse_pointer(TRUE)
	charge_arrow.icon_state = charge_arrow.active_icon
	justice_state = JUSTICE_CHARGE
	movedelay = MOVEDELAY_PRE_CHARGE
	remember_strafe = strafe
	strafe = TRUE
	set_charge_mouse_pointer()
	playsound(src, pre_charge_sound, 75, FALSE)
	SEND_SIGNAL(src, COMSIG_JUSTICE_CHARGE_BUTTON_DOWN)
	RegisterSignal(source, COMSIG_CLIENT_MOUSEUP, PROC_REF(driver_mouseup))
	RegisterSignal(source, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(driver_mousedrag))

/obj/vehicle/sealed/mecha/justice/proc/driver_mousedrag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	if(justice_state != JUSTICE_CHARGE)
		return

	turf_to_charge = get_turf(over_object)
	if(isnull(turf_to_charge))
		set_charge_mouse_pointer(TRUE)
		return
	set_charge_mouse_pointer()
	var/rotate_dir = get_dir(src, turf_to_charge)
	animate(charge_arrow, transform = matrix(dir2angle(rotate_dir), MATRIX_ROTATE), 0.2 SECONDS)
	dir = rotate_dir

/obj/vehicle/sealed/mecha/justice/proc/driver_mouseup(client/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)

	if(!LAZYACCESS(modifiers, RIGHT_CLICK))
		return

	charge_attack(turf_to_charge)

	UnregisterSignal(source, COMSIG_CLIENT_MOUSEUP)
	UnregisterSignal(source, COMSIG_CLIENT_MOUSEDRAG)
	charge_arrow.icon_state = charge_arrow.inactive_icon
	strafe = remember_strafe
	justice_state = JUSTICE_IDLE
	movedelay = MOVEDELAY_IDLE
	charge_on_cooldown = TRUE
	for(var/mob/mob_occupant as anything in occupants)
		set_safety(mob_occupant)
		break
	addtimer(CALLBACK(src, PROC_REF(charge_recharge)), 5 SECONDS)
	set_charge_mouse_pointer()

/obj/vehicle/sealed/mecha/justice/proc/charge_recharge()
	charge_on_cooldown = FALSE
	set_charge_mouse_pointer()

/obj/vehicle/sealed/mecha/justice/proc/create_engine()
	var/obj/effect/justice_engine/justice_engine = new /obj/effect/justice_engine(get_turf(src))
	justice_engine.transform *= 0.6
	justice_engine.orbit(src, 25, FALSE, 30)
	justice_engine.change_engine_state(JUSTICE_ENGINE_DEACTIVE)
	justice_engines += justice_engine

/obj/vehicle/sealed/mecha/justice/proc/activate_engines()
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		if(justice_engine.engine_state != JUSTICE_ENGINE_DEACTIVE)
			continue
		justice_engine.change_engine_state(JUSTICE_ENGINE_ACTIVATING)
		addtimer(CALLBACK(src, PROC_REF(after_engine_activated), justice_engine), 0.4 SECONDS)
	return null

/obj/vehicle/sealed/mecha/justice/proc/after_engine_activated(obj/effect/justice_engine/justice_engine)
	justice_engine.change_engine_state(justice_engine.remember_engine_state_on_deactivate)

/obj/vehicle/sealed/mecha/justice/proc/deactivate_engines()
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		justice_engine.remember_engine_state_on_deactivate = justice_engine.engine_state
		if(justice_engine.engine_state == JUSTICE_ENGINE_DEACTIVE)
			continue
		justice_engine.change_engine_state(JUSTICE_ENGINE_DEACTIVATING)
		addtimer(CALLBACK(src, PROC_REF(after_engine_deactivated), justice_engine), 0.4 SECONDS)
	return null

/obj/vehicle/sealed/mecha/justice/proc/after_engine_deactivated(obj/effect/justice_engine/justice_engine)
	justice_engine.change_engine_state(JUSTICE_ENGINE_DEACTIVE)

/obj/vehicle/sealed/mecha/justice/proc/get_engine_by_state(state)
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		if(justice_engine.engine_state != state)
			continue
		return justice_engine
	return null

/obj/vehicle/sealed/mecha/justice/proc/justice_attack(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_MECHA_MELEE_ATTACK))
		return COMPONENT_CANCEL_MELEE_CLICK

	if(justice_state == JUSTICE_CHARGE)
		return COMPONENT_CANCEL_MELEE_CLICK

	if(fatality_attack(source, pilot, target, on_cooldown, is_adjacent))
		return COMPONENT_CANCEL_MELEE_CLICK

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.stat >= UNCONSCIOUS)
		return
	var/obj/effect/justice_engine/cooldown_engine = get_engine_by_state(JUSTICE_ENGINE_ONCOOLDOWN)
	if(isnull(cooldown_engine))
		return
	cooldown_engine.change_engine_state(JUSTICE_ENGINE_ACTIVE)
	return

/obj/vehicle/sealed/mecha/justice/proc/set_charge_mouse_pointer(disabled = FALSE)
	if(justice_state != JUSTICE_CHARGE)
		return set_mouse_pointer()
	if(disabled)
		mouse_pointer = 'icons/effects/mouse_pointers/justice_mouse_charge-disabled.dmi'
	else
		mouse_pointer = 'icons/effects/mouse_pointers/justice_mouse_charge.dmi'

	for(var/mob/mob_occupant as anything in occupants)
		mob_occupant.update_mouse_pointer()

/obj/vehicle/sealed/mecha/justice/set_mouse_pointer()
	if(weapons_safety)
		mouse_pointer = ""
	else if(charge_on_cooldown)
		mouse_pointer = 'icons/effects/mouse_pointers/justice_mouse_charge-cooldown.dmi'
	else
		if(equipment_disabled)
			mouse_pointer = 'icons/effects/mouse_pointers/justice_mouse_charge-disabled.dmi'
		else
			mouse_pointer = 'icons/effects/mouse_pointers/justice_mouse.dmi'

	for(var/mob/mob_occupant as anything in occupants)
		mob_occupant.update_mouse_pointer()

/obj/vehicle/sealed/mecha/justice/hitby(atom/movable/throwed_by, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(throwed_by))
		var/obj/item/throwed_by_item = throwed_by
		if(throwed_by_item.throwforce < 10) /// don't counts 0-9 damage for such moments like throwforce from severed limbs and other unpleasant little things for which you would not want to lose a charge.
			block_effect()
			return

	var/obj/effect/justice_engine/active_engine = get_engine_by_state(JUSTICE_ENGINE_ACTIVE)
	if(isnull(active_engine))
		return ..()

	active_engine.change_engine_state(JUSTICE_ENGINE_ONCOOLDOWN)
	playsound(src, engine_attacked_sound , 75, FALSE)
	after_engine_attacked()

/obj/vehicle/sealed/mecha/justice/attacked_by(obj/item/attacking_item, mob/living/user)
	if(attacking_item.force < 10) /// don't counts 0-9 damage for such moments like throwforce from severed limbs and other unpleasant little things for which you would not want to lose a charge.
		block_effect()
		return

	var/obj/effect/justice_engine/active_engine = get_engine_by_state(JUSTICE_ENGINE_ACTIVE)
	if(isnull(active_engine))
		return ..()

	active_engine.change_engine_state(JUSTICE_ENGINE_ONCOOLDOWN)
	playsound(src, engine_attacked_sound , 75, FALSE)
	after_engine_attacked()

/obj/vehicle/sealed/mecha/justice/emp_act(severity)
	var/obj/effect/justice_engine/active_engine = get_engine_by_state(JUSTICE_ENGINE_ACTIVE)
	if(isnull(active_engine))
		return ..()

	active_engine.change_engine_state(JUSTICE_ENGINE_ONCOOLDOWN)
	playsound(src, engine_attacked_sound , 75, FALSE)
	after_engine_attacked()

	return EMP_PROTECT_SELF

/obj/vehicle/sealed/mecha/justice/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE, blocked = 0)
	if(istype(hitting_projectile, /obj/projectile/ion))
		return ..()

	var/reflect_change = 0
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		if(justice_engine.engine_state != JUSTICE_ENGINE_ACTIVE)
			continue
		reflect_change += 25
	if(!prob(reflect_change))
		var/obj/effect/justice_engine/active_engine = get_engine_by_state(JUSTICE_ENGINE_ACTIVE)
		if(isnull(active_engine))
			return ..()

		active_engine.change_engine_state(JUSTICE_ENGINE_ONCOOLDOWN)
		playsound(src, engine_attacked_sound , 75, FALSE)
		after_engine_attacked()
		return BULLET_ACT_BLOCK

	var/deflect_angel = dir2angle(get_dir(src, hitting_projectile.firer))
	hitting_projectile.firer = src
	hitting_projectile.set_angle(deflect_angel)
	playsound(src, 'sound/vehicles/mecha/mech_blade_break_wall.ogg' , 75, FALSE)
	return BULLET_ACT_FORCE_PIERCE

/obj/vehicle/sealed/mecha/justice/proc/block_effect()
	new /obj/effect/temp_visual/mech_sparks(get_turf(src))
	playsound(src, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/proc/after_engine_attacked()
	if(!isnull(get_engine_by_state(JUSTICE_ENGINE_ACTIVE)))
		return
	deactivate_engines()
	for(var/mob/mob_occupant as anything in occupants)
		balloon_alert(mob_occupant, "shields disabled! recharge after 20 seconds!")
	addtimer(CALLBACK(src, PROC_REF(reactivate_engines)), 20 SECONDS)
	playsound(src, shields_disabled_sound , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/proc/reactivate_engines()
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		justice_engine.remember_engine_state_on_deactivate = JUSTICE_ENGINE_ACTIVE
	if(isnull(occupants))
		return
	activate_engines()

/**
 * Attempts to dismember passed bodypart if it damage hits its damage cap.
 *
 * * dismembering: Bodypart to dismember
 * * effective_damage_modifier: Additional number to put on top of the bodypart's damage, to treat it as if it were more damaged than it is.
 * * chance: Chance to dismember the bodypart, 100 by default.
 * * blacklist: List of body zones that should not be dismembered, defaults to head and chest.
 */
/obj/vehicle/sealed/mecha/justice/proc/try_attack_dismember(obj/item/bodypart/dismembering, effective_damage_modifier = 0, chance = 100, list/blacklist = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD))
	if(!prob(chance))
		return FALSE
	if(isnull(dismembering))
		return FALSE
	if(dismembering.body_zone in blacklist)
		return FALSE
	if(dismembering.get_damage() + effective_damage_modifier > dismembering.max_damage)
		return dismembering.dismember(BRUTE)
	return FALSE

/obj/vehicle/sealed/mecha/justice/melee_attack_effect(mob/living/victim, damage, def_zone)
	// Damage hasn't been applied yet but if it ends up capping out the limb's damage, we will dismember or disembowel
	try_attack_dismember(victim.get_bodypart(def_zone), damage, 100, list(BODY_ZONE_HEAD))

	if(last_hit != REF(victim))
		last_hit = REF(victim)
		new /obj/effect/temp_visual/mech_attack_aoe_charge(get_turf(src))
		playsound(src, stealth_pre_attack_sound, 75, FALSE)
		addtimer(VARSET_CALLBACK(src, last_hit, null), 10 SECONDS)
		return

	new /obj/effect/temp_visual/mech_attack_aoe_attack(get_turf(src))
	for(var/mob/living/something_living in range(1, get_turf(src)))
		if(something_living.stat >= UNCONSCIOUS || something_living.getStaminaLoss() >= 100 || is_driver(something_living) || is_occupant(something_living))
			continue
		// pick another random limb, avoiding head or chest unless the target has no other limbs
		var/hit_zone = something_living.get_random_valid_zone(
			base_zone = def_zone,
			blacklisted_parts = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD),
			even_weights = TRUE,
			bypass_warning = TRUE,
		) || BODY_ZONE_CHEST
		// perform an "attack"
		var/armor = something_living.run_armor_check(def_zone = hit_zone, attack_flag = MELEE, armour_penetration = melee_armor_penetration)
		something_living.apply_damage(force * melee_lower_damage_range, damtype, hit_zone, armor, sharpness = melee_sharpness, attacking_item = src, wound_bonus = (victim == something_living ? CANT_WOUND : -10))
		// if the attack capped out the limb's damage, force dismember (or disembowel if chest)
		try_attack_dismember(something_living.get_bodypart(hit_zone), 0, 100, list(BODY_ZONE_HEAD))

	playsound(src, stealth_attack_sound, 75, FALSE)
	last_hit = null

/// Says 1 of 3 epic phrases before attacking and make a finishing blow to targets in stun or crit after 1 SECOND.
/obj/vehicle/sealed/mecha/justice/proc/fatality_attack(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/live_or_dead = target
	if(live_or_dead.stat < UNCONSCIOUS && live_or_dead.getStaminaLoss() < 100)
		return FALSE
	var/obj/item/bodypart/check_head = live_or_dead.get_bodypart(BODY_ZONE_HEAD)
	if(!check_head)
		return FALSE
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)
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
	if(justice_state == JUSTICE_FATALITY)
		return
	justice_state = JUSTICE_FATALITY
	say(pick("Take my Justice-Slash!", "A falling leaf...", "Justice is quite a lonely path."), forced = "Justice Mech")
	playsound(src, 'sound/vehicles/mecha/mech_stealth_pre_attack.ogg', 75, FALSE)
	if(!do_after(finisher, 1 SECONDS, him))
		justice_state = JUSTICE_IDLE
		return
	if(QDELETED(finisher) || QDELETED(him) || !LAZYLEN(my_mech?.occupants))
		justice_state = JUSTICE_IDLE
		return
	var/turf/finish_turf = get_step(him, get_dir(my_mech, him))
	var/turf/for_line_turf = get_turf(my_mech)
	var/obj/item/bodypart/in_your_head = him.get_bodypart(BODY_ZONE_HEAD)
	in_your_head?.dismember(BRUTE)
	playsound(src, brute_attack_sound, 75, FALSE)
	for_line_turf.Beam(src, icon_state = "mech_charge", time = 4)
	forceMove(finish_turf.density ? get_turf(him) : finish_turf)
	justice_state = JUSTICE_IDLE

/**
 * ## charge_attack
 *
 * Deal everyone in line for mech location to mouse location 35 damage and 25 chanse to cut off limb.
 * Teleport mech to the end of line.
 * Arguments:
 * * target - occupant inside mech.
 */
/obj/vehicle/sealed/mecha/justice/proc/charge_attack(atom/target)
	var/turf/start_charge_here = get_turf(src)
	var/turf/target_pos = get_turf(target)
	var/turf/here_we_go = start_charge_here
	for(var/turf/line_turf in get_line(start_charge_here, target_pos))
		if(floor(get_dist_euclidean(start_charge_here, line_turf)) > max_charge_range)
			break
		if(get_turf(src) == get_turf(line_turf))
			continue
		if(isclosedturf(line_turf))
			break
		var/obj/machinery/power/supermatter_crystal/funny_crystal = locate() in line_turf
		if(funny_crystal)
			funny_crystal.Bumped(src)
			break
		if(line_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
			break
		for(var/mob/living/something_living in line_turf)
			if(something_living.stat >= UNCONSCIOUS || something_living.getStaminaLoss() >= 100 || is_driver(something_living) || is_occupant(something_living))
				continue
			// hit a random limb, avoiding head or chest unless the target has no other limbs
			var/hit_zone = something_living.get_random_valid_zone(
				base_zone = BODY_ZONE_CHEST,
				blacklisted_parts = list(BODY_ZONE_CHEST), // no head blacklist for this one
				bypass_warning = TRUE,
			) || BODY_ZONE_CHEST
			// perform an "attack"
			var/armor = something_living.run_armor_check(def_zone = hit_zone, attack_flag = MELEE, armour_penetration = melee_armor_penetration)
			something_living.apply_damage(force, damtype, hit_zone, armor, sharpness = melee_sharpness, attacking_item = src, wound_bonus = 10, exposed_wound_bonus = 25)
			// if the attack capped out the limb's damage - or a small random chance -, force dismember (or disembowel if chest)
			try_attack_dismember(something_living.get_bodypart(hit_zone), 0, 25, list())

		here_we_go = line_turf

	// If the mech didn't move, it didn't charge
	if(here_we_go == start_charge_here)
		for(var/mob/occupant in occupants)
			if(is_driver(occupant))
				balloon_alert(occupant, "invalid direction!")
		return FALSE

	forceMove(here_we_go)
	start_charge_here.Beam(src, icon_state = "mech_charge", time = 8)
	playsound(src, charge_attack_sound, 75, FALSE)
	TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MELEE_ATTACK, melee_cooldown)
	use_energy(200)
	return TRUE

/obj/vehicle/sealed/mecha/justice/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	visual_effect_icon = ATTACK_EFFECT_SLASH
	return ..()

/obj/vehicle/sealed/mecha/justice/loaded
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/bola/justice,
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

/obj/effect/justice_engine
	name = "engine core"
	icon = 'icons/effects/effects.dmi'
	icon_state = "justice_engine_deactive"
	base_icon_state = "justice_engine"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	/// We need to orbit around someone.
	var/datum/weakref/owner
	/// Switch engine state for future justice checks.
	var/engine_state = JUSTICE_ENGINE_DEACTIVE
	/// Remember if engine is on cooldown when we exit justice mech
	var/remember_engine_state_on_deactivate = JUSTICE_ENGINE_ACTIVE

/obj/effect/justice_engine/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[engine_state]"

/obj/effect/justice_engine/proc/change_engine_state(new_state)
	engine_state = new_state
	update_appearance(UPDATE_ICON_STATE)

/atom/movable/screen/justice_charge_arrow
	icon = 'icons/effects/96x96.dmi'
	name = "justice charge arrow"
	icon_state = "justice_charge_arrow"
	pixel_x = -32
	pixel_y = -32
	/// Icon when we drag right mouse button to choice turf to charge
	var/active_icon = "justice_charge_arrow"
	/// Idle charge arrow icon
	var/inactive_icon = ""

#undef MOVEDELAY_IDLE
#undef MOVEDELAY_PRE_CHARGE
