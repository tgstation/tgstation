/**
 * ## Bane component
 *
 * Applied to items and projectiles that modifies damage dealt to certain things.
 * For example a sword that deals 2x damage to specifically skeletons.
 *
 * For items, you are not limited to only dealing more damage. Supports smaller multipliers or removing flat damage.
 * For projectiles, you are limited to only dealing more damage, at least until further refactors are done.
 */
/datum/component/bane
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Callback invoked when checking if a target is valid to be baned (arguments: target)
	/// Return a boolean, FALSE to stop the bane effect or TRUE to allow it
	VAR_FINAL/datum/callback/should_bane_callback
	/// Callback invoked before bane damage is applied, allows for modifying the damage or applying other effects. (arguments: target, attacker, damage_modifiers)
	/// Return value doesn't matter, but you can modify the damage_modifiers list to change the attack's values
	VAR_FINAL/datum/callback/pre_bane_callback
	/// Callback invoked after bane damage is applied, allows for applying other effects. (arguments: target, attacker)
	/// Return value doesn't matter
	VAR_FINAL/datum/callback/on_bane_callback
	/// A bitfield of mob biotypes that this bane component applies to.
	///If NONE, applies to all biotypes. Defaults to NONE.
	VAR_FINAL/affected_biotypes = NONE
	/// Multiplier applied to damage when the bane effect applies. Defaults to 1 (no change).
	VAR_FINAL/damage_multiplier = 1
	/// Flat damage added when the bane effect applies. Defaults to 0 (no change).
	VAR_FINAL/added_damage = 0
	/// Optional text to show in the weapon label readout, if not set it will generate a generic one based on the biotypes
	VAR_FINAL/label_text = ""

/datum/component/bane/Initialize(
	damage_multiplier = 1,
	added_damage = 0,
	affected_biotypes = NONE,
	datum/callback/should_bane_callback,
	datum/callback/pre_bane_callback,
	datum/callback/on_bane_callback,
	label_text = "",
)
	if(!isitem(parent) && !isprojectile(parent))
		return COMPONENT_INCOMPATIBLE

	src.damage_multiplier = damage_multiplier
	src.added_damage = added_damage
	src.affected_biotypes = affected_biotypes
	src.should_bane_callback = should_bane_callback
	src.pre_bane_callback = pre_bane_callback
	src.on_bane_callback = on_bane_callback
	src.label_text = label_text

/datum/component/bane/RegisterWithParent()
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_WEAPON_LABEL_READOUT, PROC_REF(label_readout))
		RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(pre_attack))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(after_attack))
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(on_thrown_hit))
	if(isprojectile(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(projectile_hit))

/datum/component/bane/UnregisterFromParent()
	if(isitem(parent))
		UnregisterSignal(parent, COMSIG_ITEM_WEAPON_LABEL_READOUT)
		UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK)
		UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)
		UnregisterSignal(parent, COMSIG_MOVABLE_IMPACT_ZONE)
	if(isprojectile(parent))
		UnregisterSignal(parent, COMSIG_PROJECTILE_SELF_ON_HIT)

/datum/component/bane/proc/is_bane_target(atom/target)
	if(!isliving(target))
		return FALSE

	var/mob/living/living_target = target
	if(affected_biotypes && !(living_target.mob_biotypes & affected_biotypes))
		return FALSE

	return isnull(should_bane_callback) ? TRUE : should_bane_callback.Invoke(target)

/datum/component/bane/proc/label_readout(obj/item/source, list/readout)
	SIGNAL_HANDLER

	if(damage_multiplier == 1 && added_damage == 0 && !label_text)
		return

	var/label_line = ""
	if(damage_multiplier > 1 || added_damage > 0)
		label_line += "It is especially effective against"
	else if(damage_multiplier < 1 || added_damage < 0)
		label_line += "It is less effective against"
	else
		label_line += "It interacts uniquely with" // for custom behaviors?

	label_line += " "
	if(label_text)
		label_line += label_text
	else if(affected_biotypes)
		var/list/affected_biotypes_readable = bitfield_to_list(affected_biotypes, MOB_BIOTYPES_READABLE)
		label_line += "[english_list(affected_biotypes_readable)] enemies"
	else
		label_line += "certain enemies"

	if(damage_multiplier > 1 || added_damage > 0)
		var/magnitude = ""
		switch(max(damage_multiplier, added_damage / 10))
			if(3 to INFINITY)
				magnitude = "massively increased"
			if(2 to 3)
				magnitude = "greatly increased"
			if(1.5 to 2)
				magnitude = "significantly increased"
			if(1 to 1.5)
				magnitude = "slightly increased"

		label_line += ", dealing [span_warning(magnitude)] damage per hit"

	else if(damage_multiplier < 1 || added_damage < 0)
		var/magnitude = ""
		switch(min(damage_multiplier, 10 / abs(added_damage || 1)))
			if(-INFINITY to 0)
				magnitude = "no"
			if(0 to 0.3)
				magnitude = "massively reduced"
			if(0.3 to 0.6)
				magnitude = "greatly reduced"
			if(0.6 to 0.9)
				magnitude = "significantly reduced"
			if(0.9 to 1)
				magnitude = "slightly reduced"

		label_line += ", dealing [span_warning(magnitude)] damage per hit"

	label_line += "."
	readout += label_line

// Item attack handling
/datum/component/bane/proc/pre_attack(datum/source, atom/target, mob/living/attacker, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if(!is_bane_target(target))
		return

	if(added_damage != 0)
		MODIFY_ATTACK_FORCE(attack_modifiers, added_damage)
	if(damage_multiplier != 1)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, damage_multiplier)

	pre_bane_callback?.Invoke(target, attacker, attack_modifiers)

/datum/component/bane/proc/after_attack(datum/source, atom/target, mob/living/attacker, ...)
	SIGNAL_HANDLER

	if(!is_bane_target(target))
		return

	SEND_SIGNAL(target, COMSIG_LIVING_BANED, source, attacker)
	on_bane_callback?.Invoke(target, attacker)

// Throw impact handling
/datum/component/bane/proc/on_thrown_hit(datum/source, atom/hit_atom, hit_zone, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(!is_bane_target(hit_atom))
		return

	var/mob/thrower = throwingdatum?.thrower?.resolve()
	var/list/damage_modifiers = list("[FORCE_MULTIPLIER]" = damage_multiplier, "[FORCE_MODIFIER]" = added_damage)
	pre_bane_callback?.Invoke(hit_atom, thrower, damage_modifiers)

	// We're not modifying the throwforce of the item we're just applying more damage as a separate damage event
	// That's why we do damage_multiplier - 1 (so that a 1.5x multiplier would apply 0.5x damage here for a total of 1.5x)
	var/obj/item/throwing_item = parent
	var/extra_damage = (throwing_item.throwforce * max(0, damage_modifiers[FORCE_MULTIPLIER] - 1)) + damage_modifiers[FORCE_MODIFIER]
	if(extra_damage > 0)
		var/mob/living/living_target = hit_atom // safe assertion from is_bane_target
		living_target.apply_damage(extra_damage, throwing_item.damtype, hit_zone, blocked)

	SEND_SIGNAL(hit_atom, COMSIG_LIVING_BANED, thrower, hit_atom)
	on_bane_callback?.Invoke(hit_atom, thrower)

// Projectile hit handling
/datum/component/bane/proc/projectile_hit(datum/source, atom/firer, atom/target, angle, hit_zone, blocked, ...)
	SIGNAL_HANDLER

	if(!is_bane_target(target))
		return

	var/list/damage_modifiers = list("[FORCE_MULTIPLIER]" = damage_multiplier, "[FORCE_MODIFIER]" = added_damage)
	pre_bane_callback?.Invoke(target, firer, damage_modifiers)

	// We're not modifying the projectile damage we're just applying more damage as a separate damage event
	// That's why we do damage_multiplier - 1 (so that a 1.5x multiplier would apply 0.5x damage here for a total of 1.5x)
	var/obj/projectile/projectile_owner = parent
	var/extra_damage = (projectile_owner.damage * max(0, damage_modifiers[FORCE_MULTIPLIER] - 1)) + damage_modifiers[FORCE_MODIFIER]
	if(extra_damage > 0)
		var/mob/living/living_target = target // safe assertion from is_bane_target
		living_target.apply_damage(extra_damage, projectile_owner.damage_type, hit_zone, blocked)

	SEND_SIGNAL(target, COMSIG_LIVING_BANED, firer, target)
	on_bane_callback?.Invoke(target, firer)
