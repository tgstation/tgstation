#define DISMEMBER_CHANCE_HIGH 50
#define DISMEMBER_CHANCE_LOW 25

#define MOVEDELAY_IDLE 3
#define MOVEDELAY_INVISIBILITY 2
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
	allow_diagonal_movement = TRUE
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

/datum/armor/mecha_justice
	melee = 50
	bullet = 30
	laser = 30
	energy = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/justice/Initialize(mapload, built_manually)
	. = ..()
	RegisterSignal(src, COMSIG_MECHA_MELEE_CLICK, PROC_REF(justice_attack)) //We do not hit those who are in crit or stun. We are finishing them.
	RegisterSignal(src, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_ranged_hit))
	RegisterSignal(src, COMSIG_JUSTICE_INVISIBILITY_ACTIVATE, PROC_REF(visibility_active))
	RegisterSignal(src, COMSIG_JUSTICE_INVISIBILITY_DEACTIVATE, PROC_REF(visibility_deactive))
	transform = transform.Scale(1.04, 1.04)
	for(var/i in 1 to 3)
		addtimer(CALLBACK(src, PROC_REF(create_engine)), i * 1 SECONDS)

/obj/vehicle/sealed/mecha/justice/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/invisibility)

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
	if(LAZYLEN(justice_engines) < 1)
		return ..()
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		QDEL_NULL(justice_engine)
	return ..()

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
	if(charge_on_cooldown)
		for(var/mob/mob_occupant as anything in occupants)
			balloon_alert(mob_occupant, "on cooldown!")
		return
	if(!weapons_safety)
		for(var/mob/mob_occupant as anything in occupants)
			balloon_alert(mob_occupant, "katana is out of the sheath!")
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
	justice_engines.Add(justice_engine)

/obj/vehicle/sealed/mecha/justice/proc/activate_engines()
	if(LAZYLEN(justice_engines) < 1)
		return
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		if(justice_engine.engine_state != JUSTICE_ENGINE_DEACTIVE)
			continue
		justice_engine.change_engine_state(JUSTICE_ENGINE_ACTIVATING)
		addtimer(CALLBACK(src, PROC_REF(after_engine_activated), justice_engine), 0.4 SECONDS)
	return null

/obj/vehicle/sealed/mecha/justice/proc/after_engine_activated(obj/effect/justice_engine/justice_engine)
	justice_engine.change_engine_state(justice_engine.remember_engine_state_on_deactivate)

/obj/vehicle/sealed/mecha/justice/proc/deactivate_engines()
	if(LAZYLEN(justice_engines) < 1)
		return
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
	if(LAZYLEN(justice_engines) < 1)
		return
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		if(justice_engine.engine_state != state)
			continue
		return justice_engine
	return null

/obj/vehicle/sealed/mecha/justice/proc/justice_attack(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER

	if(justice_state == JUSTICE_INVISIBILITY)
		stealth_attack_aoe(source, pilot, target, on_cooldown, is_adjacent)
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
	. = ..()
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

/obj/vehicle/sealed/mecha/justice/proc/on_ranged_hit(obj/vehicle/sealed/mecha/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	var/obj/effect/justice_engine/active_engine = get_engine_by_state(JUSTICE_ENGINE_ACTIVE)
	if(isnull(active_engine))
		return NONE

	var/deflect_angel = dir2angle(get_dir(src, hitting_projectile.firer))
	hitting_projectile.firer = src
	hitting_projectile.set_angle(deflect_angel)
	playsound(src, 'sound/vehicles/mecha/mech_blade_break_wall.ogg' , 75, FALSE)
	return COMPONENT_BULLET_PIERCED

/obj/vehicle/sealed/mecha/justice/proc/block_effect()
	new /obj/effect/temp_visual/mech_sparks(get_turf(src))
	playsound(src, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/proc/after_engine_attacked()
	if(!isnull(get_engine_by_state(JUSTICE_ENGINE_ACTIVE)))
		return
	deactivate_engines()
	for(var/mob/mob_occupant as anything in occupants)
		balloon_alert(mob_occupant, "shields disabled! recharge after 10 seconds!")
	addtimer(CALLBACK(src, PROC_REF(reactivate_engines)), 10 SECONDS)
	playsound(src, shields_disabled_sound , 75, FALSE)

/obj/vehicle/sealed/mecha/justice/proc/reactivate_engines()
	for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
		justice_engine.remember_engine_state_on_deactivate = JUSTICE_ENGINE_ACTIVE
	if(isnull(occupants))
		return
	activate_engines()

/obj/vehicle/sealed/mecha/justice/melee_attack_effect(mob/living/victim, heavy)
	if(!heavy)
		victim.Knockdown(4 SECONDS)
		return
	if(!prob(DISMEMBER_CHANCE_HIGH))
		return
	var/obj/item/bodypart/cut_bodypart = victim.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
	cut_bodypart?.dismember(BRUTE)

/obj/vehicle/sealed/mecha/justice/proc/state_change(new_state)
	if(new_state == justice_state)
		return
	if(new_state != JUSTICE_INVISIBILITY && LAZYLEN(justice_engines) > 0)
		for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
			if(!justice_engine.is_in_invis)
				continue
			justice_engine.is_in_invis = FALSE
			justice_engine.alpha = 255

	if(new_state == JUSTICE_INVISIBILITY && LAZYLEN(justice_engines) > 0)
		for(var/obj/effect/justice_engine/justice_engine as anything in justice_engines)
			if(justice_engine.is_in_invis)
				continue
			justice_engine.is_in_invis = TRUE
			justice_engine.alpha = 0

	justice_state = new_state

/obj/vehicle/sealed/mecha/justice/proc/visibility_active(obj/vehicle/sealed/mecha/source, datum/action/vehicle/sealed/mecha/invisibility/status_caller)
	SIGNAL_HANDLER

	if(justice_state == JUSTICE_INVISIBILITY)
		return COMPONENT_CANCEL_JUSTICE_INVISIBILITY_ACTIVATE
	state_change(JUSTICE_INVISIBILITY)
	movedelay = MOVEDELAY_INVISIBILITY

/obj/vehicle/sealed/mecha/justice/proc/visibility_deactive(obj/vehicle/sealed/mecha/source, datum/action/vehicle/sealed/mecha/invisibility/status_caller)
	SIGNAL_HANDLER

	if(justice_state == JUSTICE_IDLE)
		return COMPONENT_CANCEL_JUSTICE_INVISIBILITY_DEACTIVATE
	state_change(JUSTICE_IDLE)
	movedelay = MOVEDELAY_IDLE

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
	say(pick("Take my Justice-Slash!", "A falling leaf...", "Justice is quite a lonely path"), forced = "Justice Mech")
	playsound(src, 'sound/vehicles/mecha/mech_stealth_pre_attack.ogg', 75, FALSE)
	if(!do_after(finisher, 1 SECONDS, him))
		justice_state = JUSTICE_IDLE
		return
	if(QDELETED(finisher) \
	|| QDELETED(him) \
	|| !LAZYLEN(my_mech?.occupants))
		justice_state = JUSTICE_IDLE
		return
	var/turf/finish_turf = get_step(him, get_dir(my_mech, him))
	var/turf/for_line_turf = get_turf(my_mech)
	var/obj/item/bodypart/in_your_head = him.get_bodypart(BODY_ZONE_HEAD)
	in_your_head?.dismember(BRUTE)
	playsound(src, brute_attack_sound, 75, FALSE)
	for_line_turf.Beam(src, icon_state = "mech_charge", time = 4)
	forceMove(finish_turf)
	justice_state = JUSTICE_IDLE

/**
 * Proc makes an AOE attack after 0.5 SECOND.
 * Called by the mech pilot when he is in stealth mode and wants to attack.
 * During this, mech cannot move.
*/
/obj/vehicle/sealed/mecha/justice/proc/stealth_attack_aoe(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	if(justice_state == JUSTICE_INVISIBILITY_ATTACK)
		return
	justice_state = JUSTICE_INVISIBILITY_ATTACK
	new /obj/effect/temp_visual/mech_attack_aoe_charge(get_turf(src))
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, REF(src))
	playsound(src, stealth_pre_attack_sound, 75, FALSE)
	addtimer(CALLBACK(src, PROC_REF(attack_in_aoe), pilot), 0.5 SECONDS)
	return TRUE

/**
 * ## attack_in_aoe
 *
 * Brings mech out of invisibility.
 * Deal everyone in range 3x3 35 damage and 25 chanse to cut off limb.
 * Arguments:
 * * pilot - occupant inside mech.
 */
/obj/vehicle/sealed/mecha/justice/proc/attack_in_aoe(mob/living/pilot)
	new /obj/effect/temp_visual/mech_attack_aoe_attack(get_turf(src))
	for(var/mob/living/something_living in range(1, get_turf(src)))
		if(something_living.stat >= UNCONSCIOUS \
		|| something_living.getStaminaLoss() >= 100 \
		|| something_living == pilot)
			continue
		if(prob(DISMEMBER_CHANCE_LOW))
			var/obj/item/bodypart/cut_bodypart = something_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG))
			cut_bodypart?.dismember(BRUTE)
		something_living.apply_damage(35, BRUTE)
	playsound(src, stealth_attack_sound, 75, FALSE)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, REF(src))
	SEND_SIGNAL(src, COMSIG_JUSTICE_ATTACK_AOE)
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
		var/obj/machinery/door/airlock/like_a_wall = locate() in line_turf
		if(like_a_wall?.density)
			break
		if(locate(/obj/structure/window) in line_turf)
			break
		for(var/mob/living/something_living in line_turf.contents)
			if(something_living.stat >= UNCONSCIOUS \
			|| something_living.getStaminaLoss() >= 100 \
			|| is_driver(something_living) \
			|| is_occupant(something_living))
				continue
			if(prob(DISMEMBER_CHANCE_LOW))
				var/obj/item/bodypart/cut_bodypart = something_living.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_HEAD))
				cut_bodypart?.dismember(BRUTE)
			something_living.apply_damage(35, BRUTE)
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
	use_energy(200)
	return TRUE

/datum/action/vehicle/sealed/mecha/invisibility
	name = "Invisibility"
	button_icon_state = "mech_stealth_off"
	/// Is invisibility activated.
	var/on = FALSE
	/// Recharge check.
	var/charge = TRUE
	/// Energy cost to become invisibile
	var/energy_cost = 200


/datum/action/vehicle/sealed/mecha/invisibility/set_chassis(passed_chassis)
	. = ..()
	RegisterSignals(chassis, list(COMSIG_MECH_SAFETIES_TOGGLE, COMSIG_MECHA_MOB_EXIT, COMSIG_JUSTICE_ATTACK_AOE, COMSIG_JUSTICE_CHARGE_BUTTON_DOWN), PROC_REF(diactivate_invisibility_by_signal))

/datum/action/vehicle/sealed/mecha/invisibility/proc/diactivate_invisibility_by_signal()
	SIGNAL_HANDLER

	make_visible()
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
	if(SEND_SIGNAL(chassis, COMSIG_JUSTICE_INVISIBILITY_ACTIVATE, src) & COMPONENT_CANCEL_JUSTICE_INVISIBILITY_ACTIVATE)
		return
	new /obj/effect/temp_visual/mech_sparks(get_turf(chassis))
	playsound(chassis, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	animate(chassis, alpha = 0, time = 0.5 SECONDS)
	button_icon_state = "mech_stealth_on"
	RegisterSignal(chassis, COMSIG_MOVABLE_BUMP, PROC_REF(bumb_on))
	RegisterSignal(chassis, COMSIG_ATOM_BUMPED, PROC_REF(bumbed_on))
	RegisterSignal(chassis, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(take_damage))
	chassis.use_energy(energy_cost)
	build_all_button_icons()

///Called when invisibility deactivated.
/datum/action/vehicle/sealed/mecha/invisibility/proc/invisibility_off()
	if(SEND_SIGNAL(chassis, COMSIG_JUSTICE_INVISIBILITY_DEACTIVATE, src) & COMPONENT_CANCEL_JUSTICE_INVISIBILITY_DEACTIVATE)
		return
	new /obj/effect/temp_visual/mech_sparks(get_turf(chassis))
	playsound(chassis, 'sound/vehicles/mecha/mech_stealth_effect.ogg' , 75, FALSE)
	charge = FALSE
	addtimer(CALLBACK(src, PROC_REF(charge)), 5 SECONDS)
	button_icon_state = "mech_stealth_cooldown"
	animate(chassis, alpha = 255, time = 0.5 SECONDS)
	UnregisterSignal(chassis, list(
		COMSIG_MOVABLE_BUMP,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_TAKE_DAMAGE
		))
	build_all_button_icons()

/**
 * ## bumb_on
 *
 * Called when mech bumb on somthing. If is living somthing shutdown mech invisibility.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/bumb_on(obj/vehicle/sealed/mecha/our_mech, atom/obstacle)
	SIGNAL_HANDLER

	if(!iscarbon(obstacle))
		return
	make_visible()

/**
 * ## bumbed_on
 *
 * Called when somthing bumbed on mech. If is living somthing shutdown mech invisibility.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/bumbed_on(obj/vehicle/sealed/mecha/our_mech, atom/movable/bumped_atom)
	SIGNAL_HANDLER

	if(!iscarbon(bumped_atom))
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
 * ## charge
 *
 * Recharge invisibility action after 5 SECONDS.
 */
/datum/action/vehicle/sealed/mecha/invisibility/proc/charge()
	button_icon_state = "mech_stealth_off"
	charge = TRUE
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
	/// Check if engine in invis
	var/is_in_invis = FALSE;

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

#undef DISMEMBER_CHANCE_HIGH
#undef DISMEMBER_CHANCE_LOW

#undef MOVEDELAY_IDLE
#undef MOVEDELAY_INVISIBILITY
#undef MOVEDELAY_PRE_CHARGE
