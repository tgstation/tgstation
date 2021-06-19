/**
 * When attached to a gun and the gun is successfully fired, this element creates a "backblast" of fire and pain, like you'd find in a rocket launcher or recoilless rifle
 *
 * The backblast is simulated by a number of fire plumes, or invisible incendiary rounds that will torch anything they come across for a short distance, as well as knocking
 * back nearby items.
 */
/datum/element/backblast
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// How many "pellets" of backblast we're shooting backwards, spread between the angle defined in angle_spread
	var/plumes
	/// Assuming we don't just have 1 plume, this is the total angle we'll cover with the plumes, split down the middle directly behind the angle we fired at
	var/angle_spread
	/// How far each plume of fire will fly, assuming it doesn't hit a mob
	var/range

/datum/element/backblast/Attach(datum/target, plumes = 4, angle_spread = 48, range = 6)
	. = ..()
	if(!isgun(target) || plumes < 1 || angle_spread < 1 || range < 1)
		return ELEMENT_INCOMPATIBLE

	src.plumes = plumes
	src.angle_spread = angle_spread
	src.range = range

	if(plumes == 1)
		RegisterSignal(target, COMSIG_GUN_FIRED, .proc/gun_fired_simple)
	else
		RegisterSignal(target, COMSIG_GUN_FIRED, .proc/gun_fired)

/datum/element/backblast/Detach(datum/source, force)
	if(source)
		UnregisterSignal(source, COMSIG_GUN_FIRED)
	return ..()

/// For firing multiple plumes behind us, we evenly spread out our projectiles based on the [angle_spread][/datum/element/backblast/var/angle_spread] and [number of plumes][/datum/element/backblast/var/plumes]
/datum/element/backblast/proc/gun_fired(obj/item/gun/weapon, mob/living/user, atom/target, params, zone_override)
	SIGNAL_HANDLER

	if(!weapon.chambered || HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	var/backwards_angle = Get_Angle(target, user)
	var/starting_angle = SIMPLIFY_DEGREES(backwards_angle-(angle_spread * 0.5))
	var/iter_offset = angle_spread / plumes // how much we increment the angle for each plume

	for(var/i in 1 to plumes)
		var/this_angle = SIMPLIFY_DEGREES(starting_angle + ((i - 1) * iter_offset))
		var/turf/target_turf = get_turf_in_angle(this_angle, get_turf(user), 10)
		INVOKE_ASYNC(src, .proc/pew, target_turf, weapon, user)

/// If we're only firing one plume directly behind us, we don't need to bother with the loop or angles or anything
/datum/element/backblast/proc/gun_fired_simple(obj/item/gun/weapon, mob/living/user, atom/target, params, zone_override)
	SIGNAL_HANDLER

	if(!weapon.chambered || HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	var/backwards_angle = Get_Angle(target, user)
	var/turf/target_turf = get_turf_in_angle(backwards_angle, get_turf(user), 10)
	INVOKE_ASYNC(src, .proc/pew, target_turf, weapon, user)

/// For firing an actual backblast pellet
/datum/element/backblast/proc/pew(turf/target_turf, obj/item/gun/weapon, mob/living/user)
	//Shooting Code:
	var/obj/projectile/bullet/incendiary/backblast/P = new (get_turf(user))
	P.original = target_turf
	P.range = range
	P.fired_from = weapon
	P.firer = user // don't hit ourself that would be really annoying
	P.impacted = list(user = TRUE) // don't hit the target we hit already with the flak
	P.preparePixelProjectile(target_turf, weapon)
	P.fire()
