#define FIRE_DELAY (2 SECONDS)
#define FIRE_RANGE 4
#define BASE_DAMAGE 8
#define MINIMUM_DAMAGE 4
#define DAMAGE_FALLOFF 1
#define SHOOT_POWER_USE 5

/obj/structure/destructible/clockwork/gear_base/powered/ocular_warden
	name = "ocular warden"
	desc = "A wide, open eye that stares intently into your soul. It seems resistant to energy based weapons."
	clockwork_desc = "A defensive device that will fight any nearby intruders."
	break_message = span_warning("A black ooze leaks from the ocular warden as it slowly sinks to the ground.")
	icon_state = "ocular_warden"
	base_icon_state = "ocular_warden"
	max_integrity = 75
	armor_type = /datum/armor/clockwork_ocular_warden
	passive_consumption = 3
	minimum_power = SHOOT_POWER_USE
	can_unwrench = FALSE
	anchored = TRUE
	/// Cooldown between firing
	COOLDOWN_DECLARE(fire_cooldown)

/datum/armor/clockwork_ocular_warden
	melee = -50
	bullet = -10
	laser = 60
	energy = 60
	bomb = 20
	bio = 0

/obj/structure/destructible/clockwork/gear_base/powered/ocular_warden/process(delta_time)
	. = ..()
	if(!.)
		return

	if(!COOLDOWN_FINISHED(src, fire_cooldown))
		return

	//Check hostiles in range
	var/list/valid_targets = list()
	for(var/mob/living/potential_target in hearers(FIRE_RANGE, src))

		if(IS_CLOCK(potential_target) || potential_target.stat)
			continue

		valid_targets += potential_target

	if(!length(valid_targets))
		return

	if(!use_power(SHOOT_POWER_USE))
		return

	playsound(src, 'sound/machines/clockcult/ocularwarden_target.ogg', 60, TRUE)

	var/mob/living/target = pick(valid_targets)
	if(!target)
		return

	dir = get_dir(get_turf(src), get_turf(target))

	// Apply 10 damage (- 1 for each tile away they are), or 5, whichever is larger
	target.apply_damage(max(BASE_DAMAGE - (get_dist(src, target) * DAMAGE_FALLOFF), MINIMUM_DAMAGE) * delta_time, BURN)
	to_chat(target, span_boldwarning("You feel as though your soul is being burned!"))

	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(target))
	new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(src))

	playsound(target, 'sound/machines/clockcult/ocularwarden_dot1.ogg', 60, TRUE)

	COOLDOWN_START(src, fire_cooldown, FIRE_DELAY)

#undef FIRE_DELAY
#undef FIRE_RANGE
#undef BASE_DAMAGE
#undef MINIMUM_DAMAGE
#undef DAMAGE_FALLOFF
#undef SHOOT_POWER_USE
