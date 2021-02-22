/// How many tiles around the target the shooter can roam without losing their shot
#define GUNPOINT_SHOOTER_STRAY_RANGE 2
/// How long it takes from the gunpoint is initiated to reach stage 2
#define GUNPOINT_DELAY_STAGE_2 2.5 SECONDS
/// How long it takes from stage 2 starting to move up to stage 3
#define GUNPOINT_DELAY_STAGE_3 7.5 SECONDS
/// If the projectile doesn't have a wound_bonus of CANT_WOUND, we add (this * the stage mult) to their wound_bonus and bare_wound_bonus upon triggering
#define GUNPOINT_BASE_WOUND_BONUS 5
/// How much the damage and wound bonus mod is multiplied when you're on stage 1
#define GUNPOINT_MULT_STAGE_1 1
/// As above, for stage 2
#define GUNPOINT_MULT_STAGE_2 2
/// As above, for stage 3
#define GUNPOINT_MULT_STAGE_3 2.5


/datum/component/gunpoint
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/living/target
	var/obj/item/gun/weapon

	var/stage = 1
	var/damage_mult = GUNPOINT_MULT_STAGE_1

	var/point_of_no_return = FALSE

// *extremely bad russian accent* no!
/datum/component/gunpoint/Initialize(mob/living/targ, obj/item/gun/wep)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/shooter = parent
	target = targ
	weapon = wep
	RegisterSignal(targ, list(COMSIG_MOB_ATTACK_HAND, COMSIG_MOB_ITEM_ATTACK, COMSIG_MOVABLE_MOVED, COMSIG_MOB_FIRED_GUN), .proc/trigger_reaction)

	RegisterSignal(weapon, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/cancel)

	shooter.visible_message("<span class='danger'>[shooter] aims [weapon] point blank at [target]!</span>", \
		"<span class='danger'>You aim [weapon] point blank at [target]!</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[shooter] aims [weapon] point blank at you!</span>")

	shooter.apply_status_effect(STATUS_EFFECT_HOLDUP, shooter)
	target.apply_status_effect(STATUS_EFFECT_HELDUP, shooter)

	if(istype(weapon, /obj/item/gun/ballistic/rocketlauncher) && weapon.chambered)
		if(target.stat == CONSCIOUS && is_nuclear_operative(shooter) && !is_nuclear_operative(target) && (locate(/obj/item/disk/nuclear) in target.get_contents()) && shooter.client)
			shooter.client.give_award(/datum/award/achievement/misc/rocket_holdup, shooter)

	target.do_alert_animation()
	target.playsound_local(target.loc, 'sound/machines/chime.ogg', 50, TRUE)
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gunpoint", /datum/mood_event/gunpoint)

	addtimer(CALLBACK(src, .proc/update_stage, 2), GUNPOINT_DELAY_STAGE_2)

/datum/component/gunpoint/Destroy(force, silent)
	var/mob/living/shooter = parent
	shooter.remove_status_effect(STATUS_EFFECT_HOLDUP)
	target.remove_status_effect(STATUS_EFFECT_HELDUP, shooter)
	return ..()

/datum/component/gunpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_deescalate)
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, .proc/flinch)
	RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, .proc/check_shove)
	RegisterSignal(parent, list(COMSIG_LIVING_START_PULL, COMSIG_MOVABLE_BUMP), .proc/check_bump)

/datum/component/gunpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMGE)
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_HAND)
	UnregisterSignal(parent, list(COMSIG_LIVING_START_PULL, COMSIG_MOVABLE_BUMP))

///If the shooter bumps the target, cancel the holdup to avoid cheesing and forcing the charged shot
/datum/component/gunpoint/proc/check_bump(atom/B, atom/A)
	SIGNAL_HANDLER

	if(A != target)
		return
	var/mob/living/shooter = parent
	shooter.visible_message("<span class='danger'>[shooter] bumps into [target] and fumbles [shooter.p_their()] aim!</span>", \
		"<span class='danger'>You bump into [target] and fumble your aim!</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[shooter] bumps into you and fumbles [shooter.p_their()] aim!</span>")
	qdel(src)

///If the shooter shoves or grabs the target, cancel the holdup to avoid cheesing and forcing the charged shot
/datum/component/gunpoint/proc/check_shove(mob/living/carbon/shooter, mob/shooter_again, mob/living/T, datum/martial_art/attacker_style, modifiers)
	SIGNAL_HANDLER

	if(T != target || LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	shooter.visible_message("<span class='danger'>[shooter] bumps into [target] and fumbles [shooter.p_their()] aim!</span>", \
		"<span class='danger'>You bump into [target] and fumble your aim!</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[shooter] bumps into you and fumbles [shooter.p_their()] aim!</span>")
	qdel(src)

///Update the damage multiplier for whatever stage we're entering into
/datum/component/gunpoint/proc/update_stage(new_stage)
	stage = new_stage
	if(stage == 2)
		to_chat(parent, "<span class='danger'>You steady [weapon] on [target].</span>")
		to_chat(target, "<span class='userdanger'>[parent] has steadied [weapon] on you!</span>")
		damage_mult = GUNPOINT_MULT_STAGE_2
		addtimer(CALLBACK(src, .proc/update_stage, 3), GUNPOINT_DELAY_STAGE_3)
	else if(stage == 3)
		to_chat(parent, "<span class='danger'>You have fully steadied [weapon] on [target].</span>")
		to_chat(target, "<span class='userdanger'>[parent] has fully steadied [weapon] on you!</span>")
		damage_mult = GUNPOINT_MULT_STAGE_3

///Cancel the holdup if the shooter moves out of sight or out of range of the target
/datum/component/gunpoint/proc/check_deescalate()
	SIGNAL_HANDLER

	if(!can_see(parent, target, GUNPOINT_SHOOTER_STRAY_RANGE - 1))
		cancel()

///Bang bang, we're firing a charged shot off
/datum/component/gunpoint/proc/trigger_reaction()
	SIGNAL_HANDLER_DOES_SLEEP

	var/mob/living/shooter = parent
	shooter.remove_status_effect(STATUS_EFFECT_HOLDUP) // try doing these before the trigger gets pulled since the target (or shooter even) may not exist after pulling the trigger, dig?
	target.remove_status_effect(STATUS_EFFECT_HELDUP, shooter)
	SEND_SIGNAL(target, COMSIG_CLEAR_MOOD_EVENT, "gunpoint")

	if(point_of_no_return)
		return
	point_of_no_return = TRUE

	if(!weapon.can_shoot() || !weapon.can_trigger_gun(shooter) || (weapon.weapon_weight == WEAPON_HEAVY && shooter.get_inactive_held_item()))
		shooter.visible_message("<span class='danger'>[shooter] fumbles [weapon]!</span>", \
			"<span class='danger'>You fumble [weapon] and fail to fire at [target]!</span>", ignored_mobs = target)
		to_chat(target, "<span class='userdanger'>[shooter] fumbles [weapon] and fails to fire at you!</span>")
		qdel(src)
		return

	if(weapon.chambered && weapon.chambered.loaded_projectile)
		weapon.chambered.loaded_projectile.damage *= damage_mult
		if(weapon.chambered.loaded_projectile.wound_bonus != CANT_WOUND)
			weapon.chambered.loaded_projectile.wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.loaded_projectile.bare_wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS

	if(weapon.check_botched(shooter))
		return

	var/fired = weapon.process_fire(target, shooter)
	if(!fired && weapon.chambered?.loaded_projectile)
		weapon.chambered.loaded_projectile.damage /= damage_mult
		if(weapon.chambered.loaded_projectile.wound_bonus != CANT_WOUND)
			weapon.chambered.loaded_projectile.wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.loaded_projectile.bare_wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS

	qdel(src)

///Shooter canceled their shot, either by dropping/equipping their weapon, leaving sight/range, or clicking on the alert
/datum/component/gunpoint/proc/cancel()
	SIGNAL_HANDLER

	var/mob/living/shooter = parent
	shooter.visible_message("<span class='danger'>[shooter] breaks [shooter.p_their()] aim on [target]!</span>", \
		"<span class='danger'>You are no longer aiming [weapon] at [target].</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[shooter] breaks [shooter.p_their()] aim on you!</span>")
	SEND_SIGNAL(target, COMSIG_CLEAR_MOOD_EVENT, "gunpoint")
	qdel(src)

///If the shooter is hit by an attack, they have a 50% chance to flinch and fire. If it hit the arm holding the trigger, it's an 80% chance to fire instead
/datum/component/gunpoint/proc/flinch(attacker, damage, damagetype, def_zone)
	SIGNAL_HANDLER

	var/mob/living/shooter = parent
	if(attacker == shooter)
		return // somehow this wasn't checked for months but no one tried punching themselves to initiate the shot, amazing

	var/flinch_chance = 50
	var/gun_hand = LEFT_HANDS

	if(shooter.held_items[RIGHT_HANDS] == weapon)
		gun_hand = RIGHT_HANDS

	if((def_zone == BODY_ZONE_L_ARM && gun_hand == LEFT_HANDS) || (def_zone == BODY_ZONE_R_ARM && gun_hand == RIGHT_HANDS))
		flinch_chance = 80

	if(prob(flinch_chance))
		shooter.visible_message("<span class='danger'>[shooter] flinches!</span>", \
			"<span class='danger'>You flinch!</span>")
		INVOKE_ASYNC(src, .proc/trigger_reaction)

#undef GUNPOINT_SHOOTER_STRAY_RANGE
#undef GUNPOINT_DELAY_STAGE_2
#undef GUNPOINT_DELAY_STAGE_3
#undef GUNPOINT_BASE_WOUND_BONUS
#undef GUNPOINT_MULT_STAGE_1
#undef GUNPOINT_MULT_STAGE_2
#undef GUNPOINT_MULT_STAGE_3
