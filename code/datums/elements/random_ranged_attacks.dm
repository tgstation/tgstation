/**
 * Variant of the ranged attacks element which picks a random projectile type from a list
 * You don't actually need to bother to pass casingtype or projectiletype when constructing because we won't use either of them
 */
/datum/element/ranged_attacks/random
	var/list/permitted_projectiles

/datum/element/ranged_attacks/random/Attach(atom/movable/target, casingtype, projectilesound, projectiletype, list/permitted_projectiles)
	casingtype = NONE
	. = ..()
	if (. == ELEMENT_INCOMPATIBLE)
		return
	src.permitted_projectiles = permitted_projectiles

/datum/element/ranged_attacks/random/async_fire_ranged_attack(mob/living/basic/firer, atom/target, modifiers)
	projectiletype = pick(permitted_projectiles)
	return ..()
