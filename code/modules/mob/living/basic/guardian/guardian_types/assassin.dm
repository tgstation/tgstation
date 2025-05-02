#define CAN_STEALTH_ALERT "can_stealth"

/**
 * Can enter stealth mode to become invisible and deal bonus damage on their next attack, an ambush predator.
 */
/mob/living/basic/guardian/assassin
	guardian_type = GUARDIAN_ASSASSIN
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	sharpness = SHARP_POINTY
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	playstyle_string = span_holoparasite("As an <b>assassin</b> type you do medium damage and have no damage resistance, but can enter stealth, massively increasing the damage of your next attack and causing it to ignore armor. Stealth is broken when you attack or take damage.")
	creator_name = "Assassin"
	creator_desc = "Does medium damage and takes full damage, but can enter stealth, causing its next attack to do massive damage and ignore armor. However, it becomes briefly unable to recall after attacking from stealth."
	creator_icon = "assassin"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode/assassin
	/// How long to put stealth on cooldown if we are forced out?
	var/stealth_cooldown_time = 16 SECONDS
	/// Cooldown for the stealth toggle.
	COOLDOWN_DECLARE(stealth_cooldown)

/mob/living/basic/guardian/assassin/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	show_can_stealth()
	RegisterSignal(src, COMSIG_GUARDIAN_ASSASSIN_REVEALED, PROC_REF(on_forced_unstealth))

// Toggle stealth
/mob/living/basic/guardian/assassin/toggle_modes()
	var/stealthed = has_status_effect(/datum/status_effect/guardian_stealth)
	if (stealthed)
		to_chat(src, span_bolddanger("You exit stealth."))
		remove_status_effect(/datum/status_effect/guardian_stealth)
		show_can_stealth()
		return
	if (COOLDOWN_FINISHED(src, stealth_cooldown))
		if (!is_deployed())
			to_chat(src, span_bolddanger("You have to be manifested to enter stealth!"))
			return
		apply_status_effect(/datum/status_effect/guardian_stealth)
		clear_alert(CAN_STEALTH_ALERT)
		return
	to_chat(src, span_bolddanger("You cannot yet enter stealth, wait another [DisplayTimeText(COOLDOWN_TIMELEFT(src, stealth_cooldown))]!"))

/mob/living/basic/guardian/assassin/get_status_tab_items()
	. = ..()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		. += "Stealth Cooldown Remaining: [DisplayTimeText(COOLDOWN_TIMELEFT(src, stealth_cooldown))]"

/// Called when we are removed from stealth involuntarily
/mob/living/basic/guardian/assassin/proc/on_forced_unstealth(mob/living/source)
	SIGNAL_HANDLER
	visible_message(span_danger("\The [src] suddenly appears!"))
	COOLDOWN_START(src, manifest_cooldown, 4 SECONDS)
	COOLDOWN_START(src, stealth_cooldown, stealth_cooldown_time)
	addtimer(CALLBACK(src, PROC_REF(show_can_stealth)), stealth_cooldown_time)

/// Displays an alert letting us know that we can enter stealth
/mob/living/basic/guardian/assassin/proc/show_can_stealth()
	if(!COOLDOWN_FINISHED(src, stealth_cooldown))
		return
	throw_alert(CAN_STEALTH_ALERT, /atom/movable/screen/alert/canstealth)

/// Status effect which makes us sneakier and do bonus damage
/datum/status_effect/guardian_stealth
	id = "guardian_stealth"
	alert_type = /atom/movable/screen/alert/status_effect/instealth
	/// Damage added in stealth mode.
	var/damage_bonus = 35
	/// Our wound bonus when in stealth mode. Allows you to actually cause wounds, unlike normal.
	var/stealth_wound_bonus = -20

/datum/status_effect/guardian_stealth/on_apply()
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(owner))
	owner.melee_damage_lower += damage_bonus
	owner.melee_damage_upper += damage_bonus
	if (isbasicmob(owner))
		var/mob/living/basic/basic_owner = owner
		basic_owner.armour_penetration = 100
		basic_owner.wound_bonus = stealth_wound_bonus
		basic_owner.obj_damage = 0
	to_chat(owner, span_bolddanger("You enter stealth, empowering your next attack."))
	animate(owner, alpha = 15, time = 0.5 SECONDS)

	RegisterSignals(owner, list(COMSIG_GUARDIAN_RECALLED, COMSIG_HOSTILE_POST_ATTACKINGTARGET), PROC_REF(forced_exit))
	RegisterSignals(owner, COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES, PROC_REF(on_health_changed))
	return TRUE

/datum/status_effect/guardian_stealth/on_remove()
	owner.melee_damage_lower -= damage_bonus
	owner.melee_damage_upper -= damage_bonus
	if (isbasicmob(owner))
		var/mob/living/basic/basic_owner = owner
		basic_owner.armour_penetration = initial(basic_owner.armour_penetration)
		basic_owner.wound_bonus = initial(basic_owner.wound_bonus)
		basic_owner.obj_damage = initial(basic_owner.obj_damage)
	animate(owner, alpha = initial(owner.alpha), time = 0.5 SECONDS)
	UnregisterSignal(owner, list(COMSIG_GUARDIAN_RECALLED, COMSIG_HOSTILE_POST_ATTACKINGTARGET) + COMSIG_LIVING_ADJUST_STANDARD_DAMAGE_TYPES)

/// If we take damage, exit the status effect
/datum/status_effect/guardian_stealth/proc/on_health_changed(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (amount <= 0)
		return
	forced_exit()

/// Forcibly exit the status effect
/datum/status_effect/guardian_stealth/proc/forced_exit()
	SIGNAL_HANDLER
	SEND_SIGNAL(owner, COMSIG_GUARDIAN_ASSASSIN_REVEALED)
	qdel(src)

#undef CAN_STEALTH_ALERT
