/**
 * Damage Packet
 *
 * Used as a way to store vars to be passed to apply damage at a later point.
 *
 * A datum is used for this, rather than a keyed list + arglist,
 * so we can have compile time checking of argument names.
 * This way if an argument name is changed or moved,
 * we don't silently lose it until the runtime is noticed on a live server.
 *
 * Try not to keep these around for too long.
 */
/datum/apply_damage_packet
	var/damage
	var/damagetype
	var/datum/weakref/def_zone
	var/blocked
	var/forced
	var/spread_damage
	var/wound_bonus
	var/bare_wound_bonus
	var/sharpness
	var/attack_direction
	var/datum/weakref/attacking_item

/datum/apply_damage_packet/New(
	damage,
	damagetype,
	def_zone,
	blocked,
	forced,
	spread_damage,
	wound_bonus,
	bare_wound_bonus,
	sharpness,
	attack_direction,
	attacking_item,
)

	src.damage = damage
	src.damagetype = damagetype
	src.def_zone = isdatum(def_zone) ? WEAKREF(def_zone) : def_zone
	src.blocked = blocked
	src.forced = forced
	src.spread_damage = spread_damage
	src.wound_bonus = wound_bonus
	src.bare_wound_bonus = bare_wound_bonus
	src.sharpness = sharpness
	src.attack_direction = attack_direction
	src.attacking_item = isdatum(attacking_item) ? WEAKREF(attacking_item) : attacking_item

/// Executes apply_damage on the passed mob with all set arguments. Qdels immediately afterwards.
/datum/apply_damage_packet/proc/execute(mob/living/hit)
	hit.apply_damage(
		damage = src.damage,
		damagetype = src.damagetype,
		def_zone = (isweakref(src.def_zone) ? src.def_zone.resolve() : src.def_zone),
		blocked = src.blocked,
		forced = src.forced,
		spread_damage = src.spread_damage,
		wound_bonus = src.wound_bonus,
		bare_wound_bonus = src.bare_wound_bonus,
		sharpness = src.sharpness,
		attack_direction = src.attack_direction,
		attacking_item = (isweakref(src.attacking_item) ? src.attacking_item.resolve() : src.attacking_item),
	)
	// clean up next tick
	QDEL_IN(src, 1)

/// Creates a copy of the packet.
/datum/apply_damage_packet/proc/copy_packet()
	return new /datum/apply_damage_packet(
		damage,
		damagetype,
		def_zone,
		blocked,
		forced,
		spread_damage,
		wound_bonus,
		bare_wound_bonus,
		sharpness,
		attack_direction,
		attacking_item,
	)
