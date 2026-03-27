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
	toggle_button_type = /datum/action/cooldown/guardian/toggle_mode/assassin
	/// How long to put stealth on cooldown if we are forced out?
	var/stealth_cooldown_time = 16 SECONDS

/mob/living/basic/guardian/assassin/Initialize(mapload, datum/guardian_fluff/theme)
	. = ..()
	RegisterSignal(src, COMSIG_GUARDIAN_ASSASSIN_REVEALED, PROC_REF(on_forced_unstealth))

// Toggle stealth
/mob/living/basic/guardian/assassin/toggle_modes()
	var/stealthed = has_status_effect(/datum/status_effect/guardian_stealth)
	var/datum/action/cooldown/guardian/toggle_mode/assassin/stealth_ability = locate() in actions
	if (stealthed)
		to_chat(src, span_bolddanger("You exit stealth."))
		remove_status_effect(/datum/status_effect/guardian_stealth)
		if(stealth_ability)
			stealth_ability.build_all_button_icons()
		return
	if (!is_deployed())
		to_chat(src, span_bolddanger("You have to be manifested to enter stealth!"))
		return
	apply_status_effect(/datum/status_effect/guardian_stealth)
	if(stealth_ability)
		stealth_ability.build_all_button_icons()

/// Called when we are removed from stealth involuntarily
/mob/living/basic/guardian/assassin/proc/on_forced_unstealth(mob/living/source)
	SIGNAL_HANDLER
	visible_message(span_danger("\The [src] suddenly appears!"))
	COOLDOWN_START(src, manifest_cooldown, 4 SECONDS)
	var/datum/action/cooldown/guardian/toggle_mode/assassin/stealth_ability = locate() in actions
	if(stealth_ability)
		stealth_ability.StartCooldownSelf(stealth_cooldown_time)

/// Status effect which makes us sneakier and do bonus damage
/datum/status_effect/guardian_stealth
	id = "guardian_stealth"
	alert_type = null
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
