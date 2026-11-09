/**
 * When attached to a gun and the gun is successfully fired, this element creates a "backblast", like you'd find in a rocket launcher or recoilless rifle
 *
 * The backblast is simulated by a directional explosion 180 degrees from the direction of the fired projectile.
 */
/datum/element/backblast
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Devasatation range of the explosion
	var/dev_range
	/// HGeavy damage range of the explosion
	var/heavy_range
	/// Light damage range of the explosion
	var/light_range
	/// Flame range of the explosion
	var/flame_range
	/// What angle do we want the backblast to cover
	var/blast_angle

/datum/element/backblast/Attach(datum/target, dev_range = 0, heavy_range = 0, light_range = 6, flame_range = 6, blast_angle = 60)
	. = ..()
	if(!isgun(target) || dev_range < 0 || heavy_range < 0 || light_range < 0 || flame_range < 0 || blast_angle < 1)
		return ELEMENT_INCOMPATIBLE

	src.dev_range = dev_range
	src.heavy_range = heavy_range
	src.light_range = light_range
	src.flame_range = flame_range
	src.blast_angle = blast_angle

	RegisterSignal(target, COMSIG_GUN_FIRED, PROC_REF(pew))

/datum/element/backblast/Detach(datum/source)
	if(source)
		UnregisterSignal(source, COMSIG_GUN_FIRED)
	return ..()

/// For firing an actual backblast pellet
/datum/element/backblast/proc/pew(obj/item/gun/weapon, mob/living/user, atom/target)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	var/turf/origin = get_turf(weapon)
	var/backblast_angle = get_angle(target, origin)
	explosion(weapon, devastation_range = dev_range, heavy_impact_range = heavy_range, light_impact_range = light_range, flame_range = flame_range, adminlog = FALSE, protect_epicenter = TRUE, explosion_direction = backblast_angle, explosion_arc = blast_angle)
