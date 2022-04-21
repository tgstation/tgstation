/datum/action/cooldown/mob_cooldown/fire_breath
	name = "Fire Breath"
	icon_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "fireball"
	desc = "Allows you to shoot fire towards a target."
	cooldown_time = 3 SECONDS
	/// The range of the fire
	var/fire_range = 15
	/// The sound played when you use this ability
	var/fire_sound = 'sound/magic/fireball.ogg'
	/// If the fire should be icey fire
	var/ice_breath = FALSE

/datum/action/cooldown/mob_cooldown/fire_breath/Activate(atom/target_atom)
	StartCooldown(10 SECONDS)
	attack_sequence(target_atom)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/fire_breath/proc/attack_sequence(atom/target)
	playsound(owner.loc, fire_sound, 200, TRUE)
	fire_line(target, 0)

/datum/action/cooldown/mob_cooldown/fire_breath/proc/fire_line(atom/target, offset)
	SLEEP_CHECK_DEATH(0, owner)
	var/list/turfs = line_target(offset, fire_range, target)
	dragon_fire_line(owner, turfs, ice_breath)

/datum/action/cooldown/mob_cooldown/fire_breath/proc/line_target(offset, range, atom/target)
	if(!target)
		return
	var/turf/T = get_ranged_target_turf_direct(owner, target, range, offset)
	return (get_line(owner, T) - get_turf(owner))

/datum/action/cooldown/mob_cooldown/fire_breath/cone
	name = "Fire Cone"
	desc = "Allows you to shoot fire towards a target with surrounding lines of fire."
	/// The angles relative to the target that shoot lines of fire
	var/list/angles = list(-40, 0, 40)

/datum/action/cooldown/mob_cooldown/fire_breath/cone/attack_sequence(atom/target)
	playsound(owner.loc, fire_sound, 200, TRUE)
	for(var/offset in angles)
		INVOKE_ASYNC(src, .proc/fire_line, target, offset)

/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire
	name = "Mass Fire"
	icon_icon = 'icons/effects/fire.dmi'
	button_icon_state = "1"
	desc = "Allows you to shoot fire in all directions."
	cooldown_time = 3 SECONDS

/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/attack_sequence(atom/target)
	shoot_mass_fire(target, 12, 2.5 SECONDS, 3)

/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/proc/shoot_mass_fire(atom/target, spiral_count, delay_time, times)
	SLEEP_CHECK_DEATH(0, owner)
	for(var/i = 1 to times)
		playsound(owner.loc, fire_sound, 200, TRUE)
		var/increment = 360 / spiral_count
		for(var/j = 1 to spiral_count)
			INVOKE_ASYNC(src, .proc/fire_line, target, j * increment + i * increment / 2)
		SLEEP_CHECK_DEATH(delay_time, owner)

