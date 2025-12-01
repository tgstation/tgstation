/// Reduces or nullifies damage from ranged weaponry with force below a certain value
/datum/element/ranged_armour
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The minimum force a projectile must have to ignore our armour
	var/minimum_projectile_force
	/// Projectile damage below the minimum is multiplied by this value
	var/below_projectile_multiplier
	/// Projectile damage types which work regardless of force
	var/list/vulnerable_projectile_types
	/// The minimum force a thrown object must have to ignore our armour
	var/minimum_thrown_force
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message

/datum/element/ranged_armour/Attach(
	atom/target,
	minimum_projectile_force = 0,
	below_projectile_multiplier = 0,
	list/vulnerable_projectile_types = list(),
	minimum_thrown_force = 0,
	throw_blocked_message = "bounces off",
)
	. = ..()
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.minimum_projectile_force = minimum_projectile_force
	src.below_projectile_multiplier = below_projectile_multiplier
	src.vulnerable_projectile_types = vulnerable_projectile_types
	src.minimum_thrown_force = minimum_thrown_force
	src.throw_blocked_message = throw_blocked_message

	if (minimum_projectile_force > 0)
		RegisterSignal(target, COMSIG_PROJECTILE_PREHIT, PROC_REF(pre_bullet_impact))
	if (minimum_thrown_force > 0)
		RegisterSignal(target, COMSIG_ATOM_PREHITBY, PROC_REF(pre_thrown_impact))

/datum/element/ranged_armour/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PROJECTILE_PREHIT, COMSIG_ATOM_PREHITBY))
	return ..()

/// Modify or ignore bullet damage based on projectile properties
/datum/element/ranged_armour/proc/pre_bullet_impact(atom/parent, obj/projectile/bullet)
	SIGNAL_HANDLER
	if (bullet.damage >= minimum_projectile_force || (bullet.damage_type in vulnerable_projectile_types))
		return
	if (below_projectile_multiplier == 0)
		parent.visible_message(span_danger("[parent] seems unharmed by [bullet]!"))
		return PROJECTILE_INTERRUPT_HIT
	bullet.damage *= below_projectile_multiplier
	parent.visible_message(span_danger("[parent] seems resistant to [bullet]!"))

/// Ignore thrown damage based on projectile properties. There's no elegant way to multiply the damage because throwforce is persistent.
/datum/element/ranged_armour/proc/pre_thrown_impact(atom/parent, obj/item/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if (!isitem(hit_atom) || HAS_TRAIT(hit_atom, TRAIT_BYPASS_RANGED_ARMOR))
		return
	if (hit_atom.throwforce >= minimum_thrown_force)
		return
	parent.visible_message(span_danger("[hit_atom] [throw_blocked_message] [parent]!"))
	return COMSIG_HIT_PREVENTED
